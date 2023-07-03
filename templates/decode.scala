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

class DecodeEIU(num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(32.W))
    val rs        = Output(UInt(5.W))
    val rs_pos    = Output(UInt(num_src_pos_lg.W))
    val rs_mode   = Output(UInt(num_src_modes_lg.W))
    val rd        = Output(UInt(5.W))
    val rd_pos    = Output(UInt(num_dst_pos_lg.W))
    val rd_mode   = Output(UInt(num_dst_modes_lg.W))
    val rdWrEn    = Output(Bool())
  })

  io.rs := io.instr(19, 15)
  io.rs_pos := io.instr(20+num_src_pos_lg-1, 20)
  io.rs_mode := io.instr(20+num_src_pos_lg+num_src_modes_lg-1, 20+num_src_pos_lg)
  io.rd := io.instr(11, 7)
  io.rd_pos := io.instr(20+num_dst_pos_lg-1, 20)
  io.rd_mode := io.instr(20+num_dst_pos_lg+num_dst_modes_lg-1, 20+num_dst_pos_lg)

  io.rdWrEn := false.B
  when ((io.instr(12) === 1.U) && (io.rd =/= 0.U)) {
    io.rdWrEn := true.B
  }
}

class DecodeALUBFU extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(32.W))
    val rs1       = Output(UInt(5.W))
    val rs2       = Output(UInt(5.W))
    val rd        = Output(UInt(5.W))
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

  val opcode = Wire(UInt(7.W))
  val funct3 = Wire(UInt(3.W))
  val imm12 = Wire(SInt(12.W))
  val imm5 = Wire(SInt(5.W))
  val imm32 = Wire(UInt(32.W))
  opcode := io.instr(6, 0)
  funct3 := io.instr(14, 12)
  io.rd := io.instr(11, 7)
  io.rs1 := io.instr(19, 15)
  io.rs2 := io.instr(24, 20)
  io.bfu_opcode := Cat(io.instr(6, 4), io.instr(14, 12))
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
  imm12 := io.instr(31, 20).asSInt
  imm5 := io.instr(24, 20).asSInt
  imm32 := Cat(io.instr(31, 12), 0.U(12.W))

  when (opcode === 0x13.U && io.instr(14, 7) === 0.U) {
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
    io.imm := Cat(io.instr(31, 25), io.instr(11, 7)).asSInt
  } .elsewhen (opcode(3, 0) === 0xb.U) {
    io.imm := imm12
  }

  when (opcode === 0x13.U || ((opcode === 0x33.U) && (io.instr(25) === 0.U))) {
    switch (funct3) {
      is (0.U) {
        when ((opcode === 0x33.U) && io.instr(30) === 1.U) {
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
        when (io.instr(30) === 1.U) {
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

  when ((opcode === 0x33.U) && (io.instr(25) === 1.U)) {
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
  val bfu_valid = Vec(num_alus, Bool())
  val opcode    = Vec(num_alus, UInt(6.W))
  val rs1_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs1_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
  val rs2_pos   = Vec(num_alus, UInt(num_src_pos_lg.W))
  val rs2_mode  = Vec(num_alus, UInt(num_src_modes_lg.W))
  val rd        = Vec(num_alus, UInt(5.W))
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

class BRMicrocodes(num_alus: Int, num_fus: Int) extends Bundle {
  val brValid   = Bool()
  val brMode    = UInt(4.W)
  val rs1       = UInt(log2Up(num_alus*3+num_fus).W)
  val rs2       = UInt(log2Up(num_alus*3+num_fus).W)
  val pcOffset  = SInt(21.W)

  override def cloneType = (new BRMicrocodes(num_alus, num_fus).asInstanceOf[this.type])
}

class BFUMicrocodes(num_bfus: Int) extends Bundle {
  val opcode    = Vec(num_bfus, UInt(6.W))
  val rs        = Vec(num_bfus, Vec(2, UInt(5.W)))
  val rd        = Vec(num_bfus, UInt(5.W))
  val bimm      = Vec(num_bfus, UInt(12.W))

  override def cloneType = (new BFUMicrocodes(num_bfus).asInstanceOf[this.type])
}

class Decode(num_alus: Int, num_bfus: Int, num_fus: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_dst_pos_lg: Int, num_dst_modes_lg: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(((num_alus*3+num_fus+1)*32).W))

    val rs1       = Output(Vec(num_fus, UInt(5.W)))
    val rs2       = Output(Vec(num_fus, UInt(5.W)))
    val rd        = Output(Vec(num_fus, UInt(5.W)))
    val rd_pos    = Output(Vec(num_alus, UInt(num_dst_pos_lg.W)))
    val rd_mode   = Output(Vec(num_alus, UInt(num_dst_modes_lg.W)))
    val rdWrEn    = Output(Vec(num_fus, Bool()))

    val bfuValids = Output(Vec(num_bfus, Bool()))
    val brUcodes  = Output(new BRMicrocodes(num_alus, num_fus))
    val aluUcodes = Output(new ALUMicrocodes(num_alus, num_src_pos_lg, num_src_modes_lg))
    val bfuUcodes = Output(new BFUMicrocodes(num_fus-num_alus))
  })
  // num_alus cannot exceed num_regs, or index will be truncated
  // assert(num_alus + num_bfus <= 32)

  val branchDecoder = Module(new DecodeBranch)
  val eiuDecoders = Seq.fill(3*num_alus)(Module(new DecodeEIU(num_src_pos_lg, num_src_modes_lg, num_dst_pos_lg, num_dst_modes_lg)))
  val aluDecoders = Seq.fill(num_alus)(Module(new DecodeALUBFU))
  val bfuDecoders = Seq.fill(num_fus-num_alus)(Module(new DecodeBFU))

  val ALU_PKT_WIDTH = 4*32
  val EXTRACT0_LOW = 0
  val EXTRACT0_HIGH = EXTRACT0_LOW + 31
  val EXTRACT1_LOW = EXTRACT0_HIGH + 1
  val EXTRACT1_HIGH = EXTRACT1_LOW + 31
  val ALU_LOW = EXTRACT1_HIGH + 1
  val ALU_HIGH = ALU_LOW + 31
  val INSERT_LOW = ALU_HIGH + 1
  val INSERT_HIGH = INSERT_LOW + 31
  val BRINST_LOW = num_fus*32 + num_alus*3*32
  val BRINST_HIGH = BRINST_LOW + 31

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
      bfuDecoders(i).io.instr := io.instr(num_alus*ALU_PKT_WIDTH+i*32+31, num_alus*ALU_PKT_WIDTH+i*32)
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