# Counting with types {#sec:nat}

From time to time we need to count things at the type level.
For example, we may need to know the length of an `HList`
or the number of terms we have expanded so far in a computation.
We can represent numbers as values easily enough,
but if we want to influence implicit resolution
we need to represent them at the type level.
This chapter covers the theory behind counting with types,
and provides some compelling use cases for type class derivation.

## Representing numbers as types

Shapeless uses "Church encoding"
to represent natural numbers at the type level.
It provides a type `Nat` with two subtypes:
`_0` representing zero,
and `Succ[N]` representing `N+1`:

```tut:book:silent
import shapeless.{Nat, Succ}

type Zero = Nat._0
type One  = Succ[Zero]
type Two  = Succ[One]
// etc...
```

Shapeless provides aliases for the first 22 `Nats` as `Nat._N`:

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

val toInt = ToInt[Two]
```

```tut:book
toInt.apply()
```

The `Nat.toInt` method provides
a convenient shorthand for calling `toInt.apply()`.
It accepts the instance of `ToInt` as an implicit parameter:

```tut:book
Nat.toInt[Nat._3]
```
