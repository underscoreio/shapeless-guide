## Generic product encodings

In the previous section we introduced tuples
as a generic representation of products.
Unfortunately, Scala's built-in tuples have a couple of disadvantages
that make them unsuitable for shapeless' purposes:

 1. Each size of tuple has a different, unrelated type,
    making it difficult to write code that abstracts over sizes.

 2. There is no type for zero-length tuples,
    which are important for representing products with zero fields.
    We could arguably use `Unit`,
    but we ideally want all generic representations
    to have a sensible common supertype.
    The least upper bound of `Unit` and `Tuple2` is `Any`
    so a combination of the two is impractical.

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
val newProduct = 42L :: product
```

Shapeless also provides tools for performing more complex operations
such as mapping, filtering, and concatenating lists.
We'll discuss these in more detail in Part II.

The behaviour we get from `HLists` isn't magic.
We could have achieved all of this functionality
using `(A, B)` and `Unit` as alternatives to `::` and `HNil`.
However, there is an advantage in
keeping our representation types separate
from the semantic types used in our applications.
`HList` provides this separation.

### Switching representations using *Generic*

Shapeless provides a type class called `Generic`
that allows us to switch back and forth between
a concrete ADT and its generic representation.
Some behind-the-scenes macro magic
allows us to summon instances of `Generic` without boilerplate:

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
val iceCream = IceCream("Sundae", 1, false)

val repr = iceCreamGen.to(iceCream)

val iceCream2 = iceCreamGen.from(repr)
```

If two ADTs have the same `Repr`,
we can convert back and forth between them using their `Generics`:

```tut:book:silent
case class Employee(name: String, number: Int, manager: Boolean)
```

```tut:book
// Create an employee from an ice cream:
val employee = Generic[Employee].from(Generic[IceCream].to(iceCream))
```

<div class="callout callout-info">
*Other product types*

It's worth noting that
Scala tuples are actually case classes,
so `Generic` works with them just fine:

```tut:book:silent
val tupleGen = Generic[(String, Int, Boolean)]
```

```tut:book
tupleGen.to(("Hello", 123, true))
tupleGen.from("Hello" :: 123 :: true :: HNil)
```

It also works with case classes of more than 22 fields:

```tut:book:silent
case class BigData(
  a:Int,b:Int,c:Int,d:Int,e:Int,f:Int,g:Int,h:Int,i:Int,j:Int,
  k:Int,l:Int,m:Int,n:Int,o:Int,p:Int,q:Int,r:Int,s:Int,t:Int,
  u:Int,v:Int,w:Int)
```

```tut:book
Generic[BigData].from(Generic[BigData].to(BigData(
  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)))
```

In versions 2.10 and earlier, Scala had a limit of 22 fields for case
classes.  This limit was nominally fixed in 2.11, but using `HLists`
will help avoid the remaining [limitations of 22 fields in
Scala][link-dallaway-twenty-two].

</div>
