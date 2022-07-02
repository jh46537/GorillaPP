import chisel3._
import chisel3.util._
import chisel3.util.Fill
import chisel3.util.PriorityEncoder
import chisel3.experimental.ChiselEnum
import chisel3.util.experimental.loadMemoryFromFileInline

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap
import scala.io.Source


class Gather(imm_width: Int, reg_width: Int, num_blocks: Int, src_pos: Array[Int],
   max_out_width: Int, num_modes:Int, src_mode: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))
    val shift = Input(UInt(log2Up(num_blocks).W))
    val mode = Input(UInt(log2Up(num_modes).W))
    val imm = Input(UInt(imm_width.W))
    val sign_out = Output(UInt(1.W))
    val dout = Output(UInt(reg_width.W))
  })

  val din_d0 = Reg(UInt(reg_width.W))
  val shift_d0 = Reg(UInt(log2Up(num_blocks).W))
  val mode_d0 = Reg(UInt(log2Up(num_modes).W))
  val imm_d0 = Reg(UInt(imm_width.W))

  val num_muxes : Int = (num_blocks+7)/8
  val reg0 = Reg(Vec(num_muxes, UInt(max_out_width.W)))
  val src_pos_i = src_pos ++ Array(0, 0, 0, 0, 0, 0, 0)
  for (i <- 0 until num_muxes) {
    switch(io.shift(2, 0)) {
      is (0.U) {
        reg0(i) := io.din((src_pos_i(i*8)+max_out_width-1).min(reg_width-1), src_pos_i(i*8))
      }
      is (1.U) {
        reg0(i) := io.din((src_pos_i(i*8+1)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+1))
      }
      is (2.U) {
        reg0(i) := io.din((src_pos_i(i*8+2)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+2))
      }
      is (3.U) {
        reg0(i) := io.din((src_pos_i(i*8+3)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+3))
      }
      is (4.U) {
        reg0(i) := io.din((src_pos_i(i*8+4)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+4))
      }
      is (5.U) {
        reg0(i) := io.din((src_pos_i(i*8+5)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+5))
      }
      is (6.U) {
        reg0(i) := io.din((src_pos_i(i*8+6)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+6))
      }
      is (7.U) {
        reg0(i) := io.din((src_pos_i(i*8+7)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+7))
      }
    }
  }

  din_d0 := io.din
  shift_d0 := (io.shift >> 3)
  mode_d0 := io.mode
  imm_d0 := io.imm

  val reg1 = Reg(UInt(max_out_width.W))
  val din_d1 = Reg(UInt(reg_width.W))
  val mode_d1 = Reg(UInt(log2Up(num_modes).W))
  val imm_d1 = Reg(UInt(imm_width.W))

  din_d1 := din_d0
  mode_d1 := mode_d0
  imm_d1 := imm_d0
  val cases = (0 until num_muxes).map( x => x.U -> reg0(x))
  reg1 := MuxLookup(shift_d0, DontCare, cases)

  val reg2 = Reg(UInt(max_out_width.W))
  val din_d2 = Reg(UInt(reg_width.W))
  val mode_d2 = Reg(UInt(log2Up(num_modes).W))
  val imm_d2 = Reg(UInt(imm_width.W))
  din_d2 := din_d1
  mode_d2 := mode_d1
  imm_d2 := imm_d1

  val cases2 = (0 until num_modes).map( x => x.U -> reg1(src_mode(x)-1, 0))
  reg2 := MuxLookup(mode_d1, DontCare, cases2)
  when (mode_d2 === num_modes.U) {
    io.dout := Cat(0.U, imm_d2)
  } .otherwise {
    io.dout := Cat(din_d2(reg_width-1, max_out_width), reg2)
  }
  io.sign_out := 0.U
}

class Scatter(reg_width: Int, lg_num_rdBlocks: Int, lg_num_modes: Int, num_wrBlocks: Int,
  num_dst_pos: Int, dst_encode: Array[Int], dst_pos: Array[Int],
  num_wbens: Int, dst_en_encode: Array[(Int, Int)], wbens: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))
    val shift = Input(UInt(lg_num_rdBlocks.W))
    val mode = Input(UInt(lg_num_modes.W))
    val wren = Output(UInt(num_wrBlocks.W))
    val dout = Output(UInt(reg_width.W))
  })
  val din_w = Wire(UInt(reg_width.W))
  val dout_r = Reg(UInt(reg_width.W))
  val wben_r = Reg(UInt(num_wrBlocks.W))
  din_w := io.din

  val cases = (0 until num_dst_pos).map(i => (io.shift === dst_encode(i).U) -> (din_w << dst_pos(i)))
  dout_r := MuxCase(DontCare, cases)
  val cases2 = (0 until num_wbens).map(i => ((io.shift === dst_en_encode(i)._1.U) && ((dst_en_encode(i)._2 == -1).B || (io.mode === dst_en_encode(i)._2.S.asUInt))) -> wbens(i).U)
  wben_r := MuxCase(0.U, cases2)

  io.dout := dout_r
  io.wren := wben_r
}

class ALU extends Module {
  val io = IO(new Bundle {
    val rs1       = Input(UInt(32.W))
    val rs2       = Input(UInt(32.W))
    val addEn     = Input(Bool())
    val sltEn     = Input(Bool())
    val sltuEn    = Input(Bool())
    val andEn     = Input(Bool())
    val orEn      = Input(Bool())
    val xorEn     = Input(Bool())
    val sllEn     = Input(Bool())
    val srEn      = Input(Bool())
    val srMode    = Input(Bool())
    val luiEn     = Input(Bool())
    val immSel    = Input(Bool())
    val imm       = Input(SInt(32.W))
    val dout      = Output(UInt(32.W))
  })

  val opA = Reg(SInt(32.W))
  val opB = Reg(SInt(32.W))
  val res = Wire(SInt(32.W))
  val addEn_r   = RegInit(false.B)
  val sltEn_r   = RegInit(false.B)
  val sltuEn_r  = RegInit(false.B)
  val andEn_r   = RegInit(false.B)
  val orEn_r    = RegInit(false.B)
  val xorEn_r   = RegInit(false.B)
  val sllEn_r   = RegInit(false.B)
  val srEn_r    = RegInit(false.B)
  val srMode_r  = RegInit(false.B)
  val luiEn_r   = RegInit(false.B)

  opA := io.rs1.asSInt
  opB := Mux(io.immSel, io.imm, io.rs2.asSInt)
  addEn_r  := io.addEn
  sltEn_r  := io.sltEn
  sltuEn_r := io.sltuEn
  andEn_r  := io.andEn
  orEn_r   := io.orEn
  xorEn_r  := io.xorEn
  sllEn_r  := io.sllEn
  srEn_r   := io.srEn
  srMode_r := io.srMode
  luiEn_r  := io.luiEn
  res := DontCare

  when (addEn_r) {
    res := opA + opB
  } .elsewhen (sltEn_r) {
    when (opA < opB) {
      res := 1.S
    } .otherwise {
      res := 0.S
    }
  } .elsewhen(sltuEn_r) {
    val opA_u = opA.asUInt
    val opB_u = opB.asUInt
    when (opA_u < opB_u) {
      res := 1.S
    } .otherwise {
      res := 0.S
    }
  } .elsewhen (andEn_r) {
    res := opA & opB
  } .elsewhen (orEn_r) {
    res := opA | opB
  } .elsewhen (xorEn_r) {
    res := opA ^ opB
  } .elsewhen (sllEn_r) {
    val shamt = opB(4, 0).asUInt
    res := opA << shamt
  } .elsewhen (sllEn_r) {
    val shamt = opB(4, 0).asUInt
    when (srMode_r) {
      res := opA >> shamt
    } .otherwise {
      val opA_u = opA.asUInt
      res := (opA_u >> shamt).asSInt
    }
  } .elsewhen (luiEn_r) {
    res := opB
  }

  io.dout := res.asUInt

}

class BranchUnit extends Module {
  val io = IO(new Bundle {
    val rs1       = Input(SInt(32.W))
    val rs2       = Input(SInt(32.W))
    val pc        = Input(SInt(32.W))
    val brValid   = Input(Bool())
    val brMode    = Input(UInt(3.W))
    val pcOffset  = Input(SInt(21.W))

    val pcOut     = Output(SInt(32.W))
    val dout      = Output(SInt(32.W))
    val finish    = Output(Bool())
  })

  val pcInc = Wire(SInt(32.W))
  val pcOff = Wire(SInt(32.W))
  val pcPlain = Wire(SInt(32.W))
  pcInc := io.pc + 4.S
  pcOff := io.pc + io.pcOffset
  pcPlain := io.pcOffset
  io.pcOut := pcInc
  io.dout := pcInc
  io.finish := false.B

  when (io.brValid) {
    switch (io.brMode) {
      is (0.U) {
        when (io.rs1 === io.rs2) {
          io.pcOut := pcOff
        }
      }
      is (1.U) {
        when (io.rs1 =/= io.rs2) {
          io.pcOut := pcOff
        }
      }
      is (2.U) {
        io.pcOut := pcOff
      }
      is (3.U) {
        io.pcOut := pcPlain
        when (pcPlain === -2.S) {
          io.finish := true.B
        }
      }
      is (4.U) {
        when (io.rs1 < io.rs2) {
          io.pcOut := pcOff
        }
      }
      is (5.U) {
        when (io.rs1 >= io.rs2) {
          io.pcOut := pcOff
        }
      }
      is (6.U) {
        val rs1_u = io.rs1.asUInt
        val rs2_u = io.rs2.asUInt
        when (rs1_u < rs2_u) {
          io.pcOut := pcOff
        }
      }
      is (7.U) {
        val rs1_u = io.rs1.asUInt
        val rs2_u = io.rs2.asUInt
        when (rs1_u >= rs2_u) {
          io.pcOut := pcOff
        }
      }
    }
  }
}

class ram_simple2port(num: Int, width: Int) extends 
  BlackBox(Map("AWIDTH" -> log2Up(num),
               "DWIDTH" -> width,
               "DEPTH"  -> num)) with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock     = Input(Clock())
    val data      = Input(UInt(width.W))
    val rdaddress = Input(UInt(log2Up(num).W))
    val rden      = Input(Bool())
    val wraddress = Input(UInt(log2Up(num).W))
    val wren      = Input(Bool())
    val q         = Output(UInt(width.W))
  })

  // addResource("/ram_simple2port.v")
  addResource("/ram_simple2port_sim.v")

}

