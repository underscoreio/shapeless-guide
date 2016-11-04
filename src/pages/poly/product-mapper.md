## Defining type classes using *Poly* {#sec:poly:product-mapper}

We can use `Poly` and type classes
like `Mapper` and `FlatMapper`
as building blocks for our own type classes.
As an example let's build a type class
for mapping from one case class to another:

```tut:book:silent
trait ProductMapper[A, B, P] {
  def apply(a: A): B
}
```

We can create an instance of `ProductMapper`
using `Mapper` and a pair of `Generics`:

```tut:book:silent
import shapeless._
import shapeless.ops.hlist

implicit def genericProductMapper[
  A, B,
  P <: Poly,
  ARepr <: HList,
  BRepr <: HList
](
  implicit
  aGen: Generic.Aux[A, ARepr],
  bGen: Generic.Aux[B, BRepr],
  mapper: hlist.Mapper.Aux[P, ARepr, BRepr]
): ProductMapper[A, B, P] =
  new ProductMapper[A, B, P] {
    def apply(a: A): B =
      bGen.from(mapper.apply(aGen.to(a)))
  }
```

Interestingly, although we define a type `P` for our `Poly`,
we don't reference any values of type `P` anywhere in our code.
The `Mapper` type class uses implicit resolution to find `Cases`,
so the compiler only needs to know the singleton type of `P`
to locate the relevant instances.

Let's create an extension method
to make `ProductMapper` easier to use.
We only want the user to specify the type of `B` at the call site,
so we use some indirection
to allow the compiler to infer the type of the `Poly`
from a value parameter:

```tut:book:silent
implicit class ProductMapperOps[A](a: A) {
  class Builder[B] {
    def apply[P <: Poly](poly: P)
        (implicit pm: ProductMapper[A, B, P]): B =
      pm.apply(a)
  }

  def mapTo[B]: Builder[B] = new Builder[B]
}
```

Here's an example of the method's use:

```tut:book:silent
object conversions extends Poly1 {
  implicit val intCase:  Case.Aux[Int, Boolean]   = at(_ > 0)
  implicit val boolCase: Case.Aux[Boolean, Int]   = at(if(_) 1 else 0)
  implicit val strCase:  Case.Aux[String, String] = at(identity)
}

case class IceCream1(name: String, numCherries: Int, inCone: Boolean)
case class IceCream2(name: String, hasCherries: Boolean, numCones: Int)
```

```tut:book
IceCream1("Sundae", 1, false).mapTo[IceCream2](conversions)
```

The `mapTo` syntax looks like a single method call,
but is actually two calls:
one call to `mapTo` to fix the `B` type parameter,
and one call to `Builder.apply` to specify the `Poly`.
Some of shapeless' built-in ops extension methods use similar tricks
to provide the user with convenient syntax.
