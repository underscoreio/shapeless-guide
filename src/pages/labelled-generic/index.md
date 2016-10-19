# Accessing names during implicit derivation {#sec:labelled-generic}

Often, the type class instances we define
need access to more than just types.
Field and type names are often important,
and sometimes we need to parameterize our instances
based on other criteria.

In this chapter we will look the additional tools
shapeless gives us for type class derivation.
The bulk of this content involves
a variant of `Generic` called `LabelledGeneric`
that gives us access to field names and type names.

To begin with we have some theory to cover.
`LabelledGeneric` uses some clever techniques
to expose field and type names at the type level.
Understanding these techniques means
talking about *literal types*, *singleton types*,
*phantom types*, and *type tagging*.
