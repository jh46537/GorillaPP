lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version      := "1.1",
  scalaVersion := "2.12.12",
  scalacOptions += "-Xsource:2.11",
  libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.4.2",
  libraryDependencies += "edu.berkeley.cs" %% "chisel-iotesters" % "1.5.3",
  libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.7",
  libraryDependencies += "org.scalactic" %% "scalactic" % "3.2.7"
)

lazy val gorillapp = (project in file("."))
  .settings(
    commonSettings,
    name := "gorillapp"
  )