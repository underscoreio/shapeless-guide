## Libraries

### Select well-known libraries using shapeless

*argonaut-shapeless*

JSON codec derivation.

 - shapeless.Cached
 - shapeless.LowPriority
 - shapeless.Strict
 - shapeless.Widen
 - shapeless.Witness
 - shapeless.labelled.field
 - shapeless.labelled.FieldType
 - shapeless.nat
 - shapeless.tag
 - shapeless.test.illTyped

*circe*

JSON codec derivation, partial JSON codecs.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.LabelledGeneric
 - shapeless.Lazy
 - shapeless.Nat
 - shapeless.Witness
 - shapeless.labelled.field
 - shapeless.labelled.FieldType
 - shapeless.labelled.KeyTag
 - shapeless.ops.function.FnFromProduct
 - shapeless.ops.record.RemoveAll
 - shapeless.test.illTyped

*doobie*

Reading/writing data from SQL/result-sets.

 - shapeless.HList
 - shapeless.Generic
 - shapeless.Lazy
 - shapeless.labelled.field
 - shapeless.labelled.FieldType
 - shapeless.ops.hlist.IsHCons
 - shapeless.test.illTyped

*Ensime*

JSON formats for wire protocols (Jerky and Swanky).

 - shapeless.cachedImplicit
 - shapeless.HList
 - shapeless.Poly1
 - shapeless.Typeable
 - shapeless.Generic
 - shapeless.syntax.typeable._

*Finch*

Type-safe DSL for creating and combining endpoints.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Generic
 - shapeless.Witness
 - shapeless.DepFn2
 - shapeless.Poly1
 - shapeless.poly.Case (TODO: The interesting stuff here is in FromParams.scala)
 - shapeless.poly.Case1
 - shapeless.ops.adjoin.Adjoin
 - shapeless.ops.hlist.Tupler
 - shapeless.labelled.FieldType, field
 - shapeless.ops.function.FnToProduct

*Frameless*

Reading/writing data from Spark datasets/dataframes.

 - shapeless.HList
 - shapeless.Generic
 - shapeless.LabelledGeneric
 - shapeless.Lazy
 - shapeless.ProductArgs
 - shapeless.SingletonProductArgs
 - shapeless.Witness
 - shapeless.labelled.FieldType
 - shapeless.ops.hlist.Prepend
 - shapeless.ops.hlist.ToTraversable
 - shapeless.ops.hlist.Tupler
 - shapeless.ops.record.Selector
 - shapeless.test.illTyped

*kittens*

Equivalent of shapeless-contrib-scalaz for Cats.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Lazy
 - shapeless.Generic
 - shapeless.Generic1
 - shapeless.LabelledGeneric
 - shapeless.Poly
 - shapeless.Const
 - shapeless.Id
 - shapeless.Cached (TODO: related to cachedImplicit?)
 - shapeless.IsHCons1
 - shapeless.IsCCons1
 - shapeless.Split1
 - shapeless.ProductArgs
 - shapeless.pack, unpack, fh, ft, fo, fi (TODO: what are these?)
 - shapeless.ops.function.FnToProduct
 - shapeless.ops.function.FnFromProduct
 - shapeless.ops.hlist.Mapper
 - shapeless.ops.hlist.ZipWithKeys
 - shapeless.ops.record.Keys
 - shapeless.ops.record.Values
 - shapeless.syntax.std.function.toProduct, fromProduct

*Monocle*

Provides accessories for shapeless products/coproducts etc,
rather than using shapeless to provide other functionality.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Generic
 - shapeless.Nat
 - shapeless.ops.coproduct.Inject
 - shapeless.ops.coproduct.Selector
 - shapeless.ops.hlist.At
 - shapeless.ops.hlist.Init
 - shapeless.ops.hlist.IsHCons
 - shapeless.ops.hlist.Last
 - shapeless.ops.hlist.Prepend
 - shapeless.ops.hlist.ReplaceAt
 - shapeless.ops.hlist.Reverse
 - shapeless.ops.hlist.Tupler
 - shapeless.ops.tuple.Reverse

*refined*

Various kinds of refined types.

 - shapeless.Nat
 - shapeless.Witness
 - shapeless.ops.nat.ToInt
 - shapeless.test.illTyped

*parboiled2*

