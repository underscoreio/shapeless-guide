## Dependent types

Last chapter we spent a lot of time using `Generic`,
the type class for mapping ADT types to generic representations.
However, we haven't yet discussed an important bit of theory
that underpins `Generic` and much of shapeless:
*dependent types*.

To illustrate this, let's take a closer look at `Generic`.
Here's a simplified version of the definition:

```scala
trait Generic[A] {
  type Repr
  def to(value: A): Repr
  def from(value: Repr): A
}
```

Instances of `Generic` reference two other types:
a type parameter `A` and a type member `Repr`.
Suppose we implement a method `getRepr` as follows.
What type will we get back?

```tut:book:silent
import shapeless.Generic

def getRepr[A](value: A)(implicit gen: Generic[A]) =
  gen.to(value)
```

The answer is it depends on the instance we get for `gen`.
In expanding the call to `getRepr`,
the compiler will search for a `Generic[A]`
and the result type will be whatever `Repr`
is defined in that instance:

```tut:book:silent
case class Vec(x: Int, y: Int)
case class Rect(origin: Vec, size: Vec)
```

```tut:book
getRepr(Vec(1, 2))
getRepr(Rect(Vec(0, 0), Vec(5, 5)))
```

What we're seeing here is called *dependent typing*:
the result type of `getRepr` depends on its value parameters
via their type members.
Suppose we had specified `Repr`
as type parameter on `Generic`
instead of a type member:

```tut:book:silent
trait Generic2[A, Repr]

def getRepr2[A, R](value: A)(implicit generic: Generic2[A, R]): R =
  ???
```

We would have had to pass the desired value of `Repr`
to `getRepr` as a type parameter,
effectively making `getRepr` useless.
The intuitive take-away from this is
that type parameters are useful as "inputs"
and type members are useful as "outputs".
