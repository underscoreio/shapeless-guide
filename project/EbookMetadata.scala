package io.underscore.ebook

import sbt._

case class EbookMetadata(
  pandocArgs : Option[Seq[String]],
  pages      : Option[Seq[String]]
) {
  def merge(that: EbookMetadata): EbookMetadata =
    EbookMetadata(
      pandocArgs  = (this.pandocArgs, that.pandocArgs) match {
                case ( Some(a) , Some(b) ) => Some(a ++ b)
                case ( Some(a) , None    ) => Some(a)
                case ( None    , Some(b) ) => Some(b)
                case ( None    , None    ) => None
              },
      pages = this.pages orElse that.pages
    )
}

object EbookMetadata {
  import net.jcazevedo.moultingyaml._
  import net.jcazevedo.moultingyaml.DefaultYamlProtocol._

  implicit val format = yamlFormat2(apply)

  def read(source: File): EbookMetadata =
    IO.read(source).parseYaml.convertTo[EbookMetadata]
}
