## Creating a custom op

As an exercise, let's work through the creation of our own op.
We'll combine the power of `Last` and `Init`
to create a `Penultimate` type class
that retrieves the second-to-last element in an `HList`.
Here's the type class definition:

```tut:book:silent
import shapeless._

trait Penultimate[L] {
  type Out
  def apply(l: L): Out
}

object Penultimate {
  type Aux[L, O] = Penultimate[L] { type Out = O }

  def apply[L](implicit inst: Penultimate[L]): Aux[L, inst.Out] =
    inst
}
```

We can create the only instance we require
by combining `Init` and `Last`
using the techniques covered in
Section [@sec:type-level-programming:chaining]:

```tut:book:silent
import shapeless.ops.hlist

implicit def hlistPenultimate[L <: HList, M <: HList, O](
  implicit
  init: hlist.Init.Aux[L, M],
  last: hlist.Last.Aux[M, O]
): Penultimate.Aux[L, O] =
  new Penultimate[L] {
    type Out = O
    def apply(l: L): O =
      last.apply(init.apply(l))
  }
```

This gives us a `Penultimate` type class
that we can re-use in other type class definitions:

```tut:book:silent
type BigList = String :: Int :: Boolean :: Double :: HNil

val bigList = "foo" :: 123 :: true :: 456.0 :: HNil
```

```tut:book
Penultimate[BigList].apply(bigList)
```

Summoning an instance of `Penultimate`
depends on summoning instances for `Last` and `Init`,
so we inherit the same level of type checking on short `HLists`:

```tut:book:silent
type TinyList = String :: HNil

val tinyList = "bar" :: HNil
```

```tut:book:fail
Penultimate[TinyList].apply(tinyList)
```

We can make things more convenient for end users
by defining an extension method on `HList`:

```tut:book:silent
implicit class PenultimateOps[A](a: A) {
  def penultimate(implicit inst: Penultimate[A]): inst.Out =
    inst.apply(a)
}
```

```tut:book
bigList.penultimate
```

Finally, if we add a second type class instance for `Generic`,
we can access the penultimate fields of arbitrary product types:

```tut:book:silent
implicit def genericPenultimate[A, R, O](
  implicit
  generic: Generic.Aux[A, R],
  penultimate: Penultimate.Aux[R, O]
): Penultimate.Aux[A, O] =
  new Penultimate[A] {
    type Out = O
    def apply(a: A): O =
      penultimate.apply(generic.to(a))
  }

case class IceCream(name: String, numCherries: Int, inCone: Boolean)
```

```tut:book
IceCream("Sundae", 1, false).penultimate
```
