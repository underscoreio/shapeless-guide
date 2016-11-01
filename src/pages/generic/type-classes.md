## Recap: type classes {#sec:generic:type-classes}

Before we get into the depths of instance derivation,
let's quickly recap on the important aspects of type classes.

Type classes are a programming pattern borrowed from Haskell
(the word "class" has nothing to do with
classes in object oriented programming).
We encode them in Scala using traits and implicit parameters.
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
for each type we care about:

```tut:book:silent
// Helper method for creating CsvEncoder instances:
def createEncoder[A](func: A => List[String]): CsvEncoder[A] =
  new CsvEncoder[A] {
    def encode(value: A): List[String] =
      func(value)
  }

// Custom data type:
case class Employee(name: String, number: Int, manager: Boolean)

// CsvEncoder instance for the custom data type:
implicit val employeeEncoder: CsvEncoder[Employee] =
  createEncoder(e => List(
    e.name,
    e.number.toString,
    if(e.manager) "yes" else "no"
  ))
```

We mark each instance with the keyword `implicit`,
and define a generic *entry point* method
that accepts an implicit parameter of the corresponding type:

```tut:book:silent
def writeCsv[A](values: List[A])(implicit enc: CsvEncoder[A]): String =
  values.map(value => enc.encode(value).mkString(",")).
    mkString("\n")
```

When we call the entry point,
the compiler calculates the value of the type parameter
and searches for an implicit `CsvWriter`
of the corresponding type:

```tut:book:silent
val employees: List[Employee] = List(
  Employee("Bill", 1, true),
  Employee("Peter", 2, false),
  Employee("Milton", 3, false)
)
```

```tut:book
// The compiler inserts a CsvEncoder[Employee] parameter:
writeCsv(employees)
```

We can use `writeCsv` with any data type we like,
provided we have a corresponding implicit `CsvEncoder` in scope:

```tut:book:silent
case class IceCream(name: String, numCherries: Int, inCone: Boolean)

implicit val iceCreamEncoder: CsvEncoder[IceCream] =
  createEncoder(i => List(
    i.name,
    i.numCherries.toString,
    if(i.inCone) "yes" else "no"
  ))

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
  createEncoder {
    case (a, b) =>
      aEncoder.encode(a) ++ bEncoder.encode(b)
  }
```

When all the parameters to an `implicit def`
are themselves marked as `implicit`,
the compiler can use it as a *resolution rule*
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
is what makes the type class pattern so powerful.

Even with this power,
the compiler can't pull apart
our case classes and sealed traits.
We are required to define instances for ADTs by hand.
Shapeless' generic representations change all of this,
allowing us to derive instances for any ADT for free.
