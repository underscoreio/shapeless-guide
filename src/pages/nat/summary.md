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
type classes and examples we have seen in Part II,
we have seen a small part of
the comprehensive toolbox provided in `shapeless.ops`.
We don't need to use these tools to derive type classes,
which is the main use for shapeless discussed in this guide.
However, type classes like `Align`, `Mapper`, and `Length`
form substantial foundations that
make building our own type classes that much easier.
