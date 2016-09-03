import shapeless._
import shapeless.ops.hlist._
import shapeless.ops.nat._
import scala.language.implicitConversions

case class IceCream(name: String, numCherries: Int, inCone: Boolean)

case class LengthOf[A](value: Int)

implicit def lengthOf[A, H <: HList, N <: Nat](
  implicit
  gen   : Generic.Aux[A, H],
  len   : Length.Aux[H, N],
  toInt : ToInt[N]
): LengthOf[A] = LengthOf(toInt.apply())

implicitly[LengthOf[IceCream]].value

implicit def failHeadOf[A, Repr](value: A)(
  implicit
  gen: Generic.Aux[A, Repr :: HNil]
): Repr = gen.to(value).head

implicit def headOf[A, Repr <: HList, H](value: A)(
  implicit
  gen: Generic.Aux[A, Repr],
  hcons: IsHCons.Aux[Repr, H, _]
): H = gen.to(value).head

headOf(Some(123))
