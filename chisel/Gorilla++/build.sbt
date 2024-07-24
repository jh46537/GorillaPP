// SPDX-License-Identifier: Apache-2.0

lazy val commonSettings = Seq(
  organization := "",
  scalaVersion := "2.13.12",
  crossScalaVersions := Seq("2.13.12")
)

val chiselVersion = "6.5.0"

lazy val chiseltestSettings = Seq(
  name := "chiseltest",
  scalacOptions := Seq(
    "-deprecation",
    "-feature",
    "-Xcheckinit",
    "-Ymacro-annotations",
    "-language:reflectiveCalls",
  ),
  // Always target Java8 for maximum compatibility
  javacOptions ++= Seq("-source", "1.8", "-target", "1.8"),
  libraryDependencies ++= Seq(
    "org.chipsalliance" %% "chisel" % chiselVersion,
    "org.scalatest" %% "scalatest" % "3.2.17",
  ),
  addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % chiselVersion cross CrossVersion.full),
  resolvers ++= Resolver.sonatypeOssRepos("snapshots"),
  resolvers ++= Resolver.sonatypeOssRepos("releases")
)

lazy val gorillapp = (project in file("."))
  //.aggregate(kmeans)
  //.dependsOn(kmeans)
  .settings(commonSettings, name := "gorillapp")
  .settings(chiseltestSettings) 