TODO: Summarise parboiled2's use of shapeless.

 - shapeless.HList
 - shapeless.ops.hlist.Prepend
 - shapeless.ops.hlist.ReversePrepend

*scalamo*

DynamoDB driver for Scala.

TODO: Document scalamo's use of shapeless.

*scodec*

TODO: Summarise scodec's use of shapeless.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.DepFn1
 - shapeless.Lazy
 - shapeless.Typeable
 - shapeless.Sized
 - shapeless.Nat
 - shapeless.Generic
 - shapeless.LabelledGeneric
 - shapeless.=:!= <-- nice !!
 - shapeless.*->* <-- whaaat ??
 - shapeless.UnaryTCConstraint <-- whaaat ??
 - shapeless.labelled.FieldType
 - shapeless.Poly
 - shapeless.poly.Case
 - shapeless.poly.~>
 - shapeless.ops.hlist.Reverse
 - shapeless.ops.hlist.Prepend
 - shapeless.ops.hlist.RightFolder
 - shapeless.ops.hlist.Init
 - shapeless.ops.hlist.Last
 - shapeless.ops.hlist.Length
 - shapeless.ops.hlist.Mapper
 - shapeless.ops.hlist.Split
 - shapeless.ops.nat.ToInt
 - shapeless.ops.coproduct.Inject
 - shapeless.ops.coproduct.Length
 - shapeless.ops.coproduct.Selector
 - shapeless.ops.coproduct.Sized
 - shapeless.ops.coproduct.Align
 - shapeless.ops.record.Keys
 - shapeless.ops.record.Remover
 - shapeless.ops.union.Keys
 - shapeless.syntax.sized.sized(size)

*shapeless-contrib (scalacheck component)*

Spire type class instance derivation.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Orphan
 - shapeless.TypeClass
 - shapeless.TypeClassCompanion

*shapeless-contrib (scalaz component)*

Scalaz type class instance derivation.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Lazy
 - shapeless.Lens
 - shapeless.Poly
 - shapeless.TypeClass
 - shapeless.TypeClassCompanion
 - shapeless.ops.function.Apply
 - shapeless.ops.function.FnToProduct, FnFromProduct
 - shapeless.ops.hlist.Mapper
 - shapeless.ops.hlist.Sequencer
 - shapeless.syntax.std.function._

Questions:

 - When would one use this over other lens implementations (esp. Monocle)?

*shapeless-contrib (spire component)*

Spire type class instance derivation.

 - shapeless.HList
 - shapeless.Orphan
 - shapeless.ProductTypeClass
 - shapeless.ProductTypeClassCompanion

*spray-json-shapeless*

JSON codec derivation.

 - shapeless.LabelledGeneric
 - shapeless.Typeable
 - shapeless.labelled.field
 - shapeless.labelled.FieldType

### Select smaller-scale libraries using shapeless

*akka-stream-extensions*

Model streams of coproducts; dispatch to coproducts of streams.

 - shapeless.ops.coproduct.Inject
 - shapeless.ops.coproduct.Length
 - shapeless.ops.nat.Nat
 - shapeless.ops.nat.ToInt

*bulletin*

(type class instance derivation)

 - shapeless.HList
 - shapeless.Lazy
 - shapeless.Witness
 - shapeless.LabelledGeneric
 - shapeless.labelled.field
 - shapeless.labelled.FieldType
 - shapeless.test.illTyped

*case-app*

Command line parameter parsing.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Typeable
 - shapeless.Witness
 - shapeless.Generic
 - shapeless.LabelledGeneric
 - shapeless.DepFn0
 - shapeless.CaseClassMacros <-- what is this?
 - shapeless.@@ (or custom variant thereof)
 - shapeless.compat.Annotation, Annotations <-- what is this?
 - shapeless.compat.Default, Default.AsOptions <-- what is this?
 - shapeless.compat.Strict <-- what is this?
 - shapeless.labelled.field
 - shapeless.labelled.FieldType

*diff*

Calculate differences between two data structures.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Lazy
 - shapeless.Witness
 - shapeless.LabelledGeneric
 - shapeless.labelled.FieldType

*PureCSV (??)*

CSV codec derivation.

 - shapeless.HList
 - shapeless.Generic

*PureConfig*

