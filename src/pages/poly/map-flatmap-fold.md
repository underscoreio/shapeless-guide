## Mapping and flatMapping using Poly

`HList` has a `map` method that
accepts a `Poly` as the mapping function.
Here's an example:

```tut:book:silent
import shapeless._

object sizeOf extends Poly1 {
  implicit val intCase: Case.Aux[Int, Int] =
    at(identity)

  implicit val stringCase: Case.Aux[String, Int] =
    at(_.length)

  implicit val booleanCase: Case.Aux[Boolean, Int] =
    at(bool => if(bool) 1 else 0)
}
```

```tut:book
(10 :: "hello" :: true :: HNil).map(sizeOf)
```

We can use `map` provided
the `Poly` provides `Cases` for every member of the `HList`.
If the compiler can't find a `Case` for a particular member,
we get a compile error:

```tut:book:fail
(1.5 :: HNil).map(sizeOf)
```

We can also `flatMap` over an `HList` provided
every corresponding case in our `Poly` returns another `HList`:

```tut:book:silent
object valueAndSizeOf extends Poly1 {
  implicit val intCase: Case.Aux[Int, Int :: Int :: HNil] =
    at(num => num :: num :: HNil)

  implicit val stringCase: Case.Aux[String, String :: Int :: HNil] =
    at(str => str :: str.length :: HNil)

  implicit val booleanCase: Case.Aux[Boolean, Boolean :: Int :: HNil] =
    at(bool => bool :: (if(bool) 1 else 0) :: HNil)
}
```

```tut:book
(10 :: "hello" :: true :: HNil).flatMap(valueAndSizeOf)
```

If there is a missing case or one of the cases doesn't return an `HList`,
we get a compilation error:

```tut:book:fail
// Using the wrong Poly with flatMap:
(10 :: "hello" :: true :: HNil).flatMap(sizeOf)
```

## Folding using Poly

In addition to `map` and `flatMap`,
shapeless also provides
`foldLeft` and `foldRight` operations on `HLists`:

```tut:book:silent
import shapeless._

object sum extends Poly2 {
  implicit val intIntCase: Case.Aux[Int, Int, Int] =
    at((a, b) => a + b)

  implicit val intStringCase: Case.Aux[Int, String, Int] =
    at((a, b) => a + b.length)
}
```

```tut:book
(10 :: "hello" :: 100 :: HNil).foldLeft(0)(sum)
```

We can also `reduceLeft`, `reduceRight`, `foldMap`, and so on.
Each operation has its own associated type class.
We'll leave it as an exercise to the reader
to investigate the available operations.
