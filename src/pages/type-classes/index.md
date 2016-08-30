# Deriving type class instances with *Generic*

In the last chapter we saw how the `Generic` type class
allowed us to convert any instance of an ADT to
a generic encoding made of `HLists` and `Coproducts`.
In this chapter we will look at our first serious use case:
automatically derivation of type class instances.

## Recap: type classes

Before we get into the depths of instance derivation,
let's quickly recap on the important aspects of type classes.

Type classes are a programming pattern borrowed from Haskell
(the word "class" has nothing to do with
classes in object oriented programming).
We encode them in Scala using traits and implicit parameters.
A *type class* is a generic trait
representing some sort of general functionality
that we would like to apply to a wide range of types:

```tut:book
trait CsvEncoder[A] {
  def encode(value: A): List[String]
}
```

We implement our type class with *instances* for each type we care about:
```tut:book
case class Employee(name: String, number: Int, manager: Boolean)

val employees = List(
  Employee("Bill", 1, true),
  Employee("Peter", 2, false),
  Employee("Milton", 3, false)
)

implicit val employeeEncoder: CsvEncoder[Employee] =
  new CsvEncoder[Employee] {
    def encode(e: Employee): List[String] =
      List(e.name, e.number.toString, if(e.manager) "yes" else "no")
  }
```

Given the type class and a set of instances,
we can write methods that look up `CsvEncoder` parameters by type:

```tut:book
def writeCsv[A](values: List[A])(implicit encoder: CsvEncoder[A]): String =
  values.map(encoder.encode).map(_.mkString(",")).mkString("\n")

writeCsv(employees)
```

Our `writeCsv` method is capable of serializing any data type `A`
as long as we define a `CsvEncoder[A]` and place it in implicit scope:

```tut:book
case class IceCream(name: String, numCherries: Int, inCone: Boolean)

implicit val iceCreamEncoder: CsvEncoder[IceCream] =
  new CsvEncoder[IceCream] {
    def encode(i: IceCream): List[String] =
      List(i.name, i.numCherries.toString, if(i.inCone) "cone" else "glass")
  }

val iceCreams = List(
  IceCream("Sundae", 1, false),
  IceCream("Cornetto", 0, true),
  IceCream("Banana Split", 0, false)
)

writeCsv(iceCreams)
```

### Type class instance derivation

Descriptions of type classes often
overlook one of their most powerful aspects:
the compiler's ability to *derive* instances based on rules we provide.

For example, given that we have `CsvEncoders` for `Employee` and `IceCream`,
we can derive an encoder for `(Employee, IceCream)` pairs:

```tut:book
implicit def pairEncoder[A, B](
  implicit
  aEncoder: CsvEncoder[A],
  bEncoder: CsvEncoder[B]
): CsvEncoder[(A, B)] =
  new CsvEncoder[(A, B)] {
    def encode(value: (A, B)): List[String] = {
      val (a, b) = value
      aEncoder.encode(a) ++ bEncoder.encode(b)
    }
  }

writeCsv(employees zip iceCreams)
```

When expanding the call `writeCsv`,
the compiler is able to automatically combine the rules for
`pairEncoder`, `employeeEncoder`, and `iceCreamEncoder`
to produce the `CsvEncoder[(Employee, IceCream)]` it needs
for the implicit `encoder` parameter.
And this is just the tip of the iceberg:
given a set of rules encoded as `implicit vals` and `implicit defs`,
the compiler is capable of *searching* for
complex combinations that give us the type we need.

This behaviour, known as "implicit search",
is what makes type classes so powerful.
it is also the behaviour we are going to exploit
to derive type class instances automatically using shapeless
with almost no boilerplate.
