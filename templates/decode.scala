import chisel3._
import chisel3.util._

class DecodeBranch extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(32.W))
    val brValid   = Output(Bool())
    val brMode    = Output(UInt(4.W))
    val rs1       = Output(UInt(5.W))
    val rs2       = Output(UInt(5.W))
    val rd        = Output(UInt(5.W))
    val rdWrEn    = Output(Bool())
    val pcOffset  = Output(SInt(21.W))
  })

  val opcode = Wire(UInt(7.W))
  opcode := io.instr(6, 0)
  io.rd := io.instr(11, 7)
  io.rs1 := io.instr(19, 15)
  io.rs2 := io.instr(24, 20)
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
    val tmp = Cat(io.instr(31), io.instr(19, 12), io.instr(20), io.instr(30, 21), 0.U(1.W)).asSInt
    io.pcOffset := tmp
  } .elsewhen (opcode === 0x63.U) {
    io.brMode := io.instr(14, 12)
    val tmp = Cat(io.instr(31), io.instr(7), io.instr(30, 25), io.instr(11, 8), 0.U(1.W)).asSInt
    io.pcOffset := tmp
  } .elsewhen (opcode === 0x67.U) {
    val tmp = io.instr(31, 20).asSInt
    io.brMode := 8.U
    io.pcOffset := tmp
  } .otherwise {
    io.brValid := false.B
  }
}

