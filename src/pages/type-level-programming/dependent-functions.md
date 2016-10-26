## Dependently typed functions

Shapeless uses dependent types all over the place:
in `Generic`, in `Witness` (which we will see next chapter),
and in a host of other implicit values that operate on `HLists`.

For example, shapeless provides a type class called `Last`
that returns the last element in an `HList`.
Here's a simplified version of its definition:

```scala
package shapeless.ops.hlist

trait Last[L <: HList] {
  type Out
  def apply(in: L): Out =
    ??? // definition omitted for brevity
}
```

We can summon instances of `Last`
to inspect `HLists` in our code.
In the two examples below note that
the `Out` types are dependent on
the `HList` types we started with:

```tut:book:silent
import shapeless.{HList, ::, HNil}

import shapeless.ops.hlist.Last
```

```tut:book
val last1 = implicitly[Last[String :: Int :: HNil]]
val last2 = implicitly[Last[Int :: String :: HNil]]
```

Once we have summoned instances of `Last`,
we can use them at the value level:

```tut:book
last1("foo" :: 123 :: HNil)
last2(321 :: "bar" :: HNil)
```

We get two forms of protection against errors.
The implicits defined for `Last` ensure
we can only summon instances if
the input `HList` has at least one element:

```tut:book:fail
implicitly[Last[HNil]]
```

In addition, the type parameters
on the instances of `Last` check
whether we pass in the expected type of `HList`:

```tut:book:fail
last1(321 :: "bar" :: HNil)
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

We can summon instances of `Second`
subject to similar constraints to `Last`:

```tut:book
val second1 = implicitly[Second[String :: Boolean :: Int :: HNil]]
val second2 = implicitly[Second[String :: Int :: Boolean :: HNil]]
```

```tut:book:fail
implicitly[Second[String :: HNil]]
```

And use them at the value level in the same way:

```tut:book
second1("foo" :: true :: 123 :: HNil)
second2("bar" :: 321 :: false :: HNil)
```

```tut:book:fail
second1("baz" :: HNil)
```

### Chaining dependent functions {#sec:type-level-programming:chaining}

Dependently typed functions provide
a means of calculating one type from another.
We can *chain* dependently typed functions
to perform calculations involving multiple steps.
For example, we should be able to use a `Generic`
to calculate a `Repr` for a case class,
and use a `Last` to calculate
the type of the last element.
Let's try coding this:

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

Unfortunately our code doesn't compile.
This is the same problem we had
in Section [@sec:generic:product-generic]
with our definition of `genericEncoder`.
We worked around the problem by lifting
the free type variable out as a type parameter:

```tut:book:silent
def lastField[A, Repr <: HList](input: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  last: Last[Repr]
): last.Out = last.apply(gen.to(input))
```

```tut:book:invisible
case class Vec(x: Int, y: Int)
case class Rect(origin: Vec, extent: Vec)
```

```tut:book
lastField(Rect(Vec(1, 2), Vec(3, 4)))
```

As a general rule,
we always write code in this style.
By encoding all the free variables as type parameters,
we enable the compiler to
unify them with appropriate types.
This goes for more subtle constraints as well.
For example, suppose we wanted
to summon a `Generic` for
a case class of exactly one field.
We might be tempted to write this:

```tut:book:silent
def getWrappedValue[A, Head](input: A)(
  implicit
  gen: Generic.Aux[A, Head :: HNil]
): Head = gen.to(input).head
```

The result here is more insidious.
The method definition compiles but
the compiler can never
find the implicits its needs
at the call site:

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
it shouldn't be appearing
in the type the compiler is trying to unify.
The problem is that the `gen` parameter is over-constrained:
the compiler can't find a `Repr`
*and* ensure its length at the same time.
`Nothing` also often provides a clue,
appearing when the compiler
fails to unify covariant type parameters.

The solution to our problem above
is to separate implicit resolution into steps:

1. find a `Generic` with a suitable `Repr` for `A`;
2. provide that the `Repr` has a `Head` type.

Here's a revised version of the method
using `=:=` to constrain `Repr`:

```tut:book:fail
def getWrappedValue[A, Repr <: HList, Head, Tail <: HList](input: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  ev: (Head :: Tail) =:= Repr
): Head = gen.to(input).head
```

This doesn't compile
because the `head` method in the method body
requires an implicit parameter of type `IsHCons`.
This is a much simpler error message to fix---we
just need to learn a tool from shapeless' toolbox.
`IsHCons` is a shapeless type class
that splits an `HList` into a `Head` and `Tail`.
We can use `IsHCons` instead of `=:=`:

```tut:book:silent
import shapeless.ops.hlist.IsHCons

def getWrappedValue[A, Repr <: HList, Head, Tail <: HList](in: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  isHCons: IsHCons.Aux[Repr, Head, Tail]
): Head = gen.to(in).head
```

This fixes the bug.
Both the method definition
and the call site now compile as expected:

```tut:book
getWrappedValue(Wrapper(42))
```

The take home point here isn't
that we solved the problem using `IsHCons`.
Shapeless provides a lot of tools like this,
and we can supplement them where necessary
with our own type classes.
The important point is
the process we used to write code that compiles
and is capable of finding solutions.
We'll finish off this section
with a step-by-step guide
summarising our findings so far.
