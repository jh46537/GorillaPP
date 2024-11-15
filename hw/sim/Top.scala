import chisel3._
import chisel3.util._
import chisel3.stage.ChiselStage

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


/* This source implements a module that adds a constant value
 * to each input data element, and send the result out as
 * the output data element. The constant value is retrieved
 * through an offload interface.
 */

class Top extends Module with GorillaUtil {
  val io = IO(new gInOutOffBundle(new input_t, new output_t))
  val result = new gComponentGen(new primate("result"), new input_t, new output_t, ArrayBuffer(), "result")
  val generatedTop = Module(result())
  generatedTop.io <> io
}

object Main extends App {
  print(ChiselStage.emitSystemVerilog(new Top))
}
