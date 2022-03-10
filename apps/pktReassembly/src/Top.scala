import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


/* This source implements a module that adds a constant value
 * to each input data element, and send the result out as
 * the output data element. The constant value is retrieved
 * through an offload interface.
 */

class Top extends Module with GorillaUtil {
  val io = IO(new gInOutOffBundle(new metadata_t, new metadata_t))
  val main = MTEngine("pktReassembly.c", 16)
  val dynamicMem = Engine("dynamicMem.c")
  val result = Offload(main, dynamicMem, "dynamicMem")
}
