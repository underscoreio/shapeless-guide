## Deriving instances for recursive types

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

```tut:book:silent
sealed trait Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
case class Leaf[A](value: A) extends Tree[A]
```

Theoretically we should already have
all of the definitions in place
to summon a CSV writer for this definition.
However, calls to `writeCsv` fail to compile:

```tut:book:fail
CsvEncoder[Tree[Int]]
````

The problem is that our type is recursive.
The compiler senses an infinite loop
applying our implicits and gives up.

### Implicit divergence

Implicit resolution is a search process.
The compiler uses heuristics to determine
whether it is "converging" on a solution.
If the heuristics don't yield favorable results
for a particular branch of search,
the compiler assumes the branch is not converging
and moves onto another.

One heuristic is specifically designed
to avoid infinite loops.
If the compiler sees the same target type twice
in a particular branch of search,
it gives up and moves on.
We can see this happening if
we look at the expansion for `CsvEncoder[Tree[Int]]`
The implicit resolution process
goes through the following types:

```scala
CsvEncoder[Tree[Int]]                          // 1
CsvEncoder[Branch[Int] :+: Leaf[Int] :+: CNil] // 2
CsvEncoder[Branch[Int]]                        // 3
CsvEncoder[Tree[Int] :: Tree[Int] :: HNil]     // 4
CsvEncoder[Tree[Int]]                          // 5 uh oh
```

We see `Tree[A]` twice in lines 1 and 5,
so the compiler moves onto another branch of search.
The eventual consequence is that
it fails to find a suitable implicit.

In fact, the situation is worse than this.
If the compiler sees the same type constructor twice
and the complexity of the type parameters is *increasing*,
it assumes that branch of search is "diverging".
This is a problem for shapeless
because types like `::[H, T]` and `:+:[H, T]`
can appear several times as the compiler expands
different generic representations.
This causes the compiler to give up prematurely
even though it would eventually find a solution
if it persisted with the same expansion.
Consider the following types:

```tut:book:silent
case class Bar(baz: Int, qux: String)
case class Foo(bar: Bar)
```

The expansion for `Foo` looks like this:

```scala
CsvEncoder[Foo]                   // 1
CsvEncoder[Bar :: HNil]           // 2
CsvEncoder[Bar]                   // 3
CsvEncoder[Int :: String :: HNil] // 4 uh oh
```

The compiler attempts to resolve a `CsvEncoder[::[H, T]]`
twice in this branch of search, on lines 2 and 4.
The type parameter for `T` is more complex on line 4 than on line 2,
so the compiler assumes (incorrectly in this case)
that the branch of search is diverging.
It moves onto another branch and, again,
the result is failure to generate a suitable instance.

### *Lazy*

Implicit divergence would be a show-stopper
for libraries like shapeless.
Fortunately, shapeless provides
a type called `Lazy` as a workaround.
`Lazy` does two things:

 1. it suppresses implicit divergence at compile time
    by guarding against the aforementioned
    over-defensive convergence heuristics;

 2. it defers evaluation of the implicit parameter at runtime,
    permitting the derivation of self-referential implicits.

We use `Lazy` by wrapping it around specific implicit parameters.
As a rule of thumb, it is always a good idea to wrap
the "head" parameter of any `HList` or `Coproduct` rule
and the `Repr` parameter of any `Generic` rule in `Lazy`:

```tut:book:invisible:reset
// Forward definitions -------------------------
import shapeless._

trait CsvEncoder[A] {
  def encode(value: A): List[String]
}

object CsvEncoder {
  def apply[A](implicit enc: CsvEncoder[A]): CsvEncoder[A] =
    enc
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

implicit val cnilEncoder: CsvEncoder[CNil] =
  createEncoder(cnil => throw new Exception("Inconceivable!"))

// ----------------------------------------------
```

```tut:book:silent
implicit def hlistEncoder[H, T <: HList](
  implicit
  hEncoder: Lazy[CsvEncoder[H]], // wrap in Lazy
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :: T] = createEncoder {
  case h :: t =>
    hEncoder.value.encode(h) ++ tEncoder.encode(t)
}
```

```tut:book:silent
implicit def coproductEncoder[H, T <: Coproduct](
  implicit
  hEncoder: Lazy[CsvEncoder[H]], // wrap in Lazy
  tEncoder: CsvEncoder[T]
): CsvEncoder[H :+: T] = createEncoder {
  case Inl(h) => hEncoder.value.encode(h)
  case Inr(t) => tEncoder.encode(t)
}
```

```tut:book:silent
implicit def genericEncoder[A, R](
  implicit
  gen: Generic.Aux[A, R],
  rEncoder: Lazy[CsvEncoder[R]] // wrap in Lazy
): CsvEncoder[A] = createEncoder { value =>
  rEncoder.value.encode(gen.to(value))
}
```

```tut:book:invisible
sealed trait Tree[A]
final case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
final case class Leaf[A](value: A) extends Tree[A]
```

This prevents the compiler giving up prematurely,
and enables the solution to work
on complex/recursive types like `Tree`:

```tut:book
CsvEncoder[Tree[Int]]
```
