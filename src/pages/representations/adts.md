## Recap: algebraic data types

*Algebraic data types (ADTs)*[^adts]
are a functional programming concept
with a fancy name but a very simple meaning.
They are an idiomatic way of representing data
using "ands" and "ors". For example:

 - a shape is a rectangle **or** a circle
 - a rectangle has a width **and** a height
 - a circle has a radius

[^adts]: Not to be confused with "abstract data types",
which are a different tool from computer science
that has little bearing on the discussion here.

In ADT terminology,
"and" types such as rectangle and circle are called *products*
and "or" types such as shape are called *coproducts*.
In Scala we typically represent products using
case classes and coproducts using sealed traits:

```tut:book:silent
sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape

val rect: Shape = Rectangle(3.0, 4.0)
val circ: Shape = Circle(1.0)
```

The beauty of ADTs is that they are completely type safe.
The compiler has complete knowledge of the algebras[^algebra] we define,
so it can help us write complete,
correctly typed methods involving our types:

[^algebra]: The word "algebra" meaning: the symbols we define, such as rectangle and circle; and the rules for manipulating those symbols, encoded as methods.

```tut:book:silent
def area(shape: Shape): Double =
  shape match {
    case Rectangle(w, h) => w * h
    case Circle(r)       => math.Pi * r * r
  }
```

```tut:book
area(rect)
area(circ)
```

### Alternative encodings

Sealed traits and case classes are undoubtedly
the most convenient encoding of ADTs in Scala.
However, they aren't the *only* encoding.
For example, the Scala standard library provides
generic products in the form of `Tuples`
and a generic coproduct in the form of `Either`.
We could have chosen these to encode our `Shape`:

```tut:book:silent
type Rectangle2 = (Double, Double)
type Circle2    = Double
type Shape2     = Either[Rectangle2, Circle2]

val rect2: Shape2 = Left((3.0, 4.0))
val circ2: Shape2 = Right(1.0)
```

While this encoding is less readable than the case class encoding above,
it does have some of the same desirable properties.
We can still write completely type safe operations involving `Shape2`:

```tut:book:silent
def area2(shape: Shape2): Double =
  shape match {
    case Left((w, h)) => w * h
    case Right(r)     => math.Pi * r * r
  }
```

```tut:book
area2(rect2)
area2(circ2)
```

Importantly, `Shape2` is a more *generic* encoding than `Shape`[^generic].
Any code that operates on a pair of `Doubles`
will be able to operate on a `Rectangle2` and vice versa.
As Scala developers we tend to prefer
semantic types like `Rectangle` and `Circle`
to generic ones like `Rectangle2` and `Circle2`
precisely because of their specialised nature.
However, in some cases generality is desirable.
For example, if we're serializing data to disk,
we don't care about the difference
between a pair of `Doubles` and a `Rectangle2`.
We just write two numbers and we're done.

Shapeless gives us the best of both worlds:
we can use friendly semantic types by default
and switch to generic representations
when we want interoperability (more on this later).
However, instead of using `Tuples` and `Either`,
shapeless uses its own data types to represent
generic products and coproducts.
We'll introduce these types in the next sections.

[^generic]: We're using "generic" in an informal way here,
rather than the conventional meaning of
"a type with a type parameter".
