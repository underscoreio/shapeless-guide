## Summary

In this chapter we discussed `LabelledGeneric`,
a variant of `Generic` that exposes type and field names
in its generic representations.

The names exposed by `LabelledGeneric`
are encoded as type-level tags
so we can target them during implicit resolution.
We started the chapter discussing *literal types*
and the way shapeless uses them in its tags.
We also discussed the `Witness` type class,
which is used to reify literal types as values.

Finally, we combined `LabelledGeneric`,
literal types, and `Witness` to build a `JsonEcoder` library
that includes sensible names in its output.

The key take home point from this chapter
is that none of this code uses runtime reflection.
Everything is implemented with types, implicits,
and a small set of macros that are internal to shapeless.
The code we're generating is consequently
very fast and reliable at runtime.
