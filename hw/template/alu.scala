// Basic ALU (Green Fuctional Unit) for Primate
// supports RV32i R and I ops

import chisel3._
import chisel3.util._

// TODO: does naming this bundle provide any value?
class ALU_IO(conf: PrimateConfig) extends Bundle {
  val opcode    = Input(ALUOpCodes())
  val rs1       = Input(UInt(conf.REG_WIDTH.W))
  val rs2       = Input(UInt(32.W))
  val imm       = Input(UInt(12.W)) // imm[11:0] (31:20)
  val immSel    = Input(Bool())
  val dout      = Output(UInt(conf.REG_WIDTH.W))
  val in_tag    = Input(UInt(conf.TAGWIDTH.W))
  val out_tag   = Output(UInt(conf.TAGWIDTH.W))
}

class ALU(conf: PrimateConfig) extends Module {
  val io = IO(new ALU_IO(conf))

  val opcode_r = Reg(ALUOpCodes())
  val opA_r    = Reg(UInt(32.W))
  val opB_r    = Reg(UInt(32.W))
  val imm_r    = Reg(UInt(12.W))
  val sr2      = Wire(UInt(32.W))
  val result   = Wire(UInt(32.W))

  // adjust tag stages to match ALU depth
  val tag_r = RegNext(io.in_tag)
  io.out_tag := tag_r

  opcode_r  := io.opcode
  opA_r     := io.rs1(31,0)
  opB_r     := io.rs2(31,0)
  imm_r     := io.imm
  sr2       := Mux(io.immSel, Fill(32-12, imm_r(11)) ## imm_r, opB_r)
  result    := DontCare

  switch (opcode_r) {
    is (ALUOpCodes.add) {
      result := opA_r + sr2
    }
    is (ALUOpCodes.sub) {
      result := opA_r - sr2
    }
    is (ALUOpCodes.xor) {
      result := opA_r ^ sr2
    }
    is (ALUOpCodes.or) {
      result := opA_r | sr2
    }
    is (ALUOpCodes.and) {
      result := opA_r & sr2
    }
    is (ALUOpCodes.sll) {
      result := opA_r << sr2(4,0)
    }
    is (ALUOpCodes.srl) {
      result := opA_r.asUInt >> sr2(4,0)
    }
    is (ALUOpCodes.sra) {
      result := (opA_r.asSInt >> sr2(4,0)).asUInt
    }
    is (ALUOpCodes.slt) {
      result := Mux(opA_r.asSInt < sr2.asSInt, 1.U(32.W), 0.U)
    }
    is (ALUOpCodes.sltu) {
      result := Mux(opA_r.asUInt < sr2, 1.U(32.W), 0.U)
    }
    is (ALUOpCodes.lui) { // TODO: does this belong in ALU?
      result := (opA_r(31,12) ## 0.U(12.W))
    }
    is (ALUOpCodes.cat) { // TODO: what is this for?
      result := Cat(0.U(1.W),opB_r(8,0),opA_r(8,0))
    }
  }

  val rs1_r = Reg(UInt(conf.REG_WIDTH.W))
  rs1_r := io.rs1

  if (conf.REG_WIDTH > 32) {
    io.dout := Cat(rs1_r(conf.REG_WIDTH-1, 32), result.asUInt)
  } else {
    io.dout := result.asUInt
  }
}
