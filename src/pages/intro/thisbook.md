## About this book {#sec:intro:about-this-book}

This book is divided into two parts.

In Part I we introduce *type class derivation*,
which allows us to create type class instances
for any algebraic data type
using only a handful of generic rules.
Part I consists of four chapters:

  - In Chapter [@sec:representations]
    we introduce *generic representations*.
    We also introduce shapeless' `Generic` type class,
    which can produce a generic encoding
    for any case class or sealed trait.

  - In Chapter [@sec:generic] we use `Generic`
    to derive instances of a custom type class.
    We create an example type class
    to encode Scala data as
    Comma Separated Values (CSV),
    but the techniques we cover
    can be extended to many situations.
    We also introduce shapeless' `Lazy` type,
    which lets us handle recursive data like lists and trees.

  - In Chapter [@sec:type-level-programming]
    we introduce the theory and programming patterns we need
    to generalise the techniques from earlier chapters.
    Specifically we look at dependent types,
    dependently typed functions,
    and type level programming.
    This allows us to access
    more advanced applications of shapeless.

  - In Chapter [@sec:labelled-generic] we introduce `LabelledGeneric`,
    a variant of `Generic` that exposes field and type names
    as part of its generic representations.
    We also introduce additional theory:
    literal types, singleton types, phantom types, and type tagging.
    We demonstrate `LabelledGeneric` by creating
    a JSON encoder that preserves field and type names in its output.

In Part II we introduce the "ops type classes"
provided in the `shapeless.ops` package.
Ops type classes form an extensive library of tools
for manipulating generic representations.
Rather than discuss every op in detail,
we provide a theoretical primer in three chapters:

  - In Chapter [@sec:ops] we discuss
    the general layout of the ops type classes
    and provide an example
    that strings several simple ops together
    to form a powerful "case class migration" tool.

  - In Chapter [@sec:poly] we introduce
    *polymorphic functions*,
    also known as `Polys`,
    and show how they are used in
    ops type classes for mapping,
    flat mapping, and folding
    over generic representations.

  - Finally, in Chapter [@sec:nat] we introduce
    the `Nat` type that shapeless uses
    to represent natural numbers at the type level.
    We introduce several related ops type classes,
    and use `Nat` to develop
    our own version of Scalacheck's `Arbitrary`.
