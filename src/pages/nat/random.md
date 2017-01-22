## Case study: random value generator

Property-based testing libraries like [ScalaCheck][link-scalacheck]
use type classes to generate random data for unit tests.
For example, ScalaCheck provides the `Arbitrary` type class
that we can use as follows:

```tut:book:silent
import org.scalacheck._
```

```tut:book
for(i <- 1 to 3) println(Arbitrary.arbitrary[Int].sample)
for(i <- 1 to 3) println(Arbitrary.arbitrary[(Boolean, Byte)].sample)
```

ScalaCheck provides built-in instances of `Arbitrary`
for a wide range of standard Scala types.
However, creating instances of `Arbitrary` for user ADTs
is still a time-consuming manual process.
This makes shapeless integration via libraries like
[scalacheck-shapeless][link-scalacheck-shapeless] very attractive.

In this section we will create a simple `Random` type class
to generate random values of user-defined ADTs.
We will show how `Length` and `Nat` form
a crucial part of the implementation.
As usual we start with
the definition of the type class itself:

```tut:book:invisible
// Ensure we always get the same output:
scala.util.Random.setSeed(0)
```

```tut:book:silent
trait Random[A] {
  def get: A
}

def random[A](implicit r: Random[A]): A = r.get
```

### Simple random values

Let's start with some basic instances of `Random`:

```tut:book:silent
// Instance constructor:
def createRandom[A](func: () => A): Random[A] =
  new Random[A] {
    def get = func()
  }

// Random numbers from 0 to 9:
implicit val intRandom: Random[Int] =
  createRandom(() => scala.util.Random.nextInt(10))

// Random characters from A to Z:
implicit val charRandom: Random[Char] =
  createRandom(() => ('A'.toInt + scala.util.Random.nextInt(26)).toChar)

// Random booleans:
implicit val booleanRandom: Random[Boolean] =
  createRandom(() => scala.util.Random.nextBoolean)
```

We can use these simple generators
via the `random` method as follows:

```tut:book
for(i <- 1 to 3) println(random[Int])
for(i <- 1 to 3) println(random[Char])
```

### Random products

We can create random values for products
using the `Generic` and `HList` techniques
from Chapter [@sec:generic]:

```tut:book:silent
import shapeless._

implicit def genericRandom[A, R](
  implicit
  gen: Generic.Aux[A, R],
  random: Lazy[Random[R]]
): Random[A] =
  createRandom(() => gen.from(random.value.get))

implicit val hnilRandom: Random[HNil] =
  createRandom(() => HNil)

implicit def hlistRandom[H, T <: HList](
  implicit
  hRandom: Lazy[Random[H]],
  tRandom: Random[T]
): Random[H :: T] =
  createRandom(() => hRandom.value.get :: tRandom.get)
```

This gets us as far as summoning random instances for case classes:

```tut:book:silent
case class Cell(col: Char, row: Int)
```

```tut:book
for(i <- 1 to 5) println(random[Cell])
```

### Random coproducts

This is where we start hitting problems.
Generating a random instance of a coproduct
involves choosing a random subtype.
Let's start with a naïve implementation:

```tut:book:silent
implicit val cnilRandom: Random[CNil] =
  createRandom(() => throw new Exception("Inconceivable!"))

implicit def coproductRandom[H, T <: Coproduct](
  implicit
  hRandom: Lazy[Random[H]],
  tRandom: Random[T]
): Random[H :+: T] =
  createRandom { () =>
    val chooseH = scala.util.Random.nextDouble < 0.5
    if(chooseH) Inl(hRandom.value.get) else Inr(tRandom.get)
  }
```

There problems with this implementation
lie in the 50/50 choice in calculating `chooseH`.
This creates an uneven probability distribution.
For example, consider the following type:

```tut:book:silent
sealed trait Light
case object Red extends Light
case object Amber extends Light
case object Green extends Light
```

The `Repr` for `Light` is `Red :+: Amber :+: Green :+: CNil`.
An instance of `Random` for this type
will choose `Red` 50% of the time
and `Amber :+: Green :+: CNil` 50% of the time.
A correct distribution would be
33% `Red` and 67% `Amber :+: Green :+: CNil`.

And that's not all.
If we look at the overall probability distribution
we see something even more alarming:

- `Red` is chosen 1/2 of the time
- `Amber` is chosen 1/4 of the time
- `Green` is chosen 1/8 of the time
- *`CNil` is chosen 1/16 of the time*

Our coproduct instances will throw exceptions 6.75% of the time!

```scala
for(i <- 1 to 100) random[Light]
// java.lang.Exception: Inconceivable!
//   ...
```

To fix this problem we have to alter
the probability of choosing `H` over `T`.
The correct behaviour should be to choose
`H` `1/n` of the time,
where `n` is the length of the coproduct.
This ensures an even probability distribution
across the subtypes of the coproduct.
It also ensures we choose the head
of a single-subtype `Coproduct` 100% of the time,
which means we never call `cnilProduct.get`.
Here's an updated implementation:

```tut:book:silent
import shapeless.ops.coproduct
import shapeless.ops.nat.ToInt

implicit def coproductRandom[H, T <: Coproduct, L <: Nat](
  implicit
  hRandom: Lazy[Random[H]],
  tRandom: Random[T],
  tLength: coproduct.Length.Aux[T, L],
  tLengthAsInt: ToInt[L]
): Random[H :+: T] = {
  createRandom { () =>
    val length = 1 + tLengthAsInt()
    val chooseH = scala.util.Random.nextDouble < (1.0 / length)
    if(chooseH) Inl(hRandom.value.get) else Inr(tRandom.get)
  }
}

```

With these modifications
we can generate random values of any product or coproduct:

```tut:book
for(i <- 1 to 5) println(random[Light])
```

Generating test data for ScalaCheck
normally requires a great deal of boilerplate.
Random value generation is a compelling use case for shapeless
of which `Nat` forms an essential component.
