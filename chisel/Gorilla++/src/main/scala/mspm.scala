import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class mspm(extCompName: String) extends gComponentLeaf(new mspmIn_t, new mspmOut_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(TAGWIDTH.W))

  io.out.valid := valid_r
  io.out.tag := tag_r
  io.out.bits := 0.U.asTypeOf(chiselTypeOf(io.out.bits))
  io.in.ready := true.B
  when (io.in.valid) {
    valid_r := true.B
    tag_r := io.in.tag
  }
}

