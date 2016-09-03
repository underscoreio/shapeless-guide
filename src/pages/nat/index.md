// <!--
// # Counting with Types
//
// From time to time we may need to count things at the type level.
// For example, we may need to know the length of an `HList`
// or the number of terms we have expanded so far in a computation.
// This chapter covers the theory behind counting with types,
// and provides a few use cases related to type class derivation.
//
// ## Representing numbers as types
//
// Shapeless uses "church encoding"
// to represent natural numbers at the type level.
// It provides a type `Nat` with two subtypes:
// `_0` representing zero,
// and `Succ[N]` representing the successor of `N`:
//
// ```tut:book
// import shapeless.{Nat, Succ}
//
// type Zero = Nat._0
// type One  = Succ[Zero]
// type Two  = Succ[One]
// // etc...
// ```
//
// `Nat` has no runtime semantics.
// We have to use the `ToInt` type class
// to convert a `Nat` to a runtime `Int`:
//
// ```tut:book
// import shapeless.ops.nat.ToInt
//
// val toInt = implicitly[ToInt[Two]]
//
// toInt.apply()
// ```
//
// Shapeless also provides a type class `Length`
// that calculates the length of an `HList`:
//
// ```tut:book
// import shapeless.{HList, ::, HNil},
       // shapeless.ops.hlist.Length
//
// val len = implicitly[Length[String :: Int :: Boolean :: HNil]]
//
// type N = len.Out
//
// implicitly[ToInt[N]].apply()
// ```
//
// Let's use this in a concrete example:
// calculating the number of fields in a case class.
// To do this we need three things:
//
// 1. a `Generic` to calculate the corresponding `HList` type;
// 2. a `Length` to calculate the length of the `HList` as a `Nat`;
// 3. a `ToInt` to convert the `Nat` to an `Int`.
//
// We have to do all of this computation at the type level:
// so we'll do it by creating our own type class.
// We'll call it `LengthOf`:
//
// ```tut:book
// case class LengthOf[A](value: Int)
//
// implicit def genericLengthOf[A, L <: HList, N <: Nat](
  // implicit
  // generic: Generic.Aux[A, L],
  // length: Length.Aux[L, N],
  // toInt: ToInt[N]
// ): LengthOf[A] = LengthOf(toInt.apply())
//
// def lengthOf[A](implicit lengthOf: LengthOf[A]): Int =
  // lengthOf.value
//
// case class IceCream(name: String, numCherries: Int, inCone: Boolean)
//
// lengthOf[IceCream]
// ```
//
// - Compelling examples
   // - Always seeding `Random` with the same number
   // - Padding CSV output with the length of the lists
   // -
//
// - `Nat`
   // - How the types work
   // - How to create a `Nat`
   // - How to convert a `Nat` to an `Int`
//
// - `Sized`
//
// -->