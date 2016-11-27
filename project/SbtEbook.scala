package io.underscore.ebook

import sbt._
import sbt.Keys._

object SbtEbook extends AutoPlugin {
  override def requires = plugins.JvmPlugin
  override def trigger  = allRequirements

  object autoImport {
    val Pdf                     = config("pdf").describedAs("PDF eBook configuration")
    val Html                    = config("html").describedAs("HTML eBook configuration")
    val Epub                    = config("epub").describedAs("ePub eBook configuration")

    val ebookMetadataDirectory  = settingKey[File]("eBook metadata directory")
    val ebookCommonMetadataFile = settingKey[File]("Common eBook metadata file")
    val ebookFormatMetadataFile = settingKey[File]("Format-specific eBook metadata file")
    val ebookCommonMetadata     = settingKey[EbookMetadata]("Common eBook metadata")
    val ebookFormatMetadata     = settingKey[EbookMetadata]("Format-specific eBook metadata")

    val ebookCommandLineArgs    = settingKey[Seq[String]]("Extra Pandoc command line arguments")

    val ebookTemplateDirectory  = settingKey[File]("eBook template directory")
    val ebookTemplate           = settingKey[File]("eBook template")

    val ebookTarget             = settingKey[File]("eBook target")
    val ebookCommandLine        = taskKey[String]("Pandoc command line")
    val ebook                   = taskKey[Seq[File]]("Compile eBook")
  }

  import autoImport._

  def templateFile(config: Configuration): String =
    config match {
      case Pdf  => "template.tex"
      case Html => "template.html"
      case Epub => "template.epub.html"
      case _    => sys.error(s"Not an eBook configuration: ${config.name}")
    }

  def filterPath(dir: File)(filename: String): String =
    if(filename startsWith "=") filename.substring(1) else (dir / filename).getAbsolutePath

  def settingsIn(config: Configuration): Seq[Def.Setting[_]] =
    inConfig(config)(Seq(
      name                       := name.in(Compile).value,

      ebookMetadataDirectory     := sourceDirectory.in(Compile).value / "meta",
      ebookCommonMetadataFile    := ebookMetadataDirectory.value / "metadata.yaml",
      ebookFormatMetadataFile    := ebookMetadataDirectory.value / s"${config.name}.yaml",
      ebookCommonMetadata        := EbookMetadata.read(ebookCommonMetadataFile.value),
      ebookFormatMetadata        := EbookMetadata.read(ebookFormatMetadataFile.value),

      ebookTemplateDirectory     := sourceDirectory.in(Compile).value / "templates",
      ebookTemplate              := ebookTemplateDirectory.value / templateFile(config),

      ebookCommandLineArgs       := ebookCommonMetadata.value
                                      .merge(ebookFormatMetadata.value)
                                      .pandocArgs
                                      .getOrElse(Seq.empty),

      sourceDirectory            := sourceDirectory.in(Compile).value / "pages",
      sources                    := ebookCommonMetadata.value
                                      .merge(ebookFormatMetadata.value)
                                      .pages.getOrElse(Seq.empty)
                                      .map(sourceDirectory.value / _),

      target                     := target.in(Compile).value,
      ebookTarget                := target.in(config).value / s"${config.name}.pdf",

      ebookCommandLine           := Ebook.pandocCommandLine(
                                      target   = ebookTarget.value,
                                      template = ebookTemplate.value,
                                      args     = ebookCommandLineArgs.value,
                                      metadata = Seq(
                                                   ebookCommonMetadataFile.value,
                                                   ebookFormatMetadataFile.value
                                                 ),
                                      sources  = sources.in(config).value
                                    ),

      ebook                      := {
                                      Process(ebookCommandLine.value).!
                                      Seq(ebookTarget.value)
                                    }
    ))

  lazy val baseSettings =
    settingsIn(Pdf)  ++
    settingsIn(Html) ++
    settingsIn(Epub)

  override lazy val projectSettings =
    inConfig(Compile)(baseSettings)
}
