## Literal types

A Scala value may have multiple types.
For example, the string `"hello"`
has at least three types:
`String`, `AnyRef`,
and `Any`[^multiple-inheritance]:

```tut:book
"hello" : String
"hello" : AnyRef
"hello" : Any
```

[^multiple-inheritance]:
`String` has a bunch of other types
like `Serializable` and `Comparable`
but let's ignore those for now.

Interestingly, `"hello"` also has another type:
a "singleton type"
that belongs exclusively to that one value.
This is similar to the singleton type we get
when we define a companion object:

```tut:book:silent
object Foo
```

```tut:book
Foo
```

Singleton types applied to literal values are called *literal types*.
We don't normally interact with them
because the default behaviour of the compiler is to "cast" literals
to their nearest non-singleton type.
So, for example, these two expressions are essentially equivalent:

```tut:book
"hello"

("hello" : String)
```

Shapeless provides a few tools for working with literal types.
First, there is a `narrow` macro that converts a
literal expression into a singleton-typed literal expression:

```tut:book:silent
import shapeless.syntax.singleton._
```

```tut:book
var x = 42.narrow
```

Note the type of `x` here: `Int(42)` is a literal type.
It is a subtype of `Int` that only contains the value `42`.
If we attempt to assign a different number to `x`,
we get a compile error:

```tut:book:fail
x = 43
```

However, `x` is still an `Int` according to normal subtyping rules.
If we operate on `x` we get a regular type of result:

```tut:book
x + 1
```

We can use `narrow` on any literal in Scala:

```tut:book
1.narrow
true.narrow
"hello".narrow
// and so on...
```

However, we can't use it on compound expressions:
the compiler has to be able to determine the literal value
straight from the source:

```tut:book:fail
math.sqrt(4).narrow
```

<div class="callout callout-info">
*Literal types in Scala*

Until recently, Scala had no syntax for writing literal types.
The types were there in the compiler,
but we couldn't express them directly in code.
As of
[Lightbend Scala 2.12.1][link-lightbend-scala-singleton-type-literals],
Lightbend Scala 2.11.9,
and
[Typelevel Scala 2.11.8][link-typelevel-scala-singleton-type-literals],
however, we now have direct syntax support for literal types.
In these versions of Scala
we can write declarations like the following:

```scala
val theAnswer: 42 = 42
```

The type `42` is the same as the type `Int(42)`
we saw in printed output earlier.
You'll still see `Int(42)` in output for legacy reasons,
but the canonical syntax going forward is `42`.
</div>

## Type tagging and phantom types {#sec:labelled-generic:type-tagging}

Shapeless uses literal types
to model the names of fields in case classes.
It does this by "tagging" the types of the fields
with the literal types of their names.
Before we see how shapeless does this,
we'll do it ourselves to show that there's no magic
(well... minimal magic, at any rate).
Suppose we have a number:

```tut:book:silent
val number = 42
```

This number is an `Int` in two worlds:
at runtime, where it has methods like `+` and `*`,
and at compile-time,
where the compiler uses the type
to calculate which pieces of code work together
and to search for implicits.

We can modify the type of `number` at compile time
without modifying its run-time behaviour
by "tagging" it with a "phantom type".
Phantom types are types with no run-time semantics,
like this:

```tut:book:silent
trait Cherries
```

We can tag `number` using `asInstanceOf`.
We end up with a value that is both
an `Int` and a `Cherries` at compile-time,
and an `Int` at run-time:

```tut:book
val numCherries = number.asInstanceOf[Int with Cherries]
```

Shapeless uses this trick to tag
the types of fields in a case classes
with the singleton types of their names.
If you find using `asInstanceOf` uncomfortable then don't worry:
shapeless provides two tagging syntaxes
that avoid such unsavoriness.

The first syntax, `->>`,
tags the expression on the right of the arrow
with singleton type of the literal expression on the left:

```tut:book:silent
import shapeless.labelled.{KeyTag, FieldType}
import shapeless.syntax.singleton._

val someNumber = 123
```

```tut:book
val numCherries = "numCherries" ->> someNumber
```

Here we are tagging `someNumber` with
the phantom type `KeyTag["numCherries", Int]`.
The tag encodes both the name and type of the field,
both of which are useful when searching for entries in a `Repr`
using implicit resolution.

The second syntax takes the tag as a type
rather than a literal value.
This is useful when writing implicit resolution rules
where we don't have the ability
to write specific literals expressions in our code:

```tut:book:silent
import shapeless.labelled.field

field[Cherries](123)
```

Shapeless provides us with the `FieldType` type alias
to make it easy to extract the key tag and value from a type:

```scala
type FieldType[K, V] = V with KeyTag[K, V]
```

As we'll see later,
shapeless uses this mechanism to tag
fields in products and subtypes in coproducts
with identifiers from our source code.
But tags are just a phantom types.
How do we convert them to values we can use at runtime?
Shapeless provides a type class called `Witness` for this purpose.
If we combine `Witness` and `FieldType`,
we get something very compelling---the
ability extract the field name
from a tagged field:

```tut:book:silent
import shapeless.Witness
```

```tut:book
val numCherries = "numCherries" ->> 123
```

```tut:book:silent
// Get the tag from a tagged value:
def getFieldName[K, V](value: FieldType[K, V])
    (implicit witness: Witness.Aux[K]): K =
  witness.value
```

```tut:book
getFieldName(numCherries)
```

```tut:book:silent
// Get the untagged value from a tagged value:
def getFieldValue[K, V](value: FieldType[K, V]): V =
  value
```

```tut:book
getFieldValue(numCherries)
```

### Records and *LabelledGeneric*

Shapeless includes a set of tools for working with
data structures called *records*.
Records are `HLists` of items that are each
tagged with type-level identifiers:

```tut:book:silent
import shapeless.{HList, ::, HNil}
```

```tut:book
val garfield = ("cat" ->> "Garfield") ::  ("orange" ->> true) :: HNil
```

For clarity, the type of `garfield` is as follows:

```scala
// FieldType["cat",    String]  ::
// FieldType["orange", Boolean] ::
// HNil
```

<div class="callout callout-danger">
  TODO: Insert link to records chapter if we have one.
</div>

We don't need to go into depth regarding records here,
suffice to say that records are the generic representation
used by the `LabelledGeneric` type class that we will discuss next.
`LabelledGeneric` tags each item in a product or coproduct
with the corresponding field or type name from the concrete ADT
(although the names are represented as `Symbols`, not `Strings`).
Accessing names without using reflection is incredibly compelling,
so let's derive some type class instances using `LabelledGeneric`.
