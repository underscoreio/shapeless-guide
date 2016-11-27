package io.underscore.ebook

import sbt._

object CommandLineImplicits {
  import scala.language.implicitConversions

  case class CommandLineParam(value: String) {
    override def toString = value
  }

  implicit class CommandLineHelper(val ctx: StringContext) extends AnyVal {
    def cmd(args: CommandLineParam *): String = {
      val ans = ctx
        .s(args.map(_.toString) : _*)
        .split("[\r\n]+")
        .map(_.trim)
        .filterNot(_.isEmpty)
        .mkString(" ")

      println(ans)

      ans
    }
  }

  implicit def stringToParam(string: String): CommandLineParam =
    CommandLineParam(string)

  implicit def stringToParam(strings: Seq[String]): CommandLineParam =
    CommandLineParam(strings.mkString(" "))

  implicit def fileToParam(file: File): CommandLineParam =
    CommandLineParam(file.getAbsolutePath)

  implicit def seqFileToParam(files: Seq[File]): CommandLineParam =
    CommandLineParam(files.map(_.getAbsolutePath).mkString(" "))
}