class ram_qp(num: Int, width: Int) extends 
  BlackBox(Map("AWIDTH" -> log2Up(num),
               "DWIDTH" -> width,
               "DEPTH"  -> num)) with HasBlackBoxResource {
  val io = IO(new Bundle {
    val read_address_a  = Input(UInt(log2Up(num).W))
    val read_address_b  = Input(UInt(log2Up(num).W))
    val q_a             = Output(UInt(width.W))
    val q_b             = Output(UInt(width.W))

    val wren_a          = Input(Bool())
    val wren_b          = Input(Bool())
    val write_address_a = Input(UInt(log2Up(num).W))
    val write_address_b = Input(UInt(log2Up(num).W))
    val data_a          = Input(UInt(width.W))
    val data_b          = Input(UInt(width.W))

    val clock           = Input(Clock())
  })

  // addResource("/ram_qp.v")
  addResource("/ram_qp_sim.v")

}

class Regfile(num: Int, width: Int, num_blocks: Int, block_widths: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val rdAddr1 = Input(UInt(log2Up(num).W))
    val rdAddr2 = Input(UInt(log2Up(num).W))
    val rdData1 = Output(UInt(width.W))
    val rdData2 = Output(UInt(width.W))

    val wrEn1   = Input(Bool())
    val wrEn2   = Input(Bool())
    val wrBen1  = Input(UInt(num_blocks.W))
    val wrBen2  = Input(UInt(num_blocks.W))
    val wrAddr1 = Input(UInt(log2Up(num).W))
    val wrAddr2 = Input(UInt(log2Up(num).W))
    val wrData1 = Input(UInt(width.W))
    val wrData2 = Input(UInt(width.W))
  })

  val mems = for (i <- 0 until num_blocks) yield {
    val mem = Module(new ram_qp(num, block_widths(i)))
    mem
  }
  val rdData1 = Wire(MixedVec((0 until num_blocks) map {i => UInt(block_widths(i).W)}))
  val rdData2 = Wire(MixedVec((0 until num_blocks) map {i => UInt(block_widths(i).W)}))
  var pos = 0
  for (i <- 0 until num_blocks) {
    mems(i).io.clock := clock
    mems(i).io.read_address_a := io.rdAddr1
    mems(i).io.read_address_b := io.rdAddr2
    mems(i).io.write_address_a := io.wrAddr1
    mems(i).io.write_address_b := io.wrAddr2
    mems(i).io.wren_a := io.wrEn1 && io.wrBen1(i)
    mems(i).io.wren_b := io.wrEn2 && io.wrBen2(i)
    mems(i).io.data_a := io.wrData1(pos+block_widths(i)-1, pos)
    mems(i).io.data_b := io.wrData2(pos+block_widths(i)-1, pos)
    pos = pos + block_widths(i)
    rdData1(i) := mems(i).io.q_a
    rdData2(i) := mems(i).io.q_b
  }

  io.rdData1 := rdData1.asUInt
  io.rdData2 := rdData2.asUInt

}

class RegRead(threadnum: Int, num_rd: Int, num_wr: Int, num_regs: Int, reg_w: Int, num_blocks: Int, block_widths: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val rdEn        = Input(Bool())
    val thread_rd   = Input(UInt(log2Up(threadnum).W))
    val rdAddr1     = Input(Vec(num_rd, UInt(log2Up(num_regs).W)))
    val rdAddr2     = Input(Vec(num_rd, UInt(log2Up(num_regs).W)))
    val rdData1     = Output(Vec(num_rd, UInt(reg_w.W)))
    val rdData2     = Output(Vec(num_rd, UInt(reg_w.W)))

    val wrEn        = Input(Bool())
    val wrEn1       = Input(Vec(num_wr, Bool()))
    val wrEn2       = Input(Vec(num_wr, Bool()))
    val thread_wr   = Input(UInt(log2Up(threadnum).W))
    val wrBen1      = Input(Vec(num_wr, UInt(num_blocks.W)))
    val wrBen2      = Input(Vec(num_wr, UInt(num_blocks.W)))
    val wrAddr1     = Input(Vec(num_wr, UInt(log2Up(num_regs).W)))
    val wrAddr2     = Input(Vec(num_wr, UInt(log2Up(num_regs).W)))
    val wrData1     = Input(Vec(num_wr, UInt(reg_w.W)))
    val wrData2     = Input(Vec(num_wr, UInt(reg_w.W)))
  })

  val num_regfile = scala.math.pow(2, log2Up(num_rd)).toInt
  val regfile = Seq.fill(num_regfile)(Module(new Regfile(num_regs*threadnum/num_regfile, reg_w, num_blocks, block_widths)))

  // Read logic
  val thread_rd_vec = Reg(Vec(num_rd+1, UInt(log2Up(threadnum).W)))
  if (num_rd > 1) {
    val state_rd = RegInit(VecInit(Seq.fill(num_regfile)(0.U(log2Up(num_rd).W))))
    val thread_rd = Reg(Vec(num_regfile, UInt(log2Up(threadnum/num_regfile).W)))
    val rdAddr1 = Reg(Vec(num_regfile, Vec(num_rd, UInt(log2Up(num_regs).W))))
    val rdAddr2 = Reg(Vec(num_regfile, Vec(num_rd, UInt(log2Up(num_regs).W))))
    for (i <- 0 until num_regfile) {
      when (state_rd(i) === 0.U) {
        when (io.rdEn && (io.thread_rd(log2Up(num_regfile)-1, 0) === i.U)) {
          regfile(i).io.rdAddr1 := Cat(io.thread_rd(log2Up(threadnum)-1, log2Up(num_regfile)), io.rdAddr1(state_rd(i)))
          regfile(i).io.rdAddr2 := Cat(io.thread_rd(log2Up(threadnum)-1, log2Up(num_regfile)), io.rdAddr2(state_rd(i)))
          rdAddr1(i) := io.rdAddr1
          rdAddr2(i) := io.rdAddr2
          thread_rd(i) := io.thread_rd(log2Up(threadnum)-1, log2Up(num_regfile))
          state_rd(i) := 1.U
        } .otherwise {
          regfile(i).io.rdAddr1 := DontCare
          regfile(i).io.rdAddr2 := DontCare
        }
      } .otherwise {
        regfile(i).io.rdAddr1 := Cat(thread_rd(i), rdAddr1(i)(state_rd(i)))
        regfile(i).io.rdAddr2 := Cat(thread_rd(i), rdAddr2(i)(state_rd(i)))
        when (state_rd(i) + 1.U === num_rd.U) {
          state_rd(i) := 0.U
        } .otherwise {
          state_rd(i) := state_rd(i) + 1.U
        }
      }
    }
  } else {
    regfile(0).io.rdAddr1 := Cat(io.thread_rd, io.rdAddr1(0))
    regfile(0).io.rdAddr2 := Cat(io.thread_rd, io.rdAddr2(0))
  }

  if (num_rd > 1) {
    thread_rd_vec(0) := io.thread_rd
    for (i <- 0 until num_rd) {
      thread_rd_vec(i+1) := thread_rd_vec(i)
    }
    val rdData1 = Wire(Vec(num_regfile, UInt(reg_w.W)))
    val rdData2 = Wire(Vec(num_regfile, UInt(reg_w.W)))
    for (i <- 0 until num_regfile) {
      rdData1(i) := regfile(i).io.rdData1
      rdData2(i) := regfile(i).io.rdData2
    }
    for (i <- 0 until num_rd) {
      val rdData1_vec = Reg(Vec(num_rd-i, UInt(reg_w.W)))
      val rdData2_vec = Reg(Vec(num_rd-i, UInt(reg_w.W)))
      val regfile_slct = Wire(UInt(log2Up(num_rd).W))
      regfile_slct := thread_rd_vec(1+i)(log2Up(num_regfile)-1, 0)
      rdData1_vec(0) := rdData1(regfile_slct)
      rdData2_vec(0) := rdData2(regfile_slct)
      if (i < num_rd-1) {
        for (j <- 1 until num_rd-i) {
          rdData1_vec(j) := rdData1_vec(j-1)
          rdData2_vec(j) := rdData2_vec(j-1)
        }
      }
      io.rdData1(i) := rdData1_vec(num_rd-1-i)
      io.rdData2(i) := rdData2_vec(num_rd-1-i)
    }
  } else {
    io.rdData1(0) := regfile(0).io.rdData1
    io.rdData2(0) := regfile(0).io.rdData2
  }

  // Write logic
  if (num_wr > 1) {
    for (i <- 0 until num_regfile) {
      val state_wr = RegInit(0.U(log2Up(num_wr).W))
      val thread_wr = Reg(UInt(log2Up(threadnum/num_regfile).W))
      val wrAddr1 = Reg(Vec(num_wr, UInt(log2Up(num_regs).W)))
      val wrAddr2 = Reg(Vec(num_wr, UInt(log2Up(num_regs).W)))
      val wrEn1 = Reg(Vec(num_wr, Bool()))
      val wrEn2 = Reg(Vec(num_wr, Bool()))
      val wrBen1 = Reg(Vec(num_wr, UInt(num_blocks.W)))
      val wrBen2 = Reg(Vec(num_wr, UInt(num_blocks.W)))
      val wrData1 = Reg(Vec(num_wr, UInt(reg_w.W)))
      val wrData2 = Reg(Vec(num_wr, UInt(reg_w.W)))
      when (state_wr === 0.U) {
        when (io.wrEn && (io.thread_wr(log2Up(num_regfile)-1, 0) === i.U)) {
          regfile(i).io.wrAddr1 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr1(state_wr))
          regfile(i).io.wrAddr2 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr2(state_wr))
          regfile(i).io.wrBen1 := io.wrBen1(state_wr)
          regfile(i).io.wrBen2 := io.wrBen2(state_wr)
          regfile(i).io.wrEn1 := io.wrEn1(state_wr)
          regfile(i).io.wrEn2 := io.wrEn2(state_wr)
          regfile(i).io.wrData1 := io.wrData1(state_wr)
          regfile(i).io.wrData2 := io.wrData2(state_wr)
          thread_wr := io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile))
          wrAddr1 := io.wrAddr1
          wrAddr2 := io.wrAddr2
          wrEn1 := io.wrEn1
          wrEn2 := io.wrEn2
          wrBen1 := io.wrBen1
          wrBen2 := io.wrBen2
          wrData1 := io.wrData1
          wrData2 := io.wrData2
          state_wr := 1.U
        } .otherwise {
          regfile(i).io.wrAddr1 := DontCare
          regfile(i).io.wrAddr2 := DontCare
          regfile(i).io.wrBen1 := DontCare
          regfile(i).io.wrBen2 := DontCare
          regfile(i).io.wrEn1 := false.B
          regfile(i).io.wrEn2 := false.B
          regfile(i).io.wrData1 := DontCare
          regfile(i).io.wrData2 := DontCare
        }
      } .otherwise {
        regfile(i).io.wrAddr1 := Cat(thread_wr, wrAddr1(state_wr))
        regfile(i).io.wrAddr2 := Cat(thread_wr, wrAddr2(state_wr))
        regfile(i).io.wrBen1 := wrBen1(state_wr)
        regfile(i).io.wrBen2 := wrBen2(state_wr)
        regfile(i).io.wrEn1 := wrEn1(state_wr)
        regfile(i).io.wrEn2 := wrEn2(state_wr)
        regfile(i).io.wrData1 := wrData1(state_wr)
        regfile(i).io.wrData2 := wrData2(state_wr)
        when (state_wr + 1.U === num_wr.U) {
          state_wr := 0.U
        } .otherwise {
          state_wr := state_wr + 1.U
        }
      }
    }
  } else {
    if (num_regfile > 1) {
      for (i <- 0 until num_regfile) {
        when (io.wrEn && (io.thread_wr(log2Up(num_regfile)-1, 0) === i.U)) {
          regfile(i).io.wrAddr1 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr1(0))
          regfile(i).io.wrAddr2 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr2(0))
          regfile(i).io.wrBen1 := io.wrBen1(0)
          regfile(i).io.wrBen2 := io.wrBen2(0)
          regfile(i).io.wrEn1 := io.wrEn1(0)
          regfile(i).io.wrEn2 := io.wrEn2(0)
          regfile(i).io.wrData1 := io.wrData1(0)
          regfile(i).io.wrData2 := io.wrData2(0)
        } .otherwise {
          regfile(i).io.wrAddr1 := DontCare
          regfile(i).io.wrAddr2 := DontCare
          regfile(i).io.wrBen1 := DontCare
          regfile(i).io.wrBen2 := DontCare
          regfile(i).io.wrEn1 := false.B
          regfile(i).io.wrEn2 := false.B
          regfile(i).io.wrData1 := DontCare
          regfile(i).io.wrData2 := DontCare
        }
      }
    } else {
      regfile(0).io.wrAddr1 := Cat(io.thread_wr, io.wrAddr1(0))
      regfile(0).io.wrAddr2 := Cat(io.thread_wr, io.wrAddr2(0))
      regfile(0).io.wrBen1 := io.wrBen1(0)
      regfile(0).io.wrBen2 := io.wrBen2(0)
      regfile(0).io.wrEn1 := io.wrEn1(0)
      regfile(0).io.wrEn2 := io.wrEn2(0)
      regfile(0).io.wrData1 := io.wrData1(0)
      regfile(0).io.wrData2 := io.wrData2(0)
    }
  }

}

