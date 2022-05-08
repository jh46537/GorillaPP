import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class mspm(extCompName: String) extends gComponentLeaf(new mspmIn_t, new mspmOut_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  val valid_r = RegInit(false.B)
  val valid_r1 = RegInit(false.B)
  val tag_r = Reg(UInt(TAGWIDTH.W))
  val tag_r1 = Reg(UInt(TAGWIDTH.W))
  val mspm_in_r = Reg(new mspmIn_t)

  val mspm_inst = Module(new MSPMcore(32, 16))

  mspm_in_r := io.in.bits

  mspm_inst.io.command := mspm_in_r.opcode
  mspm_inst.io.string := mspm_in_r.word.string.asTypeOf(chiselTypeOf(mspm_inst.io.string))
  mspm_inst.io.length := mspm_in_r.word.length
  mspm_inst.io.idx := mspm_in_r.word.idx
  mspm_inst.io.valid := valid_r

  io.out.valid := RegNext(valid_r1)
  io.out.tag := RegNext(tag_r1)
  io.in.ready := mspm_inst.io.ready
  io.out.bits.matched := mspm_inst.io.matched.asUInt
  io.out.bits.match_pos0  := mspm_inst.io.pos(0)
  io.out.bits.match_pos1  := mspm_inst.io.pos(1)
  io.out.bits.match_pos2  := mspm_inst.io.pos(2)
  io.out.bits.match_pos3  := mspm_inst.io.pos(3)
  io.out.bits.match_pos4  := mspm_inst.io.pos(4)
  io.out.bits.match_pos5  := mspm_inst.io.pos(5)
  io.out.bits.match_pos6  := mspm_inst.io.pos(6)
  io.out.bits.match_pos7  := mspm_inst.io.pos(7)
  io.out.bits.match_pos8  := mspm_inst.io.pos(8)
  io.out.bits.match_pos9  := mspm_inst.io.pos(9)
  io.out.bits.match_pos10 := mspm_inst.io.pos(10)
  io.out.bits.match_pos11 := mspm_inst.io.pos(11)
  io.out.bits.match_pos12 := mspm_inst.io.pos(12)
  io.out.bits.match_pos13 := mspm_inst.io.pos(13)
  io.out.bits.match_pos14 := mspm_inst.io.pos(14)
  io.out.bits.match_pos15 := mspm_inst.io.pos(15)
  when (io.in.valid) {
    valid_r := true.B
    tag_r := io.in.tag
  } .otherwise {
    valid_r := false.B
  }
  valid_r1 := valid_r
  tag_r1 := tag_r

}

