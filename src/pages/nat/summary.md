## Summary

In this chapter we discussed
how shapeless represents natural numbers
and how we can use them in type classes.
We saw some predefined ops type classes
that let us do things like calculate lengths
and access elements by index,
and created our own type classes
that use `Nat` in other ways.

Between `Nat`, `Poly`, and the variety of
types we have seen in the last few chapters,
we have seen just a small fraction of
the toolbox provided in `shapeless.ops`.
There are many other ops type classes
that provide a comprehensive foundation
on which to build our own code.
However, the theory laid out here
is enough to understand the majority of ops
needed to derive our own type classes.
The source code in the `shapeless.ops`
packages should now be approachable enough
to pick up other useful ops.
