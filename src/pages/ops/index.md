# Working with HLists and Coproducts {#sec:ops}

We have now seen several examples of type class derivation.
In each case we convert an ADT to an `HList` or `Coproduct`
and recurse over it in some manner to calculate our output.

In this chapter we'll look at some built-in type classes
that shapeless provides for manipulating `HLists` and `Coproducts`.
We can use these in two ways.
If we're creating our own type classes
We can build our own type classes on top of them,
or we can use them directly via *extension methods*
on `HList` and `Coproduct`.

There are three general sets of type classes,
available from three packages:

`shapeless.ops.hlist` defines type classes for `HLists`.
Many can be used directly via extension methods on `HList`,
defined in `shapeless.syntax.hlist`.

`shapeless.ops.coproduct` defines type classes for `Coproducts`.
Many can be used directly via extension methods on `Coproduct`,
defined in `shapeless.syntax.coproduct`.

`shapeless.ops.record` defines type classes for `HLists`
whose elements are tagged with key types
(see Section [@sec:labelled-generic:type-tagging]).
Many can be used directly via extension methods on `HList`,
defined in `shapeless.syntax.record`.

There are a huge number of these "ops" type classes,
all written in a consistent style and
many defined for both `HLists` and `Coproducts`.
Rather than cover them all
(which would make this book significantly larger),
we will walk through a few worked examples,
cover the main theory points,
and show you how to extract further information
from the shapeless codebase.
