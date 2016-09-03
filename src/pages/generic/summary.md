## Summary

In this chapter we discussed how to use `Generic`,
`HLists`, and `Coproducts` to automatically derive type class instances.
We also covered the `Lazy` type as a means of handling complex/recursive types.

Taking all of this into account,
we can write a common skeleton for deriving type class instances as follows:

```tut:book:silent
import shapeless.{HList, ::, HNil, Coproduct, :+:, CNil, Generic, Lazy}

// Step 1. Define the type class

trait MyTC[A] {
  // etc...
}

// Step 2. Define basic instances

implicit def intInstance: MyTC[Int] = ???

// Step 3. Define instances for HList and Coproduct

implicit def hnilInstance: MyTC[HNil] = ???

implicit def hlistInstance[H, T <: HList](
  implicit
  hInstance: Lazy[MyTC[H]], // wrap in Lazy
  tInstance: MyTC[T]
): MyTC[H :: T] = ???

implicit def cnilInstance: MyTC[CNil] = ???

implicit def coproductInstance[H, T <: Coproduct](
  implicit
  hInstance: Lazy[MyTC[H]], // wrap in Lazy
  tInstance: MyTC[T]
): MyTC[H :+: T] = ???

// Step 4. Define an instance for Generic

implicit def genericInstance[A, R](
  implicit
  generic: Generic.Aux[A, R], // wrap in Lazy
  rInstance: Lazy[MyTC[R]]
): MyTC[A] = ???
```

In the next chapter we'll cover some useful theory,
programming patterns, and debugging techniques
to help write code in this style.

In the chapter following we will revisit type class derivation
using a variant of `Generic` that
allows us to inspect field and type names in our ADTs.
