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
  val res = Wire(new asciiOut_t)

  val isDigitInst = Module(new IsDigit(32))
  val extractDigitInst = Module(new ExtractDigit(32))
  val isDigitOut = Wire(new isDigitOut_t(32))
  val LATENCY = 9
  val tagVec = Reg(Vec(LATENCY, UInt(TAGWIDTH.W)))

  // Input
  when (io.in.valid) {
    tagVec(LATENCY-1) := io.in.tag
    when (io.in.bits.opcode === 0.U) {
      isDigitInst.io.valid := true.B
      extractDigitInst.io.valid := false.B
    } .otherwise {
      isDigitInst.io.valid := false.B
      extractDigitInst.io.valid := true.B
    }
  } .otherwise {
      isDigitInst.io.valid := false.B
      extractDigitInst.io.valid := false.B
  }

  isDigitInst.io.segment := io.in.bits.string.asTypeOf(chiselTypeOf(isDigitInst.io.segment))
  extractDigitInst.io.segment := io.in.bits.string.asTypeOf(chiselTypeOf(extractDigitInst.io.segment))

  // Output
  isDigitOut.isDigit := isDigitInst.io.isDigit
  isDigitOut.digitPos := isDigitInst.io.digitPos

  when (isDigitInst.io.valid_out) {
    io.out.valid := true.B
    res.integer := isDigitOut.asUInt
  } .elsewhen(extractDigitInst.io.valid_out) {
    io.out.valid := true.B
    res.integer := extractDigitInst.io.resultNum
  } .otherwise {
    io.out.valid := false.B
    res.integer := DontCare
  }

  for (i <- 0 to LATENCY-2) {
    tagVec(i) := tagVec(i+1)
  }

  io.out.tag := tagVec(0)
  io.out.bits := res
  io.in.ready := true.B

}

