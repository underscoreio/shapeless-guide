## Deriving instances for products

In this section we're going to use shapeless
to derive type class instances for product types
using two main intuitions:

1. If we can derive aninstance for the `HList` encoding of a product,
   we can derive an instance for the product itself
   using its `Generic` to convert back and forth.

2. If we can derive a type class instance for the head and tail of an `HList`,
   we can derive an instance for the whole `HList`.

When read one way, these intuitions show us that
we can construct a type class instance for a given case class
from a number of very small building blocks.
When read the opposite way, the small building blocks
can be assembled in many different combinations to provide
instances for a wide range of case classes.
Let's take our `CsvEncoder` type class and `IceCream` type as an example:

```tut:book
trait CsvEncoder[A] {
  def encode(value: A): List[String]
}

def writeCsv[A](values: List[A])(implicit encoder: CsvEncoder[A]): String =
  values.map(encoder.encode).map(_.mkString(",")).mkString("\n")

case class IceCream(name: String, numCherries: Int, inCone: Boolean)

val iceCreams = List(
  IceCream("Sundae", 1, false),
  IceCream("Cornetto", 0, true),
  IceCream("Banana Split", 0, false)
)
```

`IceCream` has a generic `Repr` of type
`String :: Int :: Boolean :: HNil`.
According to our first intuition above,
we can derive a `CsvEncoder` for `IceCream`
by deriving an encoder for this `HList` type.

The `HList` in turn is made up of three pairs,
a `String`, an `Int`, a `Boolean`, and an `HNil`.
If we create `CsvEncoders` for these types,
the compiler should be able to derive `CsvEncoders`
for our `HList`, for `IceCream`,
and for any case class involving
combinations of `Strings`, `Ints`, and/or `Booleans`.

### Deriving instances for *HLists*

Let's start by building a library of `CsvEncoders`
for the three field types in our `IceCream`:
`String`, `Int`, and `Boolean`.
We'll be writing a lot of encoder instances
so we'll define a helper method to keep our code concise:

```tut:book
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
```

Our next job is to combine these buildign blocks to create
an encoder for our `HList`.
We can do this with two rules: one for an empty `HList`
and one for a non-empty `HList` with a head and a tail
(colloquially referred to as a "cons cell", a term borrowed from Lisp):

```tut:book
import shapeless.{HList, HNil, ::}

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(hnil => Nil)

implicit def hconsEncoder[H, T <: HList](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] = createEncoder {
  case h :: t =>
    hEncoder.encode(h) ++ tEncoder.encode(t)
}
```

Given these rules, we can define a `CsvEncoder`
for the generic form of `IceCream`:

```tut:book
val iceCreamHlistEncoder: CsvEncoder[String :: Int :: Boolean :: HNil] =
  implicitly

iceCreamHlistEncoder.encode("Cherry Garcia" :: 1000 :: false :: HNil)
```

Perhaps more importantly,
we can also create encoders for any `HList` involving
`Strings`, `Ints`, and/or `Booleans`:

```
val encoder1 = implicitly[CsvEncoder[Int :: Boolean :: Int :: Boolean :: HNil]]
val encoder2 = implicitly[CsvEncoder[Boolean :: String :: String :: HNil]]
val encoder3 = implicitly[CsvEncoder[Int :: HNil]]
// and so on...
```

### Converting instances for *HList* instances for case classes

Our `iceCreamHlistEncoder` from the previous section
gets us almost all the way towards an actual encoder for `IceCream`.
All we need to do is combine it with the `Generic` for `IceCream`.
Here is an example that suits our particular use case:

```tut:book
import shapeless.Generic

implicit val iceCreamEncoder: CsvEncoder[IceCream] = {
  createEncoder { iceCream =>
    val hlist = Generic[IceCream].to(iceCream)
    iceCreamHlistEncoder.encode(hlist)
  }
}

writeCsv(iceCreams)
```

Note that we can summon instances of `Generic`
implicitly without defining them first.
Shapeless provides a default implementation of `Generic` via an implicit macro,
that works for any family of sealed traits and case classes,
so unless we need to explicitly override the default behaviour of the type class
we never need to summon


