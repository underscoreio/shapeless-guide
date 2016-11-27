# Notes

This stuff won't be here when the book is done.

## Outline

TODO: Introduce `illTyped` wherever makes sense.

 - DONE Introduction

    - What is generic programming?
       - Abstracting over types
       - Abstracting over arity
    - Patterns in our code
       - Algebraic data types
       - Type classes
    - The rest of this book

 - DONE Generic representations

    - Products and coproducts
       - `HList`
       - `Coproduct`
    - `Generic`
       - Converting to/from generic representations
       - Converting between different specific representations

  - Deriving type class instances

     - Example using `Generic` and products
        - `Lazy` (probably)
        - `Strict` (maybe)
     - Example using `Generic`, products, and coproducts

  - Making use of field and type names

     - `Witness` and singleton types
        - `Widen` and `Narrow`, `SingletonOps`
        - `narrow` from `shapeless.syntax.singleton`
     - `LabelledGeneric`
        - `FieldType`, `KeyTag`, `field`
        - `->>` from `shapeless.syntax.singleton`

  - Other useful tools
     - `Typeable`
     - `Annotation` and `Annotations`
     - `Default`, `Default.AsRecord`, and `Default.AsOptions`

 - Counting with types
    - `Nat`
    - `ToInt`

 - Working with tuples
    - `Tupler`
    - `shapeless.Tuple.fill` (depends on `Nat`)

 - Working with functions

    - `FnFromProduct` and `FnToProduct`
    - `shapeless.syntax.std.function.{fromProduct, toProduct}`
    - `ProductArgs` and `FromProductArgs` ??

 - Performance concerns
    - `Cached`
    - `Lazy` and `Strict`
    - `cachedImplicit`

 - Working with HLists
    - go through the most common ops from the use cases

 - Working with tuples
    - this would be a short section
    - relate a lot of this back to HLists

 - Working with coproducts
    - go through the most common ops from the use cases

 - Working with records (include this? not used much)
    - What is a record?
    - these in no particular order
    - `Keys`
    - `RemoveAll`
    - `Remover`
    - `Selector`
    - `Values`

 - Polymorphic functions (include this? not used much)
    - `Poly` and `Case`

 - Dealing with higher kinds (include this? not used much)
    - `Generic1`
    - `IsHCons1`
    - `IsCCons1`
