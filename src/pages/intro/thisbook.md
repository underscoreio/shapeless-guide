## About this book

This book is divided into chapters
that introduce parts of the shapeless machinery.

In Chapter [@sec:representations] 
we introduce *generic representations*
and shapeless' `Generic` type class,
which can produce a generic encoding
for any case class or sealed trait.
The main use case will be something basic:
converting one type of data to another.

In Chapter [@sec:generic] we use `Generic`
to derive instances of a custom type class.
We use CSV encoding as an example,
but these techniques can be extended to many situations.
We will introduce shapeless' `Lazy` type,
which lets us handle recursive data like lists and trees.

In Chapter [@sec:type-level-programming] we cover some more theory:
dependent types, dependently typed functions,
and type level programming.
We will introduce the programming patterns
we need to generalise from deriving type class instances
to doing more advanced things in shapeless.

In Chapter [@sec:labelled-generic] we introduce `LabelledGeneric`,
a variant of `Generic` that exposes field and type names
as part of its generic representations.
We also introduce some new theory:
literal types, singleton types, phantom types, and type tagging.
In our examples we upgrade from CSV encoding
to writing JSON encoders
that preserve field and type names in their output.

In Chapter [@sec:hlist-ops] 
we open the shapeless toolbox,
introducing a variety of operations 
on generic representations 
including mapping and filtering.
We also introduce *polymorphic functions*
that can have different output types 
depending on their parameter types.

<div class="callout callout-danger">
  TODO: Function and tuple interop
</div>

<div class="callout callout-danger">
  TODO: Counting with types
</div>

<div class="callout callout-danger">
  TODO: Polymorphic functions
</div>
