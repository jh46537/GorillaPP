import chisel3._
import chisel3.util._

class DecodeBranch(inst_width: Int, num_regs_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(inst_width.W))
    val brValid   = Output(Bool())
    val brMode    = Output(UInt(4.W))
    val rs1       = Output(UInt(num_regs_lg.W))
    val rs2       = Output(UInt(num_regs_lg.W))
    val rd        = Output(UInt(num_regs_lg.W))
    val rdWrEn    = Output(Bool())
    val pcOffset  = Output(SInt(21.W))
  })

  val OPCODE_LOW = 0
  val OPCODE_HIGH = OPCODE_LOW + 6
  val RD_LOW = OPCODE_HIGH + 1
  val RD_HIGH = RD_LOW + num_regs_lg - 1
  val FUNCT3_LOW = RD_HIGH + 1
  val FUNCT3_HIGH = FUNCT3_LOW + 2
  val RS1_LOW = FUNCT3_HIGH + 1
  val RS1_HIGH = RS1_LOW + num_regs_lg - 1
  val RS2_LOW = RS1_HIGH + 1
  val RS2_HIGH = RS2_LOW + num_regs_lg - 1
  val IMM_LOW = RS2_HIGH + 1
  val IMM_HIGH = IMM_LOW + 6

  val opcode = Wire(UInt(7.W))
  opcode := io.instr(OPCODE_HIGH, OPCODE_LOW)
  io.rd := io.instr(RD_HIGH, RD_LOW)
  io.rs1 := io.instr(RS1_HIGH, RS1_LOW)
  io.rs2 := io.instr(RS2_HIGH, RS2_LOW)
  io.rdWrEn := false.B
  io.pcOffset := 0.S
  io.brMode := DontCare
  io.brValid := true.B

  when (opcode === 0x6f.U) {
    when (io.rd =/= 0.U) {
      io.brMode := 2.U
      io.rdWrEn := true.B
    } .otherwise {
      io.brMode := 3.U
    }
    val tmp = Cat(io.instr(FUNCT3_LOW+19), io.instr(FUNCT3_LOW+7, FUNCT3_LOW), io.instr(FUNCT3_LOW+8), io.instr(FUNCT3_LOW+18, FUNCT3_LOW+9)).asSInt
    io.pcOffset := tmp
  } .elsewhen (opcode === 0x63.U) {
    io.brMode := io.instr(FUNCT3_LOW+2, FUNCT3_LOW)
    val tmp = Cat(io.instr(IMM_HIGH), io.instr(RD_LOW), io.instr(IMM_HIGH-1, IMM_LOW), io.instr(RD_LOW+4, RD_LOW+1)).asSInt
    io.pcOffset := tmp
  } .elsewhen (opcode === 0x67.U) {
    val tmp = io.instr(RS2_LOW+11, RS2_LOW).asSInt
    io.brMode := 8.U
    io.pcOffset := tmp
  } .otherwise {
    io.brValid := false.B
  }
}

class DecodeEIU(inst_width: Int, num_regs_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(inst_width.W))
    val rs        = Output(UInt(num_regs_lg.W))
    val rs_pos    = Output(UInt(num_src_pos_lg.W))
    val rs_mode   = Output(UInt(num_src_modes_lg.W))
    val rd        = Output(UInt(num_regs_lg.W))
    val rd_pos    = Output(UInt(num_dst_pos_lg.W))
    val rd_mode   = Output(UInt(num_dst_modes_lg.W))
    val rdWrEn    = Output(Bool())
  })

  val OPCODE_LOW = 0
  val OPCODE_HIGH = OPCODE_LOW + 6
  val RD_LOW = OPCODE_HIGH + 1
  val RD_HIGH = RD_LOW + num_regs_lg - 1
  val FUNCT3_LOW = RD_HIGH + 1
  val FUNCT3_HIGH = FUNCT3_LOW + 2
  val RS1_LOW = FUNCT3_HIGH + 1
  val RS1_HIGH = RS1_LOW + num_regs_lg - 1
  val IMM_LOW = RS1_HIGH + 1
  val IMM_HIGH = IMM_LOW + 11

  io.rs := io.instr(RS1_HIGH, RS1_LOW)
  io.rs_pos := io.instr(IMM_LOW+num_src_pos_lg-1, IMM_LOW)
  io.rs_mode := io.instr(IMM_LOW+num_src_pos_lg+num_src_modes_lg-1, IMM_LOW+num_src_pos_lg)
  io.rd := io.instr(RD_HIGH, RD_LOW)
  io.rd_pos := io.instr(IMM_LOW+num_dst_pos_lg-1, IMM_LOW)
  io.rd_mode := io.instr(IMM_LOW+num_dst_pos_lg+num_dst_modes_lg-1, IMM_LOW+num_dst_pos_lg)

  io.rdWrEn := false.B
  when ((io.instr(FUNCT3_LOW) === 1.U) && (io.rd =/= 0.U)) {
    io.rdWrEn := true.B
  }
}