// class Scheduler(num_threads: Int, num_regfile: Int) extends Module {
//   val io = IO(new Bundle {
//     val valid = Input(Vec(num_threads, Bool()))
//     val chosen = Output(UInt((log2Up(num_threads)+1).W))
//   })
//   val thread = RegInit(0.U(log2Up(num_threads).W))
//   val chosen = RegInit(num_threads.U((log2Up(num_threads)+1).W))
//   val prot = RegInit(0.U(log2Up(num_regfile).W))
//   when (prot =/= 0.U) {
//     when (io.valid(thread)) {
//       chosen := thread
//       prot := (num_regfile-1).U
//     } .otherwise {
//       chosen := num_threads.U
//       prot := prot - 1.U
//     }
//     thread := thread + 1.U
//   } .otherwise {
//     val cases = (0 until num_threads).map( x => io.valid(x) -> x.U)
//     chosen := MuxCase(num_threads.U, cases)
//     thread := MuxCase(num_threads.U, cases) + 1.U
//     when (io.valid.asUInt =/= 0.U) {
//       prot := (num_regfile-1).U
//     }
//   }

//   io.chosen := chosen
// }

class Scheduler(num_threads: Int, num_regfile: Int) extends Module {
  val io = IO(new Bundle {
    val valid = Input(Vec(num_threads, Bool()))
    val chosen = Output(UInt((log2Up(num_threads)+1).W))
  })
  val thread = RegInit(0.U(log2Up(num_regfile).W))
  val chosen_i = Wire(Vec(num_regfile, UInt((log2Up(num_threads)+1).W)))
  for (i <- 0 until num_regfile) {
    val cases = (0 until (num_threads/num_regfile)).map( x => io.valid(x * num_regfile + i) -> (x * num_regfile + i).U)
    chosen_i(i) := MuxCase(num_threads.U, cases)
  }
  thread := thread + 1.U

  io.chosen := chosen_i(thread)
}

class Scheduler_order(num_threads: Int) extends Module {
  val io = IO(new Bundle {
    val valid = Input(Bool())
    val tag = Input(UInt((log2Up(num_threads)).W))
    val order_ready = Input(Vec(num_threads, Bool()))
    val ready = Input(Vec(num_threads, Bool()))
    val chosen = Output(UInt((log2Up(num_threads)+1).W))
  })
  val thread = RegInit(0.U(1.W))
  val thread_count = RegInit(0.U((log2Up(num_threads) + 1).W))
  val fifo = Module(new Queue(UInt((log2Up(num_threads)).W), num_threads))
  thread := thread + 1.U
  val chosen_i = Wire(Vec(2, UInt((log2Up(num_threads)+1).W)))
  for (i <- 0 until 2) {
    val cases = (0 until (num_threads/2)).map( x => io.ready(x * 2 + i) -> (x * 2 + i).U)
    chosen_i(i) := MuxCase(num_threads.U, cases)
  }
  thread := thread + 1.U

  fifo.io.enq.valid := false.B
  fifo.io.enq.bits := DontCare
  when (io.valid) {
    fifo.io.enq.valid := true.B
    fifo.io.enq.bits := io.tag
  }

  io.chosen := num_threads.U
  fifo.io.deq.ready := false.B
  // deq fifo
  val tag = fifo.io.deq.bits
  when (fifo.io.count > 0.U && (tag(0) === thread) && io.order_ready(tag)) {
    io.chosen := fifo.io.deq.bits
    fifo.io.deq.ready := true.B
  } .otherwise {
    io.chosen := chosen_i(thread)
  }
}

class Fetch(num: Int, ipWidth: Int, instrWidth: Int) extends Module {
  val io = IO(new Bundle {
    val cfgIn      = Input(UInt(instrWidth.W))
    val cfgIp      = Input(UInt(ipWidth.W))
    val cfgValid   = Input(Bool())
    val ip         = Input(UInt(ipWidth.W))
    val instr      = Output(UInt(instrWidth.W))
  })

  // FIXME: implement i$

  // var mem_array = Array.fill[UInt](1 << ipWidth)(0.U(instrWidth.W))
  var mem = VecInit(
    "h000000130000001300000013000000130000028b7d0001133e800093".U,
    "h000000130002937b0042935b000000130040100b0020e233002081b3".U,
    "hfffff06f000000130000005b00000013000000130000001300000037".U,
  )

  // val mem = SyncReadMem(1 << ipWidth, UInt(instrWidth.W))
  // loadMemoryFromFileInline(mem, "../assembler/npu.bin")

  // when (io.cfgValid) {
  //   mem.write(io.cfgIp, io.cfgIn)
  // }

  io.instr := mem((io.ip)/4.U)
}

class Shifter(num_bytes: Int) extends Module {
  val io = IO(new Bundle {
    val in0        = Input(Vec(num_bytes, UInt(8.W)))
    val in1        = Input(Vec(num_bytes, UInt(8.W)))
    val length     = Input(UInt((log2Up(num_bytes)).W))
    val ptr        = Input(UInt((log2Up(num_bytes)).W))
    val valid_o    = Output(Bool())
    val buf0_out   = Output(Vec(num_bytes, UInt(8.W)))
    val buf1_out   = Output(Vec(num_bytes, UInt(8.W)))
    val buf0_wben  = Output(Vec(num_bytes, Bool()))
    val new_length = Output(UInt((log2Up(num_bytes)).W))
    val new_ptr    = Output(UInt((log2Up(num_bytes)).W))
  })

  io.new_length := io.length
  io.new_ptr := 0.U
  io.buf0_wben := VecInit(Seq.fill(num_bytes)(true.B))
  when (io.length === 0.U) {
    when (io.ptr === 0.U) {
      io.valid_o := true.B
    } .otherwise {
      io.valid_o := false.B
      io.new_length := num_bytes.U - io.ptr
      (0 until num_bytes).map(i => io.buf0_wben(i) := Mux(i.U < io.ptr, true.B, false.B))
    }
  } .otherwise {
    when (io.ptr === 0.U) {
      io.valid_o := true.B
      io.new_ptr := num_bytes.U - io.length
    } .elsewhen (io.length <= io.ptr) {
      io.valid_o := true.B
      io.new_ptr := io.ptr - io.length
    } .otherwise {
      io.valid_o := false.B
      io.new_length := io.length - io.ptr
      (0 until num_bytes).map(i => io.buf0_wben(i) := Mux(i.U < num_bytes.U - io.length + io.ptr, true.B, false.B))
    }
  }

  when (io.length === 0.U) {
    (0 until num_bytes).map(i => io.buf0_out(i) := io.in1(i))
  } .otherwise {
    (0 until num_bytes).map(i => io.buf0_out(i) := Mux(i.U < num_bytes.U - io.length, io.in0(i.U + io.length), io.in1(i.U + io.length - num_bytes.U)))
  }

  (0 until num_bytes).map(i => io.buf1_out(i) := Mux(i.U < num_bytes.U - io.length, io.in1(i.U + io.length), io.in1(i)))

}

class input_buf(buf_depth: Int) extends Module {
  val io = IO(new Bundle {
    val wvalid  = Input(Bool())
    val wdata   = Input(UInt(128.W))
    val wready  = Output(Bool())

    val arvalid = Input(Bool())
    val opcode  = Input(Bool())
    val ardata  = Input(UInt(4.W))
    // val arready = Output(Bool())

    val rvalid  = Output(Bool())
    val rdata   = Output(UInt(128.W))
  })

  val buf = Module(new Queue(UInt(128.W), buf_depth))
  val shifter = Module(new Shifter(16))

  io.wready := buf.io.enq.ready
  buf.io.enq.valid := io.wvalid && io.wready
  buf.io.enq.bits := io.wdata

  val outBuf0 = Reg(Vec(16, UInt(8.W)))
  val outBuf1 = Reg(Vec(16, UInt(8.W)))
  val outState = RegInit(0.U(3.W))
  val rvalid_r = RegInit(false.B)
  val rdata_r = Reg(UInt(128.W))
  val outBuf1_ptr = RegInit(0.U(4.W))
  val length = RegInit(0.U(4.W))
  val wben = RegInit(0.U(16.W))

  io.rvalid := rvalid_r
  io.rdata := rdata_r
  buf.io.deq.ready := false.B
  shifter.io.in0 := outBuf0
  shifter.io.in1 := outBuf1
  shifter.io.ptr := outBuf1_ptr
  shifter.io.length := DontCare

