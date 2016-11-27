# Accessing names during implicit derivation {#sec:labelled-generic}

Often, the type class instances we define
need access to more than just types.
In this chapter we will look at 
a variant of `Generic` called `LabelledGeneric`
that gives us access to field names and type names.

To begin with we have some theory to cover.
`LabelledGeneric` uses some clever techniques
to expose name information at the type level.
To understand these techniques 
we must discuss *literal types*, 
*singleton types*,
*phantom types*, 
and *type tagging*.