class DecodeALU(alu_inst_w: Int, num_regs_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(alu_inst_w.W))
    val rs1       = Output(UInt(num_regs_lg.W))
    val rs1_pos   = Output(UInt(num_src_pos_lg.W))
    val rs1_mode  = Output(UInt(num_src_modes_lg.W))
    val rs2       = Output(UInt(num_regs_lg.W))
    val rs2_pos   = Output(UInt(num_src_pos_lg.W))
    val rs2_mode  = Output(UInt(num_src_modes_lg.W))
    val rd        = Output(UInt(num_regs_lg.W))
    val rd_pos    = Output(UInt(num_dst_pos_lg.W))
    val rd_mode   = Output(UInt(num_dst_modes_lg.W))
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
  })

  val RD_LOW = 7
  val RD_HIGH = RD_LOW + num_regs_lg + num_dst_pos_lg + num_dst_modes_lg - 1
  val FUNCT3_LOW = RD_HIGH + 1
  val FUNCT3_HIGH = FUNCT3_LOW + 2
  val RS1_LOW = FUNCT3_HIGH + 1
  val RS1_HIGH = RS1_LOW + num_regs_lg + num_src_pos_lg + num_src_modes_lg - 1
  val RS2_LOW = RS1_HIGH + 1
  val RS2_HIGH = RS2_LOW + num_regs_lg + num_src_pos_lg + num_src_modes_lg - 1

  val opcode = Wire(UInt(7.W))
  val funct3 = Wire(UInt(3.W))
  val imm12 = Wire(SInt(12.W))
  val imm5 = Wire(SInt(5.W))
  val imm32 = Wire(UInt(32.W))
  opcode := io.instr(6, 0)
  funct3 := io.instr(FUNCT3_HIGH, FUNCT3_LOW)
  io.rd := io.instr(RD_LOW+num_regs_lg-1, RD_LOW)
  io.rd_pos := io.instr(RD_LOW+num_regs_lg+num_dst_pos_lg-1, RD_LOW+num_regs_lg)
  io.rd_mode := io.instr(RD_HIGH, RD_LOW+num_regs_lg+num_dst_pos_lg)
  io.rs1 := io.instr(RS1_LOW+num_regs_lg-1, RS1_LOW)
  io.rs1_pos := io.instr(RS1_LOW+num_regs_lg+num_src_pos_lg-1, RS1_LOW+num_regs_lg)
  io.rs1_mode := io.instr(RS1_HIGH, RS1_LOW+num_regs_lg+num_src_pos_lg)
  io.rs2 := io.instr(RS2_LOW+num_regs_lg-1, RS2_LOW)
  io.rs2_pos := io.instr(RS2_LOW+num_regs_lg+num_src_pos_lg-1, RS2_LOW+num_regs_lg)
  io.rs2_mode := io.instr(RS2_HIGH, RS2_LOW+num_regs_lg+num_src_pos_lg)
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

  // when (opcode === 0x13.U && io.instr(FUNCT3_HIGH, RD_LOW) === 0.U) {
  when (io.instr(RD_LOW+num_regs_lg-1, RD_LOW) === 0.U) {
    io.rdWrEn := false.B
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
  }

  when (opcode === 0x13.U || ((opcode === 0x33.U) && (io.instr(RS2_HIGH+1) === 0.U))) {
    switch (funct3) {
      is (0.U) {
        when ((opcode === 0x33.U) && io.instr(RS2_HIGH+5) === 1.U) {
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
        when (io.instr(RS2_HIGH+5) === 1.U) {
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

  when ((opcode === 0x33.U) && (io.instr(RS2_HIGH+1) === 1.U)) {
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

class DecodeBFU extends Module {
  val io = IO(new Bundle{
    val instr     = Input(UInt(32.W))
    val valid     = Output(Bool())
    val opcode    = Output(UInt(6.W))
    val rs        = Output(Vec(2, UInt(5.W)))
    val rd        = Output(UInt(5.W))
    val rdWrEn    = Output(Bool())
    val imm       = Output(UInt(12.W))
  })

  val opcode = io.instr(6, 0)
  io.opcode := Cat(io.instr(6, 4), io.instr(14, 12))
  io.rd := io.instr(11, 7)
  io.rs(0) := io.instr(19, 15)
  io.rs(1) := io.instr(24, 20)
  io.rdWrEn := false.B
  io.imm := io.instr(31, 20)

  when (opcode(3, 0) === 0xb.U) {
    io.valid := true.B
    when (io.rd =/= 0.U) {
      io.rdWrEn := true.B
    }
  } .elsewhen (opcode === 3.U) {
    io.valid := true.B
    when (io.rd =/= 0.U && opcode(5) === 0.U) {
      io.rdWrEn := true.B
    }
  } .elsewhen (opcode === 0x23.U) {
    io.valid := true.B
    io.imm := Cat(io.instr(31, 25), io.instr(11, 7))
  } .otherwise {
    io.valid := false.B
  }


}

class ALUMicrocodes(num_alus: Int, num_src_pos_lg: Int, num_src_modes_lg: Int) extends Bundle {
  val rs1_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs1_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
  val rs2_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs2_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
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

  override def cloneType = (new ALUMicrocodes(num_alus, num_src_pos_lg, num_src_modes_lg).asInstanceOf[this.type])
}

class BRMicrocodes(num_alus: Int, num_bfus: Int) extends Bundle {
  val brValid   = Bool()
  val brMode    = UInt(4.W)
  val rs1       = UInt(log2Up(num_alus+num_bfus).W)
  val rs2       = UInt(log2Up(num_alus+num_bfus).W)
  val pcOffset  = SInt(21.W)

  override def cloneType = (new BRMicrocodes(num_alus, num_bfus).asInstanceOf[this.type])
}

class BFUMicrocodes(num_alus: Int, num_bfus: Int) extends Bundle {
  val opcode    = Vec(num_bfus, UInt(6.W))
  val rs        = Vec(num_bfus, Vec(2, UInt(5.W)))
  val rd        = Vec(num_bfus, UInt(5.W))
  val bimm      = Vec(num_bfus, UInt(12.W))

  override def cloneType = (new BFUMicrocodes(num_alus, num_bfus).asInstanceOf[this.type])
}

class Decode(num_alus: Int, num_bfus: Int, alu_inst_w: Int, num_regs_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt((num_alus*alu_inst_w+(num_bfus+1)*32).W))

    val rs1       = Output(Vec(num_alus, UInt(num_regs_lg.W)))
    val rs2       = Output(Vec(num_alus, UInt(num_regs_lg.W)))
    val rd        = Output(Vec((num_alus+num_bfus+1), UInt(num_regs_lg.W)))
    val rd_pos    = Output(Vec(num_alus, UInt(num_dst_pos_lg.W)))
    val rd_mode   = Output(Vec(num_alus, UInt(num_dst_modes_lg.W)))
    val rdWrEn    = Output(Vec((num_alus+num_bfus+1), Bool()))

    val bfuValids = Output(Vec(num_bfus, Bool()))
    val brUcodes  = Output(new BRMicrocodes(num_alus, num_bfus))
    val aluUcodes = Output(new ALUMicrocodes(num_alus, num_src_pos_lg, num_src_modes_lg))
    val bfuUcodes = Output(new BFUMicrocodes(num_alus, num_bfus))
  })
  // num_alus cannot exceed num_regs, or index will be truncated
  // assert(num_alus + num_bfus <= 32)

  val branchDecoder = Module(new DecodeBranch)
  val aluDecoders = Seq.fill(num_alus)(Module(new DecodeALU(alu_inst_w, num_regs_lg, num_src_pos_lg, num_src_modes_lg, num_dst_pos_lg, num_dst_modes_lg)))
  val bfuDecoders = Seq.fill(num_bfus)(Module(new DecodeBFU))

  val ALUINST_LOW = 0
  val ALUINST_HIGH = ALUINST_LOW + num_alus*alu_inst_w - 1
  val BFUINST_LOW = ALUINST_HIGH + 1
  val BFUINST_HIGH = BFUINST_LOW + num_bfus*32 - 1
  val BRINST_LOW = BFUINST_HIGH + 1
  val BRINST_HIGH = BRINST_LOW + 31

  branchDecoder.io.instr := io.instr(BRINST_HIGH, BRINST_LOW)
  io.brUcodes.brValid := branchDecoder.io.brValid
  io.brUcodes.brMode := branchDecoder.io.brMode
  io.brUcodes.pcOffset := branchDecoder.io.pcOffset
  io.brUcodes.rs1 := branchDecoder.io.rs1
  io.brUcodes.rs2 := branchDecoder.io.rs2
  io.rd(num_alus+num_bfus) := branchDecoder.io.rd
  io.rdWrEn(num_alus+num_bfus) := branchDecoder.io.rdWrEn

  for (i <- 0 until num_alus) {
    aluDecoders(i).io.instr := io.instr(ALUINST_LOW+(i+1)*alu_inst_w-1, ALUINST_LOW+i*alu_inst_w)
    io.rs1(i)                 := aluDecoders(i).io.rs1
    io.rs2(i)                 := aluDecoders(i).io.rs2
    io.rd(i)                  := aluDecoders(i).io.rd
    io.rd_pos(i)              := aluDecoders(i).io.rd_pos
    io.rd_mode(i)             := aluDecoders(i).io.rd_mode
    io.rdWrEn(i)              := aluDecoders(i).io.rdWrEn
    io.aluUcodes.rs1_pos(i)   := aluDecoders(i).io.rs1_pos
    io.aluUcodes.rs1_mode(i)  := aluDecoders(i).io.rs1_mode
    io.aluUcodes.rs2_pos(i)   := aluDecoders(i).io.rs2_pos
    io.aluUcodes.rs2_mode(i)  := aluDecoders(i).io.rs2_mode
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

  for (i <- 0 until num_bfus) {
    bfuDecoders(i).io.instr := io.instr(BFUINST_LOW+(i+1)*32-1, BFUINST_LOW+i*32)
    io.rd(num_alus+i)         := bfuDecoders(i).io.rd
    io.rdWrEn(num_alus+i)     := bfuDecoders(i).io.rdWrEn
    io.bfuValids(i)           := bfuDecoders(i).io.valid
    io.bfuUcodes.opcode(i)    := bfuDecoders(i).io.opcode
    io.bfuUcodes.rs(i)        := bfuDecoders(i).io.rs
    io.bfuUcodes.rd(i)        := bfuDecoders(i).io.rd
    io.bfuUcodes.bimm(i)      := bfuDecoders(i).io.imm
  }
}