## Summary

When coding with shapeless,
we are often trying to find a target type
that depends on the types we start with.
This relationship is called *dependent typing*.

Problems involving dependent types
can be conveniently expressed using implicit search,
allowing the compiler to resolve intermediate and target types
given a starting point at the call site.

We often have to use multiple resolution steps to calculate a result
(e.g. using a `Generic` to get a `Repr`,
then using another type class to get to another type).
When doing this,
there are a few rules we should follow
to ensure our code compiles and works as expected:

 1. Extract every intermediate type out to a type parameter.
    Many type parameters won't be used in the result,
    but the compiler needs them to know which types it has to unify.

 2. The compiler resolves implicits from left to right,
    backtracking if it can't find a working combination.
    Write implicits in the order you'll need them,
    using one or more type variables to connect them to previous implicits.

 3. The compiler can only solve for one constraint at a time,
    so don't over-constrain any implicit.

 4. Write the return type explicitly,
    specifying any type parameters and type members
    you may need to use elsewhere.

 5. If you're creating your own dependently typed functions,
    consider introducing an `Aux` type alias to make them easier to use.

<div class="callout callout-danger">
  TODO: Other tips?

  Always put return types on implicits?

  Ensure those return types include type members
  when declaring dependently typed implicits?
</div>

<div class="callout callout-danger">
  TODO: Section on debugging using `implicitly`?

  Section on debugging using `reify`?
</div>
