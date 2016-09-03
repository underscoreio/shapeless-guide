## What is generic programming?

As Scala developers, we are used to types.
Types are helpful because they are specific:
they show us how different pieces of code fit together,
helping us prevent bugs,
and guiding us toward solutions when we code.

Sometimes, however, types are *too* specific.
There are situations where we want
to exploit similarities between types
to avoid repetition and boilerplate.
For example, consider the following types:

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

def cocktailCsv(c: IceCream): List[String] =
  List(c.name, c.numCherries.toString, c.inCone.toString)
```

Generic programming is about overcoming differences like these.
Shapeless makes it convenient to convert specific types
into generic ones that we can manipulate with common code.

For example, we can use the code below to
convert employees and ice creams to values of the same type.
Don't worry if you don't follow this example yet:
we'll get to grips with the concepts in play later on:

```tut:book
import shapeless._

val genericEmployee = Generic[Employee].to(Employee("Dave", 123, false))
val genericIceCream = Generic[IceCream].to(IceCream("Sundae", 1, false))
```

Now that both sets of data are the same type,
we can serialize them with the same function:

```tut:book
def genericCsv(gen: String :: Int :: Boolean :: HNil): List[String] =
  List(gen(0), gen(1).toString, gen(2).toString)

genericCsv(genericEmployee)
genericCsv(genericIceCream)
```

This example is very basic
but it hints at the essence of generic programming:
reformulating problems so we can solve them use generic building blocks,
and writing code that works with a wide variety of types as a result.
Generic programming with shapeless
allows us to eliminate huge amounts of boilerplate,
making Scala applications easier to read, write, and maintain.

Does that sound compelling? Thought so. Let's jump in!

<div class="callout callout-info">
  *Formatting in code samples*

  We're using Rob Norris' awesome tool [Tut][link-tut]
  to type check and run the code samples in this book.

  Unfortunately, as you can see,
  shapeless tends to generate verbose output
  and we haven't solved the problem of line wrapping in LaTeX yet.

  We'll address this in a future version of the book.
  In the mean time, we'll call it out manually
  when we need to reference output that's wider than the page.
</div>
