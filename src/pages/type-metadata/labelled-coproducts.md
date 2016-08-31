## Deriving coproduct instances with *LabelledGeneric*

Applying `LabelledGeneric` with `Coproducts`
involves a mixture of the concepts we've covered in the last two chapters.
Let's start by examining a `Coproduct` type derived by `LabelledGeneric`.
We'll re-visit our `Shape` ADT from last chapter:

```tut:book
import shapeless.LabelledGeneric

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape

LabelledGeneric[Shape].to(Circle(1.0))
```

Here is that `Coproduct` type in a more readable format:

```scala
import shapeless.{Coproduct, :+:, CNil},
       shapeless.labelled.KeyTag,
       shapeless.tag.Tagged

// Note: this won't actually compile because of the singleton types:
type Repr =
  Rectangle with KeyTag[Symbol with Tagged[String("Rectangle")], Rectangle] :+:
  Circle    with KeyTag[Symbol with Tagged[String("Circle")],    Circle]    :+:
  CNil
```

As you can see, the result is a `Coproduct` of the subtypes of `Shape`,
each tagged with the type name.
We can use this information to write `JsonEncoders` for `:+:` and `CNil`:

```tut:book:invisible:reset
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

import shapeless.{HList, ::, HNil, Witness, Lazy},
       shapeless.labelled.FieldType

implicit val hnilEncoder: JsonEncoder[HNil] =
  createEncoder(hnil => JsonObject(Nil))

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

import shapeless.LabelledGeneric

implicit def genericEncoder[A, H](
  implicit
  generic: LabelledGeneric.Aux[A, H],
  hEncoder: Lazy[JsonEncoder[H]]
): JsonEncoder[A] =
  createEncoder(value => hEncoder.value.encode(generic.to(value)))

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape
```

```tut:book
import shapeless.{Coproduct, :+:, CNil, Inl, Inr, Witness, Lazy},
       shapeless.labelled.FieldType

implicit val cnilEncoder: JsonEncoder[CNil] =
  createEncoder(cnil => throw new Exception("Should not get here"))

implicit def coproductEncoder[K <: Symbol, H, T <: Coproduct](
  implicit
  witness: Witness.Aux[K],
  hEncoder: Lazy[JsonEncoder[H]],
  tEncoder: JsonEncoder[T]
): JsonEncoder[FieldType[K, H] :+: T] = {
  val typeName = witness.value.name
  createEncoder {
    case Inl(h) => JsonObject(List(typeName -> hEncoder.value.encode(h)))
    case Inr(t) => tEncoder.encode(t)
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
and we use a `Witness` to access the runtime value of the type name:
The result is an object containing a single key/value pair.
The key is the type name and the value is the result:

```tut:book
val shape: Shape = Circle(1.0)

implicitly[JsonEncoder[Shape]].encode(shape)
```
