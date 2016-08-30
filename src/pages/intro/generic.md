## What is generic programming?

As Scala developers, we are used to writing types.
We rely on them to prevent bugs and document our code.
Types are useful because they are specific:
they ensure we only use certain data in certain contexts,
and they guide us toward correct solutions when we are coding.

Sometimes, however, types are *too* specific.
There are situations where we want to exploit
similarities between different types.
Scala doesn't make this easy for us.
For example, consider the following types:

```tut:book
case class Employee(name: String, number: Int, manager: Boolean)

case class IceCream(name: String, numCherries: Int, inCone: Boolean)
```

These case classes represent completely different kinds of data
but they have clear similarities:
they both contain three fields of the same types.
Suppose we want to implement a generic operation
such as serializing to a CSV file.
Despite the similarity between the two types,
we have to write two separate methodsto achieve this:

```tut:book
def employeeCsv(e: Employee): List[String] =
  List(e.name, e.number.toString, e.manager.toString)

def cocktailCsv(c: IceCream): List[String] =
  List(c.name, c.numCherries.toString, c.inCone.toString)
```

Generic programming is about overcoming these differences
(and many other deeper differences).
Shapeless makes it convenient to convert situational types like these
to *generic representations* that we can manipulate with common code.
For example, we can convert employees and ice creams
to values of the same generic representation type as follows
(don't worry if you don't follow this yet---we'll go through this code
in detail in later chapters):

```tut:book
import shapeless._

val employee = Employee("Dave", 123, false)
val iceCream = IceCream("Sundae", 1, false)

val generic1 = Generic[Employee].to(employee)
val generic2 = Generic[IceCream].to(iceCream)
```

Now that both sets of data are the same type,
we can serialize them with the same function:

```tut:book
def genericCsv(gen: String :: Int :: Boolean :: HNil): List[String] =
  List(gen(0), gen(1).toString, gen(2).toString)

genericCsv(generic1)
genericCsv(generic2)
```

But this is only scratching the surface of what shapeless can do for us.
Shapeless' generic representations can be
decomposed and traversed at compile time.
Rather than write a function to serialize
a single generic representation,
we can write functions that serialize *all* generic representations.
This allows us to eliminate huge amounts of boilerplate,
making application code easier to read, write, and maintain.
