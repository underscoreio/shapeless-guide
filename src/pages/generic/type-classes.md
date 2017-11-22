## Recap: type classes {#sec:generic:type-classes}

Before we get into the depths of instance derivation,
let's quickly recap on the important aspects of type classes.

Type classes are a programming pattern borrowed from Haskell
(the word "class" has nothing to do with
classes in object oriented programming).
We encode them in Scala using traits and implicits.
A *type class* is a parameterised trait
representing some sort of general functionality
that we would like to apply to a wide range of types:

```tut:book:silent
// Turn a value of type A into a row of cells in a CSV file:
trait CsvEncoder[A] {
  def encode(value: A): List[String]
}
```

We implement our type class with *instances*
for each type we care about.
If we want the instances to automatically be in scope
we can place them in the type class' companion object.
Otherwise we can place them in a separate library object
for the user to import manually:

```tut:book:silent
// Custom data type:
case class Employee(name: String, number: Int, manager: Boolean)

// CsvEncoder instance for the custom data type:
implicit val employeeEncoder: CsvEncoder[Employee] =
  new CsvEncoder[Employee] {
    def encode(e: Employee): List[String] =
      List(
        e.name,
        e.number.toString,
        if(e.manager) "yes" else "no"
      )
  }
```

We mark each instance with the keyword `implicit`,
and define one or more entry point methods
that accept an implicit parameter of the corresponding type:

```tut:book:silent
def writeCsv[A](values: List[A])(implicit enc: CsvEncoder[A]): String =
  values.map(value => enc.encode(value).mkString(",")).mkString("\n")
```

We'll test `writeCsv` with some test data:

```tut:book:silent
val employees: List[Employee] = List(
  Employee("Bill", 1, true),
  Employee("Peter", 2, false),
  Employee("Milton", 3, false)
)
```

When we call `writeCsv`,
the compiler calculates the value of the type parameter
and searches for an implicit `CsvEncoder`
of the corresponding type:

```tut:book
writeCsv(employees)
```

We can use `writeCsv` with any data type we like,
provided we have a corresponding implicit `CsvEncoder` in scope:

```tut:book:silent
case class IceCream(name: String, numCherries: Int, inCone: Boolean)

implicit val iceCreamEncoder: CsvEncoder[IceCream] =
  new CsvEncoder[IceCream] {
    def encode(i: IceCream): List[String] =
      List(
        i.name,
        i.numCherries.toString,
        if(i.inCone) "yes" else "no"
      )
  }

val iceCreams: List[IceCream] = List(
  IceCream("Sundae", 1, false),
  IceCream("Cornetto", 0, true),
  IceCream("Banana Split", 0, false)
)
```

```tut:book
writeCsv(iceCreams)
```

### Resolving instances

Type classes are very flexible
but they require us to define instances
for every type we care about.
Fortunately, the Scala compiler has a few tricks up its sleeve
to resolve instances for us given sets of user-defined rules.
For example, we can write a rule
that creates a `CsvEncoder` for `(A, B)`
given `CsvEncoders` for `A` and `B`:

```tut:book:silent
implicit def pairEncoder[A, B](
  implicit
  aEncoder: CsvEncoder[A],
  bEncoder: CsvEncoder[B]
): CsvEncoder[(A, B)] =
  new CsvEncoder[(A, B)] {
    def encode(pair: (A, B)): List[String] = {
      val (a, b) = pair
      aEncoder.encode(a) ++ bEncoder.encode(b)
    }
  }
```

When all the parameters to an `implicit def`
are themselves marked as `implicit`,
the compiler can use it as a resolution rule
to create instances from other instances.
For example, if we call `writeCsv`
and pass in a `List[(Employee, IceCream)]`,
the compiler is able to combine
`pairEncoder`, `employeeEncoder`, and `iceCreamEncoder`
to produce the required `CsvEncoder[(Employee, IceCream)]`:

```tut:book
writeCsv(employees zip iceCreams)
```

Given a set of rules
encoded as `implicit vals` and `implicit defs`,
the compiler is capable of *searching* for
combinations to give it the required instances.
This behaviour, known as "implicit resolution",
is what makes the type class pattern so powerful in Scala.

Even with this power,
the compiler can't pull apart
our case classes and sealed traits.
We are required to define instances for ADTs by hand.
Shapeless' generic representations change all of this,
allowing us to derive instances for any ADT for free.

### Idiomatic type class definitions {#sec:generic:idiomatic-style}

The commonly accepted idiomatic style for type class definitions
includes a companion object containing some standard methods:

```tut:book:silent
object CsvEncoder {
  // "Summoner" method
  def apply[A](implicit enc: CsvEncoder[A]): CsvEncoder[A] =
    enc

  // "Constructor" method
  def instance[A](func: A => List[String]): CsvEncoder[A] =
    new CsvEncoder[A] {
      def encode(value: A): List[String] =
        func(value)
    }

  // Globally visible type class instances
}
```

The `apply` method, known as a "summoner" or "materializer",
allows us to summon a type class instance given a target type:

```tut:book
CsvEncoder[IceCream]
```

In simple cases the summoner does the same job as
the `implicitly` method defined in `scala.Predef`:

```tut:book
implicitly[CsvEncoder[IceCream]]
```

However,
as we will see in Section [@sec:type-level-programming:depfun],
when working with shapeless we encounter situations
where `implicitly` doesn't infer types correctly.
We can always define the summoner method to do the right thing,
so it's worth writing one for every type class we create.
We can also use a special method from shapeless called "`the`"
(more on this later):

```tut:book:silent
import shapeless._
```

```tut:book
the[CsvEncoder[IceCream]]
```

The `instance` method, sometimes named `pure`,
provides a terse syntax for creating new type class instances,
reducing the boilerplate of anonymous class syntax:

```tut:book:silent
implicit val booleanEncoder: CsvEncoder[Boolean] =
  new CsvEncoder[Boolean] {
    def encode(b: Boolean): List[String] =
      if(b) List("yes") else List("no")
  }
```

down to something much shorter:

```tut:book:invisible
import CsvEncoder.instance
```

```tut:book:silent
implicit val booleanEncoder: CsvEncoder[Boolean] =
  instance(b => if(b) List("yes") else List("no"))
```

Unfortunately,
several limitations of typesetting code in a book
prevent us writing long singletons
containing lots of methods and instances.
We therefore tend to describe definitions
outside of their context in the companion object.
Bear this in mind as you read
and check the accompanying repo
linked in Section [@sec:intro:source-code]
for complete worked examples.