class DecodeALUBFU(inst_width: Int, num_regs_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(inst_width.W))
    val rs1       = Output(UInt(num_regs_lg.W))
    val rs2       = Output(UInt(num_regs_lg.W))
    val rd        = Output(UInt(num_regs_lg.W))
    val rdWrEn    = Output(Bool())
    val addEn     = Output(Bool())
    val subEn     = Output(Bool())
    val sltEn     = Output(Bool())
    val sltuEn    = Output(Bool())
    val andEn     = Output(Bool())
    val orEn      = Output(Bool())
    val xorEn     = Output(Bool())
    val sllEn     = Output(Bool())
    val srEn      = Output(Bool())
    val srMode    = Output(Bool())
    val luiEn     = Output(Bool())
    val immSel    = Output(Bool())
    val imm       = Output(SInt(32.W))
    val mulEn     = Output(Bool())
    val mulH      = Output(Bool())
    val catEn     = Output(Bool())
    // val divEn     = Output(Bool())
    val remEn     = Output(Bool())
    val rs1Signed = Output(Bool())
    val rs2Signed = Output(Bool())
    val bfu_valid  = Output(Bool())
    val bfu_opcode = Output(UInt(6.W))
  })

  val OPCODE_LOW = 0
  val OPCODE_HIGH = OPCODE_LOW + 6
  val RD_LOW = OPCODE_HIGH + 1
  val RD_HIGH = RD_LOW + num_regs_lg - 1
  val FUNCT3_LOW = RD_HIGH + 1
  val FUNCT3_HIGH = FUNCT3_LOW + 2
  val RS1_LOW = FUNCT3_HIGH + 1
  val RS1_HIGH = RS1_LOW + num_regs_lg - 1
  val RS2_LOW = RS1_HIGH + 1
  val RS2_HIGH = RS2_LOW + num_regs_lg - 1
  val IMM_LOW = RS2_HIGH + 1
  val IMM_HIGH = IMM_LOW + 6

  val opcode = Wire(UInt(7.W))
  val funct3 = Wire(UInt(3.W))
  val imm12 = Wire(SInt(12.W))
  val imm5 = Wire(SInt(5.W))
  val imm32 = Wire(UInt(32.W))
  opcode := io.instr(OPCODE_HIGH, OPCODE_LOW)
  funct3 := io.instr(FUNCT3_HIGH, FUNCT3_LOW)
  io.rd := io.instr(RD_HIGH, RD_LOW)
  io.rs1 := io.instr(RS1_HIGH, RS1_LOW)
  io.rs2 := io.instr(RS2_HIGH, RS2_LOW)
  io.bfu_opcode := Cat(io.instr(OPCODE_LOW+6, OPCODE_LOW+4), io.instr(FUNCT3_LOW+2, FUNCT3_LOW))
  io.rdWrEn := true.B
  io.addEn  := false.B
  io.subEn  := false.B
  io.sltEn  := false.B
  io.sltuEn := false.B
  io.andEn  := false.B
  io.orEn   := false.B
  io.xorEn  := false.B
  io.sllEn  := false.B
  io.srEn   := false.B
  io.srMode := false.B
  io.luiEn  := false.B
  io.immSel := false.B
  io.mulEn  := false.B
  io.mulH   := false.B
  io.catEn  := false.B
  // io.divEn  := false.B
  io.remEn  := false.B
  io.rs1Signed := true.B
  io.rs2Signed := true.B
  io.imm := 0.S
  imm12 := io.instr(RS2_LOW+11, RS2_LOW).asSInt
  imm5 := io.instr(RS2_LOW+4, RS2_LOW).asSInt
  imm32 := Cat(io.instr(FUNCT3_LOW+19, FUNCT3_LOW), 0.U(12.W))

  when (opcode === 0x13.U && io.instr(FUNCT3_HIGH, RD_LOW) === 0.U) {
    io.rdWrEn := false.B
  } .elsewhen (opcode(3, 0) === 0xb.U) {
    when (io.rd === 0.U) {
      io.rdWrEn := false.B
    }
  } .elsewhen (opcode === 0x23.U) {
    io.rdWrEn := false.B
  }

  when (opcode(3, 0) === 0xb.U) {
    io.bfu_valid := true.B
  } .elsewhen (opcode === 3.U) {
    io.bfu_valid := true.B
  } .elsewhen (opcode === 0x23.U) {
    io.bfu_valid := true.B
  } .otherwise {
    io.bfu_valid := false.B
  }

  when (opcode === 0x13.U) {
    io.immSel := true.B
  }

  when (opcode === 0x37.U) {
    io.luiEn := true.B
    io.immSel := true.B
  }

  when (opcode === 0x13.U) {
    when (funct3(1, 0) === 1.U) {
      io.imm := imm5
    } .otherwise {
      io.imm := imm12
    }
  } .elsewhen (opcode === 0x37.U) {
    io.imm := imm32.asSInt
  } .elsewhen (opcode === 0x3.U) {
    io.imm := imm12
  } .elsewhen (opcode === 0x23.U) {
    io.imm := Cat(io.instr(IMM_HIGH, IMM_LOW), io.instr(RD_LOW+4, RD_LOW)).asSInt
  } .elsewhen (opcode(3, 0) === 0xb.U) {
    io.imm := imm12
  }

  when (opcode === 0x13.U || ((opcode === 0x33.U) && (io.instr(IMM_LOW) === 0.U))) {
    switch (funct3) {
      is (0.U) {
        when ((opcode === 0x33.U) && io.instr(IMM_LOW+5) === 1.U) {
          io.subEn := true.B
        } .otherwise {
          io.addEn := true.B
        }
      }
      is (1.U) {
        io.sllEn := true.B
      }
      is (2.U) {
        io.sltEn := true.B
      }
      is (3.U) {
        io.sltuEn := true.B
      }
      is (4.U) {
        io.xorEn := true.B
      }
      is (5.U) {
        io.srEn := true.B
        when (io.instr(IMM_LOW+5) === 1.U) {
          io.srMode := true.B
        } .otherwise {
          io.srMode := false.B
        }
      }
      is (6.U) {
        io.orEn := true.B
      }
      is (7.U) {
        io.andEn := true.B
      }
    }
  }

  when ((opcode === 0x33.U) && (io.instr(IMM_LOW) === 1.U)) {
    switch (funct3) {
      is (0.U) {
        io.mulEn := true.B
      }
      is (1.U) {
        io.mulEn := true.B
        io.mulH := true.B
      }
      is (2.U) {
        io.mulEn := true.B
        io.mulH := true.B
        io.rs1Signed := true.B
        io.rs2Signed := false.B
      }
      is (3.U) {
        io.mulEn := true.B
        io.mulH := true.B
        io.rs1Signed := false.B
        io.rs2Signed := false.B
      }
      is (4.U) {
        io.catEn := true.B
        // io.divEn := true.B
      }
      is (5.U) {
        io.catEn := true.B
        // io.divEn := true.B
        io.rs2Signed := false.B
      }
      is (6.U) {
        io.remEn := true.B
      }
      is (7.U) {
        io.remEn := true.B
        io.rs2Signed := false.B
      }
    }
  }
}

