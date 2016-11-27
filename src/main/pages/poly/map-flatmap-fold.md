## Mapping and flatMapping using *Poly*

Shapeless provides a suite of
functional operations based on `Poly`,
each implemented as an ops type class.
Let's look at `map` and `flatMap` as examples.
Here's `map`:

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

Note that the elements in the resulting `HList`
have types matching the `Cases` in `sizeOf`.
We can use `map` with any `Poly` that
provides `Cases` for every member of our starting `HList`.
If the compiler can't find a `Case` for a particular member,
we get a compile error:

```tut:book:fail
(1.5 :: HNil).map(sizeOf)
```

We can also `flatMap` over an `HList`,
as long as every corresponding case in our `Poly`
returns another `HList`:

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

Again, we get a compilation error if there is a missing case
or one of the cases doesn't return an `HList`:

```tut:book:fail
// Using the wrong Poly with flatMap:
(10 :: "hello" :: true :: HNil).flatMap(sizeOf)
```

`map` and `flatMap` are based on type classes
called `Mapper` and `FlatMapper` respectively.
We'll see an example that makes direct use of `Mapper`
in Section [@sec:poly:product-mapper].

## Folding using *Poly*

In addition to `map` and `flatMap`,
shapeless also provides
`foldLeft` and `foldRight` operations based on `Poly2`:

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
