## Deriving coproduct instances with *LabelledGeneric*

```tut:book:invisible:reset
// ----------------------------------------------
// Forward definitions:

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

object JsonEncoder {
  def apply[A](implicit enc: JsonEncoder[A]): JsonEncoder[A] =
    enc
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

trait JsonObjectEncoder[A] extends JsonEncoder[A] {
  def encode(value: A): JsonObject
}

def createObjectEncoder[A](func: A => JsonObject): JsonObjectEncoder[A] =
  new JsonObjectEncoder[A] {
    def encode(value: A): JsonObject =
      func(value)
  }

import shapeless.{HList, ::, HNil, Witness, Lazy}
import shapeless.labelled.FieldType

implicit val hnilObjectEncoder: JsonObjectEncoder[HNil] =
  createObjectEncoder(hnil => JsonObject(Nil))

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

import shapeless.LabelledGeneric

implicit def genericObjectEncoder[A, H](
  implicit
  generic: LabelledGeneric.Aux[A, H],
  hEncoder: Lazy[JsonObjectEncoder[H]]
): JsonObjectEncoder[A] =
  createObjectEncoder(value => hEncoder.value.encode(generic.to(value)))

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape

// ----------------------------------------------
```

Applying `LabelledGeneric` with `Coproducts`
involves a mixture of the concepts we've covered already.
Let's start by examining
a `Coproduct` type derived by `LabelledGeneric`.
We'll re-visit our `Shape` ADT from Chapter [@sec:generic]:

```tut:book:silent
import shapeless.LabelledGeneric

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape
```

```tut:book
LabelledGeneric[Shape].to(Circle(1.0))
```

Here is that `Coproduct` type in a more readable format:

```scala
// Rectangle with KeyTag[Symbol with Tagged["Rectangle"], Rectangle] :+:
// Circle    with KeyTag[Symbol with Tagged["Circle"],    Circle]    :+:
// CNil
```

As you can see, the result is a `Coproduct` of the subtypes of `Shape`,
each tagged with the type name.
We can use this information to write `JsonEncoders` for `:+:` and `CNil`:

```tut:book:silent
import shapeless.{Coproduct, :+:, CNil, Inl, Inr, Witness, Lazy}
import shapeless.labelled.FieldType

implicit val cnilObjectEncoder: JsonObjectEncoder[CNil] =
  createObjectEncoder(cnil => throw new Exception("Inconceivable!"))

implicit def coproductObjectEncoder[K <: Symbol, H, T <: Coproduct](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonObjectEncoder[T]
): JsonObjectEncoder[FieldType[K, H] :+: T] = {
  val typeName = witness.value.name
  createObjectEncoder {
    case Inl(h) =>
      JsonObject(List(typeName -> hEncoder.value.encode(h)))

    case Inr(t) =>
      tEncoder.encode(t)
  }
}
```

`coproductEncoder` follows the same pattern as `hlistEncoder`.
We have three type parameters:
`K` for the type name,
`H` for the value at the head of the `HList`,
and `T` for the value at the tail.
We use `FieldType` and `:+:` in the result type
to declare the relationships between the three,
and we use a `Witness` to access the runtime value of the type name.
The result is an object containing a single key/value pair,
the key being the type name and the value the result:

```tut:book:silent
val shape: Shape = Circle(1.0)
```

```tut:book
JsonEncoder[Shape].encode(shape)
```

Other encodings are possible with a little more work.
We can add a `"type"` field to the output, for example,
or even allow the user to configure the format.
Sam Halliday's [spray-json-shapeless][link-spray-json-shapeless]
is an excellent example of a codebase
that is approachable while providing a great deal of flexibility.
