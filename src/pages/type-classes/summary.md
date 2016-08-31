## Summary

In this chapter we re-acquianted ourselves with type classes
and discussed how we can use shapeless
to automatically derive type class instances.
By defining implicits to produce type class instances for
`HNil`, `::`, `CNil`, and `:+:`,
we can derive type class instances
for any `HList` or `Coproduct`.
We can then map those instances onto regalar ADTs
using `Generic`.

We also covered the `Lazy` type class,
which helps avoid infinite loops
when summoning type class instances for recursive data types.
When defining implicits for `HList`, `Coproduct`, and `Generic`,
it is normally a good idea to wrap any implicit parameters
that involve other types with `Lazy`.

Taking all of this into account,
we can write a common skeleton
for deriving type class instances using shapeless:

```tut:book
import shapeless.{HList, ::, HNil, Coproduct, :+:, CNil, Generic, Lazy}

// The type class

trait MyTC[A] {
  // etc...
}

// Instances for HList

implicit def hnilInstance: MyTC[HNil] = ???

implicit def hlistInstance[H, T <: HList](
  implicit
  hInstance: Lazy[MyTC[H]],
  tInstance: MyTC[T]
): MyTC[H :: T] = ???

// Instances for Coproduct

implicit def cnilInstance: MyTC[CNil] = ???

implicit def coproductInstance[H, T <: Coproduct](
  implicit
  hInstance: Lazy[MyTC[H]],
  tInstance: MyTC[T]
): MyTC[H :+: T] = ???

// Instance for Generic

implicit def genericInstance[A, R](
  implicit
  generic: Generic.Aux[A, R],
  rInstance: Lazy[MyTC[R]]
): MyTC[A] = ???
```

Finally, we discussed packaging instances as part of a library,
using shapeless to provide default behaviour
and providing custom overrides for specific types
without running into ambiguous implicit errors.

