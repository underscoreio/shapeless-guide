# TODOs

Still to do:

  - Mention SI-7046 in Chapter 3
  - Complete the "debugging" section in Chapter 4
  - Maybe type class instance selection in Chapter 4
    - Low and high priority
    - `LowPriorityImplicit`
  - **DONE** Built-in `HList` and `Coproduct` operations
    - **DONE** Migrating case class as a basic example
  - **DONE** Polymorphic functions
    - **DONE** Mapping over `HLists` as an example
  - **DONE** Counting with `Nat`
    - **DONE** Generating `Arbitrary` instances as an example
  - Callout box on quirkiness of type inference with poly:
    - `val len1: Int = lengthPoly("foo")` fails, but...
    - `val len2      = lengthPoly("foo")` compiles, but...
    - `val len3: Int = lengthPoly[String]("foo")` fails
  - Generic applied to tuples
  - Built-in record operations
  - Performance
    - `cachedImplicit`
    - Maybe `Cached`
    - Maybe
  - Check cross references
  - Final summary
  - **SHIP IT!**
