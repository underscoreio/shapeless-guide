## Polymorphic functions

Shapeless provides the `Poly` datatype
for representing polymorphic functions.
At its core, a `Poly` is an object with an `apply` method
that accepts an implicit `Case` parameter
to map input types to output types.
Here is a simplified explanation of how it all works.
Note that this isn't real shapeless code---we're
eliding a lot of extra stuff
that makes real shapeless `Polys`
much more flexible and easier to use.

### How Polys work

The implementation of `Poly` boils down to the following.
The `apply` method delegates all concrete functionality
to a type class, `Case`:

```tut:book:silent
// This is not real shapeless code.
// It is purely for illustration.

trait Case[P, A] {
  type Result
  def apply(a: A): Result
}

trait Poly {
  def apply[A](arg: A)(implicit cse: Case[this.type, A]): cse.Result =
    cse.apply(arg)
}
```

We'll define some extra helpers to simplify the examples below:

```tut:book:silent
type CaseAux[P, A, R] = Case[P, A] { type Result = R }

def createCase[P, A, R](func: A => R): CaseAux[P, A, R] =
  new Case[P, A] {
    type Result = R
    def apply(a: A): R = func(a)
  }
```

`Case` maps an input type `A` to an output type `Result`.
It also has a second type parameter `P`
referencing the singleton type of the `Poly` it is supporting
(we'll come to this in a moment).
When we create a `Poly`, we define the `Cases`
as `implicit vals` within its body:

```tut:book:silent
// This is not real shapeless code.
// It is purely for illustration.

object myPoly extends Poly {
  implicit def intCase: CaseAux[this.type, Int, Double] =
    createCase(num => num / 2.0)

  implicit def stringCase: CaseAux[this.type, String, Int] =
    createCase(str => str.length)
}
```

The `Cases` define the behaviour for each input type.
When we call `myPoly.apply`,
the compiler searches for the relevant implicit `Case`
and fills it in as usual:

```scala
myPoly.apply(123) // search for a `Case[myPoly.type, Int]`
```

But how do the `Cases` end up in implicit scope?
There is some subtle behaviour that makes this work.
The implicit scope for `Case[P, A]` includes
the companion objects for `Case`, `P`, and `A`.
We defined `P` as the singleton type `myPoly.type`
and it turns out that
the companion object for `myPoly.type` is `myPoly` itself,
so the `Cases` defined in the body of the `Poly`
are always in implicit scope:

```tut:book
myPoly.apply(123)     // search for a `Case[myPoly.type, Int]`
myPoly.apply("hello") // search for a `Case[myPoly.type, String]`
```

### Poly syntax

The code so far this chapter hasn't been real shapeless code.
Here's our demo function from above rewritten in proper syntax:

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
    `Poly1` through `Poly2`, supporting different arities
    of polymorphic function.

 2. The `Case` and `Case.Aux` types don't include
    the singleton type of the `Poly`.
    In this context `Case` actually refers to
    a type alias defined within the body of `Poly1`.
    The singleton type is there---we just don't see it.

 3. We're using a helper method, `at`, to define cases.

These syntactic differences aside,
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
    at((a, b) => b.toString * a)
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
  implicit def baseCase[A](implicit num: Numeric[A]): Case.Aux[A, Double] =
    at(num.toDouble)

  implicit def optionCase[A](implicit num: Numeric[A]): Case.Aux[Option[A], Double] =
    at(opt => opt.map(num.toDouble).getOrElse(0.0))

  implicit def listCase[A](implicit num: Numeric[A]): Case.Aux[List[A], Double] =
    at(list => num.toDouble(list.sum))
}
```

```tut:book
total(10)
total(Option(20.0))
total(List(1L, 2L, 3L))
```
