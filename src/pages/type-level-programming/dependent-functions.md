## Dependently typed functions

Shapeless uses dependent types all over the place:
in `Generic`, in `Witness` (which we will see next chapter),
and in a host of other implicit values that operate on `HLists`.

For example, shapeless provides a type class called `Last`
that returns the last element in an `HList`:

```tut:book:silent
import shapeless.{HList, ::, HNil}

import shapeless.ops.hlist.Last
```

```tut:book
val last = implicitly[Last[String :: Int :: HNil]]
```

In each case note that the `Out` type is dependent
on the `HList` type we started with.
Also note that instances can only be summoned
if the input `HList` has at least one element:

```tut:book:fail
implicitly[Last[HNil]]
```

As a further example, let's implement
our own type class, called `Second`,
that returns the second element in an `HList`:

```tut:book:silent
trait Second[H <: HList] {
  type Out
  def apply(value: H): Out
}

implicit def hlistSecond[A, B, Rest <: HList]: Second[A :: B :: Rest] =
  new Second[A :: B :: Rest] {
    type Out = B
    def apply(value: A :: B :: Rest): B =
      value.tail.head
  }
```

```tut:book
val second = implicitly[Second[String :: Boolean :: Int :: HNil]]

second("Woo!" :: true :: 321 :: HNil)
```

### Chaining dependent functions

We can see dependently typed functions
as a way of calculating one type from another type:
we use a `Generic` to calculate a `Repr` for a case class,
and so on.

What about calculations involving more than one step?
Suppose, for example, we want to find the last item in a case class.
To do this we need a combination of `Generic` and `Last`.
Let's try writing this:

```tut:book:invisible
import shapeless.Generic
```

```tut:book:fail
def lastField[A](input: A)(
  implicit
  gen: Generic[A],
  last: Last[gen.Repr]
): last.Out = last.apply(gen.to(input))
```

Unfortunately this doesn't compile.
This is the same problem we had last chapter
when creating the `CsvWriter` for `HList` pairs.
As a general rule,
we always write code in this style
by lifting all the variable types out as type parameters
and letting the compiler unify them with appropriate types:

```tut:book:invisible
case class Vec(x: Int, y: Int)
case class Rect(origin: Vec, extent: Vec)
```

```tut:book:silent
def lastField[A, Repr <: HList](input: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  last: Last[Repr]
): last.Out = last.apply(gen.to(input))
```

```tut:book
lastField(Rect(Vec(1, 2), Vec(3, 4)))
```

This goes for more subtle constraints as well.
For example, suppose we wanted to get
the contents of a case class of exactly one field.
We might be tempted to write this:

```tut:book:silent
def getWrappedValue[A, Head](input: A)(
  implicit
  gen: Generic.Aux[A, Head :: HNil]
): Head = gen.to(input).head
```

The result here is more insidious.
The method definition compiles,
but it never finds the implicits its needs
for the call site to compile:

```tut:book:silent
case class Wrapper(value: Int)
```

```tut:book:fail
getWrappedValue(Wrapper(42))
```

The error message hints at the problem:

> error: could not find implicit value for parameter gen:
>
>   `Generic.Aux[Wrapper, Head :: HNil]`

The clue is in the appearance of the type `Head`.
This is the name of a type parameter in the method:
it shouldn't be appearing in the type the compiler is trying to unify.
The problem is that the `gen` parameter is over-constrained:
the compiler isn't capable of finding a `Repr`
and ensuring it is an `HList` with one field at the same time.
Other "smell" types include `Nothing`,
which often appears when the compiler
fails to unify covariant type parameters.

The solution is to separate the problem out into steps:

1. find a `Generic` with a suitable `Repr` for `A`;
2. provide that the `Repr` has a `Head` type.

Here's a revised version of the method
that tries to use this using `=:=`:

```tut:book:fail
def getWrappedValue[A, Repr <: HList, Head, Tail <: HList](input: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  ev: (Head :: Tail) =:= Repr
): Head = gen.to(input).head
```

This doesn't compile because the `head` method in the method body
requires an implicit parameter of type `IsHCons`.
This is a much simpler error message to fix---we
just need to learn a tool from shapeless' toolbox.
`IsHCons` is a type class shapeless uses to split an `HList`
into a `Head` and `Tail` type:
we should be using `IsHCons` instead of `=:=`:

```tut:book:silent
import shapeless.ops.hlist.IsHCons

def getWrappedValue[A, Repr <: HList, Head, Tail <: HList](input: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  isHCons: IsHCons.Aux[Repr, Head, Tail]
): Head = gen.to(input).head
```

This fixes the bug
and allows our method to find implicits as expected:

```tut:book
getWrappedValue(Wrapper(42))
```

The take home point here isn't `IsHCons`.
Shapeless provides a lot of tools like this
and where tools are missing we can write them ourselves.
The important point is the process of
writing code that compiles
and is capable of finding solutions.
We'll finish off this section with a step-by-step guide
summarising our findings so far.
