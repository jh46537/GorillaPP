import chisel3._
import chisel3.util._

// opcodes defined in include.scala
import ALUOpCodes._

// Basic ALU (Green Fuctional Unit) for Primate
// supports RV32i R and I ops

class ALU(reg_width: Int) extends Module {
  val io = IO(new Bundle {
    val opcode    = Input(ALUOpCodes())
    val rs1       = Input(UInt(reg_width.W))
    val rs2       = Input(UInt(32.W))
    val imm       = Input(UInt(32.W))
    val immSel    = Input(Bool())
    val dout      = Output(UInt(reg_width.W))
  })

  val opcode_r = Reg(ALUOpCodes())
  val opA_r    = Reg(SInt(32.W))
  val opB_r    = Reg(SInt(32.W))
  val result   = Wire(SInt(32.W))

  opcode_r  := io.opcode
  opA_r     := io.rs1(31,0).asSInt
  opB_r     := Mux(io.immSel, io.imm.asSInt, io.rs2(31,0).asSInt)
  //val shamt = opB_r(4,0).asUInt
  result    := DontCare

  switch (opcode_r) {
    is (add) {
      result := opA_r + opB_r
    }
    is (sub) {
      result := opA_r - opB_r
    }
    is (xor) {
      result := opA_r ^ opB_r
    }
    is (or) {
      result := opA_r | opB_r
    }
    is (and) {
      result := opA_r & opB_r
    }
    is (sll) {
      result := opA_r << opB_r(4,0).asUInt
    }
    is (srl) {
      result := (opA_r.asUInt >> opB_r(4,0).asUInt).asSInt
    }
    is (sra) {
      result := opA_r >> opB_r(4,0).asUInt
    }
    is (slt) {
      result := Mux(opA_r < opB_r, 1.U(32.W), 0.U).asSInt
    }
    is (sltu) {
      result := Mux(opA_r.asUInt < opB_r.asUInt, 1.U(32.W), 0.U).asSInt
    }
    is (lui) { // TODO: does this belong in ALU?
      result := (opA_r(31,12) ## 0.U(12.W)).asSInt
    }
    is (cat) { // TODO: what is this for?
      result := Cat(0.U(1.W),opB_r(8,0),opA_r(8,0)).asSInt
    }
  }

  val rs1_r = Reg(UInt(reg_width.W))
  rs1_r := io.rs1

  // why does the alu pass the upper bits of rs1 through to the output?
  if (reg_width > 32) {
    io.dout := Cat(rs1_r(reg_width-1, 32), result.asUInt).asSInt
  } else {
    io.dout := result.asUInt
  }
}

// TODOSIM: remove this
import _root_.circt.stage.ChiselStage
object ALUTop extends App {
  ChiselStage.emitSystemVerilogFile(new ALU(32), Array("--target-dir", "generated"))
}