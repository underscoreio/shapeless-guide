## Summary

In this chapter we explored a few of the
type classes that are provided in the `shapeless.ops` package.
We looked at `Last` and `Init`
as two simple examples of the ops pattern,
and built our own `Penultimate` and `Migration` type classes
by chaining together existing building blocks.

Many of the ops type classes share a similar pattern
to the ops we've seen here.
The easiest way to learn them is to
look at the source code
in `shapeless.ops` and `shapeless.syntax`.

In the next chapters we will look at two suites
of ops type classes that require further theoretical discussion.
Chapter [@sec:poly] discusses functional operations
such as `map` and `flatMap` on `HLists`,
and Chapter [@sec:nat] discusses
how to implement type classes that require
type level representations of numbers.
This knowledge will help us gain
a more complete understanding of
the variety of type classes from `shapeless.ops`.
