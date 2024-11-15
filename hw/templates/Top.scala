package primate

import chisel3._
import _root_.circt.stage.ChiselStage

//TODO: make this the top primate chisel file

class HelloWorld extends Module {
  val io = IO(new Bundle{})
  printf("hello world\n")
}


object Main extends App {
  ChiselStage.emitSystemVerilogFile(new HelloWorld)
}