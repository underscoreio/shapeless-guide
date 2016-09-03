## Deriving instances for coproducts

```tut:book:invisible
// ----------------------------------------------
// Forward definitions

trait CsvEncoder[A] {
  def encode(value: A): List[String]
}

def writeCsv[A](values: List[A])(implicit encoder: CsvEncoder[A]): String =
  values.map(encoder.encode).map(_.mkString(",")).mkString("\n")

def createEncoder[A](func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    def encode(value: A): List[String] =
      func(value)
  }

implicit val stringEncoder: CsvEncoder[String] =
  createEncoder(str => List(str))

implicit val intEncoder: CsvEncoder[Int] =
  createEncoder(num => List(num.toString))

implicit val booleanEncoder: CsvEncoder[Boolean] =
  createEncoder(bool => List(if(bool) "cone" else "glass"))

import shapeless.{HList, HNil, ::}

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(hnil => Nil)

implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] = createEncoder {
  case h :: t =>
    hEncoder.encode(h) ++ tEncoder.encode(t)
}

import shapeless.Generic

implicit def genericEncoder[A, R](
  implicit
  gen: Generic.Aux[A, R],
  rEncoder: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(value => rEncoder.encode(gen.to(value)))

// ----------------------------------------------
```

In the last section we created a set of rules
to automatically derive a `CsvEncoder` for any product type.
In this section we will apply the same patterns to coproducts.
Let's return to our shape ADT as an example:

```tut:book:silent
sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape
```

The generic representation for `Shape` is `Rectangle :+: Circle :+: CNil`.
We can write generic `CsvEncoders` for `:+:` and `CNil`
using the same principles we used for `HLists`.
Our existing encoders will take care of `Rectangle` and `Circle`:

```tut:book:silent
import shapeless.{Coproduct, :+:, CNil, Inl, Inr}

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(cnil => throw new Exception("Universe exploded! Abort!"))

implicit def coproductEncoder[H, T <: Coproduct](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :+: T] = createEncoder {
  case Inl(h) => hEncoder.encode(h)
  case Inr(t) => tEncoder.encode(t)
}
```

There are two key points of note:

1. Alarmingly, the encoder for `CNil` rather throws an exception!
   Don't panic, though.
   Remember that we can't actually create any values of type `CNil`.
   It's just there as a marker for the compiler.
   We're right to fail abruptly here because we should never reach this point.

2. Because `Coproducts` are *disjunctions* of types,
   the encoder for `:+:` has to *choose* whether to encode a left or right value.
   We pattern match on the two subtypes of `:+:`: `Inl` for left and `Inr` for right.

With these definitions and the definitions we wrote for product types,
we should be able to serialize a list of shapes.
Let's give it a try:

```tut:book:silent
val shapes: List[Shape] = List(
  Rectangle(3.0, 4.0),
  Circle(1.0)
)
```

```tut:book:fail
writeCsv(shapes)
```

Oh no, it failed!
The error message is unhelpful as we discussed earlier.
The reason for the failure is we don't have a `CsvEncoder` instance for `Double`.

```tut:book:silent
implicit val doubleEncoder: CsvEncoder[Double] =
  createEncoder(d => List(d.toString))
```

With this definition in place, everything works as expected:

```tut:book
writeCsv(shapes)
```

### Exercise: Aligning columns in CSV output

It would perhaps be better if we separated
the data for rectangles and circles into two separate sets of columns.
We can do this by adding a `width` field to `CsvEncoder`:

```tut:book:silent
trait CsvEncoder[A] {
  def width: Int
  def encode(value: A): List[String]
}
```

If we follow through with all of our definitions,
we can produce instances
that place each field in the ADT in a different column.
We will leave this as an exercise to the reader.

<div class="solution">
We start by modifying the definition of `createEncoder`
to accept a `width` parameter:

```tut:book:silent
def createEncoder[A](cols: Int)(func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    val width = cols
    def encode(value: A): List[String] =
      func(value)
  }
```

Then we modify our base encoders to each record a width of `1`:

```tut:book:silent
implicit val stringEncoder: CsvEncoder[String] =
  createEncoder(1)(str => List(str))

implicit val intEncoder: CsvEncoder[Int] =
  createEncoder(1)(num => List(num.toString))

implicit val booleanEncoder: CsvEncoder[Boolean] =
  createEncoder(1)(bool => List(if(bool) "cone" else "glass"))

implicit val doubleEncoder: CsvEncoder[Double] =
  createEncoder(1)(d => List(d.toString))
```

Our encoders for `HNil` and `CNil` have width `0` and our
encoders for `::` and `:+:` have a width determined by
the encoders for their heads and tails:

```tut:book:silent
import shapeless.{HList, HNil, ::}

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(0)(hnil => Nil)

implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] =
  createEncoder(hEncoder.width + tEncoder.width) {
    case h :: t =>
      hEncoder.encode(h) ++ tEncoder.encode(t)
  }
```

Our `:+:` encoder pads its output with a number of columns
equal to the width of the encoder it isn't using for serialization:

```tut:book:silent
import shapeless.{Coproduct, CNil, :+:, Inl, Inr}

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(0) { cnil =>
    throw new Exception("The impossible has happened!")
  }

implicit def coproductEncoder[H, T <: Coproduct](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :+: T] =
  createEncoder(hEncoder.width + tEncoder.width) {
    case Inl(h) => hEncoder.encode(h) ++ List.fill(tEncoder.width)("")
    case Inr(t) => List.fill(hEncoder.width)("") ++ tEncoder.encode(t)
  }
```

Finally, our ADT encoder mirrors the width of
the encoder for its generic representation:

```tut:book:silent
import shapeless.Generic

implicit def genericEncoder[A, R](
  implicit
  gen: Generic.Aux[A, R],
  lEncoder: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(lEncoder.width) { value =>
    lEncoder.encode(gen.to(value))
  }
```

With all these definitions in place,
our `writeCsv` method gains the ability to align its output correctly:

```tut:book:invisible
def writeCsv[A](values: List[A])(implicit encoder: CsvEncoder[A]): String =
  values.map(encoder.encode).map(_.mkString(",")).mkString("\n")
```

```tut:book
writeCsv(shapes)
```
</div>