  rvalid_r := false.B
  when (outState === 0.U) {
    // deq 16B
    // io.arready := false.B
    when (buf.io.deq.valid) {
      buf.io.deq.ready := true.B
      outBuf0 := buf.io.deq.bits.asTypeOf(chiselTypeOf(outBuf0))
      outState := 1.U
    }
  } .elsewhen (outState === 1.U) {
    // only 1 output buffer filled
    // io.arready := true.B
    when (io.arvalid) {
      when (io.opcode === 0.U) {
        // read 16B
        // rvalid_r := true.B
        rdata_r := outBuf0.asUInt
      } .elsewhen (io.opcode === 1.U) {
        // seek
        // io.arready := false.B
        length := io.ardata
        when (buf.io.deq.valid) {
          // deq 16B
          buf.io.deq.ready := true.B
          outBuf1 := buf.io.deq.bits.asTypeOf(chiselTypeOf(outBuf1))
          outBuf1_ptr := 0.U
          outState := 2.U
        }
      }
    } .elsewhen (buf.io.deq.valid) {
      // deq 16B
      buf.io.deq.ready := true.B
      outBuf1 := buf.io.deq.bits.asTypeOf(chiselTypeOf(outBuf1))
      outBuf1_ptr := 0.U
      outState := 2.U
    }
  } .elsewhen (outState === 2.U) {
    // both output buffers filled
    // io.arready := true.B
    when (io.arvalid) {
      when (io.opcode === 0.U) {
        // read 16B
        // rvalid_r := true.B
        rdata_r := outBuf0.asUInt
      } .elsewhen (io.opcode === 1.U) {
        // seek
        shifter.io.length := io.ardata
        length := shifter.io.new_length
        outBuf1_ptr := shifter.io.new_ptr
        outBuf0 := shifter.io.buf0_out
        wben := ~(shifter.io.buf0_wben.asUInt)
        when ((io.ardata > outBuf1_ptr && (outBuf1_ptr =/= 0.U)) || (io.ardata === outBuf1_ptr) || (io.ardata === 0.U)) {
          buf.io.deq.ready := buf.io.deq.valid
          outBuf1 := buf.io.deq.bits.asTypeOf(chiselTypeOf(outBuf1))
        } .otherwise {
          outBuf1 := shifter.io.buf1_out
        }
        when (!shifter.io.valid_o) {
          when (buf.io.deq.valid) {
            outState := 3.U
          } .otherwise {
            outState := 4.U
          }
        } .otherwise {
          rvalid_r := true.B
          when ((io.ardata === outBuf1_ptr) && !buf.io.deq.valid) {
            outState := 1.U
          }
        }
      }
    }
  } .elsewhen (outState === 3.U) {
    // io.arready := false.B
    shifter.io.length := length
    (0 until 16).map(i => outBuf0(i) := Mux(wben(i), shifter.io.buf0_out(i), outBuf0(i)))
    outBuf1 := shifter.io.buf1_out
    outBuf1_ptr := shifter.io.new_ptr
    rvalid_r := true.B
    outState := 2.U
  } .elsewhen (outState === 4.U) {
    when (buf.io.deq.valid) {
      outBuf1 := buf.io.deq.bits.asTypeOf(chiselTypeOf(outBuf1))
      outState := 3.U
    }
  }
}

class DecodeBranch extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(32.W))
    val brValid   = Output(Bool())
    val brMode    = Output(UInt(3.W))
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
  } .otherwise {
    io.brValid := false.B
  }
}

class DecodeALU extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(32.W))
    val rs1       = Output(UInt(5.W))
    val rs2       = Output(UInt(5.W))
    val rd        = Output(UInt(5.W))
    val rdWrEn    = Output(Bool())
    val addEn     = Output(Bool())
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
    val divEn     = Output(Bool())
    val remEn     = Output(Bool())
    val rs1Signed = Output(Bool())
    val rs2Signed = Output(Bool())
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
  io.rdWrEn := true.B
  io.addEn  := false.B
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
  io.divEn  := false.B
  io.remEn  := false.B
  io.rs1Signed := true.B
  io.rs2Signed := true.B
  io.imm := 0.S
  imm12 := io.instr(31, 20).asSInt
  imm5 := io.instr(24, 20).asSInt
  imm32 := Cat(io.instr(31, 12), 0.U(12.W))

  when (opcode === 0x13.U && io.instr(14, 7) === 0.U) {
    io.rdWrEn := false.B
  }

  when (opcode === 0x13.U) {
    io.immSel := true.B
  }

  when (opcode === 0x37.U) {
    io.luiEn := true.B
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

  when (opcode === 0x13.U || ((opcode === 0x33.U) && (io.instr(25) === 0.U))) {
    switch (funct3) {
      is (0.U) {
        io.addEn := true.B
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
        io.divEn := true.B
      }
      is (5.U) {
        io.divEn := true.B
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
    val b0En      = Output(Bool())
    val b1En      = Output(Bool())
    val b2En      = Output(Bool())
    val b3En      = Output(Bool())
    val funct     = Output(Bool())
    val rs1Sel    = Output(Bool())
    val rs1       = Output(UInt(5.W))
    val rs2Sel    = Output(Bool())
    val rs2       = Output(UInt(5.W))
    val rd        = Output(UInt(5.W))
    val rdWrEn    = Output(Bool())
    val imm       = Output(UInt(12.W))
  })

  val opcode = Wire(UInt(7.W))
  opcode := io.instr(6, 0)
  io.b0En := false.B
  io.b1En := false.B
  io.b2En := false.B
  io.b3En := false.B
  io.rd := io.instr(11, 7)
  io.rs1 := io.instr(19, 15)
  io.rs2 := io.instr(24, 20)
  io.funct := io.instr(12).asBool
  io.rs1Sel := io.instr(13).asBool
  io.rs2Sel := io.instr(14).asBool
  io.rdWrEn := false.B

  when (opcode === 0xb.U || opcode === 0x2b.U || opcode === 0x5b.U || opcode === 0x7b.U) {
    io.valid := true.B
    when (io.rd =/= 0.U) {
      io.rdWrEn := true.B
    }
  } .otherwise {
    io.valid := false.B
  }

  when (opcode === 0xb.U) {
    io.b0En := true.B
  } .elsewhen (opcode === 0x2b.U) {
    io.b1En := true.B
  } .elsewhen (opcode === 0x5b.U) {
    io.b2En := true.B
  } .elsewhen (opcode === 0x7b.U) {
    io.b3En := true.B
  }

  when (io.instr(12) === 1.U) {
    io.imm := io.instr(31, 20)
  } .otherwise {
    io.imm := io.instr(31, 25)
  }

}

class ALUMicrocodes(num_alus: Int) extends Bundle {
  val addEn     = Vec(num_alus, Bool())
  val sltEn     = Vec(num_alus, Bool())
  val sltuEn    = Vec(num_alus, Bool())
  val andEn     = Vec(num_alus, Bool())
  val orEn      = Vec(num_alus, Bool())
  val xorEn     = Vec(num_alus, Bool())
  val sllEn     = Vec(num_alus, Bool())
  val srEn      = Vec(num_alus, Bool())
  val srMode    = Vec(num_alus, Bool())
  val luiEn     = Vec(num_alus, Bool())
  val immSel    = Vec(num_alus, Bool())
  val imm       = Vec(num_alus, SInt(32.W))

  override def cloneType = (new ALUMicrocodes(num_alus).asInstanceOf[this.type])
}

class BRMicrocodes extends Bundle {
  val brValid   = Bool()
  val brMode    = UInt(3.W)
  val pcOffset  = SInt(21.W)

  override def cloneType = (new BRMicrocodes().asInstanceOf[this.type])
}

class BFUMicrocodes(num_bfus: Int) extends Bundle {
  val b0En      = Vec(num_bfus, Bool())
  val b1En      = Vec(num_bfus, Bool())
  val b2En      = Vec(num_bfus, Bool())
  val b3En      = Vec(num_bfus, Bool())
  val funct     = Vec(num_bfus, Bool())
  val rs1Sel    = Vec(num_bfus, Bool())
  val rs2Sel    = Vec(num_bfus, Bool())
  val bimm      = Vec(num_bfus, UInt(12.W))

  override def cloneType = (new BFUMicrocodes(num_bfus).asInstanceOf[this.type])
}

class Decode(num_alus: Int, num_bfus: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(((num_alus+num_bfus+1)*32).W))

    val rs1       = Output(Vec((num_alus+num_bfus+1), UInt(5.W)))
    val rs2       = Output(Vec((num_alus+num_bfus+1), UInt(5.W)))
    val rd        = Output(Vec((num_alus+num_bfus+1), UInt(5.W)))
    val rdWrEn    = Output(Vec((num_alus+num_bfus+1), Bool()))

    val bfuValids = Output(Vec(num_bfus, Bool()))
    val brUcodes  = Output(new BRMicrocodes)
    val aluUcodes = Output(new ALUMicrocodes(num_alus))
    val bfuUcodes = Output(new BFUMicrocodes(num_bfus))
  })

  val branchDecoder = Module(new DecodeBranch)
  val aluDecoders = Seq.fill(num_alus)(Module(new DecodeALU))
  val bfuDecoders = Seq.fill(num_bfus)(Module(new DecodeBFU))

  val ALUINST_LOW = 0
  val ALUINST_HIGH = ALUINST_LOW + num_alus*32 - 1
  val BFUINST_LOW = ALUINST_HIGH + 1
  val BFUINST_HIGH = BFUINST_LOW + num_bfus*32 - 1
  val BRINST_LOW = BFUINST_HIGH + 1
  val BRINST_HIGH = BRINST_LOW + 31

  branchDecoder.io.instr := io.instr(BRINST_HIGH, BRINST_LOW)
  io.brUcodes.brValid := branchDecoder.io.brValid
  io.brUcodes.brMode := branchDecoder.io.brMode
  io.brUcodes.pcOffset := branchDecoder.io.pcOffset
  io.rs1(num_alus+num_bfus) := branchDecoder.io.rs1
  io.rs2(num_alus+num_bfus) := branchDecoder.io.rs2
  io.rd(num_alus+num_bfus) := branchDecoder.io.rd
  io.rdWrEn(num_alus+num_bfus) := branchDecoder.io.rdWrEn

  for (i <- 0 until num_alus) {
    aluDecoders(i).io.instr := io.instr(ALUINST_LOW+(i+1)*32-1, ALUINST_LOW+i*32)
    io.rs1(i)                 := aluDecoders(i).io.rs1
    io.rs2(i)                 := aluDecoders(i).io.rs2
    io.rd(i)                  := aluDecoders(i).io.rd
    io.rdWrEn(i)              := aluDecoders(i).io.rdWrEn
    io.aluUcodes.addEn(i)     := aluDecoders(i).io.addEn
    io.aluUcodes.sltEn(i)     := aluDecoders(i).io.sltEn
    io.aluUcodes.sltuEn(i)    := aluDecoders(i).io.sltuEn
    io.aluUcodes.andEn(i)     := aluDecoders(i).io.andEn
    io.aluUcodes.orEn(i)      := aluDecoders(i).io.orEn
    io.aluUcodes.xorEn(i)     := aluDecoders(i).io.xorEn
    io.aluUcodes.sllEn(i)     := aluDecoders(i).io.sllEn
    io.aluUcodes.srEn(i)      := aluDecoders(i).io.srEn
    io.aluUcodes.srMode(i)    := aluDecoders(i).io.srMode
    io.aluUcodes.luiEn(i)     := aluDecoders(i).io.luiEn
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
    io.rs1(num_alus+i)        := bfuDecoders(i).io.rs1
    io.rs2(num_alus+i)        := bfuDecoders(i).io.rs2
    io.rd(num_alus+i)         := bfuDecoders(i).io.rd
    io.rdWrEn(num_alus+i)     := bfuDecoders(i).io.rdWrEn
    io.bfuValids(i)           := bfuDecoders(i).io.valid
    io.bfuUcodes.b0En(i)      := bfuDecoders(i).io.b0En
    io.bfuUcodes.b1En(i)      := bfuDecoders(i).io.b1En
    io.bfuUcodes.b2En(i)      := bfuDecoders(i).io.b2En
    io.bfuUcodes.b3En(i)      := bfuDecoders(i).io.b3En
    io.bfuUcodes.funct(i)      := bfuDecoders(i).io.funct
    io.bfuUcodes.rs1Sel(i)    := bfuDecoders(i).io.rs1Sel
    io.bfuUcodes.rs2Sel(i)    := bfuDecoders(i).io.rs2Sel
    io.bfuUcodes.bimm(i)      := bfuDecoders(i).io.imm
  }
}


