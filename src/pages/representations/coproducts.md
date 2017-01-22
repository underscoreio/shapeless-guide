## Generic coproducts

Now we know how shapeless encodes product types.
What about coproducts?
We looked at `Either` earlier
but that suffers from similar drawbacks to tuples.
Again, shapeless provides its own encoding that is similar to `HList`:

```tut:book:silent
import shapeless.{Coproduct, :+:, CNil, Inl, Inr}

case class Red()
case class Amber()
case class Green()

type Light = Red :+: Amber :+: Green :+: CNil
```

In general coproducts take the form
`A :+: B :+: C :+: CNil` meaning "A or B or C",
where `:+:` can be loosely interpreted as `Either`.
The overall type of a coproduct
encodes all the possible types in the disjunction,
but each concrete instance
contains a value for just one of the possibilities.
`:+:` has two subtypes, `Inl` and `Inr`,
that correspond loosely to `Left` and `Right`.
We create instances of a coproduct by
nesting `Inl` and `Inr` constructors:

```tut:book
val red: Light = Inl(Red())
val green: Light = Inr(Inr(Inl(Green())))
```

Every coproduct type is terminated with `CNil`,
which is an empty type with no values, similar to `Nothing`.
We can't instantiate `CNil`
or build a `Coproduct` purely from instances of `Inr`.
We always have exactly one `Inl` in a value.

Again, it's worth stating that `Coproducts` aren't particularly special.
The functionality above can be achieved using `Either` and `Nothing`
in place of `:+:` and `CNil`.
There are technical difficulties with using `Nothing`,
but we could have used
any other uninhabited or arbitrary singleton type in place of `CNil`.

### Switching encodings using *Generic*

`Coproduct` types are difficult to parse on first glance.
However, we can see how they fit
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

The `Repr` of the `Generic` for `Shape` is
a `Coproduct` of the subtypes of the sealed trait:
`Rectangle :+: Circle :+: CNil`.
We can use the `to` and `from` methods of the generic
to map back and forth between `Shape` and `gen.Repr`:

```tut:book
gen.to(Rectangle(3.0, 4.0))

gen.to(Circle(1.0))
```
