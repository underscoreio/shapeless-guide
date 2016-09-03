## About this book

This book is divided into chapters
that introduce parts of the shapeless machinery.

In Chapter 2 we will introduce *generic representations*
and shapeless' `Generic` type class,
which can produce a generic encoding
for any case class or sealed trait.
The main use case will be something basic:
converting one type of data to another.

In Chapter 3 we will use `Generic`
to derive instances for a type class.
We will use CSV encoding as an example,
but we will write one set of encoders
that can handle any case class or sealed trait.
We will also introduce shapeless' `Lazy` type,
which lets us handle resursive data like lists and trees.

In Chapter 4 we will introduce `LabelledGeneric`,
a variant of `Generic` that exposes field and type names
as part of its generic representations.
We will also introduce some new theory:
literal types, singleton types, phantom types, and type tagging.
In our examples we will upgrade from CSV encoding
to writing JSON encoders
that preserve names from their source types.

In Chapter 5 we will cover some more theory:
dependent types, dependently typed functions,
and type level programming.
We will introduce the programming patterns
we need to generalise from deriving type class instances
to doing more advanced things in shapeless.

In Chapter 6 we will open the shapeless toolbox,
introducing some type-level operations
that may come in handy in certain situations.

<div class="callout callout-danger">
  TODO: Function and tuple interop
</div>

<div class="callout callout-danger">
  TODO: Counting with types
</div>

<div class="callout callout-danger">
  TODO: Polymorphic functions
</div>
