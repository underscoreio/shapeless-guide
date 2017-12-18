## Deriving instances for products {#sec:generic:products}

In this section we're going to use shapeless
to derive type class instances for product types
(i.e. case classes).
We'll use two intuitions:

1. If we have type class instances
   for the head and tail of an `HList`,
   we can derive an instance for the whole `HList`.

2. If we have a case class `A`, a `Generic[A]`,
   and a type class instance for the generic's `Repr`,
   we can combine them to create an instance for `A`.

Take `CsvEncoder` and `IceCream` as examples:

 - `IceCream` has a generic `Repr` of type
   `String :: Int :: Boolean :: HNil`.

 - The `Repr` is made up of
   a `String`, an `Int`, a `Boolean`, and an `HNil`.
   If we have `CsvEncoders` for these types,
   we can create an encoder for the whole thing.

 - If we can derive a `CsvEncoder` for the `Repr`,
   we can create one for `IceCream`.

```tut:book:invisible
// ----------------------------------------------
// Forward definitions

trait CsvEncoder[A] {
  def encode(value: A): List[String]
}

object CsvEncoder {
  def apply[A](implicit enc: CsvEncoder[A]): CsvEncoder[A] =
    enc
}

def writeCsv[A](values: List[A])(implicit encoder: CsvEncoder[A]): String =
  values.map(encoder.encode).map(_.mkString(",")).mkString("\n")

case class IceCream(name: String, numCherries: Int, inCone: Boolean)

val iceCreams: List[IceCream] = List(
  IceCream("Sundae", 1, false),
  IceCream("Cornetto", 0, true),
  IceCream("Banana Split", 0, false)
)

case class Employee(name: String, number: Int, manager: Boolean)

val employees: List[Employee] = List(
  Employee("Bill", 1, true),
  Employee("Peter", 2, false),
  Employee("Milton", 3, false)
)
// ----------------------------------------------
```

### Instances for *HLists*

Let's start by defining an instance constructor
and `CsvEncoders` for `String`, `Int`, and `Boolean`:

```tut:book:silent
def createEncoder[A](func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    def encode(value: A): List[String] = func(value)
  }

implicit val stringEncoder: CsvEncoder[String] =
  createEncoder(str => List(str))

implicit val intEncoder: CsvEncoder[Int] =
  createEncoder(num => List(num.toString))

implicit val booleanEncoder: CsvEncoder[Boolean] =
  createEncoder(bool => List(if(bool) "yes" else "no"))
```

We can combine these building blocks
to create an encoder for our `HList`.
We'll use two rules:
one for `HNil` and one for `::` as shown below:

```tut:book:silent
import shapeless.{HList, ::, HNil}

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(hnil => Nil)

implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: CsvEncoder[H],
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] =
  createEncoder {
    case h :: t =>
      hEncoder.encode(h) ++ tEncoder.encode(t)
  }
```

Taken together, these five instances
allow us to summon `CsvEncoders` for any `HList`
involving `Strings`, `Ints`, and `Booleans`:

```tut:book:silent
val reprEncoder: CsvEncoder[String :: Int :: Boolean :: HNil] =
  implicitly
```

```tut:book
reprEncoder.encode("abc" :: 123 :: true :: HNil)
```

### Instances for concrete products {#sec:generic:product-generic}

We can combine our derivation rules for `HLists`
with an instance of `Generic`
to produce a `CsvEncoder` for `IceCream`:

```tut:book:silent
import shapeless.Generic

implicit val iceCreamEncoder: CsvEncoder[IceCream] = {
  val gen = Generic[IceCream]
  val enc = CsvEncoder[gen.Repr]
  createEncoder(iceCream => enc.encode(gen.to(iceCream)))
}
```

and use it as follows:

```tut:book
writeCsv(iceCreams)
```

This solution is specific to `IceCream`.
Ideally we'd like to have a single rule
that handles all case classes
that have a `Generic` and a matching `CsvEncoder`.
Let's work through the derivation step by step.
Here's a first cut:

```scala
implicit def genericEncoder[A](
  implicit
  gen: Generic[A],
  enc: CsvEncoder[???]
): CsvEncoder[A] = createEncoder(a => enc.encode(gen.to(a)))
```

