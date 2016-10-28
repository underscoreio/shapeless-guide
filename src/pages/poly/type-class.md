## Defining type classes using Poly

We can use `Poly` and type classes
such as `Mapper` and `FlatMapper`
in the definitions of our own type classes.
As an example let's build a type class
for mapping from one case class to another:

```tut:book:silent
trait ProductMapper[A, B, P] {
  def apply(a: A): B
}
```

We can create a type class instance
using a `Mapper` and a pair of `Generics`:

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

Interestingly,
the value of the `Poly` does not appear in this code.
The `Mapper` type class uses implicit resolution to find `Cases`,
so we only need to know the singleton type of the `Poly`
to do the mapping.

We can create an extension method
to make the type class easy to use.
We only want the user to specify the type of `B` at the call site,
so we use some indirection
to allow the compiler to infer the type of the `Poly`
from a value parameter:

```tut:book:silent
implicit class ProductMapperOps[A](a: A) {
  class Builder[B] {
    def apply[P <: Poly](poly: P)
        (implicit prodMap: ProductMapper[A, B, P]): B =
      prodMap(a)
  }

  def mapTo[B]: Builder[B] =
    new Builder[B]
}
```

The resulting `mapTo` syntax looks like a single method call,
but is actually two calls:
one call to `mapTo` to fix the `B` type parameter,
and one call to `Builder.apply` to specify the `Poly`:

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
