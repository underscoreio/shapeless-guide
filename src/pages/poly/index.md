# Functional operations on HLists

Regular Scala programs make heavy use
of traversal functions such as `map` and `flatMap`.
A question arises: can we perform similar operations
on `HLists` and `Coproducts`?
The answer is "yes", but the code looks
a little different to regular Scala code.

Let's take the `map` method as an example.
Figure [@fig:poly:monomorphic-map] shows
a type chart for mapping over a regular list.
We start with a `List[A]`, supply a function `A => B`,
and end up with a `List[B]`.

![Mapping over a regular list ("monomorphic" map)](src/pages/poly/monomorphic-map.pdf+svg){#fig:poly:monomorphic-map}

This model breaks down for `HLists` and `Coproducts`
because all of the elements are different types.
Ideally we'd like a mapping
like the one shown in Figure [@fig:poly:polymorphic-map],
which inspects the type of each input element
and uses it to determine the type of each output element.
This way we can preserve the heterogeneous nature
of the input data structure.

![Mapping over a heterogeneous list ("polymorphic" map)](src/pages/poly/polymorphic-map.pdf+svg){#fig:poly:polymorphic-map}

The problem with this model is that regular Scala functions,
unlike Scala methods, are not polymorphic in their input type.
That is to say we can't choose an output type based on our input type.
To work around this restriction
we have to lean on some more shapeless infrastructure.

## Polymorphic functions

Shapeless provides a type called `Poly`
that represents a polymorphic function.
Instance of `Poly` are objects with an `apply` method
that is defined in terms of a dependently typed function.
Here is an abbreviated definition:

```scala
trait Poly {
  def apply[A](a: A)
      (implicit cse: Case[this.type, A :: HNil]): cse.Result =
    cse(a :: HNil)
  // etc...
}
```

The setup should be recognisable from Chapter [@sec:type-level-programming].
The method accepts a parameter of type `A` and an implicit parameter
of type `Case` that does the actual mapping:

```scala
trait Case[P, L <: HList] {
  type Result
  def apply(arg: L): Result
  // etc...
}
```

The structure of `Case` is familiar:
it provides a type member called `Result`
and a user-defined `apply` method that accepts an `HList` as a parameter list
and implements the function body.

Shapeless provides a comprehensive API to simplify
constructing instances of `Poly` and `Case`.
For now we're going to ignore the conveniences
and write bare-bones `Poly` to show how it all works:

```tut:book:silent
import shapeless._
import shapeless.poly._

object myPoly extends Poly {
  type MyType = this.type

  implicit val intCase: Case.Aux[MyType, Int :: HNil, Double] =
    Case { case num :: HNil => num / 2.0 }

  implicit val stringCase: Case.Aux[MyType, String :: HNil, Int] =
    Case { case str :: HNil => str.length }
}
```

```tut:book
val intResult = myPoly(123)
val stringResult = myPoly("Hello")

intResult : Double
```
