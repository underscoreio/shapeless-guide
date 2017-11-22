## Source code and examples {#sec:intro:source-code}

This book is open source.
You can find the [Markdown source on Github][link-book-repo].
The book receives constant updates from the community
so be sure to check the Github repo
for the most up-to-date version.

We also maintain a copy of the book
on the [Underscore web site][link-underscore-book].
If you grab a copy of the book from there
we will notify you whenever we release an update.

There are complete implementations of
the major examples in an [accompanying repo][link-code-repo].
See the README for installation details.
We assume shapeless 2.3.2 and either
Typelevel Scala 2.11.8+ or
Lightbend Scala 2.11.9+ / 2.12.1+.

Most of the examples in this book
are compiled and executed using
version 2.12.1 of the Typelevel Scala compiler.
Among other niceties
this version of Scala introduces *infix type printing*,
which cleans up the console output on the REPL:

```tut:book:invisible
import shapeless._
```

```tut:book
val repr = "Hello" :: 123 :: true :: HNil
```

If you are using an older version of Scala
you might end up with prefix type printing like this:

```scala
val repr = "Hello" :: 123 :: true :: HNil
// repr: shapeless.::[String,shapeless.::[Int,shapeless.::[Boolean,shapeless.HNil]]] = "Hello" :: 123 :: true :: HNil
```

Don't panic!
Aside from the printed form of the result
(infix versus prefix syntax),
these types are the same.
If you find the prefix types difficult to read,
we recommend upgrading to a newer version of Scala.
Simply add the following to your `build.sbt`,
substituting in contemporary version numbers as appropriate:

```scala
scalaOrganization := "org.typelevel"
scalaVersion      := "2.12.1"
```

The `scalaOrganization` setting
is only supported in SBT 0.13.13 or later.
You can specify an SBT version
by writing the following in `project/build.properties`
(create the file if it isn't there in your project):

```
sbt.version=0.13.13
```
