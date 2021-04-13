import chisel3._
import chisel3.util._


/* This source implements a module that adds a constant value
 * to each input data element, and send the result out as
 * the output data element. The constant value is retrieved
 * through an offload interface.
 */

class Top extends Module with GorillaUtil {
  val io = new gInOutBundle (() => new testStruct_t, () => new testStruct_t)
  val main = MTEngine("incThroughOffload.c", 1)
  val incFactor = Engine("sendConst.c")
  val result = Offload(main, incFactor, "incrementFactor")
}
