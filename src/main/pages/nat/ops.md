## Other operations involving *Nat*

Shapeless provides a suite of other operations based on `Nat`.
The `apply` methods on `HList` and `Coproduct`
can accept `Nats` as value or type parameters:

```tut:book:silent
import shapeless._

val hlist = 123 :: "foo" :: true :: 'x' :: HNil
```

```tut:book
hlist.apply[Nat._1]
hlist.apply(Nat._3)
```

There are also operations such as
`take`, `drop`, `slice`, and `updatedAt`:

```tut:book
hlist.take(Nat._3).drop(Nat._1)
hlist.updatedAt(Nat._1, "bar").updatedAt(Nat._2, "baz")
```

These operations and their associated type classes
are useful for manipulating
individual elements within a product or coproduct.
