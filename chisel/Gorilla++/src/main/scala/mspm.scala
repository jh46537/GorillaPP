import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class mspm(extCompName: String) extends gComponentLeaf(new mspmIn_t, new mspmOut_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(TAGWIDTH.W))

  val mspm_inst = Module(new MSPMcore(16, 8))

  mspm_inst.io.command := io.in.bits.opcode
  mspm_inst.io.string := io.in.bits.word.string.asTypeOf(chiselTypeOf(mspm_inst.io.string))
  mspm_inst.io.length := io.in.bits.word.length
  mspm_inst.io.idx := io.in.bits.word.idx
  mspm_inst.io.valid := io.in.valid

  io.out.valid := valid_r
  io.out.tag := tag_r
  io.in.ready := mspm_inst.io.ready
  io.out.bits.matched := mspm_inst.io.matched.asUInt
  io.out.bits.match_pos0 := mspm_inst.io.pos(0)
  io.out.bits.match_pos1 := mspm_inst.io.pos(1)
  io.out.bits.match_pos2 := mspm_inst.io.pos(2)
  io.out.bits.match_pos3 := mspm_inst.io.pos(3)
  io.out.bits.match_pos4 := mspm_inst.io.pos(4)
  io.out.bits.match_pos5 := mspm_inst.io.pos(5)
  io.out.bits.match_pos6 := mspm_inst.io.pos(6)
  io.out.bits.match_pos7 := mspm_inst.io.pos(7)
  when (io.in.valid) {
    valid_r := true.B
    tag_r := io.in.tag
  } .otherwise {
    valid_r := false.B
  }

}

