## Literal types

As Scala developers,
we are used to the notion that a value may have multiple types.
For example, the string `"hello"` has at least three types:
`String`, `AnyRef`, and `Any`[^multiple-inheritance]:

```tut:book
"hello" : String
"hello" : AnyRef
"hello" : Any
```

[^multiple-inheritance]: `String` has a bunch of other types
like `Serializable` and `Comparable`
but let's ignore those for now.

Interestingly, `"hello"` also has another type:
a "literal type" that belongs exclusively to that one value.
This is similar to the singleton type we get
when we define a companion object:

```tut:book
object Foo

val foo: Foo.type = Foo
```

We don't normally interact with literal types
because the default behaviour of Scala is to "cast" literals
to their nearest non-singleton type.
So, for example, when we write `"hello"`
it is equivalent to writing `("hello" : String)`.
```

In fact, there is currently no syntax
for writing literal types in Lightbend Scala 2.11.
The feature has been added
to [Typelevel Scala 2.11.8][link-typelevel-scala-singleton-type-literals]
and it is planned for release in
[Lightbend Scala 2.12.1][link-lightbend-scala-singleton-type-literals],
but if we're stuck on an older version of Scala
we have to rely on some macros for this demonstration.

Shapeless provides a few tools for working with literal types.
First, there is a `narrow` macro that converts a
literal expression into a singleton-typed literal expression:

```tut:book
import shapeless.syntax.singleton._

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

## Type tagging and phantom types

Shapeless uses literal types to model the names of fields in case classes.
It does this by "tagging" the types of the fields
with the literal types of their names.
Before we see how shapeless does this,
we'll do it ourselves to show that there's no magic.
Suppose we have a number:

```tut:book
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

```tut:book
trait Cherries
```

If can tag `number` using `asInstanceOf`,
we end up with a value that is both
an `Int` and a `Cherries` at compile-time
and an `Int` at run-time:

```tut:book
val numCherries = number.asInstanceOf[Int with Cherries]
```

Shapeless uses this trick to tag the types of fields in a case classes
with the singleton types of their names.
If you find using `asInstanceOf` uncomfortable then don't worry:
there's explicit syntax for tagging that avoids such unsavoriness:

```tut:book:silent
import shapeless.labelled.{KeyTag, FieldType},
       shapeless.syntax.singleton._
```

```tut:book
val someNumber = 123

val numCherries = "numCherries" ->> someNumber
```

Here we are tagging `someNumber` with
the phantom type `KeyTag[String("numCherries"), Int]`,
which encodes both the name and type of the field
so we can uniquely reference it within the body of a class or object.
This is how `LabelledGeneric` tags entries in `HLists`,
so Shapeless provides us with a type alias
to make it easy to extract the key and value types:

```scala
type FieldType[K, V] = V with KeyTag[K,V]
```

We know how to tag the type of a value with a field name.
How do we actually get hold of the field name as a value?
Shapeless provides a type class called `Witness` for this purpose:

```tut:book
import shapeless.Witness

val fieldName = "hello".narrow

val witness = implicitly[Witness.Aux[fieldName.type]]

val result: String = witness.value
```

This example doesn't look particularly interesting,
but note that we're extracting the value of `result`
from *the type of `fieldName`*, not its value.
If we combine `Witness` and `FieldType`,
we get something very compelling:
we're able to extract the name or value from a tagged field:

```tut:book
def getFieldValue[K, V](value: FieldType[K, V]): V =
  value

def getFieldName[K, V](value: FieldType[K, V])(implicit witness: Witness.Aux[K]): K =
  witness.value

getFieldValue(numCherries)

getFieldName(numCherries)
```

We've now covered everything we need to know about
literal types and type tagging.
With this knowledge in hand,
it's time to derive some type class instances using `LabelledGeneric`.