class porc(extCompName: String) extends gComponentLeaf(new porcIn_t, new porcOut_t, ArrayBuffer(("mspm", new mspmIn_t, new mspmOut_t), ("ascii", new asciiIn_t, new asciiOut_t)), extCompName + "__type__engine__MT__16__") {
  val filename = "./src/main/scala/primate.cfg"
  val fileSource = Source.fromFile(filename)
  val lines = fileSource.getLines.toList
  var knobs:Map[String, String] = Map()
  for (line <- lines) {
    val Array(key, value) = line.split("=")
    knobs += (key -> value)
  }
  val NUM_THREADS = knobs.apply("NUM_THREADS").toInt
  val REG_WIDTH = knobs.apply("REG_WIDTH").toInt
  val NUM_REGS = knobs.apply("NUM_REGS").toInt
  val NUM_BFUS = knobs.apply("NUM_BFUS").toInt
  val NUM_ALUS = knobs.apply("NUM_ALUS").toInt
  val IMM_WIDTH = knobs.apply("IMM_WIDTH").toInt
  val NUM_REGBLOCKS = knobs.apply("NUM_REGBLOCKS").toInt
  val NUM_SRC_POS = knobs.apply("NUM_SRC_POS").toInt
  val NUM_SRC_MODES = knobs.apply("NUM_SRC_MODES").toInt
  val NUM_DST_POS = knobs.apply("NUM_DST_POS").toInt
  val NUM_DST_MODE = knobs.apply("NUM_DST_MODE").toInt
  val MAX_FIELD_WIDTH = knobs.apply("MAX_FIELD_WIDTH").toInt
  val IP_WIDTH = knobs.apply("IP_WIDTH").toInt
  val reg_block_width:Array[Int] = knobs.apply("REG_BLOCK_WIDTH").split(" ").map(_.toInt)
  val src_pos:Array[Int] = knobs.apply("SRC_POS").split(" ").map(_.toInt)
  val src_mode:Array[Int] = knobs.apply("SRC_MODE").split(" ").map(_.toInt)
  val dst_encode:Array[Int] = knobs.apply("DST_ENCODE").split(" ").map(_.toInt)
  val dst_pos:Array[Int] = knobs.apply("DST_POS").split(" ").map(_.toInt)
  val wbens:Array[Int] = knobs.apply("DST_EN").split(" ").map(_.toInt)
  val dst_en_encode:Array[(Int, Int)] = knobs.apply("DST_EN_ENCODE").split(";").map(_.split(" ") match {case Array(a1, a2) => (a1.toInt, a2.toInt)})

  // val NUM_THREADS = 16
  // val REG_WIDTH = 270
  // val NUM_REGS = 16
  // val NUM_BFUS = 4
  // val NUM_ALUS = 2
  // val IMM_WIDTH = 8
  // val NUM_REGBLOCKS = 14
  // val NUM_SRC_POS = 26
  // val NUM_SRC_MODES = 14
  // val NUM_DST_POS = 9
  // val NUM_DST_MODE = 10
  // val MAX_FIELD_WIDTH = 56
  // val IP_WIDTH = 8
  val INIT_IP = 8
  val NUM_THREADS_LG = log2Up(NUM_THREADS)
  val NUM_REGS_LG = log2Up(NUM_REGS)
  val NUM_FUOPS_LG = 2
  val NUM_FUS = NUM_BFUS + NUM_ALUS + 1
  val NUM_FUS_LG = log2Up(NUM_FUS)
  val NUM_DST = 1
  val NUM_PREOPS = 11
  val NUM_PREOPS_LG = log2Up(NUM_PREOPS)
  val NUM_ALUOPS_LG = 4
  val NUM_BTS = 3
  val NUM_SRC_POS_LG = log2Up(NUM_SRC_POS)
  val NUM_SRC_MODES_LG = log2Up(NUM_SRC_MODES)
  val NUM_RF_BANKS = scala.math.pow(2, log2Up(NUM_FUS)).toInt
  val NUM_RF_RD_PORTS = NUM_FUS
  val NUM_RF_WR_PORTS = (NUM_FUS+1)/2
  val NUM_WR_BANKS = scala.math.pow(2, log2Up(NUM_RF_WR_PORTS)).toInt
  // FIXME
  val INSTR_WIDTH = 32 * NUM_FUS
  // val INSTR_WIDTH = NUM_PREOPS_LG + NUM_ALUS * (NUM_ALUOPS_LG + 3 * (NUM_SRC_POS_LG + NUM_SRC_MODES_LG) + 2 * NUM_REGS_LG) + 2 * NUM_DST * (NUM_FUS_LG + NUM_REGS_LG + 1) + NUM_FUS * (1 + NUM_FUOPS_LG) + IP_WIDTH * NUM_BTS + NUM_ALUS * IMM_WIDTH
  // val INSTR_WIDTH = 6  // 40-bits

  val NONE_SELECTED = (NUM_THREADS).U((log2Up(NUM_THREADS+1)).W)

/* vvvvvvvvvvv DELETE vvvvvvvvvv */
  //val WaitForInputValid = (0).U((8).W)
  //val WaitForOutputReady = (255).U((8).W)
  //val WaitForReady = (0).U((1).W)
  //val WaitForValid = (1).U((1).W)
  //val inputTag = Reg(Vec(NUM_THREADS, UInt((TAGWIDTH*2).W)))
  //val State = RegInit(VecInit(Seq.fill(NUM_THREADS)(WaitForInputValid)))
  //val EmitReturnState = RegInit(VecInit(Seq.fill(NUM_THREADS)(WaitForInputValid)))
  //val outstandingOffs = RegInit(VecInit(Seq.fill(NUM_THREADS)((0).U((5).W))))
  val AllOffloadsReady = Reg(Bool())
  val AllOffloadsValid  = Reg(Vec(NUM_THREADS, Bool()))

  /*******************Thread states*********************************/
  //val subStateTh = RegInit(VecInit(Seq.fill(NUM_THREADS)(WaitForReady)))

  //def myOff = io.elements.getOrElse("off", nullOff)
  // 160-bits
  //val ipv4Input = Reg(Vec(NUM_THREADS, new IPv4Header_t))	//Global variable
  // 160-bits
  //val ipv4Output = Reg(Vec(NUM_THREADS, new IPv4Header_t))	//Global variable
  // 32-bits
  //val gOutPort = Reg(Vec(NUM_THREADS, UInt((32).W)))	//Global variable

  //val inputReg = Reg(Vec(NUM_THREADS, new NP_EthMpl3Header_t))
  //val outputReg = Reg(Vec(NUM_THREADS, new NP_EthMpl3Header_t))
/* ^^^^^^^^^^^ DELETE ^^^^^^^^^^ */

  // set up function units
  def functionalUnits = io.elements("off")
  def mspmPort = functionalUnits.asInstanceOf[Bundle].elements("mspm").asInstanceOf[gOffBundle[mspmIn_t, mspmOut_t]]
  def asciiPort = functionalUnits.asInstanceOf[Bundle].elements("ascii").asInstanceOf[gOffBundle[asciiIn_t, asciiOut_t]]

  object ThreadStageEnum extends ChiselEnum {
    val idle        = Value
    // val order_fetch = Value
    val fetch       = Value
    val decode      = Value
    val read        = Value
    val pre         = Value
    val exec        = Value
    //val post        = Value
    val branch      = Value
  }
  val threadStages = RegInit(VecInit(Seq.fill(NUM_THREADS)(ThreadStageEnum.idle)))

  val ThreadStateT = new Bundle {
    val tag         = UInt((TAGWIDTH*2).W)
    // FIXME: input -> rf & rf -> output
    // val input       = new porcIn_t
    // val output      = new porcIn_t
    val seekDone    = Bool()

    val ip          = UInt(IP_WIDTH.W)
    // val instr       = UInt(INSTR_WIDTH.W)
    // val instrReady  = Bool()

    // val imm         = UInt(IMM_WIDTH.W)
    // val srcAId      = UInt(NUM_REGS_LG.W)
    // val srcBId      = UInt(NUM_REGS_LG.W)

    // val aluInstA    = new aluInstBundle(NUM_ALUOPS_LG, VLIW_OPS)
    // val aluInstB    = new aluInstBundle(NUM_ALUOPS_LG, VLIW_OPS)
    // val preOp       = UInt(NUM_PREOPS_LG.W)
    // val fuOps       = Vec(NUM_FUS, UInt(NUM_FUOPS_LG.W))
    val bfuValids   = Vec(NUM_BFUS, Bool())
    // val brMask      = Vec(NUM_FUS + 1, Bool())

    // val srcA        = UInt(REG_WIDTH.W)
    // val srcB        = UInt(REG_WIDTH.W)

    // val preOpBranch = Bool()
    // val preOpA      = UInt(REG_WIDTH.W)
    // val preOpB      = UInt(REG_WIDTH.W)
    // val branchFU    = Bool()
    val brTarget    = UInt(IP_WIDTH.W)

    val execValids  = Vec(NUM_BFUS, Bool())
    val execDone    = Bool()
    val finish      = Bool()
    val order_ready = Bool()
  }
  val threadStates  = Reg(Vec(NUM_THREADS, ThreadStateT))

