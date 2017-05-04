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
`String` also has a bunch of other types
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

The type `Foo.type` is the type of `Foo`,
and `Foo` is the only value with that type.

Singleton types applied to literal values are called *literal types*.
These have existed in Scala for a long time,
but we don't normally interact with them
because the default behaviour of the compiler is
to "widen" literals to their nearest non-singleton type.
For example, these two expressions are essentially equivalent:

```tut:book
"hello"

("hello" : String)
```

Shapeless provides a few tools for working with literal types.
First, there is a `narrow` macro that converts a
literal expression to a singleton-typed literal expression:

```tut:book:silent
import shapeless.syntax.singleton._
```

```scala
var x = 42.narrow
// x: Int(42) = 42
```

Note the type of `x` here: `Int(42)` is a literal type.
It is a subtype of `Int` that only contains the value `42`.
If we attempt to assign a different number to `x`,
we get a compile error:

```scala
x = 43
// <console>:16: error: type mismatch:
//  found   : Int(43)
//  required: Int(42)
//        x = 43
//            ^
```

However, `x` is still an `Int` according to normal subtyping rules.
If we operate on `x` we get a regular type of result:

```tut:book:invisible
var x: 42 = 42
```

```tut:book
x + 1
```

We can use `narrow` on any literal in Scala:

```scala
1.narrow
// res7: Int(1) = 1

true.narrow
// res8: Boolean(true) = true

"hello".narrow
// res9: String("hello") = hello

// and so on...
```

```tut:book:invisible
1 : 1
true : true
"hello" : "hello"
```

However, we can't use it on compound expressions:

```scala
math.sqrt(4).narrow
// <console>:17: error: Expression scala.math.`package`.sqrt(4.0) does not evaluate to a constant or a stable reference value
//        math.sqrt(4.0).narrow
//                 ^
// <console>:17: error: value narrow is not a member of Double
//        math.sqrt(4.0).narrow
//                       ^
```

<div class="callout callout-info">
*Literal types in Scala*

Until recently, Scala had no syntax for writing literal types.
The types were there in the compiler
but we couldn't express them directly in code.
However, as of Lightbend Scala 2.12.1, Lightbend Scala 2.11.9,
and Typelevel Scala 2.11.8 we have
direct syntax support for literal types.
In these versions of Scala
we can use the `-Yliteral-types` compiler option
and write declarations like the following:

```tut:book
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
at runtime, where it has an actual value
and methods that we can call,
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
fields and subtypes in an ADT
with the singleton types of their names.
If you find using `asInstanceOf` uncomfortable then don't worry:
shapeless provides two tagging syntaxes
to avoid such unsavoriness.

The first syntax, `->>`,
tags the expression on the right of the arrow
with the singleton type of the literal expression on the left:

```tut:book:silent
import shapeless.labelled.{KeyTag, FieldType}
import shapeless.syntax.singleton._

val someNumber = 123
```

```tut:book
val numCherries = "numCherries" ->> someNumber
```

Here we are tagging `someNumber` with
the following phantom type:

```scala
KeyTag["numCherries", Int]
```

The tag encodes both the name and type of the field,
the combination of which is useful
when searching for entries in a `Repr` using implicit resolution.

The second syntax takes the tag as a type
rather than a literal value.
This is useful when we know what tag to use
but don't have the ability
to write specific literals in our code:

```tut:book:silent
import shapeless.labelled.field
```

```tut:book
field[Cherries](123)
```

`FieldType` is a type alias that simplifies
extracting the tag and base types from a tagged type:

```scala
type FieldType[K, V] = V with KeyTag[K, V]
```

As we'll see in a moment,
shapeless uses this mechanism to tag
fields and subtypes with
their names in our source code.

Tags exist purely at compile time
and have no runtime representation.
How do we convert them to values we can use at runtime?
Shapeless provides a type class called `Witness` for this purpose[^witness].
If we combine `Witness` and `FieldType`,
we get something very compelling---the
ability to extract the field name
from a tagged field:

[^witness]: The term "witness" is borrowed from
[mathematical proofs][link-witness].

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
// Get the untagged type of a tagged value:
def getFieldValue[K, V](value: FieldType[K, V]): V =
  value
```

```tut:book
getFieldValue(numCherries)
```

If we build an `HList` of tagged elements,
we get a data structure that has some of the properties of a `Map`.
We can reference fields by tag,
manipulate and replace them,
and maintain all of the type and naming information along the way.
Shapeless calls these structures "records".

### Records and *LabelledGeneric*

Records are `HLists` of tagged elements:

```tut:book:silent
import shapeless.{HList, ::, HNil}
```

```tut:book
val garfield = ("cat" ->> "Garfield") :: ("orange" ->> true) :: HNil
```

For clarity, the type of `garfield` is as follows:

```scala
// FieldType["cat",    String]  ::
// FieldType["orange", Boolean] ::
// HNil
```

We don't need to go into depth regarding records here;
suffice to say that records are the generic representation
used by `LabelledGeneric`.
`LabelledGeneric` tags each item in a product or coproduct
with the corresponding field or type name from the concrete ADT
(although the names are represented as `Symbols`, not `Strings`).
Shapeless provides a suite of `Map`-like operations on records,
some of which we'll cover in Section [@sec:ops:record].
For now, though, let's derive some type classes using `LabelledGeneric`.
