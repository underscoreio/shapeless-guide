## Deriving product instances with *LabelledGeneric*

We'll use a running example of JSON encoding to illustrate `LabelledGeneric`.
Imagine a `JsonEncoder` type class that converts values to a JSON AST.
This is the approach taken by [argonaut][link-argonaut], [circe][link-circe],
[play-json][link-play-json], [spray-json][link-spray-json],
and every other Scala JSON library out there:

```tut:book:silent
sealed trait JsonValue
final case class JsonObject(fields: List[(String, JsonValue)]) extends JsonValue
final case class JsonArray(items: List[JsonValue]) extends JsonValue
final case class JsonString(value: String) extends JsonValue
final case class JsonNumber(value: Double) extends JsonValue
final case class JsonBoolean(value: Boolean) extends JsonValue
case object JsonNull extends JsonValue

trait JsonEncoder[A] {
  def encode(value: A): JsonValue
}

def createEncoder[A](func: A => JsonValue): JsonEncoder[A] =
  new JsonEncoder[A] {
    def encode(value: A): JsonValue =
      func(value)
  }

implicit val stringEncoder: JsonEncoder[String] =
  createEncoder(str => JsonString(str))

implicit val doubleEncoder: JsonEncoder[Double] =
  createEncoder(num => JsonNumber(num))

implicit val intEncoder: JsonEncoder[Int] =
  createEncoder(num => JsonNumber(num))

implicit val booleanEncoder: JsonEncoder[Boolean] =
  createEncoder(bool => JsonBoolean(bool))

implicit def listEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[List[A]] =
  createEncoder(list => JsonArray(list.map(encoder.encode)))

implicit def optionEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[Option[A]] =
  createEncoder(opt => opt.map(encoder.encode).getOrElse(JsonNull))
```

We can easily define instances of `JsonEncoder`
for basic types like `Strings`, `Ints`, and `Lists`,
but when it comes to serializing case classes
we'd ideally like to use the names of the fields
in the resulting JSON object:

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

```tut:book
import shapeless.LabelledGeneric

LabelledGeneric[IceCream].to(iceCream)
```

For those of you who can't read off the right hand side of the page,
the full type of the `HList` is:

```scala
import shapeless.{HList, ::, HNil},
       shapeless.labelled.KeyTag,
       shapeless.tag.Tagged

// Note: this won't actually compile because of the singleton types:
type Repr =
  String  with KeyTag[Symbol with Tagged[String("name")], String]     ::
  Int     with KeyTag[Symbol with Tagged[String("numCherries")], Int] ::
  Boolean with KeyTag[Symbol with Tagged[String("inCone")], Boolean]  ::
  HNil
```

The type here is slightly more complex than we have seen.
Instead of representing the field names with literal string types,
shapeless is representing them with symbols tagged with literal string types.
The details of the implementation aren't particularly important.
The key point is that we can use `Witness` and `FieldType`
to extract the information we need for our JSON encoders.
The definition of `hnilEncoder` is straightfoward:

```tut:book
import shapeless.{HList, ::, HNil, Lazy}

implicit val hnilEncoder: JsonEncoder[HNil] =
  createEncoder(hnil => JsonObject(Nil))
```

The definition of `hlistEncoder` involves a few moving parts
so we'll go through it piece by piece.
We'll start with the definition we might expect
if we were using regular `Generic`:

```tut:book
implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[H :: T] = ???
```

`LabelledGeneric` is going to give us an `HList` of tagged types,
so let's start by introducing a new type variable for the key type:

```tut:book
import shapeless.Witness,
       shapeless.labelled.FieldType

implicit def hlistEncoder[K, H, T <: HList](
  implicit
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[FieldType[K, H] :: T] = ???
```

In the body of our method
we're going to need to get the value associated with `K`.
We'll add an implicit `Witness[K]` to do this for us:

```tut:book
implicit def hlistEncoder[K, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[FieldType[K, H] :: T] = {
  val fieldName = witness.value
  ???
}
```

We can access the value of `K` using `witness.value`,
but the compiler has no way of knowing what type of tag we're going to get.
`LabelledGeneric` uses `Symbols` as the tag types,
so we'll put a type bound on `K`
and use `symbol.name` to convert it to a `String`:

```tut:book
implicit def hlistEncoder[K <: Symbol, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[FieldType[K, H] :: T] = {
  val fieldName: String = witness.value.name
  ???
}
```

This gives us the field name we need to write our encoder.
The rest of the definition uses
the principles we covered in the previous chapter:

```tut:book
implicit def hlistEncoder[K <: Symbol, H, T <: HList](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[FieldType[K, H] :: T] = {
  val fieldName: String = witness.value.name
  createEncoder { hlist =>
    val head: JsonValue = hEncoder.value.encode(hlist.head)
    val tail: JsonValue = tEncoder.encode(hlist.tail)
    JsonObject((fieldName, head) :: tail.asInstanceOf[JsonObject].fields)
  }
}
```

Note the `asInstanceOf` in the code.
This is an artefact of the way we have defined `JsonEncoder`:
it encodes to a `JsonValue` and not a `JsonObject`.
It isn't something we'd want in production code
but it is fine for this example.
We could eliminate it by introducing a `JsonObjectEncoder`
in addition to `JsonEncoder` and updating our definitions accordingly.

Finally let's turn to our `JsonEncoder` for case classes.
This is identical to the definitions we've seen before,
except that we're using `LabelledGeneric` instead of `Generic`.
Without `LabelledGeneric`
we wouldn't have the tags needed to use `hlistEncoder`:

```tut:book
import shapeless.LabelledGeneric

implicit def genericEncoder[A, H <: HList](
  implicit
  generic: LabelledGeneric.Aux[A, H],
  hEncoder: Lazy[JsonEncoder[H]]
): JsonEncoder[A] =
  createEncoder(value => hEncoder.value.encode(generic.to(value)))
```

And that's all we need!
With these definitions in place
we can serialize instances of any case class
and retain the field names in the resulting JSON:

```tut:book
implicitly[JsonEncoder[IceCream]].encode(iceCream)
```

<div class="callout callout-danger">
  TODO: Produce set of rules of thumb for how to write implicit methods like this:

  - declare all your type variables as free variables first;
  - order your implicits to give the compiler as little work to do on each one (left to right)
  - any more?
</div>
