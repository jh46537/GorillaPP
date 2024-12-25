// RISC-V branch unit

import chisel3._
import chisel3.util._

class BRU(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val val_br_op = Input(Bool())
    val br_opcode = Input(BranchOpCodes())
    val r1        = Input(UInt(32.W))
    val r2        = Input(UInt(32.W))
    val imm       = Input(UInt(12.W))
    val ip_e      = Input(UInt(conf.IP_WIDTH.W))
    val branch    = Output(Bool())
    val br_target = Output(UInt(conf.IP_WIDTH.W))
  })

  val branch_q = Wire(Bool())
  val branch_r = RegInit(Bool(), false.B)
  val br_target_r = Reg(UInt(conf.IP_WIDTH.W))

  // calculate new branch target
  br_target_r := io.ip_e + io.imm

  switch (io.br_opcode) {
    is (BranchOpCodes.beq) { 
      branch_q := io.r1 === io.r2
    }
    is (BranchOpCodes.bne) { 
      branch_q := io.r1 =/= io.r2
    }
    is (BranchOpCodes.blt) { 
      branch_q := io.r1.asSInt < io.r2.asSInt
    }
    is (BranchOpCodes.bge) { 
      branch_q := io.r1.asSInt >= io.r2.asSInt
    }
    is (BranchOpCodes.bltu) { 
      branch_q := io.r1 < io.r2
    }
    is (BranchOpCodes.bgeu) { 
      branch_q := io.r1 >= io.r2
    }
  }
  branch_r := branch_q && io.val_br_op // latch branch signal

  io.branch := branch_r
  io.br_target := br_target_r
}
