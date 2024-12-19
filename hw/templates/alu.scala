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
    val imm       = Input(UInt(12.W)) // imm[11:0] (31:20)
    val immSel    = Input(Bool())
    val dout      = Output(UInt(reg_width.W))
  })

  val opcode_r = Reg(ALUOpCodes())
  val opA_r    = Reg(UInt(32.W))
  val opB_r    = Reg(UInt(32.W))
  val imm_r    = Reg(UInt(12.W))
  val sr2      = Wire(UInt(32.W))
  val result   = Wire(UInt(32.W))

  opcode_r  := io.opcode
  opA_r     := io.rs1(31,0)
  opB_r     := io.rs2(31,0)
  imm_r     := io.imm
  sr2       := Mux(io.immSel, Fill(32-12, imm_r(11)) ## imm_r, opB_r)
  result    := DontCare

  switch (opcode_r) {
    is (add) {
      result := opA_r + sr2
    }
    is (sub) {
      result := opA_r - sr2
    }
    is (xor) {
      result := opA_r ^ sr2
    }
    is (or) {
      result := opA_r | sr2
    }
    is (and) {
      result := opA_r & sr2
    }
    is (sll) {
      result := opA_r << sr2(4,0)
    }
    is (srl) {
      result := opA_r.asUInt >> sr2(4,0)
    }
    is (sra) {
      result := (opA_r.asSInt >> sr2(4,0)).asUInt
    }
    is (slt) {
      result := Mux(opA_r.asSInt < sr2.asSInt, 1.U(32.W), 0.U) // todo sign extend sr2
    }
    is (sltu) {
      result := Mux(opA_r.asUInt < sr2, 1.U(32.W), 0.U)
    }
    is (lui) { // TODO: does this belong in ALU?
      result := (opA_r(31,12) ## 0.U(12.W))
    }
    is (cat) { // TODO: what is this for?
      result := Cat(0.U(1.W),opB_r(8,0),opA_r(8,0))
    }
  }

  val rs1_r = Reg(UInt(reg_width.W))
  rs1_r := io.rs1

  if (reg_width > 32) {
    io.dout := Cat(rs1_r(reg_width-1, 32), result.asUInt)
  } else {
    io.dout := result.asUInt
  }
}

// TODOSIM: remove this
import _root_.circt.stage.ChiselStage
object ALUTop extends App {
  ChiselStage.emitSystemVerilogFile(new ALU(32), Array("--target-dir", "generated"))
}