import chisel3._
import chisel3.util._
import chisel3.util.Fill
import chisel3.util.PriorityEncoder
import chisel3.experimental.ChiselEnum
import chisel3.util.experimental.loadMemoryFromFileInline

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class Gather(imm_width: Int, reg_width: Int, num_blocks: Int, block_widths: ArrayBuffer[Int],
   max_out_width: Int, num_modes:Int, mode_bits: ArrayBuffer[Int]) extends Module {
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
  block_widths ++= List(0, 0, 0, 0, 0, 0, 0)
  for (i <- 0 until num_muxes) {
    switch(io.shift(2, 0)) {
      is (0.U) {
        reg0(i) := io.din((block_widths(i*8)+max_out_width-1).min(reg_width-1), block_widths(i*8))
      }
      is (1.U) {
        reg0(i) := io.din((block_widths(i*8+1)+max_out_width-1).min(reg_width-1), block_widths(i*8+1))
      }
      is (2.U) {
        reg0(i) := io.din((block_widths(i*8+2)+max_out_width-1).min(reg_width-1), block_widths(i*8+2))
      }
      is (3.U) {
        reg0(i) := io.din((block_widths(i*8+3)+max_out_width-1).min(reg_width-1), block_widths(i*8+3))
      }
      is (4.U) {
        reg0(i) := io.din((block_widths(i*8+4)+max_out_width-1).min(reg_width-1), block_widths(i*8+4))
      }
      is (5.U) {
        reg0(i) := io.din((block_widths(i*8+5)+max_out_width-1).min(reg_width-1), block_widths(i*8+5))
      }
      is (6.U) {
        reg0(i) := io.din((block_widths(i*8+6)+max_out_width-1).min(reg_width-1), block_widths(i*8+6))
      }
      is (7.U) {
        reg0(i) := io.din((block_widths(i*8+7)+max_out_width-1).min(reg_width-1), block_widths(i*8+7))
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

  val cases2 = (0 until num_modes).map( x => x.U -> reg1(mode_bits(x)-1, 0))
  reg2 := MuxLookup(mode_d1, DontCare, cases2)
  when (mode_d2 === num_modes.U) {
    io.dout := Cat(0.U, imm_d2)
  } .otherwise {
    io.dout := Cat(din_d2(reg_width-1, max_out_width), reg2)
  }
  io.sign_out := 0.U
}

class Scatter(reg_width: Int, lg_num_rdBlocks: Int, lg_num_modes: Int, num_wrBlocks: Int,
  num_wr_offset: Int, wr_encode: ArrayBuffer[Int], wr_offset: ArrayBuffer[Int],
  num_wbens: Int, wben_encode: ArrayBuffer[(Int, Int)], wbens: ArrayBuffer[Int]) extends Module {
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

  val cases = (0 until num_wr_offset).map(i => (io.shift === wr_encode(i).U) -> (din_w << wr_offset(i)))
  dout_r := MuxCase(DontCare, cases)
  val cases2 = (0 until num_wbens).map(i => ((io.shift === wben_encode(i)._1.U) && ((wben_encode(i)._2 == -1).B || (io.mode === wben_encode(i)._2.S.asUInt))) -> wbens(i).U)
  wben_r := MuxCase(0.U, cases2)

  io.dout := dout_r
  io.wren := wben_r
}

class ALU(num_aluops_lg: Int, reg_width: Int) extends Module {
  val io = IO(new Bundle {
    val signA = Input(UInt(1.W))
    val srcA = Input(UInt(reg_width.W))
    val signB = Input(UInt(1.W))
    val srcB = Input(UInt(reg_width.W))
    val aluOp = Input(UInt(num_aluops_lg.W))
    val dout = Output(UInt(reg_width.W))
  })
  val opA = Wire(SInt(33.W))
  val opB = Wire(SInt(33.W))
  val res = Wire(UInt(32.W))
  opA := Cat(io.signA, io.srcA(31, 0)).asSInt
  opB := Cat(io.signB, io.srcB(31, 0)).asSInt
  io.dout := 0.U
  res := 0.U
  switch (io.aluOp) {
    is (0.U) {
      // fall through srcA
      io.dout := io.srcA
    }
    is (1.U) {
      // fall through srcB
      io.dout := io.srcB
    }
    is (2.U) {
      // add
      res := (opA + opB).asUInt
      io.dout := Cat(0.U, res)
    }
    is (3.U) {
      // subtract
      res := (opA - opB).asUInt
      io.dout := Cat(0.U, res)
    }
    is (4.U) {
      // equal
      when (opA === opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (5.U) {
      // not equal
      when (opA =/= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (6.U) {
      // less than
      when (opA < opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (7.U) {
      // less than or equal
      when (opA <= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (8.U) {
      // greater than
      when (opA > opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (9.U) {
      // greater than or equal
      when (opA >= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (10.U) {
      // and
      io.dout := (opA & opB).asUInt
    }
    is (11.U) {
      // or
      io.dout := (opA | opB).asUInt
    }
    is (12.U) {
      // concatenate
      io.dout := Cat(0.U(252.W), io.srcB(8, 0), io.srcA(8, 0))
    }
  }
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

  addResource("/ram_qp_sim.v")

}

class Regfile(num: Int, width: Int, num_blocks: Int, block_widths: ArrayBuffer[Int]) extends Module {
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

class RegRead(threadnum: Int, num_rd: Int, num_wr: Int, num_regs: Int, reg_w: Int, num_blocks: Int, block_widths: ArrayBuffer[Int]) extends Module {
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
    val rdData1 = Wire(Vec(num_rd, UInt(reg_w.W)))
    val rdData2 = Wire(Vec(num_rd, UInt(reg_w.W)))
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

class Fetch(num: Int, ipWidth: Int, instrWidth: Int) extends Module {
  val io = IO(new Bundle {
    val ip         = Input(UInt(ipWidth.W))
    val instr      = Output(UInt(instrWidth.W))
  })

  // FIXME: implement i$

  // var mem_array = Array.fill[UInt](1 << ipWidth)(0.U(instrWidth.W))
  var mem = VecInit(
    "h00000000000a3014008741ba00000e8374000008".U,
    "h000000b060105020000b41ba00080e837400100c".U,
    "h0000000000000000000341ba00080e837400100a".U,
    "h0040100000300000000281cc08085503981010a5".U,
    "h0000000000011021004341ba00080d0a69030020".U,
    "h0000000000000000241b41ba00100e837400200a".U,
    "h0000000000000000341b41ba00100e837400200a".U,
    "h000000000008f431406280da60100d0269030020".U,
    "h000000000fc00000000341ba001a0d02a8603452".U,
    "h0000000000115004008341ba0019868374003009".U,
    "h000010000fdb322500c18cdb80190bab9c0a3232".U,
    "h000000000f800000000341ba00080e8374001001".U,
    "h00000000002000000002815400100d02a8432082".U,
    "h0000100001211001004341ba0008094778001001".U,
    "h000000000008f641006341ba00100381f5402010".U,
    "h00000000002af53440a181ac0c0106839c0a0252".U,
    "h0000000000cb322500c1b1ac0002031b58000401".U,
    "h0000000000600000000281348199950368033007".U,
    "h000000000000d030402181ac0301068374000200".U,
    "h00000000002000000002815a30180d0269030026".U,
    "h0000000000811021806340cc002a631b58005401".U,
    "h000000000f8000000002815a30018d0269033326".U,
    "h000010000028f671406340db801b0b839c003632".U,
    "h0000000000511021806340cc0022e36374004511".U,
    "h00000000003000000002815a30380d0269030026".U,
    "h0000000000000000802340cd801a668374003400".U,
    "h0000000000200000802340cc0022e68374004501".U,
    "h000000000fab335500c341ba00398b6358187301".U,
    "h0000100000011021004341ba000103ab9c0a0220".U,
    "h0000000000000000241b41ba000106837400020b".U,
    "h0000000000100000000341ba00000e837400000a".U,
    "h0000000000100000040b41ba00000e837400000a".U,
    "h004010000ff00000000281cc08005503981000a5".U,
    "h00102000002150140082a9d401801503981000a2".U,
    "h00000000000b311500c2a934818015af6c130000".U,
    "h0000000000000000141b41ba00080e837400100a".U,
  )


  // val mem = RegInit(VecInit(mem_array.toSeq))
  //val mem = SyncReadMem(1 << ipWidth, UInt(instrWidth.W))
  //loadMemoryFromFileInline(mem, "../assembler/npu.bin")

  io.instr := mem(io.ip)
}

class aluInstBundle(num_aluops_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_regs_lg: Int) extends Bundle {
  val dstMode = UInt(num_src_modes_lg.W)
  val dstShiftL = UInt(num_src_pos_lg.W)
  val srcMode = Vec(2, UInt(num_src_modes_lg.W))
  val srcShiftR = Vec(2, UInt(num_src_pos_lg.W))
  val srcId = Vec(2, UInt(num_regs_lg.W))
  val aluOp = UInt(num_aluops_lg.W)
  override def cloneType = (new aluInstBundle(num_aluops_lg, num_src_pos_lg, num_src_modes_lg, num_regs_lg)).asInstanceOf[this.type]
}

class Decode(instrWidth: Int, num_regs_lg: Int, num_aluops_lg: Int, num_src_pos_lg: Int, num_src_modes_lg: Int, num_alus: Int, num_dst: Int,
  num_fus: Int, num_fuops_lg: Int, num_preops_lg: Int, num_bts: Int, ip_width: Int, imm_width: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(instrWidth.W))

    val imm       = Output(Vec(num_alus, UInt(imm_width.W)))
    val destAEn   = Output(Vec(num_dst, Bool()))
    val destBEn   = Output(Vec(num_dst, Bool()))
    val destAId   = Output(Vec(num_dst, UInt(num_regs_lg.W)))
    val destBId   = Output(Vec(num_dst, UInt(num_regs_lg.W)))
    val destALane = Output(Vec(num_dst, UInt(log2Up(num_fus).W)))
    val destBLane = Output(Vec(num_dst, UInt(log2Up(num_fus).W)))
    val preOp     = Output(UInt(num_preops_lg.W))
    val fuOps     = Output(Vec(num_fus, UInt(num_fuops_lg.W)))
    val fuValids  = Output(Vec(num_fus, Bool()))
    val brTarget  = Output(Vec(num_bts, UInt(ip_width.W)))
    val aluInsts  = Output(Vec(num_alus, new aluInstBundle(num_aluops_lg, num_src_pos_lg, num_src_modes_lg, num_regs_lg)))
  })

  val PREOP_LOW = 0
  val PREOP_HIGH = PREOP_LOW + num_preops_lg - 1
  val ALUINST_LOW = PREOP_HIGH + 1
  val ALUINST_HIGH = ALUINST_LOW + num_alus * (num_aluops_lg + 3 * (num_src_pos_lg + num_src_modes_lg) + 2 * num_regs_lg) - 1
  val FUVALIDS_LOW = ALUINST_HIGH + 1
  val FUVALIDS_HIGH = FUVALIDS_LOW + num_fus - 1
  val FUOPS_LOW = FUVALIDS_HIGH + 1
  val FUOPS_HIGH = FUOPS_LOW + num_fus * num_fuops_lg - 1
  val DESTAID_LOW = FUOPS_HIGH + 1
  val DESTAID_HIGH = DESTAID_LOW + num_dst * num_regs_lg - 1
  val DESTBID_LOW = DESTAID_HIGH + 1
  val DESTBID_HIGH = DESTBID_LOW + num_dst * num_regs_lg - 1
  val DESTAEN_LOW = DESTBID_HIGH + 1
  val DESTAEN_HIGH = DESTAEN_LOW + num_dst - 1
  val DESTBEN_LOW = DESTAEN_HIGH + 1
  val DESTBEN_HIGH = DESTBEN_LOW + num_dst - 1
  val DESTALANE_LOW = DESTBEN_HIGH + 1
  val DESTALANE_HIGH = DESTALANE_LOW + num_dst * log2Up(num_fus) - 1
  val DESTBLANE_LOW = DESTALANE_HIGH + 1
  val DESTBLANE_HIGH = DESTBLANE_LOW + num_dst * log2Up(num_fus) - 1
  val BRTARGET_LOW = DESTBLANE_HIGH + 1
  val BRTARGET_HIGH = BRTARGET_LOW + ip_width * num_bts - 1
  val IMM_LOW = BRTARGET_HIGH + 1
  val IMM_HIGH = IMM_LOW + num_alus * imm_width - 1

  io.imm       := io.instr(IMM_HIGH, IMM_LOW).asTypeOf(chiselTypeOf(io.imm))
  io.brTarget  := io.instr(BRTARGET_HIGH, BRTARGET_LOW).asTypeOf(chiselTypeOf(io.brTarget))
  io.destBLane := io.instr(DESTBLANE_HIGH, DESTBLANE_LOW).asTypeOf(chiselTypeOf(io.destBLane))
  io.destALane := io.instr(DESTALANE_HIGH, DESTALANE_LOW).asTypeOf(chiselTypeOf(io.destALane))
  io.destBEn   := io.instr(DESTBEN_HIGH, DESTBEN_LOW).asBools
  io.destAEn   := io.instr(DESTAEN_HIGH, DESTAEN_LOW).asBools
  io.destBId   := io.instr(DESTBID_HIGH, DESTBID_LOW).asTypeOf(chiselTypeOf(io.destBId))
  io.destAId   := io.instr(DESTAID_HIGH, DESTAID_LOW).asTypeOf(chiselTypeOf(io.destAId))
  io.fuOps     := io.instr(FUOPS_HIGH, FUOPS_LOW).asTypeOf(chiselTypeOf(io.fuOps))
  io.fuValids  := io.instr(FUVALIDS_HIGH, FUVALIDS_LOW).asBools
  io.aluInsts  := io.instr(ALUINST_HIGH, ALUINST_LOW).asTypeOf(chiselTypeOf(io.aluInsts))
  io.preOp     := io.instr(PREOP_HIGH, PREOP_LOW)
}


class flowTableV extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    // ch0 read channel
    val ch0_meta_tuple_sIP    = Input(UInt(32.W))
    val ch0_meta_tuple_dIP    = Input(UInt(32.W))
    val ch0_meta_tuple_sPort  = Input(UInt(16.W))
    val ch0_meta_tuple_dPort  = Input(UInt(16.W))
    val ch0_meta_addr0        = Input(UInt(12.W))
    val ch0_meta_addr1        = Input(UInt(12.W))
    val ch0_meta_addr2        = Input(UInt(12.W))
    val ch0_meta_addr3        = Input(UInt(12.W))
    val ch0_meta_opcode       = Input(UInt(3.W))
    val ch0_rden              = Input(Bool())
    val ch0_q_valid           = Output(Bool())
    val ch0_q_tuple_sIP       = Output(UInt(32.W))
    val ch0_q_tuple_dIP       = Output(UInt(32.W))
    val ch0_q_tuple_sPort     = Output(UInt(16.W))
    val ch0_q_tuple_dPort     = Output(UInt(16.W))
    val ch0_q_seq             = Output(UInt(32.W))
    val ch0_q_pointer         = Output(UInt(9.W))
    val ch0_q_ll_valid        = Output(Bool())
    val ch0_q_slow_cnt        = Output(UInt(10.W))
    val ch0_q_last_7_bytes    = Output(UInt(56.W))
    val ch0_q_addr0           = Output(UInt(12.W))
    val ch0_q_addr1           = Output(UInt(12.W))
    val ch0_q_addr2           = Output(UInt(12.W))
    val ch0_q_addr3           = Output(UInt(12.W))
    val ch0_q_pointer2        = Output(UInt(9.W))
    val ch0_rd_valid          = Output(Bool())
    val ch0_bit_map           = Output(UInt(5.W))
    val ch0_rd_stall          = Output(Bool())

    // ch1 write channel
    val ch1_opcode            = Input(UInt(3.W))
    val ch1_bit_map           = Input(UInt(5.W))
    val ch1_wren              = Input(Bool())
    val ch1_data_valid        = Input(Bool())
    val ch1_data_tuple_sIP    = Input(UInt(32.W))
    val ch1_data_tuple_dIP    = Input(UInt(32.W))
    val ch1_data_tuple_sPort  = Input(UInt(16.W))
    val ch1_data_tuple_dPort  = Input(UInt(16.W))
    val ch1_data_seq          = Input(UInt(32.W))
    val ch1_data_pointer      = Input(UInt(9.W))
    val ch1_data_ll_valid     = Input(Bool())
    val ch1_data_slow_cnt     = Input(UInt(10.W))
    val ch1_data_last_7_bytes = Input(UInt(56.W))
    val ch1_data_addr0        = Input(UInt(12.W))
    val ch1_data_addr1        = Input(UInt(12.W))
    val ch1_data_addr2        = Input(UInt(12.W))
    val ch1_data_addr3        = Input(UInt(12.W))
    val ch1_data_pointer2     = Input(UInt(9.W))
    val ch1_insert_stall      = Output(Bool())

    val rst                   = Input(Reset())
    val clk                   = Input(Clock())
  })

  addResource("/bram_true2port_sim.v")
  addResource("/flow_table_wrap.sv")

}

class fse_meta_t extends Bundle {
  val addr3 = UInt(12.W)
  val addr2 = UInt(12.W)
  val addr1 = UInt(12.W)
  val addr0 = UInt(12.W)
  val pkt = new metadata_t
}

class fse_t extends Bundle {
  val meta = new fse_meta_t
  val waiting = Bool()
  val running = Bool()
}

class flowTable(tag_width: Int, num_threads: Int) extends Module {
  val io = IO(new Bundle {
    val ch0_req_valid  = Input(Bool())
    val ch0_req_tag    = Input(UInt(tag_width.W))
    val ch0_req_data   = Input(new ftCh0Input_t)
    val ch0_req_ready  = Output(Bool())

    val ch0_rep_valid  = Output(Bool())
    val ch0_rep_tag    = Output(UInt(tag_width.W))
    val ch0_rep_data   = Output(new ftCh0Output_t)
    val ch0_rep_ready  = Input(Bool())

    val ch1_req_valid  = Input(Bool())
    val ch1_req_tag    = Input(UInt(tag_width.W))
    val ch1_req_data   = Input(new ftCh1Input_t)
    val ch1_req_ready  = Output(Bool())

    val ch1_rep_valid  = Output(Bool())
    val ch1_rep_tag    = Output(UInt(tag_width.W))
    val ch1_rep_data   = Output(UInt(8.W))
    val ch1_rep_ready  = Input(Bool())
  })

  val ft_inst = Module(new flowTableV)
  val fs_table = RegInit(VecInit(Seq.fill(16)(0.U.asTypeOf(new fse_t))))
  val state = RegInit(0.U(3.W))
  val key = Reg(UInt(96.W))
  val opcode = Reg(UInt(2.W))
  val meta = Reg(new fse_meta_t)
  val meta_last = Reg(new fse_meta_t)
  val tag = Reg(UInt(tag_width.W))
  val tag_last = Reg(UInt(tag_width.W))
  val isWaiting = RegInit(VecInit(Seq.fill(16)(false.B)))
  val isRunning = RegInit(VecInit(Seq.fill(16)(false.B)))
  val path_sel = Reg(Bool())
  val ch0_req_valid = Reg(Bool())
  val ch0_req_data = Reg(new ftCh0Input_t)
  val ch0_rep_valid  = Reg(Bool())
  val ch0_rep_tag    = Reg(UInt(tag_width.W))
  val ch0_rep_data   = Reg(new ftCh0Output_t)
  val ch0_rd_valid = Wire(Bool())
  val ch0_rd_valid_r = Reg(Bool())
  val ch0_bit_map = Wire(UInt(5.W))
  val ch0_bit_map_r = Reg(UInt(5.W))
  val ch0_q = Wire(new fce_t)
  val ch0_q_r = Reg(new fce_t)
  val ch0_q_out = Wire(new fce_t)
  val ch0_rd_ready = Wire(Bool())
  val ch1_wren = Reg(Bool())
  val ch1_req_data = Reg(new ftCh1Input_t)
  val ch1_req_data_valid = Reg(Bool())

  // flow table channel 0 response
  ch0_q_out.tuple.sIP := ft_inst.io.ch0_q_tuple_sIP
  ch0_q_out.tuple.dIP := ft_inst.io.ch0_q_tuple_dIP
  ch0_q_out.tuple.sPort := ft_inst.io.ch0_q_tuple_sPort
  ch0_q_out.tuple.dPort := ft_inst.io.ch0_q_tuple_dPort
  ch0_q_out.seq := ft_inst.io.ch0_q_seq
  ch0_q_out.pointer := ft_inst.io.ch0_q_pointer
  ch0_q_out.ll_valid := ft_inst.io.ch0_q_ll_valid
  ch0_q_out.slow_cnt := ft_inst.io.ch0_q_slow_cnt
  ch0_q_out.last_7_bytes := ft_inst.io.ch0_q_last_7_bytes
  ch0_q_out.addr0 := ft_inst.io.ch0_q_addr0
  ch0_q_out.addr1 := ft_inst.io.ch0_q_addr1
  ch0_q_out.addr2 := ft_inst.io.ch0_q_addr2
  ch0_q_out.addr3 := ft_inst.io.ch0_q_addr3
  ch0_q_out.pointer2 := ft_inst.io.ch0_q_pointer2

  when (ft_inst.io.ch0_rd_valid) {
    ch0_q_r := ch0_q_out
    ch0_bit_map_r := ft_inst.io.ch0_bit_map
    ch0_q := ch0_q_out
    ch0_bit_map := ft_inst.io.ch0_bit_map
  } .otherwise {
    ch0_q := ch0_q_r
    ch0_bit_map := ch0_bit_map_r
  }

  when (ft_inst.io.ch0_rd_valid) {
    ch0_rd_valid_r := !ch0_rd_ready
  } .elsewhen (ch0_rd_ready) {
    ch0_rd_valid_r := false.B
  }
  ch0_rd_valid := ch0_rd_valid_r || (ft_inst.io.ch0_rd_valid)

  io.ch0_rep_valid := ch0_rep_valid
  io.ch0_rep_tag := ch0_rep_tag
  io.ch0_rep_data := ch0_rep_data

  // Main FSM
  io.ch0_req_ready := false.B
  ch0_req_valid := false.B
  ch0_rep_valid := false.B
  ch1_wren := false.B
  ch0_rd_ready := false.B
  ft_inst.io.ch0_rden := false.B
  ft_inst.io.ch0_meta_tuple_sIP := meta.pkt.tuple.sIP
  ft_inst.io.ch0_meta_tuple_dIP := meta.pkt.tuple.dIP
  ft_inst.io.ch0_meta_tuple_sPort := meta.pkt.tuple.sPort
  ft_inst.io.ch0_meta_tuple_dPort := meta.pkt.tuple.dPort
  ft_inst.io.ch0_meta_addr0 := meta.addr0
  ft_inst.io.ch0_meta_addr1 := meta.addr1
  ft_inst.io.ch0_meta_addr2 := meta.addr2
  ft_inst.io.ch0_meta_addr3 := meta.addr3
  ft_inst.io.ch0_meta_opcode := 0.U
  when (state === 0.U) {
    // IDLE
    io.ch0_req_ready := true.B
    when (io.ch0_req_valid) {
      // New packet
      when (io.ch0_req_data.ch0_opcode === 0.U) {
        key := io.ch0_req_data.ch0_meta.tuple.asUInt
      } .elsewhen (io.ch0_req_data.ch0_opcode === 1.U) {
        key := fs_table(io.ch0_req_tag).meta.pkt.tuple.asUInt
        fs_table(io.ch0_req_tag).running := false.B
        ch0_rep_valid := true.B
        ch0_rep_tag := io.ch0_req_tag
      }
      when (io.ch0_req_data.ch0_opcode === 0.U && 
        (io.ch0_req_data.ch0_pkt.prot === 0x11.U || 
          (io.ch0_req_data.ch0_pkt.tcp_flags === 0x10.U && io.ch0_req_data.ch0_pkt.len === 0.U))) {
        // UDP or ACK packet
        state := 0.U
        ch0_rep_valid := true.B
        ch0_rep_tag := io.ch0_req_tag
        ch0_rep_data.flag := 0.U
      } .otherwise {
        state := 1.U
      }
      opcode := io.ch0_req_data.ch0_opcode
      meta.pkt := io.ch0_req_data.ch0_pkt
      meta.addr0 := io.ch0_req_data.ch0_meta.addr0
      meta.addr1 := io.ch0_req_data.ch0_meta.addr1
      meta.addr2 := io.ch0_req_data.ch0_meta.addr2
      meta.addr3 := io.ch0_req_data.ch0_meta.addr3
      tag := io.ch0_req_tag
    }
    .elsewhen (ch0_rd_valid) {
      // last packet returns
      state := 4.U
      ch0_rd_ready := true.B
      ch0_rep_valid := true.B
      ch0_rep_tag := tag_last
      ch0_rep_data.ch0_q := ch0_q
      ch0_rep_data.ch0_bit_map := ch0_bit_map
      ch0_rep_data.flag := 0.U
      path_sel := false.B
      when (ch0_bit_map =/= 0.U) {
        // flow entry exists
        when (meta_last.pkt.seq === ch0_q.seq) {
          when (ch0_q.slow_cnt === 0.U) {
            // Fast path
            ch1_wren := true.B
            ch1_req_data.ch1_data := ch0_q
            ch1_req_data_valid := true.B
            ch1_req_data.ch1_data.seq := meta_last.pkt.seq + meta_last.pkt.len
            ch1_req_data.ch1_bit_map := ch0_bit_map
            when ((meta_last.pkt.tcp_flags & 5.U) =/= 0.U) {
              ch1_req_data.ch1_opcode := 3.U
              ch1_req_data_valid := false.B
            } .otherwise {
              ch1_req_data.ch1_opcode := 2.U
            }
          } .otherwise {
            // Slow path
            path_sel := true.B
            ch0_rep_data.flag := 1.U
          }
        } .otherwise {
          // Slow path
          path_sel := true.B
          ch0_rep_data.flag := 2.U
        }
      } .otherwise {
        // Create new flow entry
        when ((meta_last.pkt.tcp_flags & 5.U) === 0.U) {
          ch1_wren := true.B
        }
        ch1_req_data_valid := true.B
        ch1_req_data.ch1_opcode := 1.U
        ch1_req_data.ch1_bit_map := 16.U
        ch1_req_data.ch1_data.tuple := meta_last.pkt.tuple
        ch1_req_data.ch1_data.pointer := 0.U
        ch1_req_data.ch1_data.pointer2 := 0.U
        ch1_req_data.ch1_data.ll_valid := 0.U
        ch1_req_data.ch1_data.slow_cnt := 0.U
        ch1_req_data.ch1_data.addr0 := meta_last.addr0
        ch1_req_data.ch1_data.addr1 := meta_last.addr1
        ch1_req_data.ch1_data.addr2 := meta_last.addr2
        ch1_req_data.ch1_data.addr3 := meta_last.addr3
        when (meta_last.pkt.tcp_flags(1) =/= 0.U) {
          ch1_req_data.ch1_data.seq := meta_last.pkt.seq + 1.U
          ch1_req_data.ch1_data.last_7_bytes := Fill(56, 1.U)
        } .otherwise {
          ch1_req_data.ch1_data.seq := meta_last.pkt.seq + meta_last.pkt.len
          ch1_req_data.ch1_data.last_7_bytes := meta_last.pkt.last_7_bytes
        }
      }
    }
  }
  .elsewhen (state === 1.U) {
    when (opcode === 0.U) {
      fs_table(tag).meta := meta
    }

    isWaiting := fs_table.map(fse => ((fse.meta.pkt.tuple.asUInt === key) && fse.waiting))
    isRunning := fs_table.map(fse => ((fse.meta.pkt.tuple.asUInt === key) && fse.running))
    state := 2.U
  }
  .elsewhen (state === 2.U) {
    path_sel := false.B
    when (ch0_rd_valid) {
      ch0_rd_ready := true.B
      ch0_rep_valid := true.B
      ch0_rep_tag := tag_last
      ch0_rep_data.ch0_q := ch0_q
      ch0_rep_data.ch0_bit_map := ch0_bit_map
      ch0_rep_data.flag := 0.U
      when (ch0_bit_map =/= 0.U) {
        when (meta_last.pkt.seq === ch0_q.seq) {
          when (ch0_q.slow_cnt === 0.U) {
            ch1_wren := true.B
            ch1_req_data.ch1_data := ch0_q
            ch1_req_data_valid := true.B
            ch1_req_data.ch1_data.seq := meta_last.pkt.seq + meta_last.pkt.len
            ch1_req_data.ch1_bit_map := ch0_bit_map
            when ((meta_last.pkt.tcp_flags & 5.U) =/= 0.U) {
              ch1_req_data.ch1_opcode := 3.U
              ch1_req_data_valid := false.B
            } .otherwise {
              ch1_req_data.ch1_opcode := 2.U
            }
          } .otherwise {
            path_sel := true.B
            ch0_rep_data.flag := 1.U
          }
        } .otherwise {
          path_sel := true.B
          ch0_rep_data.flag := 2.U
        }
      } .otherwise {
        when ((meta_last.pkt.tcp_flags & 5.U) === 0.U) {
          ch1_wren := true.B
        }
        ch1_req_data_valid := true.B
        ch1_req_data.ch1_opcode := 1.U
        ch1_req_data.ch1_bit_map := 16.U
        ch1_req_data.ch1_data.tuple := meta_last.pkt.tuple
        ch1_req_data.ch1_data.pointer := 0.U
        ch1_req_data.ch1_data.pointer2 := 0.U
        ch1_req_data.ch1_data.ll_valid := 0.U
        ch1_req_data.ch1_data.slow_cnt := 0.U
        ch1_req_data.ch1_data.addr0 := meta_last.addr0
        ch1_req_data.ch1_data.addr1 := meta_last.addr1
        ch1_req_data.ch1_data.addr2 := meta_last.addr2
        ch1_req_data.ch1_data.addr3 := meta_last.addr3
        when (meta_last.pkt.tcp_flags(1) =/= 0.U) {
          ch1_req_data.ch1_data.seq := meta_last.pkt.seq + 1.U
          ch1_req_data.ch1_data.last_7_bytes := Fill(56, 1.U)
        } .otherwise {
          ch1_req_data.ch1_data.seq := meta_last.pkt.seq + meta_last.pkt.len
          ch1_req_data.ch1_data.last_7_bytes := meta_last.pkt.last_7_bytes
        }
      }
    }

    when (opcode === 1.U) {
      when (isWaiting.asUInt =/= 0.U) {
        val hotValue = PriorityEncoder(isWaiting.asUInt)
        meta := fs_table(hotValue).meta
        tag := hotValue
        state := 3.U
      } .otherwise {
        state := 4.U
      }
    } .otherwise {
      state := 3.U
    }
  }
  .elsewhen (state === 3.U) {
    // new packet
    when ((isRunning.asUInt === 0.U) && (!(path_sel && (meta.pkt.tuple.asUInt === meta_last.pkt.tuple.asUInt)))) {
      // No conflict
      ft_inst.io.ch0_rden := true.B
      fs_table(tag).waiting := false.B
      when (((!ch1_wren) || (!ft_inst.io.ch1_insert_stall)) && (!ft_inst.io.ch0_rd_stall)) {
        meta_last := meta
        tag_last := tag
        state := 0.U
      }
    } .elsewhen ((!ch1_wren) || (!ft_inst.io.ch1_insert_stall)) {
      fs_table(tag).waiting := true.B
      state := 0.U
    }

    when (path_sel) {
      fs_table(tag_last).running := true.B
    }
  }
  .elsewhen (state === 4.U) {
    // no new packet
    when (path_sel) {
      fs_table(tag_last).running := true.B
    }
    when ((!ch1_wren) || (!ft_inst.io.ch1_insert_stall)) {
      state := 0.U
    }
  }


  //---------------------------- flow table --------------------------------//
  val ch1_tag_reg = Reg(UInt(tag_width.W))


  ft_inst.io.clk := clock
  ft_inst.io.rst := reset

  ft_inst.io.ch1_wren := ch1_wren || io.ch1_req_valid
  io.ch1_req_ready := (!ch1_wren) && (!ft_inst.io.ch1_insert_stall)
  io.ch1_rep_tag := ch1_tag_reg
  io.ch1_rep_valid := RegNext(io.ch1_req_valid && io.ch1_req_ready)
  io.ch1_rep_data := 0.U

  when (io.ch1_req_valid && io.ch1_req_ready) {
    ch1_tag_reg := io.ch1_req_tag
  }

  when (ch1_wren) {
    ft_inst.io.ch1_opcode := ch1_req_data.ch1_opcode
    ft_inst.io.ch1_data_valid := ch1_req_data_valid
    ft_inst.io.ch1_bit_map := ch1_req_data.ch1_bit_map
    ft_inst.io.ch1_data_tuple_sIP := ch1_req_data.ch1_data.tuple.sIP
    ft_inst.io.ch1_data_tuple_dIP := ch1_req_data.ch1_data.tuple.dIP
    ft_inst.io.ch1_data_tuple_sPort := ch1_req_data.ch1_data.tuple.sPort
    ft_inst.io.ch1_data_tuple_dPort := ch1_req_data.ch1_data.tuple.dPort
    ft_inst.io.ch1_data_seq := ch1_req_data.ch1_data.seq
    ft_inst.io.ch1_data_pointer := ch1_req_data.ch1_data.pointer
    ft_inst.io.ch1_data_ll_valid := ch1_req_data.ch1_data.ll_valid
    ft_inst.io.ch1_data_slow_cnt := ch1_req_data.ch1_data.slow_cnt
    ft_inst.io.ch1_data_last_7_bytes := ch1_req_data.ch1_data.last_7_bytes
    ft_inst.io.ch1_data_addr0 := ch1_req_data.ch1_data.addr0
    ft_inst.io.ch1_data_addr1 := ch1_req_data.ch1_data.addr1
    ft_inst.io.ch1_data_addr2 := ch1_req_data.ch1_data.addr2
    ft_inst.io.ch1_data_addr3 := ch1_req_data.ch1_data.addr3
    ft_inst.io.ch1_data_pointer2 := ch1_req_data.ch1_data.pointer2
  } .otherwise {
    when (io.ch1_req_data.ch1_opcode === 3.U) {
      ft_inst.io.ch1_data_valid := false.B
    } .otherwise {
      ft_inst.io.ch1_data_valid := true.B
    }
    ft_inst.io.ch1_opcode := io.ch1_req_data.ch1_opcode
    ft_inst.io.ch1_bit_map := io.ch1_req_data.ch1_bit_map
    ft_inst.io.ch1_data_tuple_sIP := io.ch1_req_data.ch1_data.tuple.sIP
    ft_inst.io.ch1_data_tuple_dIP := io.ch1_req_data.ch1_data.tuple.dIP
    ft_inst.io.ch1_data_tuple_sPort := io.ch1_req_data.ch1_data.tuple.sPort
    ft_inst.io.ch1_data_tuple_dPort := io.ch1_req_data.ch1_data.tuple.dPort
    ft_inst.io.ch1_data_seq := io.ch1_req_data.ch1_data.seq
    ft_inst.io.ch1_data_pointer := io.ch1_req_data.ch1_data.pointer
    ft_inst.io.ch1_data_ll_valid := io.ch1_req_data.ch1_data.ll_valid
    ft_inst.io.ch1_data_slow_cnt := io.ch1_req_data.ch1_data.slow_cnt
    ft_inst.io.ch1_data_last_7_bytes := io.ch1_req_data.ch1_data.last_7_bytes
    ft_inst.io.ch1_data_addr0 := io.ch1_req_data.ch1_data.addr0
    ft_inst.io.ch1_data_addr1 := io.ch1_req_data.ch1_data.addr1
    ft_inst.io.ch1_data_addr2 := io.ch1_req_data.ch1_data.addr2
    ft_inst.io.ch1_data_addr3 := io.ch1_req_data.ch1_data.addr3
    ft_inst.io.ch1_data_pointer2 := io.ch1_req_data.ch1_data.pointer2
  }
}

class pktReassembly(extCompName: String) extends gComponentLeaf(new metadata_t, new metadata_t, ArrayBuffer(("dynamicMem", new dyMemInput_t, new llNode_t), ("hash", new tuple_t, new fce_meta_t)), extCompName + "__type__engine__MT__16__") {
  val NUM_THREADS = 16
  val NUM_THREADS_LG = log2Up(NUM_THREADS)
  val REG_WIDTH = 270
  val NUM_REGS = 16
  val NUM_REGS_LG = log2Up(NUM_REGS)
  val NUM_FUOPS_LG = 2
  val NUM_FUS = 6
  val NUM_FUS_LG = log2Up(NUM_FUS)
  // val VLIW_OPS = 2
  val NUM_DST = 1
  val NUM_PREOPS = 11
  val NUM_PREOPS_LG = log2Up(NUM_PREOPS)
  val IMM_WIDTH = 8
  val NUM_ALUOPS_LG = 4
  val NUM_ALUS = 2
  val NUM_BTS = 3
  val NUM_REGBLOCKS = 14
  val NUM_SRC_POS = 26
  val NUM_SRC_MODES = 14
  val NUM_SRC_POS_LG = log2Up(NUM_SRC_POS)
  val NUM_SRC_MODES_LG = log2Up(NUM_SRC_MODES)
  val NUM_DST_POS = 9
  val NUM_DST_MODE = 10
  val MAX_FIELD_WIDTH = 56
  // FIXME
  //val BR_INSTR_WIDTH = 8
  //val INSTR_WIDTH = NUM_PREOPS_LG + VLIW_OPS * (NUM_FUS_LG + 2 * NUM_REGS_LG) + BR_INSTR_WIDTH
  val IP_WIDTH = 8
  val INSTR_WIDTH = NUM_PREOPS_LG + NUM_ALUS * (NUM_ALUOPS_LG + 3 * (NUM_SRC_POS_LG + NUM_SRC_MODES_LG) + 2 * NUM_REGS_LG) + 2 * NUM_DST * (NUM_FUS_LG + NUM_REGS_LG + 1) + NUM_FUS * (1 + NUM_FUOPS_LG) + IP_WIDTH * NUM_BTS + NUM_ALUS * IMM_WIDTH
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
  def dynamicMemPort = functionalUnits.asInstanceOf[Bundle].elements("dynamicMem").asInstanceOf[gOffBundle[dyMemInput_t, llNode_t]]
  def hashPort = functionalUnits.asInstanceOf[Bundle].elements("hash").asInstanceOf[gOffBundle[tuple_t, fce_meta_t]]
  // val lockPort = Module(new lockU(TAGWIDTH, NUM_THREADS))
  val flowTablePort = Module(new flowTable(TAGWIDTH, NUM_THREADS))
  // def ipv4Lookup1Port = functionalUnits.asInstanceOf[Bundle].elements("ipv4Lookup1").asInstanceOf[gOffBundle[UInt, UInt]]
  // def ipv4Lookup2Port = functionalUnits.asInstanceOf[Bundle].elements("ipv4Lookup2").asInstanceOf[gOffBundle[UInt, UInt]]
  // def qosCountPort = functionalUnits.asInstanceOf[Bundle].elements("qosCount").asInstanceOf[gOffBundle[UInt, UInt]]

  object ThreadStageEnum extends ChiselEnum {
    val idle   = Value
    val fetch  = Value
    val decode = Value
    val read   = Value
    val pre    = Value
    val exec   = Value
    //val post   = Value
    val branch = Value
  }
  val threadStages = RegInit(VecInit(Seq.fill(NUM_THREADS)(ThreadStageEnum.idle)))

  val ThreadStateT = new Bundle {
    val tag         = UInt((TAGWIDTH*2).W)
    // FIXME: input -> rf & rf -> output
    val input       = new metadata_t
    // val output      = new metadata_t

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
    val fuValids    = Vec(NUM_FUS, Bool())
    // val brMask      = Vec(NUM_FUS + 1, Bool())

    // val srcA        = UInt(REG_WIDTH.W)
    // val srcB        = UInt(REG_WIDTH.W)

    val preOpBranch = Bool()
    // val preOpA      = UInt(REG_WIDTH.W)
    // val preOpB      = UInt(REG_WIDTH.W)
    val branchFU    = Bool()

    val execValids  = Vec(NUM_FUS, Bool())
    val execDone    = Bool()
    val finish      = Bool()
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
  val GS_INPUT       = 8.U
  val GS_OUTPUT      = 9.U
  val GS_OUTPUTRET   = 10.U
  val GS_RET         = 11.U
  val GS_BFU         = 12.U

  val reg_block_width = ArrayBuffer(96, 8, 24, 8, 1, 1, 10, 43, 3, 10, 32, 16, 9, 9)
  val regfile = Module(new RegRead(NUM_THREADS, NUM_ALUS, NUM_DST, NUM_REGS, REG_WIDTH, NUM_REGBLOCKS, reg_block_width))

  class ThreadMemT extends Bundle {
    val destAEn     = Vec(NUM_DST, Bool())
    val destBEn     = Vec(NUM_DST, Bool())
    val destAId     = Vec(NUM_DST, UInt(NUM_REGS_LG.W))
    val destBId     = Vec(NUM_DST, UInt(NUM_REGS_LG.W))
    val destALane   = Vec(NUM_DST, UInt(NUM_FUS_LG.W))
    val destBLane   = Vec(NUM_DST, UInt(NUM_FUS_LG.W))
    val brTarget    = Vec(NUM_BTS, UInt(IP_WIDTH.W))
  }

  class DestMemT extends Bundle {
    val slctFU     = UInt(log2Up(NUM_BTS).W)
    val wben       = UInt(NUM_REGBLOCKS.W)
    val dest       = UInt(REG_WIDTH.W)
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
  val sThreadEncoder = Module(new RREncode(NUM_THREADS))
  val sThread = sThreadEncoder.io.chosen
  val in_bits_d0 = Reg(new metadata_t)
  val in_tag_d0 = Reg(UInt((TAGWIDTH*2).W))
  val in_valid_d0 = Reg(Bool())
  val sThread_reg = RegInit(NONE_SELECTED)
  Range(0, NUM_THREADS, 1).map(i =>
    sThreadEncoder.io.valid(i) := threadStages(i) === ThreadStageEnum.idle)
  sThreadEncoder.io.ready := sThread =/= NONE_SELECTED

  io.in.ready := false.B
  sThread_reg := sThread
  in_tag_d0 := io.in.tag
  in_bits_d0 := io.in.bits

  when (sThread =/= NONE_SELECTED && io.in.valid) {
    threadStages(sThread) := ThreadStageEnum.fetch

    // threadStates(sThread).tag := io.in.tag
    // threadStates(sThread).input := io.in.bits
    in_valid_d0 := true.B
    threadStates(sThread).ip := 0.U(IP_WIDTH.W)
    io.in.ready := true.B
  }
  .otherwise {
    in_valid_d0 := false.B
  }

  when (in_valid_d0) {
    threadStates(sThread_reg).tag := in_tag_d0
    threadStates(sThread_reg).input := in_bits_d0
    when ((in_bits_d0.len =/= 0.U) || (in_bits_d0.prot === 17.U)) {
      threadStates(sThread_reg).input.pkt_flags := 2.U
    } .otherwise {
      threadStates(sThread_reg).input.pkt_flags := 0.U
    }
  }


  /****************** Scheduler logic *********************************/
  // select valid thread
  // val vThreadEncoder = Module(new RREncode(NUM_THREADS))
  val vThreadEncoder = Module(new Scheduler(NUM_THREADS, scala.math.pow(2, log2Up(NUM_ALUS)).toInt))
  val vThread = vThreadEncoder.io.chosen
  Range(0, NUM_THREADS, 1).map(i =>
    vThreadEncoder.io.valid(i) := (threadStages(i) === ThreadStageEnum.fetch))
  // vThreadEncoder.io.ready := vThread =/= NONE_SELECTED

  /****************** Fetch logic *********************************/
  val fetchUnit = Module(new Fetch(NUM_THREADS, IP_WIDTH, INSTR_WIDTH))
  val instr = Reg(UInt(INSTR_WIDTH.W))
  fetchUnit.io.ip := threadStates(vThread).ip
  instr := fetchUnit.io.instr

  when (vThread =/= NONE_SELECTED) {
      threadStages(vThread) := ThreadStageEnum.decode
  }

  /****************** Decode logic *********************************/
  val decodeThread = RegInit(NONE_SELECTED)
  decodeThread := vThread

  val decodeUnit = Module(new Decode(INSTR_WIDTH, NUM_REGS_LG, NUM_ALUOPS_LG, NUM_SRC_POS_LG, NUM_SRC_MODES_LG,
    NUM_ALUS, NUM_DST, NUM_FUS, NUM_FUOPS_LG, NUM_PREOPS_LG, NUM_BTS, IP_WIDTH, IMM_WIDTH))
  when (decodeThread =/= NONE_SELECTED) {
    decodeUnit.io.instr := instr
    threadStates(decodeThread).fuValids := decodeUnit.io.fuValids
    threadStates(decodeThread).execValids := VecInit(Seq.fill(NUM_FUS)(false.B))

    val threadMem_in = Wire(new ThreadMemT)
    threadMem_in.destAEn   := decodeUnit.io.destAEn
    threadMem_in.destBEn   := decodeUnit.io.destBEn
    threadMem_in.destAId   := decodeUnit.io.destAId
    threadMem_in.destBId   := decodeUnit.io.destBId
    threadMem_in.destALane := decodeUnit.io.destALane
    threadMem_in.destBLane := decodeUnit.io.destBLane
    threadMem_in.brTarget  := decodeUnit.io.brTarget
    threadMem.io.wraddress := decodeThread
    threadMem.io.wren      := true.B
    threadMem.io.data      := threadMem_in.asUInt
    regfile.io.thread_rd   := decodeThread
    regfile.io.rdEn        := true.B
    for (i <- 0 until NUM_ALUS) {
      regfile.io.rdAddr1(i) := decodeUnit.io.aluInsts(i).srcId(0)
      regfile.io.rdAddr2(i) := decodeUnit.io.aluInsts(i).srcId(1)
    }

    threadStages(decodeThread) := ThreadStageEnum.read
  }
  .otherwise {
    decodeUnit.io.instr := DontCare
    threadMem.io.wraddress := DontCare
    threadMem.io.wren      := false.B
    threadMem.io.data      := DontCare
    threadStates(decodeThread).fuValids := DontCare
    threadStates(decodeThread).execValids := DontCare

    regfile.io.thread_rd := DontCare
    regfile.io.rdEn := false.B
    regfile.io.rdAddr1 := DontCare
    regfile.io.rdAddr2 := DontCare
  }

  val aluOp_d = Reg(Vec(NUM_ALUS, UInt(NUM_ALUOPS_LG.W)))
  val aluA_shift = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W)))
  val aluB_shift = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W)))
  val aluA_mode = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W)))
  val aluB_mode = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W)))
  val alu_dstShift_d = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W)))
  val alu_dstMode_d = Reg(Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W)))
  val alu_imm = Reg(Vec(NUM_ALUS, UInt(IMM_WIDTH.W)))
  val preOp_d = Reg(UInt(NUM_PREOPS_LG.W))
  val fuOps_d = Reg(Vec(NUM_FUS, UInt(NUM_FUOPS_LG.W)))
  val fuValids_d = Reg(Vec(NUM_FUS, Bool()))
  for (i <- 0 until NUM_ALUS) {
    aluOp_d(i) := decodeUnit.io.aluInsts(i).aluOp
    aluA_shift(i) := decodeUnit.io.aluInsts(i).srcShiftR(0)
    aluB_shift(i) := decodeUnit.io.aluInsts(i).srcShiftR(1)
    aluA_mode(i) := decodeUnit.io.aluInsts(i).srcMode(0)
    aluB_mode(i) := decodeUnit.io.aluInsts(i).srcMode(1)
    alu_dstShift_d(i) := decodeUnit.io.aluInsts(i).dstShiftL
    alu_dstMode_d(i) := decodeUnit.io.aluInsts(i).dstMode
  }
  alu_imm := decodeUnit.io.imm
  preOp_d := decodeUnit.io.preOp
  fuOps_d := decodeUnit.io.fuOps
  fuValids_d := decodeUnit.io.fuValids

  /************************* Register read  *******************************/
  val REG_DELAY = NUM_ALUS + 4
  val readThread_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(NONE_SELECTED)))
  val aluOp_vec = Reg(Vec(REG_DELAY, Vec(NUM_ALUS, UInt(NUM_ALUOPS_LG.W))))
  val imm_vec = Reg(Vec(REG_DELAY-3, Vec(NUM_ALUS, UInt(IMM_WIDTH.W))))
  val aluA_shift_vec = Reg(Vec(REG_DELAY-3, Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W))))
  val aluB_shift_vec = Reg(Vec(REG_DELAY-3, Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W))))
  val aluA_mode_vec = Reg(Vec(REG_DELAY-3, Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W))))
  val aluB_mode_vec = Reg(Vec(REG_DELAY-3, Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W))))
  val preOp_vec = Reg(Vec(REG_DELAY, UInt(NUM_PREOPS_LG.W)))
  val aluDstShift_vec = Reg(Vec(REG_DELAY+1, Vec(NUM_ALUS, UInt(NUM_SRC_POS_LG.W))))
  val aluDstMode_vec = Reg(Vec(REG_DELAY+1, Vec(NUM_ALUS, UInt(NUM_SRC_MODES_LG.W))))
  val fuOps_vec = Reg(Vec(REG_DELAY+1, Vec(NUM_FUS, UInt(NUM_FUOPS_LG.W))))
  val fuValids_vec = Reg(Vec(REG_DELAY+1, Vec(NUM_FUS, Bool())))

  readThread_vec(REG_DELAY-1) := decodeThread
  aluOp_vec(REG_DELAY-1) := aluOp_d
  imm_vec(REG_DELAY-4) := alu_imm
  aluA_shift_vec(REG_DELAY-4) := aluA_shift
  aluB_shift_vec(REG_DELAY-4) := aluB_shift
  aluA_mode_vec(REG_DELAY-4) := aluA_mode
  aluB_mode_vec(REG_DELAY-4) := aluB_mode
  preOp_vec(REG_DELAY-1) := preOp_d
  aluDstShift_vec(REG_DELAY-1) := alu_dstShift_d
  aluDstMode_vec(REG_DELAY-1) := alu_dstMode_d
  fuOps_vec(REG_DELAY-1) := fuOps_d
  fuValids_vec(REG_DELAY-1) := fuValids_d

  for (i <- 0 until REG_DELAY-1) {
    readThread_vec(i) := readThread_vec(i+1)
    aluOp_vec(i) := aluOp_vec(i+1)
    preOp_vec(i) := preOp_vec(i+1)
    aluDstShift_vec(i) := aluDstShift_vec(i+1)
    aluDstMode_vec(i) := aluDstMode_vec(i+1)
    fuOps_vec(i) := fuOps_vec(i+1)
    fuValids_vec(i) := fuValids_vec(i+1)
  }
  for (i <- 0 until REG_DELAY-4) {
    imm_vec(i) := imm_vec(i+1)
    aluA_shift_vec(i) := aluA_shift_vec(i+1)
    aluB_shift_vec(i) := aluB_shift_vec(i+1)
    aluA_mode_vec(i) := aluA_mode_vec(i+1)
    aluB_mode_vec(i) := aluB_mode_vec(i+1)
  }

  when (readThread_vec(0) =/= NONE_SELECTED) {
    threadStages(readThread_vec(0)) := ThreadStageEnum.pre
  }

  val srcA = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  val srcB = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  srcA := regfile.io.rdData1
  srcB := regfile.io.rdData2

  val block_widths = ArrayBuffer(0, 8, 96, 104, 108, 120, 128, 132, 136, 137, 138, 148, 152, 162, 168, 173, 182, 191, 194, 196, 204, 216, 228, 240, 252, 261)
  val mode_bits = ArrayBuffer(1, 2, 3, 5, 6, 8, 9, 10, 12, 16, 32, 56, 56, 56)
  val gather_aluA = Seq.fill(NUM_ALUS)(Module(new Gather(IMM_WIDTH, REG_WIDTH, NUM_SRC_POS, block_widths, MAX_FIELD_WIDTH, NUM_SRC_MODES, mode_bits)))
  val gather_aluB = Seq.fill(NUM_ALUS)(Module(new Gather(IMM_WIDTH, REG_WIDTH, NUM_SRC_POS, block_widths, MAX_FIELD_WIDTH, NUM_SRC_MODES, mode_bits)))
  for (i <- 0 until NUM_ALUS) {
    gather_aluA(i).io.din := srcA(i)
    gather_aluA(i).io.shift := aluA_shift_vec(0)(i)
    gather_aluA(i).io.mode := aluA_mode_vec(0)(i)
    gather_aluA(i).io.imm := imm_vec(0)(i)
    gather_aluB(i).io.din := srcB(i)
    gather_aluB(i).io.shift := aluB_shift_vec(0)(i)
    gather_aluB(i).io.mode := aluB_mode_vec(0)(i)
    gather_aluB(i).io.imm := imm_vec(0)(i)
  }

  /****************** Pre logic *********************************/
  val preOpThread = RegInit(NONE_SELECTED)
  val preOp = Wire(UInt(NUM_PREOPS_LG.W))
  preOpThread := readThread_vec(0)
  preOp := preOp_vec(0)

  val alus = Seq.fill(NUM_ALUS)(Module(new ALU(NUM_ALUOPS_LG, REG_WIDTH)))

  for (i <- 0 until NUM_ALUS) {
    alus(i).io.srcA := gather_aluA(i).io.dout
    alus(i).io.signA := gather_aluA(i).io.sign_out
    alus(i).io.srcB := gather_aluB(i).io.dout
    alus(i).io.signB := gather_aluB(i).io.sign_out
    alus(i).io.aluOp := aluOp_vec(0)(i)
  }

  // val execBundle0 = new Bundle {
  //   val tag = UInt(NUM_THREADS_LG.W)
  //   val bits = (new lockUInput_t)
  // }
  val execBundle0 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new tuple_t)
  }
  val execBundle1 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new ftCh0Input_t)
  }
  val execBundle2 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new ftCh1Input_t)
  }
  val execBundle3 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = (new dyMemInput_t)
  }
  val fuFifos_0 = Module(new Queue(execBundle0, NUM_THREADS - 1))
  val fuFifos_1 = Module(new Queue(execBundle1, NUM_THREADS - 1))
  val fuFifos_2 = Module(new Queue(execBundle2, NUM_THREADS - 1))
  val fuFifos_3 = Module(new Queue(execBundle3, NUM_THREADS - 1))
  // val fuFifos_4 = Module(new Queue(execBundle4, NUM_THREADS - 1))

  fuFifos_0.io.enq.valid := false.B
  fuFifos_0.io.enq.bits := DontCare
  fuFifos_1.io.enq.valid := false.B
  fuFifos_1.io.enq.bits := DontCare
  fuFifos_2.io.enq.valid := false.B
  fuFifos_2.io.enq.bits := DontCare
  fuFifos_3.io.enq.valid := false.B
  fuFifos_3.io.enq.bits := DontCare
  // fuFifos_4.io.enq.valid := false.B
  // fuFifos_4.io.enq.bits := DontCare

  io.out.tag := DontCare
  io.out.bits := DontCare
  io.out.valid := false.B

  val preOpRes = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  for (i <- 0 until NUM_ALUS) {
    preOpRes(i) := alus(i).io.dout
  }

  when (preOpThread =/= NONE_SELECTED) {
    threadStates(preOpThread).finish := false.B
    threadStates(preOpThread).preOpBranch := false.B
    threadStates(preOpThread).branchFU := false.B

    when (preOp === GS_INPUT) {
      val input_u = Wire(UInt(REG_WIDTH.W))
      // val shift_w = Wire(UInt(4.W))
      input_u := threadStates(preOpThread).input.asUInt
      // shift_w := threadStates(preOpThread).imm(3, 0)

      // val tmp = Wire(UInt(1152.W))
      // tmp := input_u >> ((4.U-shift_w)*256.U)

      // preOpRes(0) := tmp(255, 128)
      preOpRes(0) := input_u
      preOpRes(1) := input_u
    }

    .elsewhen (preOp === GS_BR) {
      threadStates(preOpThread).preOpBranch := true.B
    }

    .elsewhen (preOp === GS_ALUA) {
      threadStates(preOpThread).preOpBranch := (preOpRes(0)(31, 0) =/= 0.U)
    }

    .elsewhen (preOp === GS_ALUB) {
      threadStates(preOpThread).preOpBranch := (preOpRes(1)(31, 0) =/= 0.U)
    }

    .elsewhen (preOp === GS_AND) {
      threadStates(preOpThread).preOpBranch := (preOpRes(0)(0) === 1.U) && (preOpRes(1)(0) === 1.U)
    }

    .elsewhen (preOp === GS_OR) {
      threadStates(preOpThread).preOpBranch := (preOpRes(0)(0) === 1.U) || (preOpRes(1)(0) === 1.U)
    }

    .elsewhen (preOp === GS_GT) {
      threadStates(preOpThread).preOpBranch := (preOpRes(0)(31, 0) > preOpRes(1)(31, 0))
    }

    .elsewhen (preOp === GS_GE) {
      threadStates(preOpThread).preOpBranch := (preOpRes(0)(31, 0) >= preOpRes(1)(31, 0))
    }

    .elsewhen (preOp === GS_OUTPUT) {
      threadStates(preOpThread).preOpBranch := true.B
      io.out.tag := threadStates(preOpThread).tag
      // io.out.bits := threadStates(preOpThread).input
      io.out.bits := preOpRes(0).asTypeOf(chiselTypeOf(io.out.bits))
      // io.out.bits.l3.h1 := preOpB
      io.out.valid := true.B
      // threadStates(preOpThread).finish := true.B
    }

    .elsewhen (preOp === GS_OUTPUTRET) {
      io.out.tag := threadStates(preOpThread).tag
      io.out.bits := preOpRes(0).asTypeOf(chiselTypeOf(io.out.bits))
      io.out.valid := true.B
      threadStates(preOpThread).finish := true.B
    }

    .elsewhen (preOp === GS_RET) {
      threadStates(preOpThread).finish := true.B
    }

    .elsewhen (preOp === GS_BFU) {
      threadStates(preOpThread).branchFU := true.B
    }

    // FIXME: choose which preOp vals to send to functional units

    when (fuValids_vec(0)(0) === true.B) {
      fuFifos_0.io.enq.bits.tag := preOpThread
      fuFifos_0.io.enq.bits.bits := (preOpRes(1).asTypeOf(new metadata_t)).tuple
      fuFifos_0.io.enq.valid := true.B
    }

    when (fuValids_vec(0)(1) === true.B) {
      fuFifos_1.io.enq.bits.tag := preOpThread
      fuFifos_1.io.enq.bits.bits.ch0_opcode := fuOps_vec(0)(1)
      fuFifos_1.io.enq.bits.bits.ch0_pkt := preOpRes(0).asTypeOf(new metadata_t)
      fuFifos_1.io.enq.bits.bits.ch0_meta := preOpRes(1).asTypeOf(new fce_meta_t)
      fuFifos_1.io.enq.valid := true.B
    }

    when (fuValids_vec(0)(2) === true.B) {
      fuFifos_2.io.enq.bits.tag := preOpThread
      fuFifos_2.io.enq.bits.bits.ch1_opcode := fuOps_vec(0)(2)
      fuFifos_2.io.enq.bits.bits.ch1_bit_map := (preOpRes(1).asTypeOf(new ftCh0Output_t)).ch0_bit_map
      fuFifos_2.io.enq.bits.bits.ch1_data := (preOpRes(1).asTypeOf(new ftCh0Output_t)).ch0_q
      fuFifos_2.io.enq.valid := true.B
    }

    when (fuValids_vec(0)(3) === true.B) {
      fuFifos_3.io.enq.bits.tag := preOpThread
      fuFifos_3.io.enq.bits.bits.opcode := fuOps_vec(0)(3)
      fuFifos_3.io.enq.bits.bits.node := preOpRes(1).asTypeOf(new llNode_t)
      fuFifos_3.io.enq.valid := true.B
    }

    threadStages(preOpThread) := ThreadStageEnum.exec
  }

  /****************** Function unit execution *********************************/
  val execThread = RegInit(NONE_SELECTED)
  val execThread_d0 = RegInit(NONE_SELECTED)
  execThread := preOpThread
  execThread_d0 := execThread
  val fuValids_e = Reg(Vec(NUM_FUS, Bool()))
  val fuValids_e_d0 = Reg(Vec(NUM_FUS, Bool()))
  fuValids_e := fuValids_vec(0)
  fuValids_e_d0 := fuValids_e
  val fuReqReadys = new Array[Bool](NUM_FUS)
  // fuReqReadys(0) = lockPort.io.req_ready
  fuReqReadys(0) = hashPort.req.ready
  fuReqReadys(1) = flowTablePort.io.ch0_req_ready
  fuReqReadys(2) = flowTablePort.io.ch1_req_ready
  fuReqReadys(3) = dynamicMemPort.req.ready
  // fuReqReadys(1) = ipv4Lookup2Port.req.ready
  // fuReqReadys(2) = qosCountPort.req.ready

  // Bypass ALU results
  val wr_encode = ArrayBuffer(0, 2, 3, 6, 10, 17, 20, 24, 25)
  val wr_offset = ArrayBuffer(0, 96, 104, 128, 138, 191, 204, 252, 261)
  val wben_encode = ArrayBuffer((0, 10), (0, -1), (2, -1), (3, -1), (6, -1), (10, -1), (17, -1), (20, -1), (24, -1), (25, -1))
  val wbens = ArrayBuffer(0x1, 0xffff, 0x6, 0xc, 0x18, 0x40, 0x100, 0x400, 0x1000, 0x2000)

  val scatter = Seq.fill(NUM_ALUS)(Module(new Scatter(REG_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_REGBLOCKS, NUM_DST_POS, wr_encode, wr_offset, NUM_DST_MODE, wben_encode, wbens)))

  for (i <- 0 until NUM_ALUS) {
    scatter(i).io.din := RegNext(preOpRes(i))
    scatter(i).io.mode := RegNext(aluDstMode_vec(0)(i))
    scatter(i).io.shift := RegNext(aluDstShift_vec(0)(i))
  }

  when (execThread_d0 =/= NONE_SELECTED) {
    when (fuValids_e_d0(4) === true.B) {
      val destMem_in = Wire(new DestMemT)
      destMem_in.slctFU := 0.U
      destMem_in.dest := scatter(0).io.dout
      destMem_in.wben := scatter(0).io.wren
      destMems(4).io.wren := true.B
      destMems(4).io.wraddress := execThread_d0
      destMems(4).io.data := destMem_in.asUInt
      threadStates(execThread_d0).execValids(4) := true.B
    }

    when (fuValids_e_d0(5) === true.B) {
      val destMem_in = Wire(new DestMemT)
      destMem_in.slctFU := 0.U
      destMem_in.dest := scatter(1).io.dout
      destMem_in.wben := scatter(1).io.wren
      destMems(5).io.wren := true.B
      destMems(5).io.wraddress := execThread_d0
      destMems(5).io.data := destMem_in.asUInt
      threadStates(execThread_d0).execValids(5) := true.B
    }
  }

  // FUs input
  when (fuFifos_0.io.count > 0.U && fuReqReadys(0) === true.B) {
    val deq = fuFifos_0.io.deq
    hashPort.req.valid := true.B
    hashPort.req.tag := deq.bits.tag
    hashPort.req.bits := deq.bits.bits
    fuFifos_0.io.deq.ready := true.B
  }
  .otherwise {
    hashPort.req.valid := false.B
    hashPort.req.tag := 0.U(NUM_THREADS_LG.W)
    hashPort.req.bits := DontCare
    fuFifos_0.io.deq.ready := false.B
  }

  when (fuFifos_1.io.count > 0.U && fuReqReadys(1) === true.B) {
    val deq = fuFifos_1.io.deq
    flowTablePort.io.ch0_req_valid := true.B
    flowTablePort.io.ch0_req_tag := deq.bits.tag
    flowTablePort.io.ch0_req_data := deq.bits.bits
    fuFifos_1.io.deq.ready := true.B
  }
  .otherwise {
    flowTablePort.io.ch0_req_valid := false.B
    flowTablePort.io.ch0_req_tag := 0.U(NUM_THREADS_LG.W)
    flowTablePort.io.ch0_req_data := DontCare
    fuFifos_1.io.deq.ready := false.B
  }

  when (fuFifos_2.io.count > 0.U && fuReqReadys(2) === true.B) {
    val deq = fuFifos_2.io.deq
    flowTablePort.io.ch1_req_valid := true.B
    flowTablePort.io.ch1_req_tag := deq.bits.tag
    flowTablePort.io.ch1_req_data := deq.bits.bits
    fuFifos_2.io.deq.ready := true.B
  }
  .otherwise {
    flowTablePort.io.ch1_req_valid := false.B
    flowTablePort.io.ch1_req_tag := 0.U(NUM_THREADS_LG.W)
    flowTablePort.io.ch1_req_data := DontCare
    fuFifos_2.io.deq.ready := false.B
  }

  when (fuFifos_3.io.count > 0.U && fuReqReadys(3) === true.B) {
    val deq = fuFifos_3.io.deq
    dynamicMemPort.req.valid := true.B
    dynamicMemPort.req.tag := deq.bits.tag
    dynamicMemPort.req.bits := deq.bits.bits
    fuFifos_3.io.deq.ready := true.B
  }
  .otherwise {
    dynamicMemPort.req.valid := false.B
    dynamicMemPort.req.tag := 0.U(NUM_THREADS_LG.W)
    dynamicMemPort.req.bits := DontCare
    fuFifos_3.io.deq.ready := false.B
  }

  // FUs output
  hashPort.rep.ready := true.B
  when (hashPort.rep.valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.slctFU := 0.U
    destMem_in.dest := hashPort.rep.bits.asUInt
    destMem_in.wben := Fill(16, 1.U)
    destMems(0).io.wren := true.B
    destMems(0).io.wraddress := hashPort.rep.tag
    destMems(0).io.data := destMem_in.asUInt
    threadStates(hashPort.rep.tag).execValids(0) := true.B
  }

  flowTablePort.io.ch0_rep_ready := true.B
  when (flowTablePort.io.ch0_rep_valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.slctFU := flowTablePort.io.ch0_rep_data.flag
    destMem_in.dest := flowTablePort.io.ch0_rep_data.asUInt
    destMem_in.wben := Fill(16, 1.U)
    destMems(1).io.wren := true.B
    destMems(1).io.wraddress := flowTablePort.io.ch0_rep_tag
    destMems(1).io.data := destMem_in.asUInt
    threadStates(flowTablePort.io.ch0_rep_tag).execValids(1) := true.B
  }

  flowTablePort.io.ch1_rep_ready := true.B
  when (flowTablePort.io.ch1_rep_valid) {
    // threadStates(flowTablePort.io.ch1_rep_tag).dests(1) := flowTablePort.io.ch1_rep_data.asUInt
    // threadStates(flowTablePort.io.ch1_rep_tag).wbens(2) := Fill(16, 0.U)
    threadStates(flowTablePort.io.ch1_rep_tag).execValids(2) := true.B
  }

  dynamicMemPort.rep.ready := true.B
  when (dynamicMemPort.rep.valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.slctFU := 0.U
    destMem_in.dest := dynamicMemPort.rep.bits.asUInt
    destMem_in.wben := Fill(16, 1.U)
    destMems(3).io.wren := true.B
    destMems(3).io.wraddress := dynamicMemPort.rep.tag
    destMems(3).io.data := destMem_in.asUInt
    threadStates(dynamicMemPort.rep.tag).execValids(3) := true.B
  }

  // finish execution
  // FIXME: this does not need to take a cycle
  Range(0, NUM_THREADS, 1).foreach(i =>
    // threadStates(i).execDone := (threadStates(i).execValids zip threadStates(i).fuValids).map(x => x._1 || x._2).forall(_ === true.B)
    threadStates(i).execDone := (threadStates(i).execValids.asUInt | (~threadStates(i).fuValids.asUInt)).andR
  )

  val fThreadEncoder = Module(new RREncode(NUM_THREADS))
  val fThread = fThreadEncoder.io.chosen
  Range(0, NUM_THREADS, 1).map(i =>
    fThreadEncoder.io.valid(i) := (threadStates(i).execDone === true.B && threadStages(i) === ThreadStageEnum.exec))
  fThreadEncoder.io.ready := fThread =/= NONE_SELECTED

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
  val branchThread = RegInit(NONE_SELECTED)
  val branchThread_d0 = RegInit(NONE_SELECTED)
  branchThread := fThread
  branchThread_d0 := branchThread

  val threadMem_out = Wire(new ThreadMemT)
  val destMems_out = Wire(Vec(NUM_FUS, (new DestMemT)))
  val slctFU = Wire(Vec(NUM_FUS, UInt(2.W)))
  val destWbens_wb = Wire(Vec(NUM_FUS, UInt((REG_WIDTH/8).W)))
  val dests_wb = Wire(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  val destALane_wb = Wire(Vec(NUM_DST, UInt(NUM_FUS_LG.W)))
  val destBLane_wb = Wire(Vec(NUM_DST, UInt(NUM_FUS_LG.W)))
  val destAId_wb = Wire(Vec(NUM_DST, UInt(NUM_REGS_LG.W)))
  val destBId_wb = Wire(Vec(NUM_DST, UInt(NUM_REGS_LG.W)))
  val destAEn_wb = Wire(Vec(NUM_DST, Bool()))
  val destBEn_wb = Wire(Vec(NUM_DST, Bool()))
  val brTarget = Wire(Vec(NUM_BTS, UInt(IP_WIDTH.W)))

  for (i <- 0 until NUM_FUS) {
    destMems_out(i) := destMems(i).io.q.asTypeOf(new DestMemT)
    dests_wb(i) := destMems_out(i).dest
    destWbens_wb(i) := destMems_out(i).wben
    slctFU(i) := destMems_out(i).slctFU
  }

  threadMem_out := threadMem.io.q.asTypeOf(chiselTypeOf(threadMem_out))
  destALane_wb := threadMem_out.destALane
  destBLane_wb := threadMem_out.destBLane
  destAId_wb := threadMem_out.destAId
  destBId_wb := threadMem_out.destBId
  brTarget := threadMem_out.brTarget

  when (branchThread_d0 =/= NONE_SELECTED) {
    // writeback
    regfile.io.wrEn := true.B
    destAEn_wb := threadMem_out.destAEn
    destBEn_wb := threadMem_out.destBEn

    // branch
    when (threadStates(branchThread_d0).finish) {
      threadStates(branchThread_d0).ip := 0.U
    }
    .elsewhen (threadStates(branchThread_d0).branchFU) {
      when (slctFU(1) === 0.U) {
        threadStates(branchThread_d0).ip := threadStates(branchThread_d0).ip + brTarget(0)
      } .elsewhen (slctFU(1) === 1.U) {
        threadStates(branchThread_d0).ip := threadStates(branchThread_d0).ip + brTarget(1)
      } .otherwise {
        threadStates(branchThread_d0).ip := threadStates(branchThread_d0).ip + brTarget(2)
      }
    }
    .elsewhen (threadStates(branchThread_d0).preOpBranch) {
      threadStates(branchThread_d0).ip := threadStates(branchThread_d0).ip + brTarget(0)
    }
    .otherwise {
      threadStates(branchThread_d0).ip := threadStates(branchThread_d0).ip + 1.U
    }

    when (threadStates(branchThread_d0).finish) {
      threadStages(branchThread_d0) := ThreadStageEnum.idle
    }
    .otherwise {
      threadStages(branchThread_d0) := ThreadStageEnum.fetch
    }
  }
  .otherwise {
    regfile.io.wrEn := false.B
    destAEn_wb := VecInit(Seq.fill(NUM_DST)(false.B))
    destBEn_wb := VecInit(Seq.fill(NUM_DST)(false.B))
  }

  // delay 1 cycle
  regfile.io.thread_wr := branchThread_d0
  regfile.io.wrEn1 := destAEn_wb
  regfile.io.wrEn2 := destBEn_wb
  regfile.io.wrAddr1 := destAId_wb
  regfile.io.wrAddr2 := destBId_wb
  for (i <- 0 until NUM_DST) {
    regfile.io.wrBen1(i) := destWbens_wb(destALane_wb(i))
    regfile.io.wrBen2(i) := destWbens_wb(destBLane_wb(i))
    regfile.io.wrData1(i) := dests_wb(destALane_wb(i))
    regfile.io.wrData2(i) := dests_wb(destBLane_wb(i))
  }

}
