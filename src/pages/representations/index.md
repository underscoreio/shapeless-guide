# Algebraic data types and generic representations

The main idea behind generic programming
is to solve problems for a wide variety of types
by writing a small amount of generic code.
Shapeless provides two sets of tools to this end:

 1. a set of generic data types
    that can be inspected, traversed, and manipulated
    at the type level;

 2. automatic mapping between *algebraic data types (ADTs)*
    (encoded in Scala as case classes and sealed traits)
    and these generic representations.

In this chapter we will start by recapping
on what algebraic data types are
and why they might be familiar to Scala developers.
Then we will look at
the data types shapeless uses as generic representations
and discuss how they map on to concrete ADTs.
Finally, we will introduce a type class called `Generic`
that provides automatic mapping
back and forth between ADTs and generic representations.
We will finish with some simple examples
using `Generic` to convert values from one type to another.
