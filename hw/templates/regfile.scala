import chisel3._
import chisel3.util._
import chisel3.util.Fill
import chisel3.util.PriorityEncoder
import chisel3.experimental.ChiselEnum

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

class RegRead(conf: PrimateConfig) extends Module {
  val threadnum    = conf.NUM_THREADS
  val num_rd       = conf.NUM_RF_RD_PORTS
  val num_wr       = conf.NUM_RF_WR_PORTS
  val num_regs     = conf.NUM_REGS
  val reg_w        = conf.REG_WIDTH
  val num_blocks   = conf.NUM_REGBLOCKS
  val block_widths = conf.REG_BLOCK_WIDTH

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
          regfile(i).io.rdAddr1 := Cat(io.thread_rd(log2Up(threadnum)-1, log2Up(num_regfile)), io.rdAddr1(0))
          regfile(i).io.rdAddr2 := Cat(io.thread_rd(log2Up(threadnum)-1, log2Up(num_regfile)), io.rdAddr2(0))
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
    for (i <- 0 until num_rd-1) {
      val rdData1_vec = Reg(Vec(num_rd-1-i, UInt(reg_w.W)))
      val rdData2_vec = Reg(Vec(num_rd-1-i, UInt(reg_w.W)))
      val regfile_slct = Wire(UInt(log2Up(num_rd).W))
      regfile_slct := thread_rd_vec(1+i)(log2Up(num_regfile)-1, 0)
      rdData1_vec(0) := rdData1(regfile_slct)
      rdData2_vec(0) := rdData2(regfile_slct)
      if (i < num_rd-2) {
        for (j <- 1 until num_rd-1-i) {
          rdData1_vec(j) := rdData1_vec(j-1)
          rdData2_vec(j) := rdData2_vec(j-1)
        }
      }
      io.rdData1(i) := rdData1_vec(num_rd-2-i)
      io.rdData2(i) := rdData2_vec(num_rd-2-i)
    }
    val regfile_slct = Wire(UInt(log2Up(num_rd).W))
    regfile_slct := thread_rd_vec(num_rd)(log2Up(num_regfile)-1, 0)
    io.rdData1(num_rd-1) := rdData1(regfile_slct)
    io.rdData2(num_rd-1) := rdData2(regfile_slct)
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
        when (io.thread_wr(log2Up(num_regfile)-1, 0) === i.U) {
          regfile(i).io.wrAddr1 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr1(state_wr))
          regfile(i).io.wrAddr2 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr2(state_wr))
          regfile(i).io.wrBen1 := io.wrBen1(state_wr)
          regfile(i).io.wrBen2 := io.wrBen2(state_wr)
          regfile(i).io.wrEn1 := io.wrEn1(state_wr)
          regfile(i).io.wrEn2 := io.wrEn2(state_wr)
          regfile(i).io.wrData1 := io.wrData1(state_wr)
          regfile(i).io.wrData2 := io.wrData2(state_wr)
          when (io.wrEn) {
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
            printf("Writing to reg %x: %x\n", wrAddr1.asUInt, wrData1.asUInt)
            printf("Writing to reg %x: %x\n", wrAddr2.asUInt, wrData2.asUInt)
          }
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
        when (io.thread_wr(log2Up(num_regfile)-1, 0) === i.U) {
          regfile(i).io.wrAddr1 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr1(0))
          regfile(i).io.wrAddr2 := Cat(io.thread_wr(log2Up(threadnum)-1, log2Up(num_regfile)), io.wrAddr2(0))
          regfile(i).io.wrBen1 := io.wrBen1(0)
          regfile(i).io.wrBen2 := io.wrBen2(0)
          regfile(i).io.wrEn1 := io.wrEn1(0)
          regfile(i).io.wrEn2 := io.wrEn2(0)
          regfile(i).io.wrData1 := io.wrData1(0)
          regfile(i).io.wrData2 := io.wrData2(0)
          when (regfile(i).io.wrEn1) {
            printf("Writing to reg %x: %x\n", regfile(i).io.wrAddr1.asUInt, regfile(i).io.wrData1.asUInt)
          }
          when (regfile(i).io.wrEn2) {
            printf("Writing to reg %x: %x\n", regfile(i).io.wrAddr2.asUInt, regfile(i).io.wrData2.asUInt)
          }
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