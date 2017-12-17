## Simple ops examples

`HList` has `init` and `last`
extension methods based on two type classes:
`shapeless.ops.hlist.Init` and
`shapeless.ops.hlist.Last`. 
While `init` drops the last element of an `HList`, 
`last` drops all except the last one.
`Coproduct` has similar methods and type classes.
These serve as perfect examples of the ops pattern.
Here are simplified definitions of the extension methods:

```scala
package shapeless
package syntax

implicit class HListOps[L <: HList](l : L) {
  def last(implicit last: Last[L]): last.Out = last.apply(l)
  def init(implicit init: Init[L]): init.Out = init.apply(l)
}
```

The return type of each method is determined
by a dependent type on the implicit parameter.
The instances for each type class provide the actual mapping.
Here's the skeleton definition of `Last` as an example:

```scala
trait Last[L <: HList] {
  type Out
  def apply(in: L): Out
}

object Last {
  type Aux[L <: HList, O] = Last[L] { type Out = O }
  implicit def pair[H]: Aux[H :: HNil, H] = ???
  implicit def list[H, T <: HList]
    (implicit last: Last[T]): Aux[H :: T, last.Out] = ???
}
```

We can make a couple of interesting observations
about this implementation.
First, we can typically implement ops type classes
with a small number of instances (just two in this case).
We can therefore package *all* of the required instances
in the companion object of the type class,
allowing us to call the corresponding extension methods
without any imports from `shapeless.ops`:

```tut:book:silent
import shapeless._
```

```tut:book
("Hello" :: 123 :: true :: HNil).last
("Hello" :: 123 :: true :: HNil).init
```

Second, the type class is only defined for `HLists`
with at least one element.
This gives us a degree of static checking.
If we try to call `last` on an empty `HList`,
we get a compile error:

```tut:book:fail
HNil.last
```
