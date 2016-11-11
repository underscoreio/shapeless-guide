## Creating a custom op (the "lemma" pattern) {#sec:ops:penultimate}

If we find a particular sequence of ops useful,
we can package them up and re-provide them as another ops type class.
This is an example of the "lemma" pattern,
a term we introduced in Section [@sec:type-level-programming:summary].

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

Again, notice that the `apply` method
has a return type of `Aux[L, O]` instead of `Penultimate[L]`.
This ensures type members are visible on summoned instances
as discussed in the callout
in Section [@sec:type-level-programming:depfun].

We only need to define one instance of `Penultimate`,
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
type BigList = String :: Int :: Boolean :: Double :: HNil

val bigList: BigList = "foo" :: 123 :: true :: 456.0 :: HNil
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

The important point here is that,
by defining `Penultimate` as another type class,
we have created a reusable tool that we can apply elsewhere.
Shapeless provides many ops for many purposes,
but it's easy to add our own to the toolbox.
