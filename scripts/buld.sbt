ThisBuild / scalaVersion 	:= "2.13.12"
val chiselVersion = "6.2.0"

lazy val root = (project in file("."))
  .settings(
	name := "chisel_template",
	libraryDependencies ++= Seq(
  	"org.chipsalliance" %% "chisel" % chiselVersion,
  	"org.scalatest" %% "scalatest" % "3.2.16" % "test",
	),
	scalacOptions ++= Seq(
  	"-language:reflectiveCalls",
  	"-deprecation",
  	"-feature",
  	"-Xcheckinit",
  	"-Ymacro-annotations",
	),
	addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % chiselVersion cross CrossVersion.full),
  )
