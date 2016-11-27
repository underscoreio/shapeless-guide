# Functional operations on *HLists* {#sec:poly}

"Regular" Scala programs make heavy use
of functional operations like `map` and `flatMap`.
A question arises: can we perform similar operations on `HLists`?
The answer is "yes", although
we have to do things a little differently than in regular Scala.
Unsurprisingly the mechanisms we use are type class based
and there are a suite of ops type classes to help us out.

Before we delve in to the type classes themselves,
we need to discuss how shapeless represents
*polymorphic functions* suitable for
mapping over heterogeneous data structures.

## Motivation: mapping over an *HList*

We'll motivate the discussion of polymorphic functions
by looking at the `map` method.
Figure [@fig:poly:monomorphic-map] shows
a type chart for mapping over a regular list.
We start with a `List[A]`, supply a function `A => B`,
and end up with a `List[B]`.

![Mapping over a regular list ("monomorphic" map)](src/pages/poly/monomorphic-map.pdf+svg){#fig:poly:monomorphic-map}

The heterogeneous element types in an `HList`
cause this model to break down.
Scala functions have fixed input and output types,
so the result of our map will have to have
the same element type in every position.

Ideally we'd like a `map` operation like
the one shown in Figure [@fig:poly:polymorphic-map],
where the function inspects the type of each input
and uses it to determine the type of each output.
This gives us a closed, composable transformation
that retains the heterogeneous nature of the `HList`.

![Mapping over a heterogeneous list ("polymorphic" map)](src/pages/poly/polymorphic-map.pdf+svg){#fig:poly:polymorphic-map}

Unfortunately we can't use Scala functions
to implement this kind of operation.
We need some new infrastructure.