Ideally we'd like to rewrite `iceCreamEncoder` to work for
any type `A` that has a `Generic[A]`.
If we can do this,
we can derive `CsvEncoders` for other case classes as well.
However, if we try to write this code we find we have a problem:

```scala
// This code will not compile:
implicit def genericEncoder[A](
  implicit
  gen: Generic[A],
  hlistEncoder: CsvEncoder[???]
): CsvEncoder[A] =
  createEncoder(value => hlistEncoder.encode(gen.to(value)))
```

The problem is, we have to refer to the type of `gen.Repr` in the method signature.
We don't have a type to put in place of the `???` in the example.

To resolve this problem
we have to define the `HList` type in the method signature
and explicitly reference it in the definitions of `gen` and `hlistEncoder`.
This produces some unsightly syntax
because `Repr` is defined as a type member on generic, not a type parameter:

```tut:book
implicit def genericEncoder[A, R <: HList](
  implicit
  gen: Generic[A] { type Repr = R },
  hlistEncoder: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(value => hlistEncoder.encode(gen.to(value)))
```

Fortunately, shapeless defines a convenient type alias `Generic.Aux`
that restates `Repr` as a type parameter:

```scala
package shapeless

object Generic {
  type Aux[A, R] = Generic[A] { type Repr = R }
}
```

allowing a much more visually appealing definition
in the final version of our code:

```tut:book
implicit def genericEncoder[A, R <: HList](
  implicit
  gen: Generic.Aux[A, R],
  hlistEncoder: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(value => hlistEncoder.encode(gen.to(value)))
```

Intuitively, this definition says:
"Given a type `A` and an `HList` type `R`,
I can summon a `CsvEncoder` for `A`
as long as the compiler can
find a `CsvEncoder` for `R`
and a `Generic` that maps `A` to `R`."
We can use the method in our code as follows:

```tut:book
writeCsv(iceCreams)
```

which the compiler expands to:

```scala
writeCsv(iceCreams)(
  genericEncoder(
    implicitly[Generic[IceCream]],
    implicitly[CsvEncoder[gen.Repr]]
  )
)
```

and then to:

```scala
writeCsv(iceCreams)(
  genericEncoder(
    Generic[IceCream],
    hconsEncoder(stringEncoder,
      hconsEncoder(intEncoder,
        hconsEncoder(booleanEncoder, hnilEncoder)))
  )
)
```

all without us having to lift a finger.
The same code works for any type
that has an instance of `Generic` and a compatible `CsvEncoder`.
In other words we can now serialize
any case class with fields of type `String`, `Int`, or `Boolean`,
all without a single additional line of code:

```tut:book
case class Coord(x: Int, y: Int)

writeCsv(List(Coord(0, 2), Coord(2, 0), Coord(6, 4)))
```

### So what are the downsides?

If all of the above seems pretty magical,
allow me to provide one significant dose of reality.
If things go wrong, the compiler isn't great at telling us why.

There are two main situations where the code above could fail.
The first is when we can't find an implicit `Generic` for our type:

```tut:book
// This isn't a case class, so there is no default Generic for it:
class Foo(val bar: String, val baz: Int)

writeCsv(List(new Foo("abc", 123)))
```

The error message here is relatively easy to understand:
if shapeless we can't calculate a `Generic` it means that
the type in question isn't an ADT---somewhere in the algebra
there is a type that isn't a case class or a sealed abstract type.

The other potential source of failure occurs
when the compiler can't calculate a `CsvEncoder` for our `HList`.
This normally happens because
we don't have an encoder for one of the fields in our ADT:

```tut:book
import java.util.Date

case class Booking(room: String, date: Date)
```

```tut:book:fail
writeCsv(List(Booking("Lecture hall", new Date())))
```

The good news is that the code doesn't compile---we won't
accidentally deploy an application that fails at runtime.
The bad news is that we aren't told *why* it doesn't compile.
Implicit resolution is a heuristic search process:
the compiler tries many different combinations of the
`implicit vals` and `implicit defs` it has at its disposal
to produce a `CsvWriter` for the relevant `HList`.
It either finds a compatible combination or it doesn't.
If resolution fails it has no idea which combination
came closest to the desired result,
so it can't tell us where the source(s) of failure lie.
