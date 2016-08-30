## Summary

In this chapter we introduced the concept of "algebraic data types":
types made up of conjunctions (products)
and disjunctions (coproducts) of other types.
We discussed the standard encodings of ADTs in Scala:
case classes for products and sealed traits for coproducts.

We also discussed alternative encodings of ADTs:
"specific" encodings that discourage interoperability,
and "generic" encodings that promote it.
We described the generic encodings used by shapeless---`HLists` for products
and `Coproducts` for their namesake---and
introduced the `Generic` type class that shapeless provides
to convert back and forth between standard ADTs and generic encodings.

We haven't yet discussed why generic encodings are so attractive.
The immediate use cases---converting between equivalent ADTs---are perhaps underwhelming.
In the next chapter we will look at our first real use case for
`HLists`, `Coproducts`, and `Generic`:
automatically deriving type class instances without boilerplate.
