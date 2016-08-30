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
In this section we will generalise our code
to work with coproducts as well as products.

Let's return to our shape ADT as an example:

```tut:book
sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape
```

Shapeless' generic representation for `Shape` is
`Rectangle :+: Circle :+: CNil`.
If we can write generic `CsvEncoders` for `:+:` and `CNil`,
our existing `hlistEncoder`, `hnilEncoder`, and `genericEncoder`
will take care of the rest.

We haven't serialized any fields of type `Double` yet,
so before we get started we'll create an additional `CsvEncoder[Double]`:

```tut:book
implicit val doubleEncoder: CsvEncoder[Double] =
  createEncoder(d => List(d.toString))
```

### Instances for generic *Coproducts*

We can write generic encoders for `Coproducts`
using the same technique we used for `HLists`,
by defining cases for `:+:` and `CNil`:

```tut:book
import shapeless.{Coproduct, :+:, CNil, Inl, Inr}

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(cnil => throw new Exception("The impossible has happened!"))

implicit def coproductEncoder[H, T <: Coproduct](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :+: T] =
  createEncoder {
    case Inl(h) => hEncoder.encode(h)
    case Inr(t) => tEncoder.encode(t)
  }
```

There are two key differences
between the encoders for `HList` and the encoders for `Coproduct`.
First, the encoder for `CNil` rather alarmingly throws an exception.
Remember that we can't actually create any values of type `CNil`---it's
just there as a marker for the compiler.
We're free to do odd things like throw exceptions without
worrying about runtime exceptions.
Second, because `Coproducts` are *disjunctions* of types,
the encoder for `:+:` has to *choose* whether to encode a left or right value.

With these definitions and the definitions we wrote for product types,
we can serialize any shape instance to CSV.
If we encounter a rectangle, we get two figures in the output.
If we encounter a circle, we get one[^better-csv-encodings].

```tut:book
val shapes: List[Shape] =
  List(Rectangle(3.0, 4.0), Circle(1.0))

writeCsv[Shape](shapes)
```

### Exercise: Aligning columns in CSV output

It would perhaps be better if we separated
the data for rectangles and circles into two separate sets of columns.
We can do this by adding a `width` field to `CsvEncoder`:

```tut:book
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

```tut:book
def createEncoder[A](cols: Int)(func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    val width = cols
    def encode(value: A): List[String] =
      func(value)
  }
```

Then we modify our base encoders to each record a width of `1`:

```tut:book
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

```tut:book
import shapeless.{HList, HNil, ::}

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(0)(hnil => Nil)

implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] = createEncoder(hEncoder.width + tEncoder.width) {
  case h :: t =>
    hEncoder.encode(h) ++ tEncoder.encode(t)
}
```

Our `:+:` encoder pads its output with a number of columns
equal to the width of the encoder it isn't using for serialization:

```tut:book
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

```tut:book
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
