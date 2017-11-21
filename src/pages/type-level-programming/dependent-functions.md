## Dependently typed functions {#sec:type-level-programming:depfun}

Shapeless uses dependent types all over the place:
in `Generic`, in `Witness` (which we will see in the next chapter),
and in a host of other "ops" type classes
that we will survey in Part II of this guide.

For example, shapeless provides a type class called `Last`
that returns the last element in an `HList`.
Here's a simplified version of its definition:

```scala
package shapeless.ops.hlist

trait Last[L <: HList] {
  type Out
  def apply(in: L): Out
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
val last1 = Last[String :: Int :: HNil]
val last2 = Last[Int :: String :: HNil]
```

Once we have summoned instances of `Last`,
we can use them at the value level
via their `apply` methods:

```tut:book
last1("foo" :: 123 :: HNil)
last2(321 :: "bar" :: HNil)
```

We get two forms of protection against errors.
The implicits defined for `Last` ensure
we can only summon instances if
the input `HList` has at least one element:

```tut:book:fail
Last[HNil]
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
trait Second[L <: HList] {
  type Out
  def apply(value: L): Out
}

object Second {
  type Aux[L <: HList, O] = Second[L] { type Out = O }

  def apply[L <: HList](implicit inst: Second[L]): Aux[L, inst.Out] =
    inst
}
```

This code uses the idiomatic layout
described in Section [@sec:generic:idiomatic-style].
We define the `Aux` type in the companion object beside
the standard `apply` method for summoning instances.

<div class="callout callout-warning">
*Summoner methods versus "implicitly" versus "the"*

Note that the return type on `apply` is `Aux[L, O]`, not `Second[L]`.
This is important.
Using `Aux` ensures the `apply` method
does not erase the type members on summoned instances.
If we define the return type as `Second[L]`,
the `Out` type member will be erased from the return type
and the type class will not work correctly.

The `implicitly` method from `scala.Predef` has this behaviour.
Compare the type of an instance of `Last` summoned with `implicitly`:

```tut:book
implicitly[Last[String :: Int :: HNil]]
```

to the type of an instance summoned with `Last.apply`:

```tut:book
Last[String :: Int :: HNil]
```

The type summoned by `implicitly` has no `Out` type member.
For this reason, we should avoid `implicitly`
when working with dependently typed functions.
We can either use custom summoner methods,
or we can use shapeless' replacement method, `the`:

```tut:book:silent
import shapeless._
```

```tut:book
the[Last[String :: Int :: HNil]]
```
</div>

We only need a single instance,
defined for `HLists` of at least two elements:

```tut:book:silent
import Second._

implicit def hlistSecond[A, B, Rest <: HList]: Aux[A :: B :: Rest, B] =
  new Second[A :: B :: Rest] {
    type Out = B
    def apply(value: A :: B :: Rest): B =
      value.tail.head
  }
```

We can summon instances using `Second.apply`:

```tut:book:invisible
import Second._
```

```tut:book
val second1 = Second[String :: Boolean :: Int :: HNil]
val second2 = Second[String :: Int :: Boolean :: HNil]
```

Summoning is subject to similar constraints as `Last`.
If we try to summon an instance for an incompatible `HList`,
resolution fails and we get a compile error:

```tut:book:fail
Second[String :: HNil]
```

Summoned instances come with an `apply` method
that operates on the relevant type of `HList` at the value level:

```tut:book
second1("foo" :: true :: 123 :: HNil)
second2("bar" :: 321 :: false :: HNil)
```

```tut:book:fail
second1("baz" :: HNil)
```

## Chaining dependent functions {#sec:type-level-programming:chaining}

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
def getWrappedValue[A, H](input: A)(
  implicit
  gen: Generic.Aux[A, H :: HNil]
): H = gen.to(input).head
```

The result here is more insidious.
The method definition compiles but
the compiler can never
find implicits at the call site:

```tut:book:silent
case class Wrapper(value: Int)
```

```tut:book:fail
getWrappedValue(Wrapper(42))
```

The error message hints at the problem.
The clue is in the appearance of the type `H`.
This is the name of a type parameter in the method:
it shouldn't be appearing
in the type the compiler is trying to unify.
The problem is that the `gen` parameter is over-constrained:
the compiler can't find a `Repr`
*and* ensure its length at the same time.
The type `Nothing` also often provides a clue,
appearing when the compiler
fails to unify covariant type parameters.

The solution to our problem above
is to separate implicit resolution into steps:

1. find a `Generic` with a suitable `Repr` for `A`;
2. provide that the `Repr` has a head type `H`.

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

def getWrappedValue[A, Repr <: HList, Head](in: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  isHCons: IsHCons.Aux[Repr, Head, HNil]
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
Shapeless provides a lot of tools like this
(see Chapters [@sec:ops] to [@sec:nat]),
and we can supplement them where necessary
with our own type classes.
The important point is
to understand the process we use
to write code that compiles
and is capable of finding solutions.
We'll finish off this section
with a step-by-step guide
summarising our findings so far.
