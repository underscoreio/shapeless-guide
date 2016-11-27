# Working with *HLists* and *Coproducts* {#sec:ops}

In Part I we discussed methods for
deriving type class instances
for algebraic data types.
We can use type class derivation
to augment almost any type class,
although in more complex cases
we may have to write a lot of supporting code
for manipulating `HLists` and `Coproducts`.

In Part II we'll look at the `shapeless.ops` package,
which provides a set of helpful tools
that we can use as building blocks.
Each op comes in two parts:
a *type class* that we can use during implicit resolution,
and *extension methods* that we can call on `HList` and `Coproduct`.

There are three general sets of ops,
available from three packages:

  - `shapeless.ops.hlist` defines type classes for `HLists`.
    These can be used directly via extension methods on `HList`,
    defined in `shapeless.syntax.hlist`.

  - `shapeless.ops.coproduct` defines type classes for `Coproducts`.
    These can be used directly via extension methods on `Coproduct`,
    defined in `shapeless.syntax.coproduct`.

  - `shapeless.ops.record` defines type classes for shapeless records
    (`HLists` containing
    tagged elements---Section [@sec:labelled-generic:type-tagging]).
    These can be used via extension methods on `HList`,
    imported from `shapeless.record`,
    and defined in `shapeless.syntax.record`.

We don't have room in this book
to cover all of the available ops.
Fortunately, in most cases the code
is understandable and well documented.
Rather than provide an exhaustive guide,
we will touch on
the major theoretical and structural points
and show you how to extract further information
from the shapeless codebase.
