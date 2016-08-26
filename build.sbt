lazy val root = project.in(file("."))
  .settings(tutSettings)

tutSourceDirectory := sourceDirectory.value / "pages"

tutTargetDirectory := target.value / "pages"

scalaVersion := "2.11.8"

scalacOptions ++= Seq(
  "-deprecation",
  "-encoding", "UTF-8",
  "-unchecked",
  "-feature",
  "-Ywarn-dead-code",
  "-Xlint",
  "-Xfatal-warnings"
)

resolvers ++= Seq(Resolver.sonatypeRepo("snapshots"))

libraryDependencies ++= Seq(
  "com.chuusai" %% "shapeless" % "2.3.2"
)

lazy val pdf  = taskKey[Unit]("Build the PDF version of the book")
lazy val html = taskKey[Unit]("Build the HTML version of the book")
lazy val epub = taskKey[Unit]("Build the ePub version of the book")
lazy val all  = taskKey[Unit]("Build all versions of the book")

pdf  := { tut.value ; "grunt pdf"  ! }
html := { tut.value ; "grunt html" ! }
epub := { tut.value ; "grunt epub" ! }
all  := { pdf ; html ; epub }
