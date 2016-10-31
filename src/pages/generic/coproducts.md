## Deriving instances for coproducts {#sec:generic:coproducts}

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

The generic representation for `Shape`
is `Rectangle :+: Circle :+: CNil`.
We can write generic `CsvEncoders` for `:+:` and `CNil`
using the same principles we used for `HLists`.
Our existing product encoders
will take care of `Rectangle` and `Circle`:

```tut:book:silent
import shapeless.{Coproduct, :+:, CNil, Inl, Inr}

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(cnil => throw new Exception("Mass hysteria!"))

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

1. Alarmingly, the encoder for `CNil` throws an exception!
   Don't panic, though.
   Remember that we can't
   create values of type `CNil`.
   It's there as a marker for the compiler.
   It's ok to fail abruptly here because
   we will never reach this point.

2. Because `Coproducts` are *disjunctions* of types,
   the encoder for `:+:` has to *choose*
   whether to encode a left or right value.
   We pattern match on the two subtypes of `:+:` which are `Inl`
   for left and `Inr` for right.

With these definitions
and our product encoders from Section [@sec:generic:products],
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
The reason for the failure is
we don't have a `CsvEncoder` instance for `Double`:

```tut:book:silent
implicit val doubleEncoder: CsvEncoder[Double] =
  createEncoder(d => List(d.toString))
```

With this definition in place, everything works as expected:

```tut:book
writeCsv(shapes)
```

<div class="callout callout-warning">
  *Aligning CSV Output*

  Our CSV encoder isn't very practical in its current form.
  It allows fields from `Rectangle` and `Circle` to
  occupy the same columns in the output.
  To fix this problem we need to modify
  the definition of `CsvEncoder`
  to incorporate the width of the data type
  and space the output accordingly.
  We leave this as an exercise to the reader.
</div>