class DecodeBFU(inst_width: Int, num_regs_lg: Int) extends Module {
  val io = IO(new Bundle{
    val instr     = Input(UInt(inst_width.W))
    val valid     = Output(Bool())
    val opcode    = Output(UInt(6.W))
    val rs        = Output(Vec(2, UInt(num_regs_lg.W)))
    val rd        = Output(UInt(num_regs_lg.W))
    val rdWrEn    = Output(Bool())
    val imm       = Output(UInt(12.W))
  })

  val OPCODE_LOW = 0
  val OPCODE_HIGH = OPCODE_LOW + 6
  val RD_LOW = OPCODE_HIGH + 1
  val RD_HIGH = RD_LOW + num_regs_lg - 1
  val FUNCT3_LOW = RD_HIGH + 1
  val FUNCT3_HIGH = FUNCT3_LOW + 2
  val RS1_LOW = FUNCT3_HIGH + 1
  val RS1_HIGH = RS1_LOW + num_regs_lg - 1
  val RS2_LOW = RS1_HIGH + 1
  val RS2_HIGH = RS2_LOW + num_regs_lg - 1
  val IMM_LOW = RS2_HIGH + 1
  val IMM_HIGH = IMM_LOW + 6

  val opcode = io.instr(OPCODE_HIGH, OPCODE_LOW)
  io.opcode := Cat(io.instr(OPCODE_LOW+6, OPCODE_LOW+4), io.instr(FUNCT3_LOW+2, FUNCT3_LOW))
  io.rd := io.instr(RD_HIGH, RD_LOW)
  io.rs(0) := io.instr(RS1_HIGH, RS1_LOW)
  io.rs(1) := io.instr(RS2_HIGH, RS2_LOW)
  io.rdWrEn := false.B
  io.imm := io.instr(RS2_LOW+11, RS2_LOW)