  val GS_FT          = 0.U
  val GS_BR          = 1.U
  val GS_ALUA        = 2.U
  val GS_ALUB        = 3.U
  val GS_AND         = 4.U
  val GS_OR          = 5.U
  val GS_GT          = 6.U
  val GS_GE          = 7.U
  val GS_EQ          = 8.U
  val GS_NEQ         = 9.U
  val GS_INPUT       = 10.U
  val GS_OUTPUT      = 11.U
  val GS_OUTPUTRET   = 12.U
  val GS_RET         = 13.U
  // val GS_BFU         = 14.U
  val GS_INPUTSEEK   = 14.U

  // val reg_block_width = ArrayBuffer(96, 8, 24, 8, 1, 1, 10, 43, 3, 10, 32, 16, 9, 9)
  val regfile = Module(new RegRead(NUM_THREADS, NUM_RF_RD_PORTS, NUM_RF_WR_PORTS, NUM_REGS, REG_WIDTH, NUM_REGBLOCKS, reg_block_width))

  class ThreadMemT extends Bundle {
    val rdWrEn     = Vec(NUM_FUS, Bool())
    val rd         = Vec(NUM_FUS, UInt(NUM_REGS_LG.W))
  }

  class DestMemT extends Bundle {
    val wben       = UInt(NUM_REGBLOCKS.W)
    val res        = UInt(REG_WIDTH.W)
  }

  val threadMem = Module(new ram_simple2port(NUM_THREADS, (new ThreadMemT).getWidth))
  val destMems = Seq.fill(NUM_FUS)(Module(new ram_simple2port(NUM_THREADS, (new DestMemT).getWidth)))
  threadMem.io.clock := clock
  threadMem.io.rden := false.B
  threadMem.io.rdaddress := DontCare
  for (destMem <- destMems) {
    destMem.io.clock := clock
    destMem.io.wren := false.B
    destMem.io.rden := false.B
    destMem.io.wraddress := DontCare
    destMem.io.rdaddress := DontCare
    destMem.io.data := DontCare
  }

  /****************** Start Thread *********************************/
  // select idle thread
  val init_state = RegInit(0.U(2.W))
  val sThreadEncoder = Module(new RREncode(NUM_THREADS))
  val sThread = sThreadEncoder.io.chosen
  val in_bits_d0 = Reg(new porcIn_t)
  val in_tag_d0 = Reg(UInt((TAGWIDTH*2).W))
  val in_valid_d0 = Reg(Bool())
  val newThread = Reg(Bool())
  val sThread_reg = RegInit(NONE_SELECTED)
  val vThreadEncoder = Module(new Scheduler(NUM_THREADS, NUM_RF_BANKS))
  val inputBufs = Seq.fill(NUM_THREADS)(Module(new input_buf(32)))
  val inputBufReady = Wire(Vec(NUM_THREADS, Bool()))
  Range(0, NUM_THREADS, 1).map(i =>
    sThreadEncoder.io.valid(i) := threadStages(i) === ThreadStageEnum.idle)
  sThreadEncoder.io.ready := sThread =/= NONE_SELECTED

  io.in.ready := false.B
  sThread_reg := sThread
  newThread := io.in.bits.newThread
  in_bits_d0 := io.in.bits
  in_tag_d0 := io.in.tag
  io.out.bits := DontCare
  // vThreadEncoder.io.valid := false.B
  // vThreadEncoder.io.tag := DontCare
  (0 until NUM_THREADS).map(i => inputBufReady(i) := inputBufs(i).io.wready)

  for (inputBuf <- inputBufs) {
    inputBuf.io.wvalid := false.B
    inputBuf.io.wdata := in_bits_d0.word
    inputBuf.io.arvalid := false.B
    inputBuf.io.opcode := 0.U
    inputBuf.io.ardata := DontCare
  }

  when (init_state === 0.U) {
    io.in.ready := false.B
    // threadStages(0) := ThreadStageEnum.order_fetch
    threadStages(0) := ThreadStageEnum.fetch
    threadStates(0).ip := INIT_IP.U(IP_WIDTH.W)
    // vThreadEncoder.io.valid := true.B
    // vThreadEncoder.io.tag := 0.U
    in_valid_d0 := false.B
    sThread_reg := 0.U
    init_state := 1.U
  } .elsewhen (init_state === 1.U) {
    when (threadStages(0) === ThreadStageEnum.idle) {
      init_state := 2.U
    }
  } .otherwise {
    when (inputBufReady(io.in.tag)) {
      when (sThread =/= NONE_SELECTED && io.in.valid && io.in.bits.newThread) {
        // spawn new thread
        io.out.bits.threadID := sThread
        threadStages(sThread) := ThreadStageEnum.fetch
        in_valid_d0 := true.B
        threadStates(sThread).ip := 0.U(IP_WIDTH.W)
        io.in.ready := true.B
        // vThreadEncoder.io.valid := true.B
        // vThreadEncoder.io.tag := sThread
      } .elsewhen (io.in.valid && !io.in.bits.newThread && !io.in.bits.newInst) {
        in_valid_d0 := true.B
        io.in.ready := true.B
        // vThreadEncoder.io.valid := false.B
        // vThreadEncoder.io.tag := DontCare
      } .otherwise {
        in_valid_d0 := false.B
        // vThreadEncoder.io.valid := false.B
        // vThreadEncoder.io.tag := DontCare
      }
    } .otherwise {
      io.in.ready := false.B
      // vThreadEncoder.io.tag := DontCare
    }
  }

  // fill inpput buffer
  for (i <- 0 until NUM_THREADS) {
    inputBufs(i).io.wvalid := false.B
    when (in_valid_d0) {
      when (newThread) {
        when (sThread_reg === i.U) {
          inputBufs(i).io.wvalid := true.B
        }
      } .otherwise {
        when (in_tag_d0 === i.U) {
          inputBufs(i).io.wvalid := true.B
        }
      }
    }
  }


  /****************** Scheduler logic *********************************/
  // select valid thread
  // val vThreadEncoder = Module(new RREncode(NUM_THREADS))
  // val vThreadEncoder = Module(new Scheduler(NUM_THREADS, scala.math.pow(2, log2Up(NUM_ALUS)).toInt))
  val vThread = vThreadEncoder.io.chosen
  Range(0, NUM_THREADS, 1).map(i =>
    vThreadEncoder.io.valid(i) := (threadStages(i) === ThreadStageEnum.fetch))
  // Range(0, NUM_THREADS, 1).map(i =>
  //   vThreadEncoder.io.order_ready(i) := (threadStages(i) === ThreadStageEnum.order_fetch))
  // Range(0, NUM_THREADS, 1).map(i =>
  //   vThreadEncoder.io.ready(i) := (threadStages(i) === ThreadStageEnum.fetch))

  /****************** Fetch logic *********************************/
  val fetchUnit = Module(new Fetch(NUM_THREADS, IP_WIDTH, INSTR_WIDTH))
  val instr = Reg(UInt(INSTR_WIDTH.W))
  fetchUnit.io.cfgIn := io.in.bits.word
  fetchUnit.io.cfgValid := io.in.valid && io.in.bits.newInst
  fetchUnit.io.cfgIp := io.in.bits.newIp
  fetchUnit.io.ip := threadStates(vThread).ip
  instr := fetchUnit.io.instr

  when (vThread =/= NONE_SELECTED) {
      threadStages(vThread) := ThreadStageEnum.decode
  }

  /****************** Decode logic *********************************/
  val decodeThread = RegInit(NONE_SELECTED)
  decodeThread := vThread

