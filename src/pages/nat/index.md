# Counting with types

<div class="callout callout-danger">
  TODO: There may be other chapters before this one.
  `Poly` and `ops.{hlist, coproduct, record}` 
  are probably more important than `Nat` and `Length`.
</div>

<div class="callout callout-danger">
  TODO: If we discuss `ops.hlist` and 
  `ops.coproduct` before this chapter, 
  we should move the discussion 
  of imports in `length.md` to cover them earlier.
</div>

From time to time we may need to count things at the type level.
For example, we may need to know the length of an `HList`
or the number of terms we have expanded so far in a computation.
This chapter covers the theory behind counting with types,
and provides some use cases related to type class derivation.

## Representing numbers as types

Shapeless uses "church encoding"
to represent natural numbers at the type level.
It provides a type `Nat` with two subtypes:
`_0` representing zero,
and `Succ[N]` representing the successor of `N`:

```tut:book:silent
import shapeless.{Nat, Succ}

type Zero = Nat._0
type One  = Succ[Zero]
type Two  = Succ[One]
// etc...
```

`Nat` has no runtime semantics.
We have to use the `ToInt` type class
to convert a `Nat` to a runtime `Int`:

```tut:book:silent
import shapeless.ops.nat.ToInt

val toInt = implicitly[ToInt[Two]]
```

```tut:book
toInt.apply()
```

The `Nat.toInt` method provides
convenient shorthand for calling `nat.apply()`:

```tut:book
Nat.toInt[Succ[Succ[Succ[Nat._0]]]]
```
