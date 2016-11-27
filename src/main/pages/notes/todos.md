# TODOs #{-}

Still to do:

  - Mention type class instance selection in Chapter 4
    - Low and high priority
    - `LowPriorityImplicit`
  - Function interop
  - Performance
    - `cachedImplicit`
    - Maybe `Cached`
    - Maybe
  - Check cross references
  - **DONE** Generic applied to tuples
  - **DONE** Mention SI-7046 in Chapter 3
  - **DONE** Complete the "debugging" section in Chapter 4
  - **DONE** Built-in `HList` and `Coproduct` operations
    - **DONE** Migrating case class as a basic example
  - **DONE** Polymorphic functions
    - **DONE** Mapping over `HLists` as an example
  - **DONE** Counting with `Nat`
    - **DONE** Generating `Arbitrary` instances as an example
  - **DONE** Callout box on quirkiness of type inference with poly:
    - **DONE** `val len1: Int = lengthPoly("foo")` fails, but...
    - **DONE** `val len2      = lengthPoly("foo")` compiles, but...
    - **DONE** `val len3: Int = lengthPoly[String]("foo")` fails
  - **DONE** Built-in record operations
  - **DONE** Final summary
  - **SHIP IT!**
