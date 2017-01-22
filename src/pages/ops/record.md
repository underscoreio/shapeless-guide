## Record ops {#sec:ops:record}

We've spent some time in this chapter
looking at type classes from the
`shapeless.ops.hlist` and `shapeless.ops.coproduct` packages.
We mustn't leave without mentioning a third important package:
`shapeless.ops.record`.

Shapeless' "record ops" provide `Map`-like
operations on `HLists` of tagged elements.
Here are a handful of examples involving ice creams:

```tut:book:silent
import shapeless._

case class IceCream(name: String, numCherries: Int, inCone: Boolean)
```

```tut:book
val sundae = LabelledGeneric[IceCream].
  to(IceCream("Sundae", 1, false))
```

Unlike the `HList` and `Coproduct` ops we have seen already,
record ops syntax requires an explicit import from `shapeless.record`:

```tut:book:silent
import shapeless.record._
```

### Selecting fields

The `get` extension method
and its corresponding `Selector` type class
allow us to fetch a field by tag:

```tut:book
sundae.get('name)
```

```tut:book
sundae.get('numCherries)
```

Attempting to access an undefined field
causes a compile error as we might expect:

```tut:book:fail
sundae.get('nomCherries)
```

### Updating and removing fields

The `updated` method and `Updater` type class allow us to modify fields by key.
The `remove` method and `Remover` type class allow us to delete fields by key:

```tut:book
sundae.updated('numCherries, 3)
```

```tut:book
sundae.remove('inCone)
```

The `updateWith` method and `Modifier` type class allow us
to modify a field with an update function:

```tut:book
sundae.updateWith('name)("MASSIVE " + _)
```

### Converting to a regular *Map*

The `toMap` method and `ToMap` type class
allow us to convert a record to a `Map`:

```tut:book
sundae.toMap
```

### Other operations

There are other record ops that we don't have room to cover here.
We can rename fields, merge records, map over their values, and much more.
See the source code of `shapeless.ops.record` and `shapeless.syntax.record`
for more information.
