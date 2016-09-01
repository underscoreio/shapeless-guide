# Accessing names during implicit derivation

Often, the type class instances we define
need access to more than just type information.
Field names and type names are often important,
and sometimes we need to parameterize our instances
based on some other criteria.

In this chapter we will look at some of the additional tools
shapeless gives us for type class derivation.
We'll cover a variant of `Generic` called `LabelledGeneric`
that gives us access to field names and type names.

To begin with, though, we have some theory to cover.
`LabelledGeneric` uses some clever techniques to expose
field and type names at the type level,
so we can take them into account when searching for implicits.
To understand `LabelledGeneric` we must first understand these techniques,
which means talking about *literal types*, *phantom types*, and *type tagging*.
