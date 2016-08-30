## Generic coproducts

Now we know how shapeless encodes product types.
What about coproducts?
We looked at `Either` earlier,
but that suffers from a similar drawback to tuples:
we have no way of representing a disjunction of fewer than two types.
For this reason, shapeless provides its a different encoding
called `Coproduct` that is similar to `HList`:

![Inheritance diagram for `Coproduct`](src/pages/representations/coproduct.png)

The type of a `Coproduct` encodes all the possible types in the disjunction,
but each concrete instantiation contains a value for just one of the possibilities:

```tut:book
import shapeless.{HList, HNil, ::}
import shapeless.{Coproduct, CNil, :+:, Inl, Inr}

type Rectangle3 = Double :: Double :: HNil
type Circle3    = Double :: HNil
type Shape3     = Rectangle3 :+: Circle3 :+: CNil
```

General coproduct types look like `A :+: B :+: C :+: CNil` meaning "A or B or C".
`:+:` can be loosely interpreted as an `Either`,
with subtypes `Inl` and `inr` corresponding loosely to `Left` and `Right`.
`CNil` is a "void" type with no values, similar to `Nothing`,
so we can never instantiate an empty `Coproduct`,
and we can never create a `Coproduct` purely from instances of `Inr`:

```tut:book
val rect3: Shape3 = Inl(3.0 :: 4.0 :: HNil)
val circ3: Shape3 = Inr(Inl(1.0 :: HNil))
```

### Switching encodings using *Generic*

`Coproduct` types are difficult to parse on first glance.
However, it is relatively easy to see how they fit
into the larger picture of generic encodings.
In addition to understanding case classes,
shapeless' `Generic` type class also understands sealed traits.
It can map any sealed family of case classes to a
type made up of `HLists` and `Coproducts`:

```tut:book
import shapeless.Generic

sealed trait Shape
final case class Rectangle(width: Double, height: Double) extends Shape
final case class Circle(radius: Double) extends Shape

val rect4: Shape = Rectangle(3.0, 4.0)
val circ4: Shape = Circle(1.0)

val gen = Generic[Shape]
```

Note that the `Repr` of the `Generic` is
a `Coproduct` of the subtypes of the sealed trait:
`Rectangle :+: Circle :+: CNil`.
We can use the `to` and `from` methods of the generic
to map back and forth between `Shape` and `gen.Repr`:

```tut:book
gen.to(rect4)

gen.to(circ4)

gen.from(gen.to(rect4))
```