  val decodeUnit = Module(new Decode(NUM_ALUS, NUM_BFUS))
  val brMicrocodes_in = Wire(new BRMicrocodes)
  val aluMicrocodes_in = Wire(new ALUMicrocodes(NUM_ALUS))
  val bfuMicrocodes_in = Wire(new BFUMicrocodes(NUM_BFUS))
  val rdWrEn_in = Wire(Vec(NUM_FUS, Bool()))
  val bfuValids_in = Wire(Vec(NUM_BFUS, Bool()))
  decodeUnit.io.instr := instr
  brMicrocodes_in := decodeUnit.io.brUcodes
  when (decodeThread =/= NONE_SELECTED) {
    threadStates(decodeThread).bfuValids := decodeUnit.io.bfuValids
    threadStates(decodeThread).execValids := VecInit(Seq.fill(NUM_BFUS)(false.B))
    threadStates(decodeThread).execValids(0) := true.B
    threadStates(decodeThread).execValids(1) := true.B

    aluMicrocodes_in := decodeUnit.io.aluUcodes
    bfuMicrocodes_in := decodeUnit.io.bfuUcodes
    rdWrEn_in := decodeUnit.io.rdWrEn
    bfuValids_in := decodeUnit.io.bfuValids

    val threadMem_in = Wire(new ThreadMemT)
    threadMem_in.rdWrEn    := decodeUnit.io.rdWrEn
    threadMem_in.rd        := decodeUnit.io.rd
    threadMem.io.wraddress := decodeThread
    threadMem.io.wren      := true.B
    threadMem.io.data      := threadMem_in.asUInt
    regfile.io.thread_rd   := decodeThread
    regfile.io.rdEn        := true.B
    for (i <- 0 until NUM_FUS) {
      regfile.io.rdAddr1(i) := decodeUnit.io.rs1(i)
      regfile.io.rdAddr2(i) := decodeUnit.io.rs2(i)
    }

    threadStages(decodeThread) := ThreadStageEnum.read
  }
  .otherwise {
    val initVec = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))
    val initVecALU = RegInit(VecInit(Seq.fill(NUM_ALUS)(false.B)))
    val initVecBFU = RegInit(VecInit(Seq.fill(NUM_BFUS)(false.B)))
    aluMicrocodes_in.addEn  := initVecALU
    aluMicrocodes_in.sltEn  := initVecALU
    aluMicrocodes_in.sltuEn := initVecALU
    aluMicrocodes_in.andEn  := initVecALU
    aluMicrocodes_in.orEn   := initVecALU
    aluMicrocodes_in.xorEn  := initVecALU
    aluMicrocodes_in.sllEn  := initVecALU
    aluMicrocodes_in.srEn   := initVecALU
    aluMicrocodes_in.srMode := initVecALU
    aluMicrocodes_in.luiEn  := initVecALU
    aluMicrocodes_in.immSel := initVecALU
    aluMicrocodes_in.imm    := DontCare

    bfuMicrocodes_in.rs1Sel    := initVecBFU
    bfuMicrocodes_in.rs2Sel    := initVecBFU
    bfuMicrocodes_in.funct     := initVecBFU
    bfuMicrocodes_in.b0En      := initVecBFU
    bfuMicrocodes_in.b1En      := initVecBFU
    bfuMicrocodes_in.b2En      := initVecBFU
    bfuMicrocodes_in.b3En      := initVecBFU
    bfuMicrocodes_in.bimm      := DontCare

    rdWrEn_in := initVec
    bfuValids_in := initVecBFU

    threadMem.io.wraddress := DontCare
    threadMem.io.wren      := false.B
    threadMem.io.data      := DontCare
    threadStates(decodeThread).bfuValids := DontCare
    threadStates(decodeThread).execValids := DontCare

    regfile.io.thread_rd := DontCare
    regfile.io.rdEn := false.B
    regfile.io.rdAddr1 := DontCare
    regfile.io.rdAddr2 := DontCare
  }

  /************************* Register read  *******************************/
  val REG_DELAY = NUM_FUS + 1
  val ALU_DELAY = 2 // fixed to 2
  val readThread_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(NONE_SELECTED)))
  val brMicrocodes_vec = Reg(Vec(REG_DELAY, new BRMicrocodes))
  val aluMicrocodes_vec = Reg(Vec(REG_DELAY, new ALUMicrocodes(NUM_ALUS)))
  val bfuMicrocodes_vec = Reg(Vec(REG_DELAY+ALU_DELAY, new BFUMicrocodes(NUM_BFUS)))
  val rdWrEn_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(VecInit(Seq.fill(NUM_FUS)(false.B)))))
  val bfuValids_vec = RegInit(VecInit(Seq.fill(REG_DELAY+ALU_DELAY)(VecInit(Seq.fill(NUM_BFUS)(false.B)))))

  readThread_vec(REG_DELAY-1) := decodeThread
  brMicrocodes_vec(REG_DELAY-1) := brMicrocodes_in
  aluMicrocodes_vec(REG_DELAY-1) := aluMicrocodes_in
  bfuMicrocodes_vec(REG_DELAY+ALU_DELAY-1) := bfuMicrocodes_in
  rdWrEn_vec(REG_DELAY-1) := rdWrEn_in
  bfuValids_vec(REG_DELAY+ALU_DELAY-1) := bfuValids_in
  for (i <- 0 until REG_DELAY-1) {
    readThread_vec(i) := readThread_vec(i+1)
    brMicrocodes_vec(i) := brMicrocodes_vec(i+1)
    aluMicrocodes_vec(i) := aluMicrocodes_vec(i+1)
    rdWrEn_vec(i) := rdWrEn_vec(i+1)
  }
  for (i <- 0 until REG_DELAY+ALU_DELAY-1) {
    bfuMicrocodes_vec(i) := bfuMicrocodes_vec(i+1)
    bfuValids_vec(i) := bfuValids_vec(i+1)
  }

  when (readThread_vec(0) =/= NONE_SELECTED) {
    threadStages(readThread_vec(0)) := ThreadStageEnum.pre
  }

  val srcA = Wire(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  val srcB = Wire(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  srcA := regfile.io.rdData1
  srcB := regfile.io.rdData2

  /****************** Pre logic Stage 0 *************************/
  // BFU(0) is always INPUT/OUTPUT unit
  // BFU(1) is always SCATTER/GATHER unit
  val preOpThread = RegInit(NONE_SELECTED)
  val inputBufOut = Wire(Vec(NUM_THREADS, UInt(128.W)))
  val brMicrocodes_out = Reg(new BRMicrocodes)
  val aluMicrocodes_out = Reg(new ALUMicrocodes(NUM_ALUS))
  val rdWrEn_out = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))
  preOpThread := readThread_vec(0)
  brMicrocodes_out := brMicrocodes_vec(0)
  aluMicrocodes_out := aluMicrocodes_vec(0)
  rdWrEn_out := rdWrEn_vec(0)

  val branchU = Module(new BranchUnit)
  val alus = Seq.fill(NUM_ALUS)(Module(new ALU))

  branchU.io.rs1 := srcA(NUM_ALUS+NUM_BFUS)(31, 0).asSInt
  branchU.io.rs2 := srcB(NUM_ALUS+NUM_BFUS)(31, 0).asSInt
  branchU.io.pc := threadStates(preOpThread).ip.asSInt
  branchU.io.brValid := brMicrocodes_out.brValid
  branchU.io.brMode := brMicrocodes_out.brMode
  branchU.io.pcOffset := brMicrocodes_out.pcOffset

  for (i <- 0 until NUM_ALUS) {
    alus(i).io.rs1 := srcA(i)(31, 0)
    alus(i).io.rs2 := srcB(i)(31, 0)
    alus(i).io.addEn  := aluMicrocodes_out.addEn(i)
    alus(i).io.sltEn  := aluMicrocodes_out.sltEn(i)
    alus(i).io.sltuEn := aluMicrocodes_out.sltuEn(i)
    alus(i).io.andEn  := aluMicrocodes_out.andEn(i)
    alus(i).io.orEn   := aluMicrocodes_out.orEn(i)
    alus(i).io.xorEn  := aluMicrocodes_out.xorEn(i)
    alus(i).io.sllEn  := aluMicrocodes_out.sllEn(i)
    alus(i).io.srEn   := aluMicrocodes_out.srEn(i)
    alus(i).io.srMode := aluMicrocodes_out.srMode(i)
    alus(i).io.luiEn  := aluMicrocodes_out.luiEn(i)
    alus(i).io.immSel := aluMicrocodes_out.immSel(i)
    alus(i).io.imm    := aluMicrocodes_out.imm(i)
  }

  io.out.tag := DontCare
  io.out.valid := false.B

  //Read inputBuf or seek
  (0 until NUM_THREADS).map(i => inputBufOut(i) := inputBufs(i).io.rdata)

  for (i <- 0 until NUM_THREADS) {
    when (readThread_vec(1) === i.U) {
      threadStates(i).seekDone := true.B
    } .elsewhen (readThread_vec(0) === i.U) {
      when (bfuMicrocodes_vec(ALU_DELAY).b0En(0) && bfuMicrocodes_vec(ALU_DELAY).funct(0)) {
        threadStates(i).seekDone := false.B
      }
    } .elsewhen (inputBufs(i).io.rvalid) {
      threadStates(i).seekDone := true.B
    }
  }

  for (i <- 0 until NUM_THREADS) {
    when (readThread_vec(0) === i.U) {
      when (bfuMicrocodes_vec(ALU_DELAY).b0En(0) && (!bfuMicrocodes_vec(ALU_DELAY).funct(0))) {
        inputBufs(i).io.arvalid := true.B
        inputBufs(i).io.opcode := 0.U
      }
    } .elsewhen (preOpThread === i.U) {
      when (bfuMicrocodes_vec(ALU_DELAY-1).b0En(0) && bfuMicrocodes_vec(ALU_DELAY-1).funct(0)) {
        inputBufs(i).io.arvalid := true.B
        inputBufs(i).io.ardata := srcA(NUM_ALUS)(3, 0) + bfuMicrocodes_vec(ALU_DELAY-1).bimm(0)(3, 0)
        inputBufs(i).io.opcode := 1.U
      }
    }
  }

  // Output Unit
  when (preOpThread =/= NONE_SELECTED) {
    when (bfuMicrocodes_vec(ALU_DELAY-1).b0En(0) && bfuMicrocodes_vec(ALU_DELAY-1).rs1Sel(0)) {
      io.out.tag := preOpThread
      // io.out.bits := threadStates(preOpThread).input
      io.out.bits.data := srcA(NUM_ALUS).asTypeOf(chiselTypeOf(io.out.bits.data))
      // io.out.bits.l3.h1 := preOpB
      io.out.valid := true.B
    }
  }

  // Gather/Scatter Unit
  val gatherU = Module(new Gather(IMM_WIDTH, REG_WIDTH, NUM_SRC_POS, src_pos, MAX_FIELD_WIDTH, NUM_SRC_MODES, src_mode))
  gatherU.io.din := srcA(NUM_ALUS+1)
  gatherU.io.shift := bfuMicrocodes_vec(ALU_DELAY-1).bimm(1)(log2Up(NUM_SRC_POS)-1, 0)
  gatherU.io.mode := bfuMicrocodes_vec(ALU_DELAY-1).bimm(1)(log2Up(NUM_SRC_POS)+log2Up(NUM_SRC_MODES)-1, log2Up(NUM_SRC_POS))
  gatherU.io.imm := 0.U
  val scatterU = Module(new Scatter(REG_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_REGBLOCKS, NUM_DST_POS, dst_encode, dst_pos, NUM_DST_MODE, dst_en_encode, wbens))
  scatterU.io.din := srcA(NUM_ALUS+1)
  scatterU.io.shift := bfuMicrocodes_vec(ALU_DELAY-1).bimm(1)(log2Up(NUM_SRC_POS)-1, 0)
  scatterU.io.mode := bfuMicrocodes_vec(ALU_DELAY-1).bimm(1)(log2Up(NUM_SRC_POS)+log2Up(NUM_SRC_MODES)-1, log2Up(NUM_SRC_POS))

  /****************** Pre logic Stage 1 *************************/
  val preOpThread_s1 = RegInit(NONE_SELECTED)
  preOpThread_s1 := preOpThread
  // Branch Unit output
  val brPcOut  = RegInit(0.S(32.W))
  val brDout   = RegInit(0.S(32.W))
  val brFinish = RegInit(false.B)
  val rdWrEn_s1 = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))
  val srcA_d1 = Reg(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  brPcOut := branchU.io.pcOut
  brDout := branchU.io.dout
  brFinish := branchU.io.finish
  rdWrEn_s1 := rdWrEn_out
  srcA_d1 := srcA

  when (preOpThread_s1 =/= NONE_SELECTED) {
    threadStates(preOpThread_s1).finish := brFinish
    threadStates(preOpThread_s1).ip := brPcOut.asUInt
    val destMem_in = Wire(new DestMemT)
    destMem_in.res := brDout.asUInt
    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    destMems(NUM_FUS-1).io.wren := rdWrEn_s1(NUM_FUS-1)
    destMems(NUM_FUS-1).io.wraddress := preOpThread_s1
    destMems(NUM_FUS-1).io.data := destMem_in.asUInt
  }

  // Input/Output Unit
  // BFU(0) is always INPUT/OUTPUT unit
  val input_u = Reg(UInt(REG_WIDTH.W))
  input_u := inputBufOut(preOpThread)
  when (preOpThread_s1 =/= NONE_SELECTED) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.res := input_u
    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    destMems(NUM_ALUS).io.wren := rdWrEn_s1(NUM_ALUS)
    destMems(NUM_ALUS).io.wraddress := preOpThread_s1
    destMems(NUM_ALUS).io.data := destMem_in.asUInt
  }

  /****************** Pre logic Stage 2 *************************/
  val preOpThread_s2 = RegInit(NONE_SELECTED)
  preOpThread_s2 := preOpThread_s1
  // ALU output
  val preOpRes = Reg(Vec(NUM_ALUS, UInt(32.W)))
  val rdWrEn_s2 = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))
  val bfuValids_out = RegInit(VecInit(Seq.fill(NUM_BFUS)(false.B)))
  val bfuMicrocodes_out = Reg(new BFUMicrocodes(NUM_BFUS))
  val bfuDin = Reg(Vec(NUM_BFUS, UInt(REG_WIDTH.W)))
  for (i <- 0 until NUM_ALUS) {
    preOpRes(i) := alus(i).io.dout
  }
  rdWrEn_s2 := rdWrEn_s1
  bfuValids_out := bfuValids_vec(0)
  bfuMicrocodes_out := bfuMicrocodes_vec(0)

  when (preOpThread_s2 =/= NONE_SELECTED) {
    for (i <- 0 until NUM_ALUS) {
      val destMem_in = Wire(new DestMemT)
      destMem_in.res := preOpRes(i)
      destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
      destMems(i).io.wren := rdWrEn_s2(i)
      destMems(i).io.wraddress := preOpThread_s2
      destMems(i).io.data := destMem_in.asUInt
    }
  }

  // Gather/Scatter Unit
  // BFU(1) is always SCATTER/GATHER unit
  val scatterOut = Reg(UInt(REG_WIDTH.W))
  val scatterWben = RegInit(0.U(NUM_REGBLOCKS.W))
  scatterOut := scatterU.io.dout
  scatterWben := scatterU.io.wren
  when (preOpThread_s2 =/= NONE_SELECTED) {
    val destMem_in = Wire(new DestMemT)
    when (bfuMicrocodes_out.funct(1)) {
      destMem_in.res := scatterOut
      destMem_in.wben := scatterWben
    } .otherwise {
      destMem_in.res := gatherU.io.dout
      destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    }
    destMems(NUM_ALUS+1).io.wren := rdWrEn_s2(NUM_ALUS+1)
    destMems(NUM_ALUS+1).io.wraddress := preOpThread_s2
    destMems(NUM_ALUS+1).io.data := destMem_in.asUInt
  }

  // Other BFUs
  val execBundle0 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new mspmIn_t)
  }
  val execBundle1 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new asciiIn_t)
  }

  val fuFifos_0 = Module(new Queue(execBundle0, NUM_THREADS - 1))
  val fuFifos_1 = Module(new Queue(execBundle1, NUM_THREADS - 1))

  fuFifos_0.io.enq.valid := false.B
  fuFifos_0.io.enq.bits := DontCare
  fuFifos_1.io.enq.valid := false.B
  fuFifos_1.io.enq.bits := DontCare

  for (i <- 0 until NUM_BFUS) {
    // when (bfuMicrocodes_vec(0).rs1Sel(i)) {
    //   bfuDin(i) := alus(0).io.dout
    // } .elsewhen (bfuMicrocodes_vec(0).rs2Sel(i)) {
    //   bfuDin(i) := alus(1).io.dout
    // } .otherwise {
      bfuDin(i) := srcA_d1(i+NUM_ALUS)
    // }
  }

  when (preOpThread_s2 =/= NONE_SELECTED) {
    when (bfuValids_out(2) === true.B) {
      fuFifos_0.io.enq.bits.tag := preOpThread_s2
      fuFifos_0.io.enq.bits.bits.opcode := Cat(0.U, bfuMicrocodes_out.rs2Sel(2), bfuMicrocodes_out.rs1Sel(2), bfuMicrocodes_out.funct(2))
      fuFifos_0.io.enq.bits.bits.word.string := bfuDin(2)
      fuFifos_0.io.enq.bits.bits.word.length := bfuMicrocodes_out.bimm(2)(4, 0)
      fuFifos_0.io.enq.bits.bits.word.idx := bfuMicrocodes_out.bimm(2)(8, 5)
      fuFifos_0.io.enq.valid := true.B
    }

    when (bfuValids_out(3) === true.B) {
      fuFifos_1.io.enq.bits.tag := preOpThread_s2
      fuFifos_1.io.enq.bits.bits.opcode := Cat(0.U, bfuMicrocodes_out.rs2Sel(3), bfuMicrocodes_out.rs1Sel(3), bfuMicrocodes_out.funct(3))
      fuFifos_1.io.enq.bits.bits.string := bfuDin(3)
      fuFifos_1.io.enq.valid := true.B
    }

    threadStages(preOpThread_s2) := ThreadStageEnum.exec
  }

  /****************** Function unit execution *********************************/
  val execThread = RegInit(NONE_SELECTED)
  val execThread_d0 = RegInit(NONE_SELECTED)
  execThread := preOpThread_s2
  execThread_d0 := execThread
  val fuReqReadys = new Array[Bool](NUM_BFUS-2)
  fuReqReadys(0) = mspmPort.req.ready
  fuReqReadys(1) = asciiPort.req.ready

  // FUs input
  when (fuFifos_0.io.count > 0.U && fuReqReadys(0) === true.B) {
    val deq = fuFifos_0.io.deq
    mspmPort.req.valid := true.B
    mspmPort.req.tag := deq.bits.tag
    mspmPort.req.bits := deq.bits.bits
    fuFifos_0.io.deq.ready := true.B
  }
  .otherwise {
    mspmPort.req.valid := false.B
    mspmPort.req.tag := 0.U(NUM_THREADS_LG.W)
    mspmPort.req.bits := DontCare
    fuFifos_0.io.deq.ready := false.B
  }

  when (fuFifos_1.io.count > 0.U && fuReqReadys(1) === true.B) {
    val deq = fuFifos_1.io.deq
    asciiPort.req.valid := true.B
    asciiPort.req.tag := deq.bits.tag
    asciiPort.req.bits := deq.bits.bits
    fuFifos_1.io.deq.ready := true.B
  }
  .otherwise {
    asciiPort.req.valid := false.B
    asciiPort.req.tag := 0.U(NUM_THREADS_LG.W)
    asciiPort.req.bits := DontCare
    fuFifos_1.io.deq.ready := false.B
  }

  // FUs output
  mspmPort.rep.ready := true.B
  when (mspmPort.rep.valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.res := mspmPort.rep.bits.asUInt
    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    destMems(NUM_ALUS+2).io.wren := true.B
    destMems(NUM_ALUS+2).io.wraddress := mspmPort.rep.tag
    destMems(NUM_ALUS+2).io.data := destMem_in.asUInt
    threadStates(mspmPort.rep.tag).execValids(2) := true.B
  }

  asciiPort.rep.ready := true.B
  when (asciiPort.rep.valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.res := asciiPort.rep.bits.asUInt
    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    destMems(NUM_ALUS+3).io.wren := true.B
    destMems(NUM_ALUS+3).io.wraddress := asciiPort.rep.tag
    destMems(NUM_ALUS+3).io.data := destMem_in.asUInt
    threadStates(asciiPort.rep.tag).execValids(3) := true.B
  }

  // finish execution
  // FIXME: this does not need to take a cycle
  Range(0, NUM_THREADS, 1).foreach(i =>
    // threadStates(i).execDone := (threadStates(i).execValids zip threadStates(i).fuValids).map(x => x._1 || x._2).forall(_ === true.B)
    threadStates(i).execDone := (threadStates(i).execValids.asUInt | (~threadStates(i).bfuValids.asUInt)).andR & threadStates(i).seekDone
  )

  val fThreadEncoder = Module(new Scheduler(NUM_THREADS, NUM_WR_BANKS))
  val fThread = fThreadEncoder.io.chosen
  Range(0, NUM_THREADS, 1).map(i =>
    fThreadEncoder.io.valid(i) := (threadStates(i).execDone === true.B && threadStages(i) === ThreadStageEnum.exec))
  // fThreadEncoder.io.ready := fThread =/= NONE_SELECTED

  when (fThread =/= NONE_SELECTED) {
    threadStages(fThread) := ThreadStageEnum.branch
    for (destMem <- destMems) {
      destMem.io.rden := true.B
      destMem.io.rdaddress := fThread
    }
    threadMem.io.rden := true.B
    threadMem.io.rdaddress := fThread
  }

  /****************** Register write & branch *********************************/
  val WB_DELAY = (NUM_FUS+1)/2
  val branchThread_out = RegInit(NONE_SELECTED)
  val branchThread_vec = RegInit(VecInit(Seq.fill(WB_DELAY)(NONE_SELECTED)))
  branchThread_out := branchThread_vec(0)

  branchThread_vec(WB_DELAY-1) := fThread
  for (i <- 0 until WB_DELAY-1) {
    branchThread_vec(i) := branchThread_vec(i+1)
  }

  val threadMem_out = Wire(new ThreadMemT)
  val destMems_out = Wire(Vec(NUM_FUS, (new DestMemT)))
  val destWbens_wb = Wire(Vec(NUM_FUS, UInt((REG_WIDTH/8).W)))
  val dests_wb = Wire(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  val dest_rdWrEn = Wire(Vec(NUM_FUS, Bool()))
  val dest_rd = Wire(Vec(NUM_FUS, UInt(NUM_REGS_LG.W)))

  for (i <- 0 until NUM_FUS) {
    destMems_out(i) := destMems(i).io.q.asTypeOf(new DestMemT)
    dests_wb(i) := destMems_out(i).res
    destWbens_wb(i) := destMems_out(i).wben
  }

  threadMem_out := threadMem.io.q.asTypeOf(chiselTypeOf(threadMem_out))
  dest_rdWrEn := threadMem_out.rdWrEn
  dest_rd := threadMem_out.rd

  when (branchThread_vec(WB_DELAY-2) =/= NONE_SELECTED) {
    // writeback
    regfile.io.wrEn := true.B
  } .otherwise {
    regfile.io.wrEn := false.B
  }
  regfile.io.thread_wr := branchThread_vec(WB_DELAY-2)
  for (i <- 0 until NUM_RF_WR_PORTS) {
    regfile.io.wrEn1(i) := dest_rdWrEn(i*2)
    regfile.io.wrAddr1(i) := dest_rd(i*2)
    regfile.io.wrBen1(i) := destWbens_wb(i*2)
    regfile.io.wrData1(i) := dests_wb(i*2)
    if (i*2+1 < NUM_FUS) {
      regfile.io.wrEn2(i) := dest_rdWrEn(i*2+1)
      regfile.io.wrAddr2(i) := dest_rd(i*2+1)
      regfile.io.wrBen2(i) := destWbens_wb(i*2+1)
      regfile.io.wrData2(i) := dests_wb(i*2+1)
    } else {
      regfile.io.wrEn2(i) := false.B
      regfile.io.wrAddr2(i) := DontCare
      regfile.io.wrBen2(i) := DontCare
      regfile.io.wrData2(i) := DontCare
    }
  }

  when (branchThread_vec(0) =/= NONE_SELECTED) {
    // branch
    when (threadStates(branchThread_vec(0)).finish) {
      threadStages(branchThread_vec(0)) := ThreadStageEnum.idle
    }
    .otherwise {
      threadStages(branchThread_vec(0)) := ThreadStageEnum.fetch
    }
  }

}
