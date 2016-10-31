## Summary

In this chapter we discussed *polymorphic functions*
whose return types vary based on the types of their parameters.
We saw how shapeless' `Poly` type is defined,
and how it is used to implement functional operations such as
`map`, `flatMap`, `foldLeft`, and `foldRight`.

Each operation is implemented as an extension method on `HList`,
based on a corresponding type class:
`Mapper`, `FlatMapper`, `LeftFolder`, and so on.
We can use these type classes, `Poly`,
and the techniques from Section [@sec:type-level-programming:chaining]
to create our own type classes involving
sequences of sophisticated transformations.
