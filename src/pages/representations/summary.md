## Summary

In this chapter we discussed the generic representations
shapeless provides for algebraic data types in Scala:
`HLists` for product types and `Coproducts` for coproduct types.
We also introduced the `Generic` type class
to map back and forth between concrete ADTs and their generic representations.
We haven't yet discussed why generic encodings are so attractive.
The one use case we did cover---converting between ADTs---is
fun but not tremendously useful.

The real power of `HLists` and `Coproducts` comes from their recursive structure.
We can write code to traverse representations
and calculate values from their constituent elements.
In the next chapter we will look at our first real use case:
automatically deriving type class instances.