  when (opcode(3, 0) === 0xb.U) {
    io.valid := true.B
    when (io.rd =/= 0.U && (opcode(6, 4) =/= 0.U) && (opcode(6, 4) =/= 5.U)) {
      io.rdWrEn := true.B
    }
  } .elsewhen (opcode === 3.U) {
    io.valid := true.B
    when (io.rd =/= 0.U && opcode(5) === 0.U) {
      io.rdWrEn := true.B
    }
  } .elsewhen (opcode === 0x23.U) {
    io.valid := true.B
    io.imm := Cat(io.instr(IMM_HIGH, IMM_LOW), io.instr(RD_LOW+4, RD_LOW))
  } .otherwise {
    io.valid := false.B
  }


}

class ALUMicrocodes(num_alus: Int, num_regs_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int) extends Bundle {
  val bfu_valid = Vec(num_alus, Bool())
  val opcode    = Vec(num_alus, UInt(6.W))
  val rs1_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs1_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
  val rs2_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs2_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
  val rd        = Vec(num_alus, UInt(num_regs_lg.W))
  val addEn     = Vec(num_alus, Bool())
  val subEn     = Vec(num_alus, Bool())
  val sltEn     = Vec(num_alus, Bool())
  val sltuEn    = Vec(num_alus, Bool())
  val andEn     = Vec(num_alus, Bool())
  val orEn      = Vec(num_alus, Bool())
  val xorEn     = Vec(num_alus, Bool())
  val sllEn     = Vec(num_alus, Bool())
  val srEn      = Vec(num_alus, Bool())
  val srMode    = Vec(num_alus, Bool())
  val luiEn     = Vec(num_alus, Bool())
  val catEn     = Vec(num_alus, Bool())
  val immSel    = Vec(num_alus, Bool())
  val imm       = Vec(num_alus, SInt(32.W))

  override def cloneType = (new ALUMicrocodes(num_alus, num_regs_lg, num_src_pos_lg, num_src_modes_lg).asInstanceOf[this.type])
}

class BRMicrocodes(num_alus: Int, num_fus: Int) extends Bundle {
  val brValid   = Bool()
  val brMode    = UInt(4.W)
  val rs1       = UInt(log2Up(num_alus*3+num_fus).W)
  val rs2       = UInt(log2Up(num_alus*3+num_fus).W)
  val pcOffset  = SInt(21.W)

  override def cloneType = (new BRMicrocodes(num_alus, num_fus).asInstanceOf[this.type])
}

class BFUMicrocodes(num_bfus: Int, num_regs_lg: Int) extends Bundle {
  val opcode    = Vec(num_bfus, UInt(6.W))
  val rs        = Vec(num_bfus, Vec(2, UInt(num_regs_lg.W)))
  val rd        = Vec(num_bfus, UInt(num_regs_lg.W))
  val bimm      = Vec(num_bfus, UInt(12.W))

  override def cloneType = (new BFUMicrocodes(num_bfus, num_regs_lg).asInstanceOf[this.type])
}

