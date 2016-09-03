## Generic coproducts

Now we know how shapeless encodes product types.
What about coproducts?
We looked at `Either` earlier,
but that suffers from a similar drawback to tuples:
we have no way of representing a disjunction of fewer than two types.
For this reason, shapeless provides a different encoding
that is similar to `HList`:

![Inheritance diagram for `Coproduct`](src/pages/representations/coproduct.png)

The type of a `Coproduct` encodes all the possible types in the disjunction,
but each concrete instantiation contains a value for just one of the possibilities:

```tut:book:silent
case class Red()
case class Amber()
case class Green()

import shapeless.{Coproduct, :+:, CNil}

type Light = Red :+: Amber :+: Green :+: CNil
```

General coproduct types take the form `A :+: B :+: C :+: CNil` meaning "A or B or C".
`:+:` can be loosely interpreted as an `Either`,
with subtypes `Inl` and `Inr` corresponding loosely to `Left` and `Right`.
`CNil` is an empty type with no values, similar to `Nothing`,
so we can never instantiate an empty `Coproduct`.
Similarly, we can never create a `Coproduct` purely from instances of `Inr`.
We always have to have exactly one `Inl` in a value:

```tut:book:silent
import shapeless.{Inl, Inr}

val red: Light =
  Inl(Red())

val green: Light =
  Inr(Inr(Inl(Green())))
```

### Switching encodings using *Generic*

`Coproduct` types are difficult to parse on first glance.
However, it is relatively easy to see how they fit
into the larger picture of generic encodings.
In addition to understanding case classes and case objects,
shapeless' `Generic` type class also understands
sealed traits and abstract classes:

```tut:book:silent
import shapeless.Generic

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape
```

```tut:book
val gen = Generic[Shape]
```

Note that the `Repr` of the `Generic` is
a `Coproduct` of the subtypes of the sealed trait:
`Rectangle :+: Circle :+: CNil`.
We can use the `to` and `from` methods of the generic
to map back and forth between `Shape` and `gen.Repr`:

```tut:book
gen.to(Rectangle(3.0, 4.0))

gen.to(Circle(1.0))
```
