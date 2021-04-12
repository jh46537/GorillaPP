lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version      := "1.1",
  scalaVersion := "2.11.12",
  //scalaVersion := "2.10.1",
  //scalaVersion := "2.9.2",
  scalaSource in Compile := baseDirectory.value / "src",
  libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.4.2"
  //libraryDependencies += "edu.berkeley.cs" %% "chisel" % "2.2.24"
  //libraryDependencies += "edu.berkeley.cs" %% "chisel" % "2.0"
  //libraryDependencies += "edu.berkeley.cs" %% "chisel" % "1.0"
)

lazy val gorillapp = (project in file("."))
  //.aggregate(kmeans)
  //.dependsOn(kmeans)
  .settings(
    commonSettings,
    name := "gorillapp"
  )

//lazy val chisel_simulate = (project in file("../../../chisel_simulate/src"))
//  .settings(
//    commonSettings,
//    name := "chisel_simulate"
//  )
