## Creating a custom op

Let's work through the creation of our own op as an exercise.
We'll combine the power of `Last` and `Init`
to create a `Penultimate` type class
that retrieves the second-to-last element in an `HList`.
Here's the type class definition,
complete with `Aux` type alias and `apply` method:

```tut:book:silent
import shapeless._

trait Penultimate[L] {
  type Out
  def apply(l: L): Out
}

object Penultimate {
  type Aux[L, O] = Penultimate[L] { type Out = O }

  def apply[L](implicit p: Penultimate[L]): Aux[L, p.Out] = p
}
```

We only need to define one instance,
combining `Init` and `Last` using the techniques
covered in Section [@sec:type-level-programming:chaining]:

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

We can use `Penultimate` as follows:

```tut:book:silent
type BigList =
  String :: Int :: Boolean :: Double :: HNil

val bigList: BigList =
  "foo" :: 123 :: true :: 456.0 :: HNil
```

```tut:book
Penultimate[BigList].apply(bigList)
```

Summoning an instance of `Penultimate`
requires the compiler to summon instances for `Last` and `Init`,
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

We can also provide `Penultimate` for all product types
by providing an instance based on `Generic`:

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