class Decode(num_alus: Int, num_bfus: Int, num_fus: Int, inst_width: Int, num_regs_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(((num_alus*3+num_fus+1)*inst_width).W))

    val rs1       = Output(Vec(num_fus, UInt(num_regs_lg.W)))
    val rs2       = Output(Vec(num_fus, UInt(num_regs_lg.W)))
    val rd        = Output(Vec(num_fus, UInt(num_regs_lg.W)))
    val rd_pos    = Output(Vec(num_alus, UInt(num_dst_pos_lg.W)))
    val rd_mode   = Output(Vec(num_alus, UInt(num_dst_modes_lg.W)))
    val rdWrEn    = Output(Vec(num_fus, Bool()))

    val bfuValids = Output(Vec(num_bfus, Bool()))
    val brUcodes  = Output(new BRMicrocodes(num_alus, num_fus))
    val aluUcodes = Output(new ALUMicrocodes(num_alus, num_regs_lg, num_src_pos_lg, num_src_modes_lg))
    val bfuUcodes = Output(new BFUMicrocodes(num_fus-num_alus, num_regs_lg))
  })
  // num_alus cannot exceed num_regs, or index will be truncated
  // assert(num_alus + num_bfus <= 32)

  print("Decode instantiated with " + num_alus + " ALUs, " + num_bfus + " BFUs, " + num_fus + " FUs, " + inst_width + " bit instructions, " + num_regs_lg + " bit register indices, " + num_src_pos_lg + " bit source positions, " + num_src_modes_lg + " bit source modes, " + num_dst_pos_lg + " bit destination positions, " + num_dst_modes_lg + " bit destination modes\n")
  val branchDecoder = Module(new DecodeBranch(inst_width, num_regs_lg))
  val eiuDecoders = Seq.fill(3*num_alus)(Module(new DecodeEIU(inst_width, num_regs_lg, num_src_pos_lg, num_src_modes_lg, num_dst_pos_lg, num_dst_modes_lg)))
  val aluDecoders = Seq.fill(num_alus)(Module(new DecodeALUBFU(inst_width, num_regs_lg)))
  val bfuDecoders = Seq.fill(num_fus-num_alus)(Module(new DecodeBFU(inst_width, num_regs_lg)))

  val ALU_PKT_WIDTH = 4*inst_width
  val EXTRACT0_LOW = 0
  val EXTRACT0_HIGH = EXTRACT0_LOW + inst_width - 1
  val EXTRACT1_LOW = EXTRACT0_HIGH + 1
  val EXTRACT1_HIGH = EXTRACT1_LOW + inst_width - 1
  val ALU_LOW = EXTRACT1_HIGH + 1
  val ALU_HIGH = ALU_LOW + inst_width -1 
  val INSERT_LOW = ALU_HIGH + 1
  val INSERT_HIGH = INSERT_LOW + inst_width - 1
  val BRINST_LOW = num_fus*inst_width + num_alus*3*inst_width
  val BRINST_HIGH = BRINST_LOW + inst_width - 1

  branchDecoder.io.instr := io.instr(BRINST_HIGH, BRINST_LOW)
  io.brUcodes.brValid := branchDecoder.io.brValid
  io.brUcodes.brMode := branchDecoder.io.brMode
  io.brUcodes.pcOffset := branchDecoder.io.pcOffset
  io.brUcodes.rs1 := branchDecoder.io.rs1
  io.brUcodes.rs2 := branchDecoder.io.rs2

  for (i <- 0 until num_alus) {
    eiuDecoders(3*i).io.instr := io.instr(i*ALU_PKT_WIDTH+EXTRACT0_HIGH, i*ALU_PKT_WIDTH+EXTRACT0_LOW)
    eiuDecoders(3*i+1).io.instr := io.instr(i*ALU_PKT_WIDTH+EXTRACT1_HIGH, i*ALU_PKT_WIDTH+EXTRACT1_LOW)
    aluDecoders(i).io.instr := io.instr(i*ALU_PKT_WIDTH+ALU_HIGH, i*ALU_PKT_WIDTH+ALU_LOW)
    eiuDecoders(3*i+2).io.instr := io.instr(i*ALU_PKT_WIDTH+INSERT_HIGH, i*ALU_PKT_WIDTH+INSERT_LOW)
  }

  if (num_alus < num_bfus) {
    for (i <- 0 until (num_bfus-num_alus)) {
      bfuDecoders(i).io.instr := io.instr(num_alus*ALU_PKT_WIDTH+i*inst_width+inst_width-1, num_alus*ALU_PKT_WIDTH+i*inst_width)
    }
  }

  for (i <- 0 until num_alus) {
    io.rs1(i)                 := eiuDecoders(i*3).io.rs
    io.rs2(i)                 := eiuDecoders(i*3+1).io.rs
    io.rd(i)                  := eiuDecoders(i*3+2).io.rd
    io.rd_pos(i)              := eiuDecoders(i*3+2).io.rd_pos
    io.rd_mode(i)             := eiuDecoders(i*3+2).io.rd_mode
    io.rdWrEn(i)              := eiuDecoders(i*3+2).io.rdWrEn
    io.aluUcodes.bfu_valid(i) := aluDecoders(i).io.bfu_valid
    io.aluUcodes.opcode(i)    := aluDecoders(i).io.bfu_opcode
    io.aluUcodes.rs1_pos(i)   := eiuDecoders(i*3).io.rs_pos
    io.aluUcodes.rs1_mode(i)  := eiuDecoders(i*3).io.rs_mode
    io.aluUcodes.rs2_pos(i)   := eiuDecoders(i*3+1).io.rs_pos
    io.aluUcodes.rs2_mode(i)  := eiuDecoders(i*3+1).io.rs_mode
    io.aluUcodes.rd(i)        := eiuDecoders(i*3+2).io.rd
    io.aluUcodes.addEn(i)     := aluDecoders(i).io.addEn
    io.aluUcodes.subEn(i)     := aluDecoders(i).io.subEn
    io.aluUcodes.sltEn(i)     := aluDecoders(i).io.sltEn
    io.aluUcodes.sltuEn(i)    := aluDecoders(i).io.sltuEn
    io.aluUcodes.andEn(i)     := aluDecoders(i).io.andEn
    io.aluUcodes.orEn(i)      := aluDecoders(i).io.orEn
    io.aluUcodes.xorEn(i)     := aluDecoders(i).io.xorEn
    io.aluUcodes.sllEn(i)     := aluDecoders(i).io.sllEn
    io.aluUcodes.srEn(i)      := aluDecoders(i).io.srEn
    io.aluUcodes.srMode(i)    := aluDecoders(i).io.srMode
    io.aluUcodes.luiEn(i)     := aluDecoders(i).io.luiEn
    io.aluUcodes.catEn(i)     := aluDecoders(i).io.catEn
    io.aluUcodes.immSel(i)    := aluDecoders(i).io.immSel
    io.aluUcodes.imm(i)       := aluDecoders(i).io.imm
    // io.mulEn(i)     := aluDecoders(i).io.mulEn
    // io.mulH(i)      := aluDecoders(i).io.mulH
    // io.divEn(i)     := aluDecoders(i).io.divEn
    // io.remEn(i)     := aluDecoders(i).io.remEn
    // io.rs1Signed(i) := aluDecoders(i).io.rs1Signed
    // io.rs2Signed(i) := aluDecoders(i).io.rs2Signed
  }

  if (num_alus == num_bfus) {
    // The last BFU is always the IO unit
    io.rdWrEn(num_alus-1) := eiuDecoders(num_alus*3-1).io.rdWrEn & (!aluDecoders(num_alus-1).io.bfu_valid)
  }

  if (num_alus < num_bfus) {
    for (i <- 0 until num_alus) {
      io.bfuValids(i) := aluDecoders(i).io.bfu_valid
    }
    for (i <- 0 until num_bfus-num_alus) {
      io.bfuValids(i+num_alus)  := bfuDecoders(i).io.valid
      io.rs1(i+num_alus)        := bfuDecoders(i).io.rs(0)
      io.rs2(i+num_alus)        := bfuDecoders(i).io.rs(1)
      io.rd(i+num_alus)         := bfuDecoders(i).io.rd
      io.rdWrEn(i+num_alus)     := bfuDecoders(i).io.rdWrEn
      io.bfuUcodes.opcode(i)    := bfuDecoders(i).io.opcode
      io.bfuUcodes.rs(i)        := bfuDecoders(i).io.rs
      io.bfuUcodes.rd(i)        := bfuDecoders(i).io.rd
      io.bfuUcodes.bimm(i)      := bfuDecoders(i).io.imm
    }
  } else {
    for (i <- 0 until num_bfus) {
      io.bfuValids(i) := aluDecoders(i).io.bfu_valid
    }
  }

}