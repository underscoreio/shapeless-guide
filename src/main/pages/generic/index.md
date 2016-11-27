# Automatically deriving type class instances {#sec:generic}

In the last chapter we saw how the `Generic` type class
allowed us to convert any instance of an ADT to
a generic encoding made of `HLists` and `Coproducts`.
In this chapter we will look at our first serious use case:
automatic derivation of type class instances.
