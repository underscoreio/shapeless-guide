## Summary

In this chapter we discussed how to use
`Generic`, `HLists`, and `Coproducts`
to automatically derive type class instances.
We also covered the `Lazy` type
as a means of handling complex/recursive types.
Taking all of this into account,
we can write a common skeleton
for deriving type class instances as follows.

First, define the type class:

```tut:book:silent
trait MyTC[A]
```

Define primitive instances:

```tut:book:silent
implicit def intInstance: MyTC[Int] = ???
implicit def stringInstance: MyTC[String] = ???
implicit def booleanInstance: MyTC[Boolean] = ???
```

Define instances for `HList`:

```tut:book:silent
import shapeless._

implicit def hnilInstance: MyTC[HNil] = ???

implicit def hlistInstance[H, T <: HList](
  implicit
  hInstance: Lazy[MyTC[H]], // wrap in Lazy
  tInstance: MyTC[T]
): MyTC[H :: T] = ???
```

If required, define instances for `Coproduct`:

```tut:book:silent
implicit def cnilInstance: MyTC[CNil] = ???

implicit def coproductInstance[H, T <: Coproduct](
  implicit
  hInstance: Lazy[MyTC[H]], // wrap in Lazy
  tInstance: MyTC[T]
): MyTC[H :+: T] = ???
```

Finally, define an instance for `Generic`:

```tut:book:silent
implicit def genericInstance[A, R](
  implicit
  generic: Generic.Aux[A, R],
  rInstance: Lazy[MyTC[R]] // wrap in Lazy
): MyTC[A] = ???
```

In the next chapter we'll cover some useful theory
and programming patterns
to help write code in this style.
In Chapter [@sec:labelled-generic]
we will revisit type class derivation
using a variant of `Generic` that
allows us to inspect field and type names
in our ADTs.
