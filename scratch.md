
## Accessing elements and subsequences

- `head` - hlist and coproduct
- `tail` - hlist and coproduct

- `at(Nat)` - hlist and coproduct
- `at[Nat]` - hlist and coproduct

- `apply(Nat)` - hlist only
- `apply[Nat]` - hlist only

- `length` - hlist and coproduct

- `init` - hlist and coproduct
- `last` - hlist and coproduct

- `take(Nat)` - hlist and coproduct
- `take[Nat]` - hlist and coproduct

- `drop(Nat)` - hlist and coproduct
- `drop[Nat]` - hlist and coproduct

- `split(Nat)` - hlist and coproduct
- `split[Nat]` - hlist and coproduct

- `slice(Nat, Nat)` - hlist

## Appending and prepending elements

- `:+` - hlist
- `+:` - hlist
- `::` - hlist

- `extendLeft[A]` - coproduct
- `extendRight[A]` - coproduct

- `++` - hlist
- `++:` - hlist
- `:::` - hlist

- `extendLeftBy[Coproduct]` - coproduct
- `extendRightBy[Coproduct]` - coproduct

## Updating and replacing elements

- `replace(U)` - hlist
- `replaceType[U](V)` - hlist

- `updatedElem(U)` - hlist
- `updatedType[U](V)` - hlist

- `updatedAt(Nat, U)` - hlist
- `updatedAt[Nat](U)` - hlist

- `patch[Nat, Nat](HList)` - hlist

## Least upper bounds

- `unify` - hlist and coproduct

## Filtering and selection by type

- `filter[U]` - hlist and coproduct
- `filterNot[U]` - hlist and coproduct
- `partition[U]` - hlist and coproduct

- `select[U]` - hlist and coproduct

- `selectMany[HList]` - hlist
- `splitLeft[U]` - hlist
- `splitRight[U]` - hlist

## Set-like operations

- `diff[HList]` - hlist
- `intersect[HList]` - hlist
- `union(hlist)` - hlist

## Ordering

- `reverse` - hlist and coproduct

- `align(HList)` - hlist and coproduct
- `align[HList]` - hlist and coproduct

## Zipping

- `zip(HList)` - hlist

- `zipWithIndex` - hlist and coproduct

- `zipWithKeys[HList]` - hlist and coproduct
- `zipWithKeys(HList)` - hlist and coproduct

## Record access

- `apply(Witness)` - hlist
- `get(Witness)` - hlist
- `fieldAt(Witness)` - hlist

- `keys` - hlist
- `values` - hlist
- `fields` - hlist

## Record update

- `-(Witness)` - hlist
- `+(Field)` - hlist
- `remove(Witness)` - hlist

- `replace(Witness, V)` - hlist
- `updated(Witness, V)` - hlist
- `updateWith(Witness)(U => V)` - hlist
- `renameField(Witness, Witness)` - hlist

- `merge(Record)` - hlist

- `mapValues(Poly)` - hlist

- `toMap[K, V]` - record

## Conversions

- `toList[Lub]` - hlist
- `toArray[Lub]` - hlist
- `to[Collection]` - hlist
- `tupled` - hlist


---

The `Length` type class is one of the simplest.
It can be used via the `length` extension method,
which is defined for `HList` and `Coproduct`:

```tut:book:silent
import shapeless._
import shapeless.ops.{hlist, coproduct}

val prod: String :: Int :: Boolean :: HNil =
  "foo" :: 123 :: true :: HNil

val coprod: String :+: Int :+: Boolean :+: CNil =
  Inr(Inl(123))
```

```tut:book
prod.length
coprod.length
```

The `length` method is defined
in terms of the `Length` type class.
Here is a simplified form of the definition for `HList`:

```scala
implicit class HListOps[L <: HList](hlist: L) {
  def length(implicit len: Length[L]): len.Out =
    length.apply()
}
```

We can use `Length` directly when deriving our own type classes.
Here is a trivial example.
Note that we're referring to the type class as `hlist.Length`
to disambiguate it from `coproduct.Length`:

```tut:book:silent
import shapeless.ops.{hlist, nat}

trait IntLength[A] {
  def value: Int
}

implicit def intLength[L <: HList, N <: Nat](
  implicit
  len: hlist.Length.Aux[L, N],
  toInt: nat.ToInt[N]
): IntLength[L] =
  new IntLength[L] {
    val value = toInt.apply()
  }
```

```tut:book
implicitly[IntLength[String :: Int :: Boolean :: HNil]].value
```

We've seen examples of the two patterns of use here:
use as a regular operation via the `length` extension method,
and use in implicit resolution via the `Length` type class.
Similar patterns apply for the other operations.
