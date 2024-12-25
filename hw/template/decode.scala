// primate instruction decoder

// TODO: 64 bit instruction support?????????

import chisel3._
import chisel3.util._


object ALUOpCodes extends ChiselEnum {
  val add = Value
  val sub = Value
  val xor = Value
  val or  = Value
  val and = Value
  val sll = Value
  val srl = Value
  val sra = Value
  val slt = Value
  val sltu = Value
  val lui = Value
  val cat = Value
}

class Decoder(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val instr = Input(UInt(conf.INSTR_WIDTH.W))
    val alu_sel = Output(Bool())
    val alu_immsel = Output(Bool())
    val alu_opcode = Output(ALUOpCodes())
    val bfu_opcode = Output(UInt(1.W))

    // todo: rs1_range
    // todo: rs2_range
  })

  /***************** RV32i ALU *****************/
  val alu_sel_r = Reg(Bool())
  val alu_immsel_r = Reg(Bool())
  val alu_opcode_r = Reg(ALUOpCodes())

  val funct3 = io.instr(14,12)
  val funct7 = io.instr(31,25)

  alu_sel_r := (io.instr(6,0) === "b0110011".U) || (io.instr(6,0) === "b0010011".U)
  alu_immsel_r := io.instr(6,0) === "b0010011".U

  alu_opcode_r := DontCare
  switch (funct3) {
    is (0.U) { alu_opcode_r := Mux(funct7(5), ALUOpCodes.sub, ALUOpCodes.add) }
    is (4.U) { alu_opcode_r := ALUOpCodes.xor }
    is (6.U) { alu_opcode_r := ALUOpCodes.or }
    is (7.U) { alu_opcode_r := ALUOpCodes.and }
    is (1.U) { alu_opcode_r := ALUOpCodes.sll }
    is (5.U) { alu_opcode_r := Mux(funct7(5), ALUOpCodes.sra, ALUOpCodes.srl) }
    is (2.U) { alu_opcode_r := ALUOpCodes.slt }
    is (3.U) { alu_opcode_r := ALUOpCodes.sltu }
  }

  /******************** BFU ********************/
  val bfu_opcode_r = Reg()


  // TODO: how????????????


  io.alu_sel := alu_sel_r
  io.alu_immsel := alu_immsel_r
  io.alu_opcode := alu_opcode_r
  io.bfu_opcode := bfu_opcode_r
}


object BranchOpCodes extends ChiselEnum {
  val beq, bne, blt, bge, bltu, bgeu = Value
}

class BranchDecoder(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(conf.INSTR_WIDTH.W))
    val val_br_op = Output(Bool())
    val br_opcode = Output(BranchOpCodes())
    val sr1       = Output(UInt(5.W))
    val sr2       = Output(UInt(5.W))
    val imm       = Output(UInt(12.W))
    val ip_d      = Input(UInt(conf.IP_WIDTH.W))
    val ip_e      = Output(UInt(conf.IP_WIDTH.W))
  })

  // keep track of IP
  val ip = RegNext(io.ip_d)
  io.ip_e := ip

  val val_br_op_r = Reg(Bool())
  val br_opcode_r = Reg(BranchOpCodes())
  val sr1_r       = Reg(UInt(5.W))
  val sr2_r       = Reg(UInt(5.W))
  val imm_r       = Reg(UInt(12.W))

  val funct3 = io.instr(14,12)

  val_br_op_r := io.instr(6,0) === "b1100011".U

  br_opcode_r := DontCare
  switch (funct3) {
    is (0.U) { br_opcode_r := BranchOpCodes.beq }
    is (1.U) { br_opcode_r := BranchOpCodes.bne }
    is (4.U) { br_opcode_r := BranchOpCodes.blt }
    is (5.U) { br_opcode_r := BranchOpCodes.bge }
    is (6.U) { br_opcode_r := BranchOpCodes.bltu }
    is (7.U) { br_opcode_r := BranchOpCodes.bgeu }
  }

  sr1_r := io.instr(19,15)
  sr2_r := io.instr(24,20)

  imm_r := io.instr(31) ## io.instr(7) ## io.instr(27,25) ## io.instr(11,6) ## 0.U(1.W)

  io.val_br_op := val_br_op_r
  io.br_opcode := br_opcode_r
  io.sr1 := sr1_r
  io.sr2 := sr2_r
  io.imm := imm_r
}


object LSOpCodes extends ChiselEnum {
  val lb, lh, lw, lbu, lhu, sb, sh, sw = Value
}

class LSDecoder(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(conf.INSTR_WIDTH.W))
    val val_ls_op = Output(Bool())
    val ls_opcode = Output(LSOpCodes())
    val sr1       = Output(UInt(5.W))
    val sr2       = Output(UInt(5.W))
    val imm       = Output(UInt(12.W))
  })

  val val_ls_op_r = Reg(Bool())
  val ls_opcode_r = Reg(BranchOpCodes())
  val sr1_r       = Reg(UInt(5.W))
  val sr2_r       = Reg(UInt(5.W))
  val imm_r       = Reg(UInt(12.W))

  val funct3 = io.instr(14,12)

  val ld_op = (io.instr(6,0) === "b0000011".U)
  val st_op = (io.instr(6,0) === "b0100011".U)

  val_ls_op_r := ld_op || st_op

  ls_opcode_r := DontCare
  when (ld_op) {
    switch (funct3) {
      is (0.U) { ls_opcode_r := LSOpCodes.lb }
      is (1.U) { ls_opcode_r := LSOpCodes.lh }
      is (2.U) { ls_opcode_r := LSOpCodes.lw }
      is (4.U) { ls_opcode_r := LSOpCodes.lbu }
      is (5.U) { ls_opcode_r := LSOpCodes.lhu }
    }
  }
  when (st_op) {
    switch (funct3) {
      is (0.U) { ls_opcode_r := LSOpCodes.sb }
      is (1.U) { ls_opcode_r := LSOpCodes.sh }
      is (2.U) { ls_opcode_r := LSOpCodes.sw }
    }
  }

  sr1_r := io.instr(19,15)
  sr2_r := io.instr(24,20)

  imm_r := Mux(ld_op, io.instr(31,20), io.instr(31,25) ## io.instr(11,7))

  io.val_ls_op := val_ls_op_r
  io.ls_opcode := ls_opcode_r
  io.sr1 := sr1_r
  io.sr2 := sr2_r
  io.imm := imm_r
}
