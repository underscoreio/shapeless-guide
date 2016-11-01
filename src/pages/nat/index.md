# Counting with types {#sec:nat}

From time to time we need to count things at the type level.
For example, we may need to know the length of an `HList`
or the number of terms we have expanded so far in a computation.
This chapter covers the theory behind counting with types,
and provides some use cases related to type class derivation.

## Representing numbers as types

Shapeless uses "Church encoding"
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

shapeless provides aliases for the first 22 `Nats`
as `Nat._N`:

```tut:book:silent
Nat._1
Nat._2
Nat._3
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
a convenient shorthand for calling `nat.apply()`:

```tut:book
Nat.toInt[Succ[Succ[Succ[Nat._0]]]]
```
