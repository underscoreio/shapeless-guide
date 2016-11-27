package io.underscore.ebook

import sbt._
import sbt.Keys._

object SbtEbook extends AutoPlugin {
  override def requires = plugins.JvmPlugin
  override def trigger  = allRequirements

  object autoImport {
    val ebook                  = taskKey[Seq[File]]("Compile all eBook targets")

    val ebookMetadataFile      = settingKey[File]("Cross-format Pandoc metadata file")
    val ebookPdfMetadataFile   = settingKey[File]("PDF-specific Pandoc metadata file")
    val ebookHtmlMetadataFile  = settingKey[File]("HTML-specific Pandoc metadata file")
    val ebookEpubMetadataFile  = settingKey[File]("ePub-specific Pandoc metadata file")
    val ebookMetadata          = settingKey[EbookMetadata]("Cross-format metadata")

    val ebookPdfTemplate       = settingKey[File]("PDF template")
    val ebookHtmlTemplate      = settingKey[File]("HTML template")
    val ebookEpubTemplate      = settingKey[File]("ePub template")

    val ebookSources           = taskKey[Seq[File]]("ePub pages")

    val ebookPdfTarget         = settingKey[File]("PDF target")
    val ebookHtmlTarget        = settingKey[File]("HTML target")
    val ebookEpubTarget        = settingKey[File]("ePub target")

    val ebookPdfCommandLine    = taskKey[String]("Pandoc PDF command line")
    val ebookHtmlCommandLine   = taskKey[String]("Pandoc HTML command line")
    val ebookEpubCommandLine   = taskKey[String]("Pandoc ePub command line")
  }

  import autoImport._

  lazy val baseEbookSettings: Seq[Def.Setting[_]] =
    Seq(
      ebookMetadataFile          := (sourceDirectory in Compile).value / "meta" / "metadata.yaml",
      ebookPdfMetadataFile       := (sourceDirectory in Compile).value / "meta" / "pdf.yaml",
      ebookHtmlMetadataFile      := (sourceDirectory in Compile).value / "meta" / "html.yaml",
      ebookEpubMetadataFile      := (sourceDirectory in Compile).value / "meta" / "epub.yaml",
      ebookMetadata              := EbookMetadata.read(ebookMetadataFile.value),

      ebookPdfTemplate           := (sourceDirectory in Compile).value / "templates" / "template.tex",
      ebookHtmlTemplate          := (sourceDirectory in Compile).value / "templates" / "template.html",
      ebookEpubTemplate          := (sourceDirectory in Compile).value / "templates" / "template.epub.html",

      ebookPdfTarget             := (target in Compile).value / s"${name.value}.pdf",
      ebookHtmlTarget            := (target in Compile).value / s"${name.value}.html",
      ebookEpubTarget            := (target in Compile).value / s"${name.value}.epub",

      sourceDirectory in ebook   := (sourceDirectory in Compile).value / "pages",
      ebookSources               := Ebook.sources((sourceDirectory in ebook).value, ebookMetadata.value),

      ebookPdfCommandLine        := Ebook.pandocCommandLine(
                                      ebookPdfTarget.value,
                                      ebookPdfTemplate.value,
                                      Seq(
                                        ebookMetadataFile.value,
                                        ebookPdfMetadataFile.value
                                      ),
                                      ebookSources.value
                                    ),
      ebookHtmlCommandLine       := Ebook.pandocCommandLine(
                                      ebookHtmlTarget.value,
                                      ebookHtmlTemplate.value,
                                      Seq(
                                        ebookMetadataFile.value,
                                        ebookHtmlMetadataFile.value
                                      ),
                                      ebookSources.value
                                    ),
      ebookEpubCommandLine       := Ebook.pandocCommandLine(
                                      ebookEpubTarget.value,
                                      ebookEpubTemplate.value,
                                      Seq(
                                        ebookMetadataFile.value,
                                        ebookEpubMetadataFile.value
                                      ),
                                      ebookSources.value
                                    )
    )

  override lazy val projectSettings =
    inConfig(Compile)(baseEbookSettings)
}

case class EbookMetadata(pages: Seq[String])

object EbookMetadata {
  import net.jcazevedo.moultingyaml._
  import net.jcazevedo.moultingyaml.DefaultYamlProtocol._

  implicit val format = yamlFormat1(apply)

  val empty = EbookMetadata(Seq.empty)

  def read(source: File): EbookMetadata =
    IO.read(source).parseYaml.convertTo[EbookMetadata]
}

object Ebook {
  import CommandLineImplicits._

  def sources(dir: File, metadata: EbookMetadata): Seq[File] =
    metadata.pages.map(dir / _)

  def pandocCommandLine(target: File, template: File, metadata: Seq[File], sources: Seq[File]): String = {
    cmd"""
    pandoc
    --smart
    --output=${target}
    --template=${template}
    --from=markdown+grid_tables+multiline_tables+fenced_code_blocks+fenced_code_attributes+yaml_metadata_block+implicit_figures+header_attributes+definition_lists+link_attributes
    --latex-engine=xelatex
    --chapters
    --number-sections
    --table-of-contents
    --highlight-style tango
    --standalone
    --self-contained
    ${metadata}
    ${sources}
    """
  }
}
