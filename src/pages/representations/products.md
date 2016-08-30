## Generic product encodings

In the previous section we introduced tuples
as a generic representation pf products.
Unfortunately, Scala's built-in tuples have a couple of disadvantages
that make them unsuitable for shapeless' purposes.
First, each size of tuple has a different, unrelated type,
making it difficult to write code that abstracts over sizes.
Second, we don't have types for 0- and 1-length tuples,
which are important for representing product types with 0 and 1 fields.

For these reasons, shapeless uses a different generic encoding
for product types called *heterogeneous lists* or `HLists`[^hlist-name].
Here's an inheritance diagram:

![Inheritance diagram for `HList`](src/pages/representations/hlist.png)

[^hlist-name]: `Product` is perhaps a better name,
but the standard library unfortunately already has a type called `Product`.

`HLists` resemble regular lists,
except that the type of each element
is maintained in the overall type signature.
The `::` type can be loosely interpreted as a `Tuple2`
where the right side has to be another `HList`:

```tut:book
import shapeless.{HList, HNil, ::}

val iceCream = "Sunday" :: 1 :: false :: HNil
```

We can also manipulate `HLists` in various ways
that are impossible with case classes and tuples.
We can retrieve the `head` and `tail`,
and all the types are preserved:

```tut:book
iceCream.head

iceCream.tail

iceCream.tail.head
```

and we can prepend elements to produce larger `HLists`:

```tut:book
42L :: iceCream
```

<div class="callout callout-info">
  TODO: Quick discussion of infix type names like `::`?
</div>

We can write recursive methods to
perform more complex manipulations
such as mapping, filtering, and concatenation.
More on these later.
The same code works for `HLists` of any size,
resolving the problem we had with tuples.

### Switching encodings using *Generic*

Shapeless provides a type class called `Generic`
that allows us to switch back and forth between
a regular ADT and its generic encoding.
There's some macro magic going on behind the scenes
that allows shapeless to summon instances of `Generic`
without any boilerplate:

```tut:book
import shapeless.Generic

case class IceCream(name: String, numCherries: Int, inCone: Boolean)

val iceCreamGen = Generic[IceCream]
```

Note that each instance of `Generic` has a type member `Repr`
providing a convenient `HList` for the type of its generic encoding
(in this case `String :: Int :: Boolean :: HNil`).
Instances of `Generic` have two methods:
one for converting `to` `Repr` and one for converting `from` it:

```tut:book
val iceCream = IceCream("Sundae", 1, false)

val genericIceCream = iceCreamGen.to(iceCream)

val secondIceCream = iceCreamGen.from(genericIceCream)
```

If two ADTs have the same `Repr`,
we can convert back and forth between them using their `Generics`:

```tut:book
case class Employee(name: String, number: Int, manager: Boolean)

val employeeGen = Generic[Employee]

val strangeEmployee = employeeGen.from(genericIceCream)
```

We can even manipulate `HLists` and
decode them to completely different case classes:

```tut:book
case class Foo(bar: Int, baz: Boolean)

Generic[Foo].from(genericIceCream.tail)
```
