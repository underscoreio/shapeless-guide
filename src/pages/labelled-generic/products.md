## Deriving product instances with *LabelledGeneric*

We'll use a running example of JSON encoding
to illustrate `LabelledGeneric`.
We'll define a `JsonEncoder` type class
that converts values to a JSON AST.
This is the approach taken by
Argonaut, Circe, Play JSON, Spray JSON,
and many other Scala JSON libraries.

First we'll define our JSON data type:

```tut:book:silent
sealed trait JsonValue
case class JsonObject(fields: List[(String, JsonValue)]) extends JsonValue
case class JsonArray(items: List[JsonValue]) extends JsonValue
case class JsonString(value: String) extends JsonValue
case class JsonNumber(value: Double) extends JsonValue
case class JsonBoolean(value: Boolean) extends JsonValue
case object JsonNull extends JsonValue
```

then the type class for encoding values as JSON:

```tut:book:silent
trait JsonEncoder[A] {
  def encode(value: A): JsonValue
}

object JsonEncoder {
  def apply[A](implicit enc: JsonEncoder[A]): JsonEncoder[A] = enc
}
```

then a few primitive instances:

```tut:book:silent
def createEncoder[A](func: A => JsonValue): JsonEncoder[A] =
  new JsonEncoder[A] {
    def encode(value: A): JsonValue = func(value)
  }

implicit val stringEncoder: JsonEncoder[String] =
  createEncoder(str => JsonString(str))

implicit val doubleEncoder: JsonEncoder[Double] =
  createEncoder(num => JsonNumber(num))

implicit val intEncoder: JsonEncoder[Int] =
  createEncoder(num => JsonNumber(num))

implicit val booleanEncoder: JsonEncoder[Boolean] =
  createEncoder(bool => JsonBoolean(bool))
```

and a few instance combinators:

```tut:book:silent
implicit def listEncoder[A]
    (implicit enc: JsonEncoder[A]): JsonEncoder[List[A]] =
  createEncoder(list => JsonArray(list.map(enc.encode)))

implicit def optionEncoder[A]
    (implicit enc: JsonEncoder[A]): JsonEncoder[Option[A]] =
  createEncoder(opt => opt.map(enc.encode).getOrElse(JsonNull))
```

Ideally, when we encode ADTs as JSON,
we would like to use the correct field names in the output JSON:

```tut:book:silent
case class IceCream(name: String, numCherries: Int, inCone: Boolean)

val iceCream = IceCream("Sundae", 1, false)

// Ideally we'd like to produce something like this:
val iceCreamJson: JsonValue =
  JsonObject(List(
    "name"        -> JsonString("Sundae"),
    "numCherries" -> JsonNumber(1),
    "inCone"      -> JsonBoolean(false)
  ))
```

This is where `LabelledGeneric` comes in.
Let's summon an instance for `IceCream`
and see what kind of representation it produces:

```tut:book:silent
import shapeless.LabelledGeneric
```

```tut:book
val gen = LabelledGeneric[IceCream].to(iceCream)
```

For clarity, the full type of the `HList` is:

```scala
// String  with KeyTag[Symbol with Tagged["name"], String]     ::
// Int     with KeyTag[Symbol with Tagged["numCherries"], Int] ::
// Boolean with KeyTag[Symbol with Tagged["inCone"], Boolean]  ::
// HNil
```

The type here is slightly more complex than we have seen.
Instead of representing the field names with literal string types,
shapeless is representing them with symbols tagged with literal string types.
The details of the implementation aren't particularly important:
we can still use `Witness` and `FieldType` to extract the tags,
but they come out as `Symbols` instead of `Strings`[^future-tags].

[^future-tags]: Future versions of shapeless may switch
to using `Strings` as tags.

### Instances for *HLists*

Let's define `JsonEncoder` instances for `HNil` and `::`.
Our encoders are going to generate and manipulate `JsonObjects`,
so we'll introduce a new type of encoder to make that easier:

```tut:book:silent
trait JsonObjectEncoder[A] extends JsonEncoder[A] {
  def encode(value: A): JsonObject
}

def createObjectEncoder[A](fn: A => JsonObject): JsonObjectEncoder[A] =
  new JsonObjectEncoder[A] {
    def encode(value: A): JsonObject =
      fn(value)
  }
```

The definition for `HNil` is then straightforward:

```tut:book:silent
import shapeless.{HList, ::, HNil, Lazy}

implicit val hnilEncoder: JsonObjectEncoder[HNil] =
  createObjectEncoder(hnil => JsonObject(Nil))
```

The definition of `hlistEncoder` involves a few moving parts
so we'll go through it piece by piece.
We'll start with the definition we might expect
if we were using regular `Generic`:

```tut:book:silent
implicit def hlistObjectEncoder[H, T <: HList](
  implicit
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonEncoder[H :: T] = ???
```

`LabelledGeneric` will give us an `HList` of tagged types,
so let's start by introducing a new type variable for the key type:

```tut:book:silent
import shapeless.Witness
import shapeless.labelled.FieldType

implicit def hlistObjectEncoder[K, H, T <: HList](
  implicit
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonObjectEncoder[FieldType[K, H] :: T] = ???
```

In the body of our method
we're going to need the value associated with `K`.
We'll add an implicit `Witness` to do this for us:

```tut:book:silent
implicit def hlistObjectEncoder[K, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonObjectEncoder[FieldType[K, H] :: T] = {
  val fieldName = witness.value
  ???
}
```

We can access the value of `K` using `witness.value`,
but the compiler has no way of knowing
what type of tag we're going to get.
`LabelledGeneric` uses `Symbols` for tags,
so we'll put a type bound on `K`
and use `symbol.name` to convert it to a `String`:

```tut:book:silent
implicit def hlistObjectEncoder[K <: Symbol, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonObjectEncoder[FieldType[K, H] :: T] = {
  val fieldName: String = witness.value.name
  ???
}
```

The rest of the definition uses
the principles we covered in Chapter [@sec:generic]:

```tut:book:silent
implicit def hlistObjectEncoder[K <: Symbol, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonObjectEncoder[FieldType[K, H] :: T] = {
  val fieldName: String = witness.value.name
  createObjectEncoder { hlist =>
    val head = hEncoder.value.encode(hlist.head)
    val tail = tEncoder.encode(hlist.tail)
    JsonObject((fieldName, head) :: tail.fields)
  }
}

```

### Instances for concrete products

Finally let's turn to our generic instance.
This is identical to the definitions we've seen before,
except that we're using `LabelledGeneric` instead of `Generic`:

```tut:book:silent
import shapeless.LabelledGeneric

implicit def genericObjectEncoder[A, H](
  implicit
  generic: LabelledGeneric.Aux[A, H],
  hEncoder: Lazy[JsonObjectEncoder[H]]
): JsonEncoder[A] =
  createObjectEncoder { value =>
    hEncoder.value.encode(generic.to(value))
  }
```

And that's all we need!
With these definitions in place
we can serialize instances of any case class
and retain the field names in the resulting JSON:

```tut:book
JsonEncoder[IceCream].encode(iceCream)
```
