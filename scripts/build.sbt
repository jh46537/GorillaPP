//ThisBuild / scalaVersion     := "2.13.12"
//ThisBuild / version          := "0.1.0"
ThisBuild / organization     := "FAST"

//val chiselVersion = "6.2.0"

lazy val root = (project in file("."))
  .settings(
    name := "Primate",
    Compile / scalaSource := baseDirectory.value / "hw-gen",
    Compile / resourceDirectory := baseDirectory.value / "hw-gen",
    //libraryDependencies ++= Seq(
    //  "org.chipsalliance" %% "chisel" % chiselVersion,
    //  "org.scalatest" %% "scalatest" % "3.2.16" % "test",
    //),
    //scalacOptions ++= Seq(
    //  "-language:reflectiveCalls",
    //  "-deprecation",
    //  "-feature",
    //  "-Xcheckinit",
    //  "-Ymacro-annotations",
    //),

    // TODO: remove this block when migrating to chisel6
    scalaVersion     := "2.12.12",
    scalacOptions += "-Xsource:2.11",
    libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.4.2",
    libraryDependencies += "edu.berkeley.cs" %% "chisel-iotesters" % "1.5.3",
    libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.7",
    libraryDependencies += "org.scalactic" %% "scalactic" % "3.2.7",

    //addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % chiselVersion cross CrossVersion.full),
  )