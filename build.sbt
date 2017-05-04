lazy val root = project.in(file("."))
  .settings(tutSettings)

tutSourceDirectory := sourceDirectory.value / "pages"

tutTargetDirectory := target.value / "pages"

scalaOrganization in ThisBuild := "org.typelevel"
scalaVersion in ThisBuild := "2.12.1"

scalacOptions ++= Seq(
  "-deprecation",
  "-encoding", "UTF-8",
  "-unchecked",
  "-feature",
  "-Xlint",
  //"-Xfatal-warnings",
  "-Ywarn-dead-code",
  "-Yliteral-types"
)

resolvers ++= Seq(Resolver.sonatypeRepo("snapshots"))

libraryDependencies ++= Seq(
  "com.chuusai"    %% "shapeless"  % "2.3.2",
  "org.scalacheck" %% "scalacheck" % "1.13.5",
  "org.typelevel"  %% "cats"       % "0.9.0"
)

lazy val pdf  = taskKey[Unit]("Build the PDF version of the book")
lazy val html = taskKey[Unit]("Build the HTML version of the book")
lazy val epub = taskKey[Unit]("Build the ePub version of the book")
lazy val all  = taskKey[Unit]("Build all versions of the book")

pdf  := { tutQuick.value ; "grunt pdf".!  }
html := { tutQuick.value ; "grunt html".! }
epub := { tutQuick.value ; "grunt epub".! }

all  := {
  tutQuick.value
  "grunt pdf".!
  "grunt html".!
  "grunt epub".!
}