Automatic config reader derivation.

 - shapeless.HList
 - shapeless.Coproduct
 - shapeless.Lazy
 - shapeless.Witness
 - shapeless.LabelledGeneric
 - shapeless.labelled.field
 - shapeless.labelled.FieldType

*slickless*

Slick/shapeless integration.

 - shapeless.HList
 - shapeless.Generic

*value-wrapper*

Wrap and unwrap value classes.

 - shapeless.HList
 - shapeless.Generic
 - shapeless.Lazy

### Transposed dependencies (what uses what)

Bits of shapeless and what uses them:

 - shapeless.*->*                            -- scodec
 - shapeless.=:!=                            -- scodec
 - shapeless.@@                              -- case-app
 - shapeless.Cached                          -- argonaut-shapeless
 - shapeless.Cached                          -- kittens
 - shapeless.cachedImplicit                  -- ensime
 - shapeless.CaseClassMacros                 -- case-app
 - shapeless.compat.Annotation               -- case-app
 - shapeless.compat.Annotations              -- case-app
 - shapeless.compat.Default                  -- case-app
 - shapeless.compat.Default.AsOptions        -- case-app
 - shapeless.compat.Strict                   -- case-app
 - shapeless.Const                           -- kittens
 - shapeless.Coproduct                       -- case-app
 - shapeless.Coproduct                       -- circe
 - shapeless.Coproduct                       -- diff
 - shapeless.Coproduct                       -- finch
 - shapeless.Coproduct                       -- kittens
 - shapeless.Coproduct                       -- monocle
 - shapeless.Coproduct                       -- PureConfig
 - shapeless.Coproduct                       -- scodec
 - shapeless.Coproduct                       -- shapeless-contrib/scalacheck
 - shapeless.Coproduct                       -- shapeless-contrib/scalaz
 - shapeless.DepFn0                          -- case-app
 - shapeless.DepFn1                          -- scodec
 - shapeless.DepFn2                          -- finch
 - shapeless.fh                              -- kittens
 - shapeless.fi                              -- kittens
 - shapeless.fo                              -- kittens
 - shapeless.ft                              -- kittens
 - shapeless.Generic                         -- case-app
 - shapeless.Generic                         -- doobie
 - shapeless.Generic                         -- ensime
 - shapeless.Generic                         -- finch
 - shapeless.Generic                         -- frameless
 - shapeless.Generic                         -- kittens
 - shapeless.Generic                         -- monocle
 - shapeless.Generic                         -- PureCSV
 - shapeless.Generic                         -- scodec
 - shapeless.Generic                         -- slickless
 - shapeless.Generic                         -- value-wrapper
 - shapeless.Generic1                        -- kittens
 - shapeless.HList                           -- bulletin
 - shapeless.HList                           -- case-app
 - shapeless.HList                           -- circe
 - shapeless.HList                           -- diff
 - shapeless.HList                           -- doobie
 - shapeless.HList                           -- ensime
 - shapeless.HList                           -- finch
 - shapeless.HList                           -- frameless
 - shapeless.HList                           -- kittens
 - shapeless.HList                           -- monocle
 - shapeless.HList                           -- parboiled2
 - shapeless.HList                           -- PureConfig
 - shapeless.HList                           -- PureCSV
 - shapeless.HList                           -- scodec
 - shapeless.HList                           -- shapeless-contrib/scalacheck
 - shapeless.HList                           -- shapeless-contrib/scalaz
 - shapeless.HList                           -- shapeless-contrib/spire
 - shapeless.HList                           -- slickless
 - shapeless.HList                           -- value-wrapper
 - shapeless.Id                              -- kittens
 - shapeless.IsCCons1                        -- kittens
 - shapeless.IsHCons1                        -- kittens
 - shapeless.labelled.field                  -- argonaut-shapeless
 - shapeless.labelled.field                  -- bulletin
 - shapeless.labelled.field                  -- case-app
 - shapeless.labelled.field                  -- circe
 - shapeless.labelled.field                  -- doobie
 - shapeless.labelled.field                  -- finch
 - shapeless.labelled.field                  -- PureConfig
 - shapeless.labelled.field                  -- spray-json-shapeless
 - shapeless.labelled.FieldType              -- argonaut-shapeless
 - shapeless.labelled.FieldType              -- bulletin
 - shapeless.labelled.FieldType              -- case-app
 - shapeless.labelled.FieldType              -- circe
 - shapeless.labelled.FieldType              -- diff
 - shapeless.labelled.FieldType              -- doobie
 - shapeless.labelled.FieldType              -- finch
 - shapeless.labelled.FieldType              -- frameless
 - shapeless.labelled.FieldType              -- PureConfig
 - shapeless.labelled.FieldType              -- scodec
 - shapeless.labelled.FieldType              -- spray-json-shapeless
 - shapeless.labelled.KeyTag                 -- circe
 - shapeless.LabelledGeneric                 -- bulletin
 - shapeless.LabelledGeneric                 -- case-app
 - shapeless.LabelledGeneric                 -- circe
 - shapeless.LabelledGeneric                 -- diff
 - shapeless.LabelledGeneric                 -- frameless
 - shapeless.LabelledGeneric                 -- kittens
 - shapeless.LabelledGeneric                 -- PureConfig
 - shapeless.LabelledGeneric                 -- scodec
 - shapeless.LabelledGeneric                 -- spray-json-shapeless
 - shapeless.Lazy                            -- bulletin
 - shapeless.Lazy                            -- circe
 - shapeless.Lazy                            -- diff
 - shapeless.Lazy                            -- doobie
 - shapeless.Lazy                            -- frameless
 - shapeless.Lazy                            -- kittens
 - shapeless.Lazy                            -- PureConfig
 - shapeless.Lazy                            -- scodec
 - shapeless.Lazy                            -- shapeless-contrib/scalaz
 - shapeless.Lazy                            -- value-wrapper
 - shapeless.Lens                            -- shapeless-contrib/scalaz
 - shapeless.LowPriority                     -- argonaut-shapeless
 - shapeless.nat                             -- argonaut-shapeless
 - shapeless.Nat                             -- circe
 - shapeless.Nat                             -- monocle
 - shapeless.Nat                             -- refined
 - shapeless.Nat                             -- scodec
 - shapeless.ops.adjoin.Adjoin               -- finch
 - shapeless.ops.coproduct.Align             -- scodec
 - shapeless.ops.coproduct.Inject            -- akka-stream-extensions
 - shapeless.ops.coproduct.Inject            -- monocle
 - shapeless.ops.coproduct.Inject            -- scodec
 - shapeless.ops.coproduct.Length            -- akka-stream-extensions
 - shapeless.ops.coproduct.Length            -- scodec
 - shapeless.ops.coproduct.Selector          -- monocle
 - shapeless.ops.coproduct.Selector          -- scodec
 - shapeless.ops.coproduct.Sized             -- scodec
 - shapeless.ops.function.Apply              -- shapeless-contrib/scalaz
 - shapeless.ops.function.FnFromProduct      -- circe
 - shapeless.ops.function.FnFromProduct      -- kittens
 - shapeless.ops.function.FnFromProduct      -- shapeless-contrib/scalaz
 - shapeless.ops.function.FnToProduct        -- finch
 - shapeless.ops.function.FnToProduct        -- kittens
 - shapeless.ops.function.FnToProduct        -- shapeless-contrib/scalaz
 - shapeless.ops.hlist.At                    -- monocle
 - shapeless.ops.hlist.Init                  -- monocle
 - shapeless.ops.hlist.Init                  -- scodec
 - shapeless.ops.hlist.IsHCons               -- doobie
 - shapeless.ops.hlist.IsHCons               -- monocle
 - shapeless.ops.hlist.Last                  -- monocle
 - shapeless.ops.hlist.Last                  -- scodec
 - shapeless.ops.hlist.Length                -- scodec
 - shapeless.ops.hlist.Mapper                -- kittens
 - shapeless.ops.hlist.Mapper                -- scodec
 - shapeless.ops.hlist.Mapper                -- shapeless-contrib/scalaz
 - shapeless.ops.hlist.Prepend               -- frameless
 - shapeless.ops.hlist.Prepend               -- monocle
 - shapeless.ops.hlist.Prepend               -- parboiled2
 - shapeless.ops.hlist.Prepend               -- scodec
 - shapeless.ops.hlist.ReplaceAt             -- monocle
 - shapeless.ops.hlist.Reverse               -- monocle
 - shapeless.ops.hlist.Reverse               -- scodec
 - shapeless.ops.hlist.ReversePrepend        -- parboiled2
 - shapeless.ops.hlist.RightFolder           -- scodec
 - shapeless.ops.hlist.Sequencer             -- shapeless-contrib/scalaz
 - shapeless.ops.hlist.Split                 -- scodec
 - shapeless.ops.hlist.ToTraversable         -- frameless
 - shapeless.ops.hlist.Tupler                -- finch
 - shapeless.ops.hlist.Tupler                -- frameless
 - shapeless.ops.hlist.Tupler                -- monocle
 - shapeless.ops.hlist.ZipWithKeys           -- kittens
 - shapeless.ops.nat.Nat                     -- akka-stream-extensions
 - shapeless.ops.nat.ToInt                   -- akka-stream-extensions
 - shapeless.ops.nat.ToInt                   -- refined
 - shapeless.ops.nat.ToInt                   -- scodec
 - shapeless.ops.record.Keys                 -- kittens
 - shapeless.ops.record.Keys                 -- scodec
 - shapeless.ops.record.RemoveAll            -- circe
 - shapeless.ops.record.Remover              -- scodec
 - shapeless.ops.record.Selector             -- frameless
 - shapeless.ops.record.Values               -- kittens
 - shapeless.ops.tuple.Reverse               -- monocle
 - shapeless.ops.union.Keys                  -- scodec
 - shapeless.Orphan                          -- shapeless-contrib/scalacheck
 - shapeless.Orphan                          -- shapeless-contrib/spire
 - shapeless.pack                            -- kittens
 - shapeless.Poly                            -- kittens
 - shapeless.Poly                            -- scodec
 - shapeless.Poly                            -- shapeless-contrib/scalaz
 - shapeless.poly.Case                       -- finch
 - shapeless.poly.Case                       -- scodec
 - shapeless.poly.Case1                      -- finch
 - shapeless.poly.~>                         -- scodec
 - shapeless.Poly1                           -- ensime
 - shapeless.Poly1                           -- finch
 - shapeless.ProductArgs                     -- frameless
 - shapeless.ProductArgs                     -- kittens
 - shapeless.ProductTypeClass                -- shapeless-contrib/spire
 - shapeless.ProductTypeClassCompanion       -- shapeless-contrib/spire
 - shapeless.SingletonProductArgs            -- frameless
 - shapeless.Sized                           -- scodec
 - shapeless.Split1                          -- kittens
 - shapeless.Strict                          -- argonaut-shapeless
 - shapeless.syntax.sized                    -- scodec
 - shapeless.syntax.std.function._           -- shapeless-contrib/scalaz
 - shapeless.syntax.std.function.fromProduct -- kittens
 - shapeless.syntax.std.function.toProduct   -- kittens
 - shapeless.syntax.typeable._               -- ensime
 - shapeless.tag                             -- argonaut-shapeless
 - shapeless.test.illTyped                   -- argonaut-shapeless
 - shapeless.test.illTyped                   -- bulletin
 - shapeless.test.illTyped                   -- circe
 - shapeless.test.illTyped                   -- doobie
 - shapeless.test.illTyped                   -- frameless
 - shapeless.test.illTyped                   -- refined
 - shapeless.Typeable                        -- case-app
 - shapeless.Typeable                        -- ensime
 - shapeless.Typeable                        -- scodec
 - shapeless.Typeable                        -- spray-json-shapeless
 - shapeless.TypeClass                       -- shapeless-contrib/scalacheck
 - shapeless.TypeClass                       -- shapeless-contrib/scalaz
 - shapeless.TypeClassCompanion              -- shapeless-contrib/scalacheck
 - shapeless.TypeClassCompanion              -- shapeless-contrib/scalaz
 - shapeless.UnaryTCConstraint               -- scodec
 - shapeless.unpack                          -- kittens
 - shapeless.Widen                           -- argonaut-shapeless
 - shapeless.Witness                         -- argonaut-shapeless
 - shapeless.Witness                         -- bulletin
 - shapeless.Witness                         -- case-app
 - shapeless.Witness                         -- circe
 - shapeless.Witness                         -- diff
 - shapeless.Witness                         -- finch
 - shapeless.Witness                         -- frameless
 - shapeless.Witness                         -- PureConfig
 - shapeless.Witness                         -- refined
