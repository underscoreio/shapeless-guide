# Functional operations on HLists {#sec:poly}

Regular Scala programs make heavy use
of functional operations like `map` and `flatMap`.
A question arises: can we perform similar operations
on `HLists` and `Coproducts`?
The answer is "yes", but the code looks
a little different to regular Scala code.
Unsurprisingly, the mechanisms are type class based
and there are a suite of ops type classes
to help us out.

Before we delve in to the type classes themselves,
however, we need to discuss some theory to understand
what operations involving functions look like
when applied to heterogeneously typed data structures.

## Motivation: mapping over an HList

Let's take the `map` method as an example.
Figure [@fig:poly:monomorphic-map] shows
a type chart for mapping over a regular list.
We start with a `List[A]`, supply a function `A => B`,
and end up with a `List[B]`.

![Mapping over a regular list ("monomorphic" map)](src/pages/poly/monomorphic-map.pdf+svg){#fig:poly:monomorphic-map}

This model breaks down for `HLists` and `Coproducts`
because of the heterogeneous nature of the element types.
Ideally we'd like a mapping
like the one shown in Figure [@fig:poly:polymorphic-map],
which inspects the type of each input element
and uses it to determine the type of each output element.
This gives us a closed, composable transformation.

![Mapping over a heterogeneous list ("polymorphic" map)](src/pages/poly/polymorphic-map.pdf+svg){#fig:poly:polymorphic-map}

Unfortunately, Scala functions are subject to a few restrictions:
they are not polymorphic and they can't have implicit parameters.
In other words, we can't choose an output type
based on input type of a regular function.
We need some new infrastructure to solve this problem.
