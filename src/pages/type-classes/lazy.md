## Deriving instances for complex/recursive types

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

Let's try something more ambitious---a binary tree:

```tut:book
sealed trait Tree[A]
final case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
final case class Leaf[A](value: A) extends Tree[A]
```

Theoretically we should already have all of the definitions in place
to summon a CSV writer for this definition:

```tut:book:fail
implicitly[CsvEncoder[Tree[Int]]]
````

Ah. Clearly something has gone wrong.

The problem here is that
the compiler is preventing itself
going into an infinite loop searching for implicits.
The `Branch` data structure is recursive,
so the generic the `CsvEncoder` for `Branch` depends on itself.

In fact, the situation is worse than this.
The compiler uses heuristics to check
for branches of implicit search
that it considers unlikely to terminate.
Even non-recursive data types can cause it to give up:

```tut:book:invisible
sealed trait Shape
```

```tut:book
case class ListOfShapes(list: List[Shape])
```

```tut:book:fail
implicitly[CsvEncoder[ListOfShapes]]
```

### The *Lazy* type class

Fortunately, shapeless provides a mechanism to deal with this.
The `Lazy` type class wraps up another type class instance,
caching the result in `lazy val` and ensuring that the same instance
is always returned for the same type within the same expansion.
We can use `Lazy` as a guard for any implicit parameter
involving a type that isn't an `HList` or a `Coproduct`.

Tut (the tool we're using to render the code samples in this book)
gets a little confused when we redefine parts of the puzzle on their own.
Here's a complete recreation from scratch.
Note the lines marked "wrapped in Lazy":

```tut:book:reset
import shapeless._

trait CsvEncoder[A] {
  def encode(value: A): List[String]
}

def createEncoder[A](func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    def encode(value: A): List[String] =
      func(value)
  }

implicit val intEncoder: CsvEncoder[Int] =
  createEncoder(num => List(num.toString))

implicit val hnilEncoder: CsvEncoder[HNil] =
  createEncoder(hnil => Nil)

implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: Lazy[CsvEncoder[H]], // wrapped in Lazy
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] =
  createEncoder {
    case h :: t =>
      hEncoder.value.encode(h) ++ tEncoder.encode(t)
  }

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(cnil => throw new Exception("The impossible has happened!"))

implicit def coproductEncoder[H, T <: Coproduct](
  implicit
  hEncoder: Lazy[CsvEncoder[H]], // wrapped in Lazy
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :+: T] =
  createEncoder {
    case Inl(h) => hEncoder.value.encode(h)
    case Inr(t) => tEncoder.encode(t)
  }

implicit def genericEncoder[A, R](
  implicit
  gen: Generic.Aux[A, R],
  rEncoder: Lazy[CsvEncoder[R]] // wrapped in Lazy
): CsvEncoder[A] =
  createEncoder { value =>
    rEncoder.value.encode(gen.to(value))
  }

sealed trait Tree[A]
final case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
final case class Leaf[A](value: A) extends Tree[A]
```

In this case we have protected
`hEncoder` in `hlistEncoder` and `coproductEncoder`,
and `rEncoder` in `genericEncoder`,
as these are the encoders that trigger new branches of search.
With these modifications we can write CSV for recursive structures like `Trees`:

```tut:book
implicitly[CsvEncoder[Tree[Int]]]
```

<div class="callout callout-danger">
  TODO: Mention `Cached` and `Strict` ??
</div>