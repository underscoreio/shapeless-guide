## Polymorphic functions

Shapeless provides a type called `Poly`
for representing *polymorphic functions*,
where the result type depends on the parameter types.
Here is a simplified explanation of how it works.
Note that the next section doesn't contain real shapeless code---we're
eliding much of the flexibility and ease of use
that comes with real shapeless `Polys`
to create a simplified API for illustrative purposes.

### How *Poly* works

At its core, a `Poly` is an object with a generic `apply` method.
In addition to its regular parameter of type `A`,
`Poly` accepts an implicit parameter of type `Case[A]`:

```tut:book:silent
// This is not real shapeless code.
// It's just for demonstration.

trait Case[P, A] {
  type Result
  def apply(a: A): Result
}

trait Poly {
  def apply[A](arg: A)(implicit cse: Case[this.type, A]): cse.Result =
    cse.apply(arg)
}
```

When we define an actual `Poly`,
we provide instances of `Case`
for each parameter type we care about.
These implement the actual function body:

```tut:book:silent
// This is not real shapeless code.
// It's just for demonstration.

object myPoly extends Poly {
  implicit def intCase =
    new Case[this.type, Int] {
      type Result = Double
      def apply(num: Int): Double = num / 2.0
    }

  implicit def stringCase =
    new Case[this.type, String] {
      type Result = Int
      def apply(str: String): Int = str.length
    }
}

```

When we call `myPoly.apply`,
the compiler searches for the relevant implicit `Case`
and inserts it as usual:

```tut:book
myPoly.apply(123)
```

There is some subtle scoping behaviour here
that allows the compiler to locate instances of `Case`
without any additional imports.
`Case` has an extra type parameter `P`
referencing the singleton type of the `Poly`.
The implicit scope for `Case[P, A]` includes
the companion objects for `Case`, `P`, and `A`.
We've assigned `P` to be `myPoly.type`
and the companion object for `myPoly.type` is `myPoly` itself.
In other words, `Cases` defined in the body of the `Poly`
are always in scope no matter where the call site is.

### *Poly* syntax

The code above isn't real shapeless code.
Fortunately, shapeless makes `Polys` much simpler to define.
Here's our `myPoly` function rewritten in proper syntax:

```tut:book:silent
import shapeless._

object myPoly extends Poly1 {
  implicit val intCase: Case.Aux[Int, Double] =
    at(num => num / 2.0)

  implicit val stringCase: Case.Aux[String, Int] =
    at(str => str.length)
}
```

There are a few key differences with our earlier toy syntax:

 1. We're extending a trait called `Poly1` instead of `Poly`.
    Shapeless has a `Poly` type and a set of subtypes,
    `Poly1` through `Poly22`, supporting different arities
    of polymorphic function.

 2. The `Case.Aux` types doesn't seem to reference
    the singleton type of the `Poly`.
    `Case.Aux` is actually a type alias
    defined within the body of `Poly1`.
    The singleton type is there---we just don't see it.

 3. We're using a helper method, `at`, to define cases.
    This acts as an instance constructor method
    as discussed in Section [@sec:generic:idiomatic-style]),
    which eliminates a lot of boilerplate.

Syntactic differences aside,
the shapeless version of `myPoly` is functionally
identical to our toy version.
We can call it with an `Int` or `String` parameter
and get back a result of the corresponding return type:

```tut:book
myPoly.apply(123)
myPoly.apply("hello")
```

Shapeless also supports `Polys` with more than one parameter.
Here is a binary example:

```tut:book:silent
object multiply extends Poly2 {
  implicit val intIntCase: Case.Aux[Int, Int, Int] =
    at((a, b) => a * b)

  implicit val intStrCase: Case.Aux[Int, String, String] =
    at((a, b) => b * a)
}
```

```tut:book
multiply(3, 4)
multiply(3, "4")
```

Because `Cases` are just implicit values,
we can define cases based on type classes
and do all of the advanced implicit resolution
covered in previous chapters.
Here's a simple example that
totals numbers in different contexts:

```tut:book:silent
import scala.math.Numeric

object total extends Poly1 {
  implicit def base[A](implicit num: Numeric[A]):
      Case.Aux[A, Double] =
    at(num.toDouble)

  implicit def option[A](implicit num: Numeric[A]):
      Case.Aux[Option[A], Double] =
    at(opt => opt.map(num.toDouble).getOrElse(0.0))

  implicit def list[A](implicit num: Numeric[A]):
      Case.Aux[List[A], Double] =
    at(list => num.toDouble(list.sum))
}
```

```tut:book
total(10)
total(Option(20.0))
total(List(1L, 2L, 3L))
```

<div class="callout callout-warning">
*Idiosyncrasies of type inference*

`Poly` pushes Scala's type inference out of its comfort zone.
We can easily confuse the compiler by
asking it to do too much inference at once.
For example, the following code compiles ok:

```tut:book:silent
val a = myPoly.apply(123)
val b: Double = a
```

However, combining the two lines causes a compilation error:

```tut:book:fail
val a: Double = myPoly.apply(123)
```

If we add a type annotation, the code compiles again:

```tut:book
val a: Double = myPoly.apply[Int](123)
```

This behaviour is confusing and annoying.
Unfortunately there are no concrete rules to follow to avoid problems.
The only general guideline is to
try not to over-constrain the compiler,
solve one constraint at a time,
and give it a hint when it gets stuck.
</div>
