## Summary

When coding with shapeless,
we are often trying to find a target type
that depends on the types we start with.
This relationship is called *dependent typing*.

Problems involving dependent types
can be conveniently expressed using implicit search,
allowing the compiler to resolve
intermediate and target types
given a starting point at the call site.

We often have to use multiple steps
to calculate a result
(e.g. using a `Generic` to get a `Repr`,
then using another type class to get to another type).
When we do this,
there are a few rules we can follow
to ensure our code compiles and works as expected:

 1. We should extract every intermediate type
    out to a type parameter.
    Many type parameters won't be used in the result,
    but the compiler needs them to know which types it has to unify.

 2. The compiler resolves implicits from left to right,
    backtracking if it can't find a working combination.
    We should write implicits in the order we need them,
    using one or more type variables
    to connect them to previous implicits.

 3. The compiler can only solve for one constraint at a time,
    so we mustn't over-constrain any single implicit.

 4. We should state the return type explicitly,
    specifying any type parameters and type members
    that may be needed elsewhere.
    Type members are often important.
    If we don't state them in the return type,
    they won't be available to the compiler
    for further implicit resolution.

 5. The `Aux` type alias pattern is useful
    for keeping code readable.
    We should look out for `Aux` aliases
    when using tools from the shapeless toolbox,
    and implement `Aux` aliases
    on our own dependently typed functions.
