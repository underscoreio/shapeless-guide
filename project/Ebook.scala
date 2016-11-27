package io.underscore.ebook

import sbt._

object Ebook {
  import CommandLineImplicits._

  def pandocCommandLine(
    target: File,
    template: File,
    args: Seq[String],
    metadata: Seq[File],
    sources: Seq[File]
  ): String = {
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
    ${args}
    ${metadata}
    ${sources}
    """
  }
}
