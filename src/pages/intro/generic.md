## What is generic programming?

Types are helpful because they are specific:
they show us how different pieces of code fit together,
help us prevent bugs,
and guide us toward solutions when we code.

Sometimes, however, types are *too* specific.
There are situations where we want
to exploit similarities between types to avoid repetition.
For example, consider the following definitions:

```tut:book:silent
case class Employee(name: String, number: Int, manager: Boolean)

case class IceCream(name: String, numCherries: Int, inCone: Boolean)
```

These two case classes represent different kinds of data
but they have clear similarities:
they both contain three fields of the same types.
Suppose we want to implement a generic operation
such as serializing to a CSV file.
Despite the similarity between the two types,
we have to write two separate serialization methods:

```tut:book:silent
def employeeCsv(e: Employee): List[String] =
  List(e.name, e.number.toString, e.manager.toString)

def iceCreamCsv(c: IceCream): List[String] =
  List(c.name, c.numCherries.toString, c.inCone.toString)
```

Generic programming is about overcoming differences like these.
Shapeless makes it convenient to convert specific types
into generic ones that we can manipulate with common code.

For example, we can use the code below to
convert employees and ice creams to values of the same type.
Don't worry if you don't follow this example yet---we'll
get to grips with the various concepts later on:

```tut:book:silent
import shapeless._
```

```tut:book
val genericEmployee = Generic[Employee].to(Employee("Dave", 123, false))
val genericIceCream = Generic[IceCream].to(IceCream("Sundae", 1, false))
```

Both values are now of the same type.
They are both heterogeneous lists (`HLists` for short)
containing a `String`, an `Int`, and a `Boolean`.
We'll look at `HLists` and the important role they play soon.
For now the point is that we can serialize each value
with the same function:

```tut:book:silent
def genericCsv(gen: String :: Int :: Boolean :: HNil): List[String] =
  List(gen(0), gen(1).toString, gen(2).toString)
```

```tut:book
genericCsv(genericEmployee)
genericCsv(genericIceCream)
```

This example is basic
but it hints at the essence of generic programming.
We reformulate problems so we can solve them using generic building blocks,
and write small kernels of code that work with a wide variety of types.
Generic programming with shapeless
allows us to eliminate huge amounts of boilerplate,
making Scala applications easier to read, write, and maintain.

Does that sound compelling? Thought so. Let's jump in!
