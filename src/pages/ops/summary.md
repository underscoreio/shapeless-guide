## Summary

In this chapter we looked at a few of the
"ops" type classes that shapeless provides in
`shapeless.ops.hlist` and `shapeless.ops.coproduct`.
These type classes, together with their extension methods
defined in `shapeless.syntax.hlist` and
`shapeless.syntax.coproduct`,
provide a wealth of functionality that we can use
in the definitions of our own type classes.

We didn't discuss the type classes in `shapeless.ops.record`,
which provide `Map`-like operations
on `HLists` of tagged types.
We've already covered all of the theory
required to understand these type classes,
so we'll leave it as an exercise to the reader
to find out more about them.

In the next chapters we will discuss
two more suites of ops type classes
that with some associated theory.
Chapter [@sec:poly] discusses
how to implement functional operations
such as `map` and `flatMap` on `HLists`,
and Chapter [@sec:nat] discusses
how to implement type classes that require
type level representations of numbers.