The first problem we have is
selecting a type to put in place of the `???`.
We want to write the `Repr` type associated with `gen`,
but we can't do this:

```tut:book:fail
implicit def genericEncoder[A](
  implicit
  gen: Generic[A],
  enc: CsvEncoder[gen.Repr]
): CsvEncoder[A] =
  createEncoder(a => enc.encode(gen.to(a)))
```

The problem here is a scoping issue:
we can't refer to a type member of one parameter
from another parameter in the same block.
The trick to solving this is
to introduce a new type parameter to our method
and refer to it in each of the associated value parameters:

```tut:book:silent
implicit def genericEncoder[A, R](
  implicit
  gen: Generic[A] { type Repr = R },
  enc: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(a => enc.encode(gen.to(a)))
```

We'll cover this coding style in more detail in the next chapter.
Suffice to say, this definition now compiles and works as expected
and we can use it with any case class as expected.
Intuitively, this definition says:

> *Given a type `A` and an `HList` type `R`,
> an implicit `Generic` to map `A` to `R`,
> and a `CsvEncoder` for `R`,
> create a `CsvEncoder` for `A`.*

We now have a complete system that handles any case class.
The compiler expands a call like:

```tut:book:silent
writeCsv(iceCreams)

```

to use our family of derivation rules:

```tut:book:silent
writeCsv(iceCreams)(
  genericEncoder(
    Generic[IceCream],
    hlistEncoder(stringEncoder,
      hlistEncoder(intEncoder,
        hlistEncoder(booleanEncoder, hnilEncoder)))))
```

and can infer the correct expansions
for many different product types.
I'm sure you'll agree,
it's nice not to have to write this code by hand!

<div class="callout callout-info">
*Aux type aliases*

Type refinements like `Generic[A] { type Repr = L }`
are verbose and difficult to read,
so shapeless provides a type alias `Generic.Aux`
to rephrase the type member as a type parameter:

```scala
package shapeless

object Generic {
  type Aux[A, R] = Generic[A] { type Repr = R }
}
```

Using this alias we get a much more readable definition:

```tut:book:silent
implicit def genericEncoder[A, R](
  implicit
  gen: Generic.Aux[A, R],
  env: CsvEncoder[R]
): CsvEncoder[A] =
  createEncoder(a => env.encode(gen.to(a)))
```

Note that the `Aux` type isn't changing any semantics---it's
just making things easier to read.
This "`Aux` pattern" is used frequently
in the shapeless codebase.
</div>

### So what are the downsides?

If all of the above seems pretty magical,
allow us to provide one significant dose of reality.
If things go wrong, the compiler isn't great at telling us why.

There are two main reasons the code above might fail to compile.
The first is when the compiler can't find
an instance of `Generic`.
For example, here we try to call `writeCsv`
with a non-case class:

```tut:book:silent
class Foo(bar: String, baz: Int)
```

```tut:book:fail
writeCsv(List(new Foo("abc", 123)))
```

In this case the error message is relatively easy to understand.
If shapeless can't calculate a `Generic`
it means that the type in question isn't an ADT---somewhere
in the algebra there is a type that isn't a case class
or a sealed abstract type.

The other potential source of failure
is when the compiler can't calculate
a `CsvEncoder` for our `HList`.
This normally happens because we don't have
an encoder for one of the fields in our ADT.
For example, we haven't yet defined
a `CsvEncoder` for `java.util.Date`,
so the following code fails:

```tut:book:silent
import java.util.Date

case class Booking(room: String, date: Date)
```

```tut:book:fail
writeCsv(List(Booking("Lecture hall", new Date())))
```

The message we get here isn't very helpful.
All the compiler knows is
it tried a lot of combinations of implicits
and couldn't make them work.
It has no idea which combination came closest to the desired result,
so it can't tell us where the source(s) of failure lie.

There's not much good news here.
We have to find the source of the error ourselves
by a process of elimination.
We'll discuss debugging techniques
in Section [@sec:generic:debugging].
For now, the main redeeming feature
is that implicit resolution always fails at compile time.
There's little chance that we will end up
with code that fails during execution.
