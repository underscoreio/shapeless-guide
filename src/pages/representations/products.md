## Generic product encodings

In the previous section we introduced tuples
as a generic representation of products.
Unfortunately, Scala's built-in tuples have a couple of disadvantages
that make them unsuitable for shapeless' purposes:

 1. Each size of tuple has a different, unrelated type,
    making it difficult to write code that abstracts over sizes.

 2. There is no type for 0-length tuples,
    which are important for representing products with 0 fields.
    We could arguably use `Unit`,
    but we would ideally like all generic representations
    to have a common supertype.
    The least upper bound of `Unit` and `Tuple2` is `Any`
    so a combination of the two is not ideal.

For these reasons, shapeless uses a different generic encoding
for product types called *heterogeneous lists* or `HLists`[^hlist-name].

[^hlist-name]: `Product` is perhaps a better name for `HList`,
but the standard library unfortunately already has a type `scala.Product`.

An `HList` is either the empty list `HNil`,
or a pair `::[H, T]` where `H` is an arbitrary type
and `T` is another `HList`.
Because every `::` has its own `H` and `T`,
the type of each element is encoded separately
in the type of the overall list:

```tut:book:silent
import shapeless.{HList, ::, HNil}

val product: String :: Int :: Boolean :: HNil =
  "Sunday" :: 1 :: false :: HNil
```

The type and value of the `HList` above mirror one another.
Both represent three members: a `String`, an `Int`, and a `Boolean`.
We can retrieve the `head` and `tail`
and the types of the elements are preserved:

```tut:book
val first = product.head
val second = product.tail.head
val rest = product.tail.tail
```

The compiler knows the exact length of each `HList`,
so it becomes a compilation error
to take the `head` or `tail` of an empty list:

```tut:book:fail
product.tail.tail.tail.head
```

We can manipulate and transform `HLists`
in addition to being able to inspect and traverse them.
For example, we can prepend an element with the `::` method.
Again, notice how the type of the result reflects
the number and types of its elements:

```tut:book:silent
val newProduct: Long :: String :: Int :: Boolean :: HNil =
  42L :: product
```

Shapeless also provides tools for performing more complex operations
such as mapping, filtering, and concatenating lists.
We'll discuss these in more detail in Part II.

The behaviour described above isn't magic.
We could have achieved all of this functionality
using `(A, B)` and `Unit` as alternatives to `::` and `HNil`.
However, there is an advantage in
keeping our representation types
separate from the types used in our applications.
`HList` provides this separation.

### Switching representations using *Generic*

Shapeless provides a type class called `Generic`
that allows us to switch back and forth between
a concrete ADT and its generic representation.
There's some macro magic going on behind the scenes
that allows us to summon instances of `Generic` without boilerplate:

```tut:book:silent
import shapeless.Generic

case class IceCream(name: String, numCherries: Int, inCone: Boolean)
```

```tut:book
val iceCreamGen = Generic[IceCream]
```

Note that the instance of `Generic` has a type member `Repr`
containing the type of its generic representation.
In this case `iceCreamGen.Repr` is `String :: Int :: Boolean :: HNil`.
Instances of `Generic` have two methods:
one for converting `to` the `Repr` type
and one for converting `from` it:

```tut:book
val iceCream: IceCream =
  IceCream("Sundae", 1, false)

val repr: iceCreamGen.Repr =
  iceCreamGen.to(iceCream)

val iceCream2: IceCream =
  iceCreamGen.from(repr)
```

If two ADTs have the same `Repr`,
we can convert back and forth between them using their `Generics`:

```tut:book:silent
case class Employee(name: String, number: Int, manager: Boolean)
```

```tut:book
// Create an employee from an ice cream:
val strangeEmployee: Employee =
  Generic[Employee].from(Generic[IceCream].to(iceCream))
```

<div class="callout callout-info">
*Other product types*

It's useful to know that
`Generic` understands tuples as well as case classes:

```tut:book:silent
val tupleGen = Generic[(String, Int, Boolean)]
```

```tut:book
tupleGen.to(("Hello", 123, true))
tupleGen.from("Hello" :: 123 :: true :: HNil)
```
</div>
