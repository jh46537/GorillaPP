import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap

class isDigitOut_t(segmentLength: Int) extends Bundle {
  val isDigit = Output(Bool())
  val digitPos = Output(UInt(log2Up(segmentLength).W))

  override def cloneType = (new isDigitOut_t(segmentLength).asInstanceOf[this.type])
}

class ascii(extCompName: String) extends gComponentLeaf(new asciiIn_t, new asciiOut_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(TAGWIDTH.W))
  val res = Reg(new asciiOut_t)

  val isDigitInst = Module(new IsDigit(32))
  val extractDigitInst = Module(new ExtractDigit(32, 20))
  val isDigitOut = Reg(new isDigitOut_t(32))
  val opcode = Reg(UInt(5.W))

  // Input
  when (io.in.bits.opcode === 0.U) {
    isDigitInst.io.valid := 1.U
    extractDigitInst.io.valid := 0.U
  } .otherwise {
    isDigitInst.io.valid := 0.U
    extractDigitInst.io.valid := 1.U
  }

  isDigitInst.io.segment := io.in.bits.string.asTypeOf(chiselTypeOf(isDigitInst.io.segment))
  extractDigitInst.io.segment := io.in.bits.string.asTypeOf(chiselTypeOf(extractDigitInst.io.segment))
  opcode := io.in.bits.opcode

  // Output
  isDigitOut.isDigit := isDigitInst.io.isDigit
  isDigitOut.digitPos := isDigitInst.io.digitPos

  when (opcode === 0.U) {
    res.integer := isDigitOut.asUInt
  } .otherwise {
    res.integer := extractDigitInst.io.resultNum
  }

  io.out.valid := RegNext(valid_r)
  io.out.tag := RegNext(tag_r)
  io.out.bits := res
  io.in.ready := true.B
  when (io.in.valid) {
    valid_r := true.B
    tag_r := io.in.tag
  } .otherwise {
    valid_r := false.B
  }

}

