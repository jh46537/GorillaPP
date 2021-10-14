import chisel3._
import chisel3.util._
import chisel3.util.Fill
import chisel3.experimental.ChiselEnum
import chisel3.util.experimental.loadMemoryFromFileInline

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class Gather(imm_pos: Int) extends Module {
  val io = IO(new Bundle {
    val dinA = Input(UInt(270.W))
    val dinB = Input(UInt(270.W))
    val slct = Input(UInt(1.W))
    val shift = Input(UInt(5.W))
    val mode = Input(UInt(4.W))
    val imm = Input(UInt(16.W))
    val sign_out = Output(UInt(1.W))
    val dout = Output(UInt(270.W))
  })

  val reg00 = Reg(UInt(64.W))
  val reg01 = Reg(UInt(64.W))
  val reg02 = Reg(UInt(64.W))
  val reg03 = Reg(UInt(64.W))
  val din_d0 = Reg(UInt(270.W))
  val shift_d0 = Reg(UInt(5.W))
  val mode_d0 = Reg(UInt(4.W))
  val imm_d0 = Reg(UInt(16.W))
  val din = Wire(UInt(270.W))

  when (io.slct === 0.U) {
    din := io.dinA
  } .otherwise {
    din := io.dinB
  }

  din_d0 := din
  shift_d0 := io.shift
  mode_d0 := io.mode
  imm_d0 := io.imm
  switch(io.shift(2, 0)) {
    is (0.U) {
      reg00 := din(63, 0)
    }
    is (1.U) {
      reg00 := din(71, 8)
    }
    is (2.U) {
      reg00 := din(159, 96)
    }
    is (3.U) {
      reg00 := din(167, 104)
    }
    is (4.U) {
      reg00 := din(171, 108)
    }
    is (5.U) {
      reg00 := din(183, 120)
    }
    is (6.U) {
      reg00 := din(191, 128)
    }
    is (7.U) {
      reg00 := din(195, 132)
    }
  }
  switch(io.shift(2, 0)) {
    is (0.U) {
      reg01 := din(199, 136)
    }
    is (1.U) {
      reg01 := din(200, 137)
    }
    is (2.U) {
      reg01 := din(201, 138)
    }
    is (3.U) {
      reg01 := din(211, 148)
    }
    is (4.U) {
      reg01 := din(215, 152)
    }
    is (5.U) {
      reg01 := din(225, 162)
    }
    is (6.U) {
      reg01 := din(231, 168)
    }
    is (7.U) {
      reg01 := din(236, 173)
    }
  }
  switch(io.shift(2, 0)) {
    is (0.U) {
      reg02 := din(245, 182)
    }
    is (1.U) {
      reg02 := din(254, 191)
    }
    is (2.U) {
      reg02 := din(257, 194)
    }
    is (3.U) {
      reg02 := din(259, 196)
    }
    is (4.U) {
      reg02 := din(267, 204)
    }
    is (5.U) {
      reg02 := din(269, 216)
    }
    is (6.U) {
      reg02 := din(269, 228)
    }
    is (7.U) {
      reg02 := din(269, 240)
    }
  }
  switch(io.shift(2, 0)) {
    is (0.U) {
      reg03 := din(269, 252)
    }
    is (1.U) {
      reg03 := din(269, 261)
    }
  }

  val reg1 = Reg(UInt(64.W))
  val din_d1 = Reg(UInt(270.W))
  val mode_d1 = Reg(UInt(4.W))
  val imm_d1 = Reg(UInt(16.W))

  din_d1 := din_d0
  mode_d1 := mode_d0
  imm_d1 := imm_d0
  switch(shift_d0(4, 3)) {
    is (0.U) {
      reg1 := reg00
    }
    is (1.U) {
      reg1 := reg01
    }
    is (2.U) {
      reg1 := reg02
    }
    is (3.U) {
      reg1 := reg03
    }
  }

  val reg2 = Reg(UInt(64.W))
  val din_d2 = Reg(UInt(270.W))
  din_d2 := din_d1
  switch(mode_d1) {
    is(0.U) {
      // uint1
      reg2 := Cat(0.U, reg1(0, 0))
    }
    is(1.U) {
      // uint2
      reg2 := Cat(0.U, reg1(1, 0))
    }
    is(2.U) {
      // uint3
      reg2 := Cat(0.U, reg1(2, 0))
    }
    is(3.U) {
      // uint5
      reg2 := Cat(0.U, reg1(4, 0))
    }
    is(4.U) {
      // uint6
      reg2 := Cat(0.U, reg1(5, 0))
    }
    is(5.U) {
      // uint8
      reg2 := Cat(0.U, reg1(7, 0))
    }
    is(6.U) {
      // uint9
      reg2 := Cat(0.U, reg1(8, 0))
    }
    is(7.U) {
      // uint10
      reg2 := Cat(0.U, reg1(9, 0))
    }
    is(8.U) {
      // uint12
      reg2 := Cat(0.U, reg1(11, 0))
    }
    is(9.U) {
      // uint16
      reg2 := Cat(0.U, reg1(15, 0))
    }
    is(10.U) {
      // uint32
      reg2 := Cat(0.U, reg1(31, 0))
    }
    is(11.U) {
      // uint56
      reg2 := Cat(0.U, reg1(55, 0))
    }
    is(13.U) {
      //uint
      reg2 := reg1
    }
    is(14.U) {
      // uimm8
      reg2 := Cat(0.U, imm_d1(imm_pos*8+7, imm_pos*8))
    }
    is(15.U) {
      // uimm16
      reg2 := Cat(0.U, imm_d1)
    }
  }
  io.dout := Cat(din_d2(269, 64), reg2(63, 0))
  io.sign_out := 0.U
}

class Scatter extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(270.W))
    val shift = Input(UInt(5.W))
    val mode = Input(UInt(4.W))
    val wren = Output(UInt(16.W))
    val dout = Output(UInt(270.W))
  })
  val dout_vec = Reg(Vec(16, UInt(8.W)))
  val wren_vec = Reg(Vec(16, Bool()))
  val din_w = Wire(UInt(64.W))
  val dout_r = Reg(UInt(270.W))
  val wren_r = Reg(UInt(16.W))
  din_w := io.din(63, 0)
  // 0, 96, 104, 128, 136, 137, 138, 148, 191, 194, 204, 236, 252, 261, 270
  when (io.shift === 0.U) {
    dout_r := io.din
    when (io.mode === 10.U) {
      wren_r := 0x1.U
    } .otherwise {
      wren_r := 0xffff.U
    }
  } .elsewhen (io.shift === 2.U) {
    dout_r := Cat(0.U(110.W), din_w, 0.U(96.W))
    wren_r := 0x6.U
  } .elsewhen (io.shift === 3.U) {
    dout_r := Cat(0.U(102.W), din_w, 0.U(104.W))
    wren_r := 0xc.U
  } .elsewhen (io.shift === 6.U) {
    dout_r := Cat(0.U(78.W), din_w, 0.U(128.W))
    wren_r := 0x18.U
  } .elsewhen (io.shift === 10.U) {
    dout_r := Cat(0.U(68.W), din_w, 0.U(138.W))
    wren_r := 0x40.U
  } .elsewhen (io.shift === 17.U) {
    dout_r := Cat(0.U(15.W), din_w, 0.U(191.W))
    wren_r := 0x100.U
  } .elsewhen (io.shift === 20.U) {
    dout_r := Cat(0.U(2.W), din_w, 0.U(204.W))
    wren_r := 0x400.U
  } .elsewhen (io.shift === 24.U) {
    dout_r := Cat(din_w(17, 0), 0.U(252.W))
    wren_r := 0x1000.U
  } .elsewhen (io.shift === 25.U) {
    dout_r := Cat(din_w(8, 0), 0.U(261.W))
    wren_r := 0x2000.U
  }
  io.dout := dout_r
  io.wren := wren_r
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

class Regfile(num: Int, width: Int) extends Module {
  val io = IO(new Bundle {
    val rdAddr1 = Input(UInt(log2Up(num).W))
    val rdAddr2 = Input(UInt(log2Up(num).W))
    val rdData1 = Output(UInt(width.W))
    val rdData2 = Output(UInt(width.W))

    val wrEn1   = Input(Bool())
    val wrEn2   = Input(Bool())
    val wrBen1  = Input(UInt(16.W))
    val wrBen2  = Input(UInt(16.W))
    val wrAddr1 = Input(UInt(log2Up(num).W))
    val wrAddr2 = Input(UInt(log2Up(num).W))
    val wrData1 = Input(UInt(width.W))
    val wrData2 = Input(UInt(width.W))
  })

  val rdAddr1_reg = Reg(UInt(log2Up(num).W))
  val rdAddr2_reg = Reg(UInt(log2Up(num).W))
  val mem = Reg(Vec(num, MixedVec(
    UInt(96.W), UInt(8.W), UInt(24.W), UInt(8.W), 
    UInt(1.W), UInt(1.W), UInt(10.W), UInt(43.W),
    UInt(3.W), UInt(10.W), UInt(32.W), UInt(16.W),
    UInt(9.W), UInt(9.W))))

  rdAddr1_reg := io.rdAddr1
  rdAddr2_reg := io.rdAddr2

  io.rdData1 := RegNext(mem(rdAddr1_reg).asUInt)
  io.rdData2 := RegNext(mem(rdAddr2_reg).asUInt)

  when (io.wrEn1) {
    when (io.wrBen1(0) === 1.U) {
      mem(io.wrAddr1)(0) := io.wrData1(95, 0)
    }
    when (io.wrBen1(1) === 1.U) {
      mem(io.wrAddr1)(1) := io.wrData1(103, 96)
    }
    when (io.wrBen1(2) === 1.U) {
      mem(io.wrAddr1)(2) := io.wrData1(127, 104)
    }
    when (io.wrBen1(3) === 1.U) {
      mem(io.wrAddr1)(3) := io.wrData1(135, 128)
    }
    when (io.wrBen1(4) === 1.U) {
      mem(io.wrAddr1)(4) := io.wrData1(136, 136)
    }
    when (io.wrBen1(5) === 1.U) {
      mem(io.wrAddr1)(5) := io.wrData1(137, 137)
    }
    when (io.wrBen1(6) === 1.U) {
      mem(io.wrAddr1)(6) := io.wrData1(147, 138)
    }
    when (io.wrBen1(7) === 1.U) {
      mem(io.wrAddr1)(7) := io.wrData1(190, 148)
    }
    when (io.wrBen1(8) === 1.U) {
      mem(io.wrAddr1)(8) := io.wrData1(193, 191)
    }
    when (io.wrBen1(9) === 1.U) {
      mem(io.wrAddr1)(9) := io.wrData1(203, 194)
    }
    when (io.wrBen1(10) === 1.U) {
      mem(io.wrAddr1)(10) := io.wrData1(235, 204)
    }
    when (io.wrBen1(11) === 1.U) {
      mem(io.wrAddr1)(11) := io.wrData1(251, 236)
    }
    when (io.wrBen1(12) === 1.U) {
      mem(io.wrAddr1)(12) := io.wrData1(260, 252)
    }
    when (io.wrBen1(13) === 1.U) {
      mem(io.wrAddr1)(13) := io.wrData1(269, 261)
    }
  }

  when (io.wrEn2) {
    when (io.wrBen2(0) === 1.U) {
      mem(io.wrAddr2)(0) := io.wrData2(95, 0)
    }
    when (io.wrBen2(1) === 1.U) {
      mem(io.wrAddr2)(1) := io.wrData2(103, 96)
    }
    when (io.wrBen2(2) === 1.U) {
      mem(io.wrAddr2)(2) := io.wrData2(127, 104)
    }
    when (io.wrBen2(3) === 1.U) {
      mem(io.wrAddr2)(3) := io.wrData2(135, 128)
    }
    when (io.wrBen2(4) === 1.U) {
      mem(io.wrAddr2)(4) := io.wrData2(136, 136)
    }
    when (io.wrBen2(5) === 1.U) {
      mem(io.wrAddr2)(5) := io.wrData2(137, 137)
    }
    when (io.wrBen2(6) === 1.U) {
      mem(io.wrAddr2)(6) := io.wrData2(147, 138)
    }
    when (io.wrBen2(7) === 1.U) {
      mem(io.wrAddr2)(7) := io.wrData2(190, 148)
    }
    when (io.wrBen2(8) === 1.U) {
      mem(io.wrAddr2)(8) := io.wrData2(193, 191)
    }
    when (io.wrBen2(9) === 1.U) {
      mem(io.wrAddr2)(9) := io.wrData2(203, 194)
    }
    when (io.wrBen2(10) === 1.U) {
      mem(io.wrAddr2)(10) := io.wrData2(235, 204)
    }
    when (io.wrBen2(11) === 1.U) {
      mem(io.wrAddr2)(11) := io.wrData2(251, 236)
    }
    when (io.wrBen2(12) === 1.U) {
      mem(io.wrAddr2)(12) := io.wrData2(260, 252)
    }
    when (io.wrBen2(13) === 1.U) {
      mem(io.wrAddr2)(13) := io.wrData2(269, 261)
    }
  }
}

class Fetch(num: Int, ipWidth: Int, instrWidth: Int) extends Module {
  val io = IO(new Bundle {
    val ips         = Input(Vec(num, UInt(ipWidth.W)))
    val ipValids    = Input(Vec(num, UInt(log2Up(num).W)))
    val instrs      = Output(Vec(num, UInt(instrWidth.W)))
    val instrReadys = Output(Vec(num, UInt(instrWidth.W)))
  })

  // FIXME: implement i$

  var mem_array = Array.fill[UInt](1 << ipWidth)(0.U(instrWidth.W))
  mem_array(0)  = "h000000000000a301004008741ba0043a0dd00207".U
  mem_array(1)  = "h0000000011020502100000b41b4004340e500252".U
  mem_array(2)  = "h00000000021f0100000000341ba004251de00201".U
  mem_array(3)  = "h0000001000020000000000281d2044b40e604255".U
  mem_array(4)  = "h00000000001d0100000000341ba004251de00201".U
  mem_array(5)  = "h00000000001d0000020000341ba004340e306242".U
  mem_array(6)  = "h00000000000b000020000028154004340aa10e52".U
  mem_array(7)  = "h00000000000515000240081b14c034140e702a52".U
  mem_array(8)  = "h0000000401030000000000281cc085540e6042a5".U
  mem_array(9)  = "h0000000000001102001004341ba0043429a40c20".U
  mem_array(10) = "h0000000000000000200201341ba0043a0dd00209".U
  mem_array(11) = "h0000000000000000200301341ba0043a0dd00209".U
  mem_array(12) = "h0000000000008f430014062814c0c41409a40c20".U
  mem_array(13) = "h0000000000fc0000340000341ba004340aa18252".U
  mem_array(14) = "h0000000000011500304008341ba0061a0dd00208".U
  mem_array(15) = "h0000000001fdb32232500c18cdb8042eae702a32".U
  mem_array(16) = "h0000000000f80000000000341ba0043a0dd00201".U
  mem_array(17) = "h000000000002000020000028154004340aa10e82".U
  mem_array(18) = "h00000000010f1100001004341ba004251de00201".U
  mem_array(19) = "h0000000000008f64201006341ba0040e07d50210".U
  mem_array(20) = "h000000000002af5302440a181ac0341a0e702a52".U
  mem_array(21) = "h00000000000a1102041004341ba0042c6d600201".U
  mem_array(22) = "h00000000000200003000002815a3043409a40c26".U
  mem_array(23) = "h0000000000081102541806340cc0058c6d600201".U
  mem_array(24) = "h0000000000fa00000300002815a3043409a40c26".U
  mem_array(25) = "h0000000001028f67361406340db8042e0e700232".U
  mem_array(26) = "h0000000000050000450802340cc0059a0dd00201".U
  mem_array(27) = "h00000000000300007000002815a3043409a40c26".U
  mem_array(28) = "h0000000000000000340802340cd8059a0dd00200".U
  mem_array(29) = "h0000000000020000450802340cc0059a0dd00201".U
  mem_array(30) = "h0000000000fab33573500c341ba0042d8d606201".U
  mem_array(31) = "h0000000001001102021004341ba0040eae702a20".U
  mem_array(32) = "h0000000000000000020201341ba0041a0dd0020a".U
  mem_array(33) = "h0000000000010000000000341ba0043a0dd00209".U
  mem_array(34) = "h0000000401ff0000000000281cc085540e6042a5".U
  mem_array(35) = "h00000001020215010040082a9d401c540e6042a2".U
  mem_array(36) = "h000000000000b31100500c2a93481856bdb04e00".U
  mem_array(37) = "h0000000000000000100101341ba0043a0dd00209".U

  val mem = RegInit(VecInit(mem_array.toSeq))
  //val mem = SyncReadMem(1 << ipWidth, UInt(instrWidth.W))
  //loadMemoryFromFileInline(mem, "../assembler/npu.bin")

  for (i <- 0 to num - 1) {
    io.instrs(i) := mem(io.ips(i))
    io.instrReadys(i) := io.ipValids(i)
  }
}

class aluInstBundle(num_aluops_lg: Int, num_srcs: Int) extends Bundle {
  val dstMode = UInt(4.W)
  val dstShiftL = UInt(5.W)
  val srcMode = Vec(num_srcs, UInt(4.W))
  val srcShiftR = Vec(num_srcs, UInt(5.W))
  val srcSlct = Vec(num_srcs, UInt(1.W))
  val aluOp = UInt(num_aluops_lg.W)
  override def cloneType = (new aluInstBundle(num_aluops_lg, num_srcs)).asInstanceOf[this.type]
}

class Decode(instrWidth: Int, num_regs_lg: Int, num_aluops_lg: Int, num_fus: Int, num_fuops_lg: Int, num_preops_lg: Int, ip_width: Int, imm_width: Int) extends Module {
  val io = IO(new Bundle {
    val instr     = Input(UInt(instrWidth.W))

    val imm       = Output(UInt(imm_width.W))
    val srcAId    = Output(UInt(num_regs_lg.W))
    val srcBId    = Output(UInt(num_regs_lg.W))
    val destAEn   = Output(Bool())
    val destBEn   = Output(Bool())
    val destAId   = Output(UInt(num_regs_lg.W))
    val destBId   = Output(UInt(num_regs_lg.W))
    val destALane = Output(UInt(log2Up(num_fus).W))
    val destBLane = Output(UInt(log2Up(num_fus).W))
    val preOp     = Output(UInt(num_preops_lg.W))
    val fuOps     = Output(Vec(num_fus, UInt(num_fuops_lg.W)))
    val fuValids  = Output(Vec(num_fus, Bool()))
    // val brMask    = Output(Vec(num_fus + 1, Bool()))
    val brTarget  = Output(UInt(ip_width.W))
    val aluInstB  = Output(new aluInstBundle(num_aluops_lg, 2))
    val aluInstA  = Output(new aluInstBundle(num_aluops_lg, 2)) // 3
  })

  val PREOP_LOW = 0
  val PREOP_HIGH = PREOP_LOW + num_preops_lg - 1
  val ALUINSTA_LOW = PREOP_HIGH + 1
  val ALUINSTA_HIGH = ALUINSTA_LOW + (num_aluops_lg + 2*10 + 9) - 1
  val ALUINSTB_LOW = ALUINSTA_HIGH + 1
  val ALUINSTB_HIGH = ALUINSTB_LOW + (num_aluops_lg + 2*10 + 9) - 1
  val FUVALIDS_LOW = ALUINSTB_HIGH + 1
  val FUVALIDS_HIGH = FUVALIDS_LOW + num_fus - 1
  val FUOPS_LOW = FUVALIDS_HIGH + 1
  val FUOPS_HIGH = FUOPS_LOW + num_fus * num_fuops_lg - 1
  val SRCAID_LOW = FUOPS_HIGH + 1
  val SRCAID_HIGH = SRCAID_LOW + num_regs_lg - 1
  val SRCBID_LOW = SRCAID_HIGH + 1
  val SRCBID_HIGH = SRCBID_LOW + num_regs_lg - 1
  val DESTAID_LOW = SRCBID_HIGH + 1
  val DESTAID_HIGH = DESTAID_LOW + num_regs_lg - 1
  val DESTBID_LOW = DESTAID_HIGH + 1
  val DESTBID_HIGH = DESTBID_LOW + num_regs_lg - 1
  val DESTAEN_POS = DESTBID_HIGH + 1
  val DESTBEN_POS = DESTAEN_POS + 1
  val DESTALANE_LOW = DESTBEN_POS + 1
  val DESTALANE_HIGH = DESTALANE_LOW + log2Up(num_fus) - 1
  val DESTBLANE_LOW = DESTALANE_HIGH + 1
  val DESTBLANE_HIGH = DESTBLANE_LOW + log2Up(num_fus) - 1
  val BRTARGET_LOW = DESTBLANE_HIGH + 1
  val BRTARGET_HIGH = BRTARGET_LOW + ip_width - 1
  val IMM_LOW = BRTARGET_HIGH + 1
  val IMM_HIGH = IMM_LOW + imm_width - 1

  io.imm       := io.instr(IMM_HIGH, IMM_LOW)
  io.brTarget  := io.instr(BRTARGET_HIGH, BRTARGET_LOW)
  io.destBLane := io.instr(DESTBLANE_HIGH, DESTBLANE_LOW)
  io.destALane := io.instr(DESTALANE_HIGH, DESTALANE_LOW)
  // io.brMask    := io.instr( 13,   8).asBools
  io.destBEn   := io.instr(DESTBEN_POS, DESTBEN_POS)
  io.destAEn   := io.instr(DESTAEN_POS, DESTAEN_POS)
  io.destBId   := io.instr(DESTBID_HIGH, DESTBID_LOW)
  io.destAId   := io.instr(DESTAID_HIGH, DESTAID_LOW)
  io.srcBId    := io.instr(SRCBID_HIGH, SRCBID_LOW)
  io.srcAId    := io.instr(SRCAID_HIGH, SRCAID_LOW)
  io.fuOps     := io.instr(FUOPS_HIGH, FUOPS_LOW).asTypeOf(chiselTypeOf(io.fuOps))
  io.fuValids  := io.instr(FUVALIDS_HIGH, FUVALIDS_LOW).asBools
  io.aluInstB  := io.instr(ALUINSTB_HIGH, ALUINSTB_LOW).asTypeOf(chiselTypeOf(io.aluInstB))
  io.aluInstA  := io.instr(ALUINSTA_HIGH, ALUINSTA_LOW).asTypeOf(chiselTypeOf(io.aluInstA))
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
    val ch1_insert_stall      = Output(Bool())

    val rst                   = Input(Reset())
    val clk                   = Input(Clock())
  })

  addResource("/flow_table_wrap.sv")

}

class flowTable(tag_width: Int) extends Module {
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

  val ch0_tag_reg = Reg(UInt(tag_width.W))
  val ch1_tag_reg = Reg(UInt(tag_width.W))

  val ft_inst = Module(new flowTableV)

  ft_inst.io.clk := clock
  ft_inst.io.rst := reset

  when (io.ch0_req_valid) {
    ft_inst.io.ch0_rden := true.B
  } .otherwise {
    ft_inst.io.ch0_rden := false.B
  }

  when (io.ch1_req_valid) {
    ft_inst.io.ch1_wren := true.B
  } .otherwise {
    ft_inst.io.ch1_wren := false.B
  }

  when (io.ch0_req_valid && !(ft_inst.io.ch0_rd_stall)) {
    ch0_tag_reg := io.ch0_req_tag
  }

  when (io.ch1_req_valid && !(ft_inst.io.ch1_insert_stall)) {
    ch1_tag_reg := io.ch1_req_tag
  }

  ft_inst.io.ch0_meta_tuple_sIP := io.ch0_req_data.ch0_meta.tuple.sIP
  ft_inst.io.ch0_meta_tuple_dIP := io.ch0_req_data.ch0_meta.tuple.dIP
  ft_inst.io.ch0_meta_tuple_sPort := io.ch0_req_data.ch0_meta.tuple.sPort
  ft_inst.io.ch0_meta_tuple_dPort := io.ch0_req_data.ch0_meta.tuple.dPort
  ft_inst.io.ch0_meta_addr0 := io.ch0_req_data.ch0_meta.addr0
  ft_inst.io.ch0_meta_addr1 := io.ch0_req_data.ch0_meta.addr1
  ft_inst.io.ch0_meta_addr2 := io.ch0_req_data.ch0_meta.addr2
  ft_inst.io.ch0_meta_addr3 := io.ch0_req_data.ch0_meta.addr3
  ft_inst.io.ch0_meta_opcode := io.ch0_req_data.ch0_opcode
  io.ch0_rep_tag := ch0_tag_reg
  io.ch0_rep_valid := ft_inst.io.ch0_rd_valid
  io.ch0_req_ready := !(ft_inst.io.ch0_rd_stall)
  io.ch0_rep_data.ch0_bit_map := ft_inst.io.ch0_bit_map
  io.ch0_rep_data.ch0_q.tuple.sIP := ft_inst.io.ch0_q_tuple_sIP
  io.ch0_rep_data.ch0_q.tuple.dIP := ft_inst.io.ch0_q_tuple_dIP
  io.ch0_rep_data.ch0_q.tuple.sPort := ft_inst.io.ch0_q_tuple_sPort
  io.ch0_rep_data.ch0_q.tuple.dPort := ft_inst.io.ch0_q_tuple_dPort
  io.ch0_rep_data.ch0_q.seq := ft_inst.io.ch0_q_seq
  io.ch0_rep_data.ch0_q.pointer := ft_inst.io.ch0_q_pointer
  io.ch0_rep_data.ch0_q.ll_valid := ft_inst.io.ch0_q_ll_valid
  io.ch0_rep_data.ch0_q.slow_cnt := ft_inst.io.ch0_q_slow_cnt
  io.ch0_rep_data.ch0_q.last_7_bytes := ft_inst.io.ch0_q_last_7_bytes
  io.ch0_rep_data.ch0_q.addr0 := ft_inst.io.ch0_q_addr0
  io.ch0_rep_data.ch0_q.addr1 := ft_inst.io.ch0_q_addr1
  io.ch0_rep_data.ch0_q.addr2 := ft_inst.io.ch0_q_addr2
  io.ch0_rep_data.ch0_q.addr3 := ft_inst.io.ch0_q_addr3

  when (io.ch1_req_data.ch1_opcode === 3.U) {
    ft_inst.io.ch1_data_valid := false.B
  } .otherwise {
    ft_inst.io.ch1_data_valid := true.B
  }
  ft_inst.io.ch1_opcode := io.ch1_req_data.ch1_opcode
  when (io.ch1_req_data.ch1_opcode === 1.U) {
    val fce_meta = Wire(new ftInsert_t)
    fce_meta := io.ch1_req_data.asUInt.asTypeOf(new ftInsert_t)
    ft_inst.io.ch1_bit_map := 16.U
    ft_inst.io.ch1_data_tuple_sIP := fce_meta.tuple.sIP
    ft_inst.io.ch1_data_tuple_dIP := fce_meta.tuple.dIP
    ft_inst.io.ch1_data_tuple_sPort := fce_meta.tuple.sPort
    ft_inst.io.ch1_data_tuple_dPort := fce_meta.tuple.dPort
    ft_inst.io.ch1_data_seq := fce_meta.seq
    ft_inst.io.ch1_data_pointer := 0.U
    ft_inst.io.ch1_data_ll_valid := 0.U
    ft_inst.io.ch1_data_slow_cnt := 0.U
    ft_inst.io.ch1_data_last_7_bytes := fce_meta.last_7_bytes
    ft_inst.io.ch1_data_addr0 := fce_meta.addr0
    ft_inst.io.ch1_data_addr1 := fce_meta.addr1
    ft_inst.io.ch1_data_addr2 := fce_meta.addr2
    ft_inst.io.ch1_data_addr3 := fce_meta.addr3
  } .otherwise {
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
  }
  io.ch1_req_ready := !(ft_inst.io.ch1_insert_stall)
  io.ch1_rep_tag := ch1_tag_reg
  io.ch1_rep_valid := RegNext(io.ch1_req_valid && !(ft_inst.io.ch1_insert_stall))
  io.ch1_rep_data := 0.U

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
  val VLIW_OPS = 2
  val NUM_PREOPS = 11
  val NUM_PREOPS_LG = log2Up(NUM_PREOPS)
  val IMM_WIDTH = 16
  val NUM_ALUOPS_LG = 4
  val NUM_ALUS = 2
  // FIXME
  //val BR_INSTR_WIDTH = 8
  //val INSTR_WIDTH = NUM_PREOPS_LG + VLIW_OPS * (NUM_FUS_LG + 2 * NUM_REGS_LG) + BR_INSTR_WIDTH
  val IP_WIDTH = 8
  val INSTR_WIDTH = NUM_PREOPS_LG + NUM_ALUS * (NUM_ALUOPS_LG + VLIW_OPS * 10 + 9) + VLIW_OPS * (NUM_FUS_LG + 2 * NUM_REGS_LG + 1) + NUM_FUS * (1 + NUM_FUOPS_LG) + IP_WIDTH + IMM_WIDTH
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
  val flowTablePort = Module(new flowTable(TAGWIDTH))
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
    val output      = new metadata_t

    val ip          = UInt(IP_WIDTH.W)
    val instr       = UInt(INSTR_WIDTH.W)
    val instrReady  = Bool()

    val imm         = UInt(IMM_WIDTH.W)
    val srcAId      = UInt(NUM_REGS_LG.W)
    val srcBId      = UInt(NUM_REGS_LG.W)
    val destAEn     = Bool()
    val destBEn     = Bool()
    val destAId     = UInt(NUM_REGS_LG.W)
    val destBId     = UInt(NUM_REGS_LG.W)
    val destALane   = UInt(NUM_FUS_LG.W)
    val destBLane   = UInt(NUM_FUS_LG.W)
    val aluInstA    = new aluInstBundle(NUM_ALUOPS_LG, VLIW_OPS)
    val aluInstB    = new aluInstBundle(NUM_ALUOPS_LG, VLIW_OPS)
    val preOp       = UInt(NUM_PREOPS_LG.W)
    val fuOps       = Vec(NUM_FUS, UInt(NUM_FUOPS_LG.W))
    val fuValids    = Vec(NUM_FUS, Bool())
    // val brMask      = Vec(NUM_FUS + 1, Bool())
    val brTarget    = UInt(IP_WIDTH.W)

    val srcA        = UInt(REG_WIDTH.W)
    val srcB        = UInt(REG_WIDTH.W)

    val preOpBranch = Bool()
    val preOpA      = UInt(REG_WIDTH.W)
    val preOpB      = UInt(REG_WIDTH.W)

    val wbens       = Vec(NUM_FUS, UInt(16.W))
    val dests       = Vec(NUM_FUS, UInt(REG_WIDTH.W))
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
  val GS_INPUT       = 7.U
  val GS_OUTPUT      = 8.U
  val GS_OUTPUTRET   = 9.U
  val GS_RET         = 10.U

  val regfile = Module(new Regfile(NUM_REGS*NUM_THREADS, REG_WIDTH))

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
    when (in_bits_d0.len =/= 0.U) {
      threadStates(sThread_reg).input.pkt_flags := 2.U
    } .otherwise {
      threadStates(sThread_reg).input.pkt_flags := 0.U
    }
  }

  /****************** Fetch logic *********************************/
  val fetchUnit = Module(new Fetch(NUM_THREADS, IP_WIDTH, INSTR_WIDTH))
  for (i <- 0 to NUM_THREADS - 1) {
    fetchUnit.io.ips(i) := threadStates(i).ip
    fetchUnit.io.ipValids(i) := threadStages(i) === ThreadStageEnum.fetch
    threadStates(i).instr := fetchUnit.io.instrs(i)
    threadStates(i).instrReady := fetchUnit.io.instrReadys(i)
  }

  /****************** Scheduler logic *********************************/
  // select valid thread
  val vThreadEncoder = Module(new RREncode(NUM_THREADS))
  val vThread = vThreadEncoder.io.chosen
  Range(0, NUM_THREADS, 1).map(i =>
    vThreadEncoder.io.valid(i) := (threadStages(i) === ThreadStageEnum.fetch) && threadStates(i).instrReady)
  vThreadEncoder.io.ready := vThread =/= NONE_SELECTED

  when (vThread =/= NONE_SELECTED) {
      threadStages(vThread) := ThreadStageEnum.decode
  }

  /****************** Decode logic *********************************/
  val decodeThread = RegInit(NONE_SELECTED)
  decodeThread := vThread

  val decodeUnit = Module(new Decode(INSTR_WIDTH, NUM_REGS_LG, NUM_ALUOPS_LG, NUM_FUS, NUM_FUOPS_LG, NUM_PREOPS_LG, IP_WIDTH, IMM_WIDTH))
  when (decodeThread =/= NONE_SELECTED) {
    decodeUnit.io.instr                  := threadStates(decodeThread).instr
    threadStates(decodeThread).imm       := decodeUnit.io.imm
    threadStates(decodeThread).srcAId    := decodeUnit.io.srcAId
    threadStates(decodeThread).srcBId    := decodeUnit.io.srcBId
    threadStates(decodeThread).destAEn   := decodeUnit.io.destAEn
    threadStates(decodeThread).destBEn   := decodeUnit.io.destBEn
    threadStates(decodeThread).destAId   := decodeUnit.io.destAId
    threadStates(decodeThread).destBId   := decodeUnit.io.destBId
    threadStates(decodeThread).destALane := decodeUnit.io.destALane
    threadStates(decodeThread).destBLane := decodeUnit.io.destBLane
    threadStates(decodeThread).preOp     := decodeUnit.io.preOp
    threadStates(decodeThread).aluInstA  := decodeUnit.io.aluInstA
    threadStates(decodeThread).aluInstB  := decodeUnit.io.aluInstB
    threadStates(decodeThread).fuOps     := decodeUnit.io.fuOps
    threadStates(decodeThread).fuValids  := decodeUnit.io.fuValids
    // threadStates(decodeThread).brMask    := decodeUnit.io.brMask
    threadStates(decodeThread).brTarget  := decodeUnit.io.brTarget
    threadStates(decodeThread).execValids := VecInit(Seq.fill(NUM_FUS)(false.B))

    regfile.io.rdAddr1 := Cat(decodeThread, decodeUnit.io.srcAId)
    regfile.io.rdAddr2 := Cat(decodeThread, decodeUnit.io.srcBId)

    threadStages(decodeThread) := ThreadStageEnum.read
  }
  .otherwise {
    decodeUnit.io.instr                  := 0.U(INSTR_WIDTH.W)
    threadStates(decodeThread).srcAId    := DontCare
    threadStates(decodeThread).srcBId    := DontCare
    threadStates(decodeThread).destAEn   := DontCare
    threadStates(decodeThread).destBEn   := DontCare
    threadStates(decodeThread).destAId   := DontCare
    threadStates(decodeThread).destBId   := DontCare
    threadStates(decodeThread).destALane := DontCare
    threadStates(decodeThread).destBLane := DontCare
    threadStates(decodeThread).preOp     := DontCare
    threadStates(decodeThread).aluInstA  := DontCare
    threadStates(decodeThread).aluInstB  := DontCare
    threadStates(decodeThread).fuOps     := DontCare
    threadStates(decodeThread).fuValids  := DontCare
    // threadStates(decodeThread).brMask    := DontCare
    threadStates(decodeThread).brTarget  := DontCare
    threadStates(decodeThread).imm       := DontCare
    threadStates(decodeThread).execValids := DontCare

    regfile.io.rdAddr1 := DontCare
    regfile.io.rdAddr2 := DontCare
  }

  val alu0Op_d = Reg(UInt(NUM_ALUOPS_LG.W))
  val alu0A_slct = Reg(UInt(1.W))
  val alu0A_shift = Reg(UInt(5.W))
  val alu0A_mode = Reg(UInt(4.W))
  val alu0B_slct = Reg(UInt(1.W))
  val alu0B_shift = Reg(UInt(5.W))
  val alu0B_mode = Reg(UInt(4.W))
  val alu0_dstShift_d = Reg(UInt(5.W))
  val alu0_dstMode_d = Reg(UInt(4.W))
  val alu1Op_d = Reg(UInt(NUM_ALUOPS_LG.W))
  val alu1A_slct = Reg(UInt(1.W))
  val alu1A_shift = Reg(UInt(5.W))
  val alu1A_mode = Reg(UInt(4.W))
  val alu1B_slct = Reg(UInt(1.W))
  val alu1B_shift = Reg(UInt(5.W))
  val alu1B_mode = Reg(UInt(4.W))
  val alu1_dstShift_d = Reg(UInt(5.W))
  val alu1_dstMode_d = Reg(UInt(4.W))
  val alu_imm = Reg(UInt(16.W))
  val preOp_d = Reg(UInt(NUM_PREOPS_LG.W))
  alu0Op_d := decodeUnit.io.aluInstA.aluOp
  alu0A_slct := decodeUnit.io.aluInstA.srcSlct(0)
  alu0A_shift := decodeUnit.io.aluInstA.srcShiftR(0)
  alu0A_mode := decodeUnit.io.aluInstA.srcMode(0)
  alu0B_slct := decodeUnit.io.aluInstA.srcSlct(1)
  alu0B_shift := decodeUnit.io.aluInstA.srcShiftR(1)
  alu0B_mode := decodeUnit.io.aluInstA.srcMode(1)
  alu0_dstShift_d := decodeUnit.io.aluInstA.dstShiftL
  alu0_dstMode_d := decodeUnit.io.aluInstA.dstMode
  alu1Op_d := decodeUnit.io.aluInstB.aluOp
  alu1A_slct := decodeUnit.io.aluInstB.srcSlct(0)
  alu1A_shift := decodeUnit.io.aluInstB.srcShiftR(0)
  alu1A_mode := decodeUnit.io.aluInstB.srcMode(0)
  alu1B_slct := decodeUnit.io.aluInstB.srcSlct(1)
  alu1B_shift := decodeUnit.io.aluInstB.srcShiftR(1)
  alu1B_mode := decodeUnit.io.aluInstB.srcMode(1)
  alu1_dstShift_d := decodeUnit.io.aluInstB.dstShiftL
  alu1_dstMode_d := decodeUnit.io.aluInstB.dstMode
  alu_imm := decodeUnit.io.imm
  preOp_d := decodeUnit.io.preOp

  /************************* Register read  *******************************/
  val REG_DELAY = 4
  val readThread_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(NONE_SELECTED)))
  val alu0Op_vec = Reg(Vec(REG_DELAY, UInt(NUM_ALUOPS_LG.W)))
  val alu1Op_vec = Reg(Vec(REG_DELAY, UInt(NUM_ALUOPS_LG.W)))
  val preOp_vec = Reg(Vec(REG_DELAY, UInt(NUM_PREOPS_LG.W)))
  val alu0DstShift_vec = Reg(Vec(REG_DELAY+1, UInt(5.W)))
  val alu0DstMode_vec = Reg(Vec(REG_DELAY+1, UInt(4.W)))
  val alu1DstShift_vec = Reg(Vec(REG_DELAY+1, UInt(5.W)))
  val alu1DstMode_vec = Reg(Vec(REG_DELAY+1, UInt(4.W)))
  readThread_vec(REG_DELAY-1) := decodeThread
  alu0Op_vec(REG_DELAY-1) := alu0Op_d
  alu1Op_vec(REG_DELAY-1) := alu1Op_d
  preOp_vec(REG_DELAY-1) := preOp_d
  alu0DstShift_vec(REG_DELAY-1) := alu0_dstShift_d
  alu0DstMode_vec(REG_DELAY-1) := alu0_dstMode_d
  alu1DstShift_vec(REG_DELAY-1) := alu1_dstShift_d
  alu1DstMode_vec(REG_DELAY-1) := alu1_dstMode_d
  var i = 0
  for (i <- 0 until REG_DELAY-1) {
    readThread_vec(i) := readThread_vec(i+1)
    alu0Op_vec(i) := alu0Op_vec(i+1)
    alu1Op_vec(i) := alu1Op_vec(i+1)
    preOp_vec(i) := preOp_vec(i+1)
    alu0DstShift_vec(i) := alu0DstShift_vec(i+1)
    alu0DstMode_vec(i) := alu0DstMode_vec(i+1)
    alu1DstShift_vec(i) := alu1DstShift_vec(i+1)
    alu1DstMode_vec(i) := alu1DstMode_vec(i+1)
  }

  when (readThread_vec(0) =/= NONE_SELECTED) {
    threadStages(readThread_vec(0)) := ThreadStageEnum.pre
  }

  val srcA = Wire(UInt(REG_WIDTH.W))
  val srcB = Wire(UInt(REG_WIDTH.W))
  srcA := regfile.io.rdData1
  srcB := regfile.io.rdData2

  val gather_alu0A = Module(new Gather(0))
  val gather_alu0B = Module(new Gather(0))
  val gather_alu1A = Module(new Gather(1))
  val gather_alu1B = Module(new Gather(1))
  gather_alu0A.io.dinA := srcA
  gather_alu0A.io.dinB := srcB
  gather_alu0A.io.slct := RegNext(alu0A_slct)
  gather_alu0A.io.shift := RegNext(alu0A_shift)
  gather_alu0A.io.mode := RegNext(alu0A_mode)
  gather_alu0A.io.imm := RegNext(alu_imm)
  gather_alu0B.io.dinA := srcA
  gather_alu0B.io.dinB := srcB
  gather_alu0B.io.slct := RegNext(alu0B_slct)
  gather_alu0B.io.shift := RegNext(alu0B_shift)
  gather_alu0B.io.mode := RegNext(alu0B_mode)
  gather_alu0B.io.imm := RegNext(alu_imm)
  gather_alu1A.io.dinA := srcA
  gather_alu1A.io.dinB := srcB
  gather_alu1A.io.slct := RegNext(alu1A_slct)
  gather_alu1A.io.shift := RegNext(alu1A_shift)
  gather_alu1A.io.mode := RegNext(alu1A_mode)
  gather_alu1A.io.imm := RegNext(alu_imm)
  gather_alu1B.io.dinA := srcA
  gather_alu1B.io.dinB := srcB
  gather_alu1B.io.slct := RegNext(alu1B_slct)
  gather_alu1B.io.shift := RegNext(alu1B_shift)
  gather_alu1B.io.mode := RegNext(alu1B_mode)
  gather_alu1B.io.imm := RegNext(alu_imm)

  /****************** Pre logic *********************************/
  val preOpThread = RegInit(NONE_SELECTED)
  val preOp = Wire(UInt(NUM_PREOPS_LG.W))
  preOpThread := readThread_vec(0)
  preOp := preOp_vec(0)

  val alu0 = Module(new ALU(NUM_ALUOPS_LG, REG_WIDTH))
  val alu1 = Module(new ALU(NUM_ALUOPS_LG, REG_WIDTH))

  alu0.io.srcA := gather_alu0A.io.dout
  alu0.io.signA := gather_alu0A.io.sign_out
  alu0.io.srcB := gather_alu0B.io.dout
  alu0.io.signB := gather_alu0B.io.sign_out
  alu0.io.aluOp := alu0Op_vec(0)
  alu1.io.srcA := gather_alu1A.io.dout
  alu1.io.signA := gather_alu1A.io.sign_out
  alu1.io.srcB := gather_alu1B.io.dout
  alu1.io.signB := gather_alu1B.io.sign_out
  alu1.io.aluOp := alu1Op_vec(0)

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

  fuFifos_0.io.enq.valid := false.B
  fuFifos_0.io.enq.bits := DontCare
  fuFifos_1.io.enq.valid := false.B
  fuFifos_1.io.enq.bits := DontCare
  fuFifos_2.io.enq.valid := false.B
  fuFifos_2.io.enq.bits := DontCare
  fuFifos_3.io.enq.valid := false.B
  fuFifos_3.io.enq.bits := DontCare

  io.out.tag := DontCare
  io.out.bits := DontCare
  io.out.valid := false.B
  threadStates(preOpThread).finish := false.B

  val preOpA = Wire(UInt(REG_WIDTH.W))
  val preOpB = Wire(UInt(REG_WIDTH.W))

  preOpA := DontCare
  preOpB := DontCare

  when (preOpThread =/= NONE_SELECTED) {
    preOpA := alu0.io.dout
    preOpB := alu1.io.dout
    threadStates(preOpThread).preOpBranch := false.B

    when (preOp === GS_INPUT) {
      val input_u = Wire(UInt(252.W))
      // val shift_w = Wire(UInt(4.W))
      input_u := threadStates(preOpThread).input.asUInt
      // shift_w := threadStates(preOpThread).imm(3, 0)

      // val tmp = Wire(UInt(1152.W))
      // tmp := input_u >> ((4.U-shift_w)*256.U)

      // preOpA := tmp(255, 128)
      preOpB := input_u
    }

    .elsewhen (preOp === GS_BR) {
      threadStates(preOpThread).preOpBranch := true.B
    }

    .elsewhen (preOp === GS_ALUA) {
      threadStates(preOpThread).preOpBranch := (preOpA(31, 0) =/= 0.U)
    }

    .elsewhen (preOp === GS_ALUB) {
      threadStates(preOpThread).preOpBranch := (preOpB(31, 0) =/= 0.U)
    }

    .elsewhen (preOp === GS_AND) {
      threadStates(preOpThread).preOpBranch := (preOpA(0) === 1.U) && (preOpB(0) === 1.U)
    }

    .elsewhen (preOp === GS_OR) {
      threadStates(preOpThread).preOpBranch := (preOpA(0) === 1.U) || (preOpB(0) === 1.U)
    }

    .elsewhen (preOp === GS_GT) {
      threadStates(preOpThread).preOpBranch := (preOpA(31, 0) > preOpB(31, 0))
    }

    .elsewhen (preOp === GS_OUTPUT) {
      threadStates(preOpThread).preOpBranch := true.B
      io.out.tag := threadStates(preOpThread).tag
      // io.out.bits := threadStates(preOpThread).input
      io.out.bits := preOpA.asTypeOf(chiselTypeOf(io.out.bits))
      // io.out.bits.l3.h1 := preOpB
      io.out.valid := true.B
      // threadStates(preOpThread).finish := true.B
    }

    .elsewhen (preOp === GS_OUTPUTRET) {
      io.out.tag := threadStates(preOpThread).tag
      io.out.bits := preOpA.asTypeOf(chiselTypeOf(io.out.bits))
      io.out.valid := true.B
      threadStates(preOpThread).finish := true.B
    }

    .elsewhen (preOp === GS_RET) {
      threadStates(preOpThread).finish := true.B
    }

    threadStates(preOpThread).preOpA := preOpA
    threadStates(preOpThread).preOpB := preOpB

    // FIXME: choose which preOp vals to send to functional units
    when (threadStates(preOpThread).fuValids(0) === true.B) {
      fuFifos_0.io.enq.bits.tag := preOpThread
      fuFifos_0.io.enq.bits.bits := (preOpB.asTypeOf(new metadata_t)).tuple
      fuFifos_0.io.enq.valid := true.B
    }

    when (threadStates(preOpThread).fuValids(1) === true.B) {
      fuFifos_1.io.enq.bits.tag := preOpThread
      fuFifos_1.io.enq.bits.bits.ch0_opcode := threadStates(preOpThread).fuOps(1)
      fuFifos_1.io.enq.bits.bits.ch0_meta := preOpB.asTypeOf(new fce_meta_t)
      fuFifos_1.io.enq.valid := true.B
    }

    when (threadStates(preOpThread).fuValids(2) === true.B) {
      fuFifos_2.io.enq.bits.tag := preOpThread
      fuFifos_2.io.enq.bits.bits.ch1_opcode := threadStates(preOpThread).fuOps(2)
      fuFifos_2.io.enq.bits.bits.ch1_bit_map := (preOpB.asTypeOf(new ftCh0Output_t)).ch0_bit_map
      fuFifos_2.io.enq.bits.bits.ch1_data := (preOpB.asTypeOf(new ftCh0Output_t)).ch0_q
      fuFifos_2.io.enq.valid := true.B
    }

    when (threadStates(preOpThread).fuValids(3) === true.B) {
      fuFifos_3.io.enq.bits.tag := preOpThread
      fuFifos_3.io.enq.bits.bits.opcode := threadStates(preOpThread).fuOps(3)
      fuFifos_3.io.enq.bits.bits.node := preOpB.asTypeOf(new llNode_t)
      fuFifos_3.io.enq.valid := true.B
    }

    threadStages(preOpThread) := ThreadStageEnum.exec
  }

  /****************** Function unit execution *********************************/
  val execThread = RegInit(NONE_SELECTED)
  val execThread_d0 = RegInit(NONE_SELECTED)
  execThread := preOpThread
  execThread_d0 := execThread
  val fuReqReadys = new Array[Bool](NUM_FUS)
  fuReqReadys(0) = hashPort.req.ready
  fuReqReadys(1) = flowTablePort.io.ch0_req_ready
  fuReqReadys(2) = flowTablePort.io.ch1_req_ready
  fuReqReadys(3) = dynamicMemPort.req.ready
  // fuReqReadys(1) = ipv4Lookup2Port.req.ready
  // fuReqReadys(2) = qosCountPort.req.ready

  // Bypass ALU results
  val scatterA = Module(new Scatter)
  val scatterB = Module(new Scatter)

  scatterA.io.din := RegNext(preOpA)
  scatterA.io.mode := RegNext(alu0DstMode_vec(0))
  scatterA.io.shift := RegNext(alu0DstShift_vec(0))
  scatterB.io.din := RegNext(preOpB)
  scatterB.io.mode := RegNext(alu1DstMode_vec(0))
  scatterB.io.shift := RegNext(alu1DstShift_vec(0))

  when (execThread_d0 =/= NONE_SELECTED) {
    when (threadStates(execThread_d0).fuValids(4) === true.B) {
      threadStates(execThread_d0).dests(4) := scatterA.io.dout
      threadStates(execThread_d0).wbens(4) := scatterA.io.wren
      threadStates(execThread_d0).execValids(4) := true.B
    }

    when (threadStates(execThread_d0).fuValids(5) === true.B) {
      threadStates(execThread_d0).dests(5) := scatterB.io.dout
      threadStates(execThread_d0).wbens(5) := scatterB.io.wren
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

  when (fuFifos_3.io.count > 0.U && fuReqReadys(0) === true.B) {
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
    threadStates(hashPort.rep.tag).dests(0) := hashPort.rep.bits.asUInt
    threadStates(hashPort.rep.tag).wbens(0) := Fill(16, 1.U)
    threadStates(hashPort.rep.tag).execValids(0) := true.B
  }

  flowTablePort.io.ch0_rep_ready := true.B
  when (flowTablePort.io.ch0_rep_valid) {
    threadStates(flowTablePort.io.ch0_rep_tag).dests(1) := flowTablePort.io.ch0_rep_data.asUInt
    threadStates(flowTablePort.io.ch0_rep_tag).wbens(1) := Fill(16, 1.U)
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
    threadStates(dynamicMemPort.rep.tag).dests(3) := dynamicMemPort.rep.bits.asUInt
    threadStates(dynamicMemPort.rep.tag).wbens(3) := Fill(16, 1.U)
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
  }

  /****************** Register write & branch *********************************/
  val branchThread = RegInit(NONE_SELECTED)
  val branchThread_d0 = RegInit(NONE_SELECTED)
  branchThread := fThread
  branchThread_d0 := branchThread

  val dests_wb = Reg(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  val destALane_wb = Reg(UInt(NUM_FUS_LG.W))
  val destBLane_wb = Reg(UInt(NUM_FUS_LG.W))
  val destAId_wb = Reg(UInt(NUM_REGS_LG.W))
  val destBId_wb = Reg(UInt(NUM_REGS_LG.W))
  val destAEn_wb = Reg(Bool())
  val destBEn_wb = Reg(Bool())
  val destWbens_wb = Reg(Vec(NUM_FUS, UInt((REG_WIDTH/8).W)))

  when (branchThread =/= NONE_SELECTED) {
    // writeback
    dests_wb := threadStates(branchThread).dests
    destALane_wb := threadStates(branchThread).destALane
    destBLane_wb := threadStates(branchThread).destBLane
    destAId_wb := threadStates(branchThread).destAId
    destBId_wb := threadStates(branchThread).destBId
    destAEn_wb := threadStates(branchThread).destAEn
    destBEn_wb := threadStates(branchThread).destBEn
    destWbens_wb := threadStates(branchThread).wbens

    // branch
    // FIXME: take all branch bits and properly mask
    when (threadStates(branchThread).finish) {
      threadStates(branchThread).ip := 0.U
    }
    .elsewhen (threadStates(branchThread).preOpBranch) {
      threadStates(branchThread).ip := threadStates(branchThread).ip + threadStates(branchThread).brTarget
    }
    .otherwise {
      threadStates(branchThread).ip := threadStates(branchThread).ip + 1.U
    }

    when (threadStates(branchThread).finish) {
      threadStages(branchThread) := ThreadStageEnum.idle
    }
    .otherwise {
      threadStages(branchThread) := ThreadStageEnum.fetch
    }
  }
  .otherwise {
    destAEn_wb := false.B
    destBEn_wb := false.B
  }

  // delay 1 cycle
  regfile.io.wrEn1 := destAEn_wb
  regfile.io.wrEn2 := destBEn_wb
  regfile.io.wrBen1 := destWbens_wb(destALane_wb)
  regfile.io.wrBen2 := destWbens_wb(destBLane_wb)
  regfile.io.wrAddr1 := Cat(branchThread_d0, destAId_wb)
  regfile.io.wrAddr2 := Cat(branchThread_d0, destBId_wb)
  regfile.io.wrData1 := dests_wb(destALane_wb)
  regfile.io.wrData2 := dests_wb(destBLane_wb)

  // FIXME: END threads
  //io.out.tag := inputTag(rThread)
  //io.out.bits := outputReg(rThread)
  //io.out.valid := rThread =/= NONE_SELECTED && State(rThread) === WaitForOutputReady
  //io.in.ready := sThread =/= NONE_SELECTED

//Range(0, NUM_THREADS, 1).foreach(i => subStateTh(i) := MuxCase(subStateTh(i), Seq((AllOffloadsReady && (i).U === rThread && State(i) =/= WaitForInputValid && State(i) =/= WaitForOutputReady , WaitForValid), ((i).U === vThread, WaitForReady))))

  //ipv4Lookup1Port.rep.ready := true.B
  //ipv4Lookup2Port.rep.ready := true.B
  //qosCountPort.rep.ready := true.B

/******************Ready stage handler************************/
//val ipv4Lookup1PortHadReadyRequest = RegInit(false.B)
//val ipv4Lookup1_ready_received = RegInit(false.B)
//val ipv4Lookup2PortHadReadyRequest = RegInit(false.B)
//val ipv4Lookup2_ready_received = RegInit(false.B)
//val qosCountPortHadReadyRequest = RegInit(false.B)
//val qosCount_ready_received = RegInit(false.B)
//
//AllOffloadsReady :=
//  (ipv4Lookup1Port.req.ready || ipv4Lookup1_ready_received || (!ipv4Lookup1PortHadReadyRequest && !ipv4Lookup1Port.req.valid)) &&
//  (ipv4Lookup2Port.req.ready || ipv4Lookup2_ready_received || (!ipv4Lookup2PortHadReadyRequest && !ipv4Lookup2Port.req.valid)) &&
//  (qosCountPort.req.ready || qosCount_ready_received || (!qosCountPortHadReadyRequest && !qosCountPort.req.valid)) &&
//  true.B
//
//ipv4Lookup1_ready_received := !(AllOffloadsReady) && (ipv4Lookup1_ready_received || ipv4Lookup1Port.req.ready)
//ipv4Lookup1PortHadReadyRequest := !AllOffloadsReady && (ipv4Lookup1PortHadReadyRequest || ipv4Lookup1Port.req.valid)
//
//ipv4Lookup2_ready_received := !(AllOffloadsReady) && (ipv4Lookup2_ready_received || ipv4Lookup2Port.req.ready)
//ipv4Lookup2PortHadReadyRequest := !AllOffloadsReady && (ipv4Lookup2PortHadReadyRequest || ipv4Lookup2Port.req.valid)
//
//qosCount_ready_received := !(AllOffloadsReady) && (qosCount_ready_received || qosCountPort.req.ready)
//qosCountPortHadReadyRequest := !AllOffloadsReady && (qosCountPortHadReadyRequest || qosCountPort.req.valid)


/******************Valid stage handler************************/
//val ipv4Lookup1PortHadValidRequest = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//val ipv4Lookup1_valid_received = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//val ipv4Lookup2PortHadValidRequest = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//val ipv4Lookup2_valid_received = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//val qosCountPortHadValidRequest = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//val qosCount_valid_received = RegInit(VecInit(Seq.fill(NUM_THREADS)(false.B)))
//
//for (i <- 0 to NUM_THREADS-1) {
//  AllOffloadsValid(i) :=
//    ((ipv4Lookup1Port.rep.valid && (ipv4Lookup1Port.rep.tag === (i).U((5).W)))|| ipv4Lookup1_valid_received(i) || !ipv4Lookup1PortHadValidRequest(i)) &&
//    ((ipv4Lookup2Port.rep.valid && (ipv4Lookup2Port.rep.tag === (i).U((5).W)))|| ipv4Lookup2_valid_received(i) || !ipv4Lookup2PortHadValidRequest(i)) &&
//    ((qosCountPort.rep.valid && (qosCountPort.rep.tag === (i).U((5).W)))|| qosCount_valid_received(i) || !qosCountPortHadValidRequest(i)) &&
//    true.B
//
//  ipv4Lookup1_valid_received(i) := !(vThread === (i).U((5).W)) && ((ipv4Lookup1_valid_received(i)) || (ipv4Lookup1Port.rep.valid && ipv4Lookup1Port.rep.tag === (i).U((5).W)))
//  ipv4Lookup1PortHadValidRequest(i) := !(vThread === (i).U((5).W)) && (ipv4Lookup1PortHadValidRequest(i) || ((i).U((5).W)===rThread && ipv4Lookup1Port.req.valid)/*(ipv4Lookup1PortHadReadyRequest && AllOffloadsReady && ((i).U((5).W) === rThread))*/)
//
//  ipv4Lookup2_valid_received(i) := !(vThread === (i).U((5).W)) && ((ipv4Lookup2_valid_received(i)) || (ipv4Lookup2Port.rep.valid && ipv4Lookup2Port.rep.tag === (i).U((5).W)))
//  ipv4Lookup2PortHadValidRequest(i) := !(vThread === (i).U((5).W)) && (ipv4Lookup2PortHadValidRequest(i) || ((i).U((5).W)===rThread && ipv4Lookup2Port.req.valid)/*(ipv4Lookup2PortHadReadyRequest && AllOffloadsReady && ((i).U((5).W) === rThread))*/)
//
//  qosCount_valid_received(i) := !(vThread === (i).U((5).W)) && ((qosCount_valid_received(i)) || (qosCountPort.rep.valid && qosCountPort.rep.tag === (i).U((5).W)))
//  qosCountPortHadValidRequest(i) := !(vThread === (i).U((5).W)) && (qosCountPortHadValidRequest(i) || ((i).U((5).W)===rThread && qosCountPort.req.valid)/*(qosCountPortHadReadyRequest && AllOffloadsReady && ((i).U((5).W) === rThread))*/)
//}
//
//  val outPort = ipv4Lookup1Port.rep.bits
//  val srcLookupResult = ipv4Lookup2Port.rep.bits
//  val qcOutput = qosCountPort.rep.bits
//  qosCountPort.req.tag :=  rThread
//  qosCountPort.req.valid :=  (rThread =/= NONE_SELECTED) && !qosCount_valid_received(rThread) && ( (rThread =/= NONE_SELECTED && State(rThread) === GS_UPDATE))
//  qosCountPort.req.bits := MuxCase(Reg(UInt((32).W)),Seq( ((rThread =/= NONE_SELECTED && State(rThread) === GS_UPDATE),gOutPort(rThread))))
//
//  ipv4Lookup2Port.req.tag :=  rThread
//  ipv4Lookup2Port.req.valid :=  (rThread =/= NONE_SELECTED) && !ipv4Lookup2_valid_received(rThread) && ( (rThread =/= NONE_SELECTED && State(rThread) === GS_LOOKUP))
//  ipv4Lookup2Port.req.bits := MuxCase(Reg(UInt((32).W)),Seq( ((rThread =/= NONE_SELECTED && State(rThread) === GS_LOOKUP),ipv4Input(rThread).srcAddr)))
//
//  ipv4Lookup1Port.req.tag :=  rThread
//  ipv4Lookup1Port.req.valid :=  (rThread =/= NONE_SELECTED) && !ipv4Lookup1_valid_received(rThread) && ( (rThread =/= NONE_SELECTED && State(rThread) === GS_LOOKUP))
//  ipv4Lookup1Port.req.bits := MuxCase(Reg(UInt((32).W)),Seq( ((rThread =/= NONE_SELECTED && State(rThread) === GS_LOOKUP),ipv4Input(rThread).dstAddr)))
//
//  when (rThread =/= NONE_SELECTED && State(rThread) === WaitForOutputReady && io.out.ready) {
//    State(rThread) := EmitReturnState(rThread)
//  }

  // when (vThread =/= NONE_SELECTED &&State(vThread) === GS_ETHERNET){
  //ipv4Input(vThread):=inputReg(vThread).l3.asTypeOf(new IPv4Header_t)
  //outputReg(vThread):=inputReg(vThread)
  //when (inputReg(vThread).l2Protocol===ETHERNET) {
  //State(vThread):=GS_IPV4
  //}
  //.otherwise {
  //State(vThread):=GS_EXCEPTION
  //}
  //}

  // when (vThread =/= NONE_SELECTED &&State(vThread) === GS_IPV4){
  //when (inputReg(vThread).eth.l3Type===IPV4) {
  //State(vThread):=GS_LOOKUP
  //ipv4Output(vThread):=ipv4Input(vThread)
  //}
  //.otherwise {
  //State(vThread):=GS_EXCEPTION
  //}
  //when (ipv4Input(vThread).length<(20).U||ipv4Input(vThread).version=/=(4).U) {
  //State(vThread):=GS_EXCEPTION
  //}
  //}

  // when (vThread =/= NONE_SELECTED &&State(vThread) === GS_LOOKUP){
  //outputReg(vThread).outPort:=outPort+srcLookupResult
  //gOutPort(vThread):=outPort
  //when (srcLookupResult===INVALID_ADDRESS||outPort===INVALID_ADDRESS) {
  //State(vThread):=GS_EXCEPTION
  //}
  //.otherwise {
  //State(vThread):=GS_UPDATE
  //}
  //}
  //
  // when (vThread =/= NONE_SELECTED &&State(vThread) === GS_UPDATE){
  //outputReg(vThread).outPort:=gOutPort(vThread)
  //when (ipv4Input(vThread).ttl===(1).U) {
  //State(vThread):=GS_EXCEPTION
  //}
  //.otherwise {
  //ipv4Output(vThread).ttl:=ipv4Input(vThread).ttl-(1).U
  //ipv4Output(vThread).chksum:=ipv4Input(vThread).chksum+(128).U
  //}
  //outputReg(vThread).l3:=ipv4Output(vThread).asTypeOf(new mpl3Header_t)
  //EmitReturnState(vThread) := WaitForInputValid
  //State(vThread) := WaitForOutputReady
  //}
  //
  // when (vThread =/= NONE_SELECTED &&State(vThread) === GS_EXCEPTION){
  //outputReg(vThread).outPort:=CONTROL_PLANE
  //EmitReturnState(vThread) := WaitForInputValid
  //State(vThread) := WaitForOutputReady
  //}

/******************Engine specific performance counters************************/
  // FIXME
  //val IsPcReset =
  // io.pcIn.valid && io.pcIn.bits.request && io.pcIn.bits.pcType === Pcounters.pcReset
  //var portId = 3
  //when (IsPcReset) {
  //  engineUtilization := (0).U((Pcounters.PCWIDTH).W)
  //} .otherwise {
  //  when (State(0) =/= WaitForInputValid) {
  //    engineUtilization := engineUtilization +
  //     (1).U((Pcounters.PCWIDTH).W)
  //  }
  //}
  //for ((n, i) <- ioOff.elements) {
  //  if (n == "ipv4Lookup1") {
  //    when (IsPcReset) {
  //      offloadRateArray(portId-3) := (0).U((Pcounters.PCWIDTH).W)
  //    } .elsewhen (i.asInstanceOf[gOffBundle[Bundle, Bundle]].req.ready &&
  //     (ipv4Lookup1PortHadValidRequest(0) || ipv4Lookup1Port.req.valid) && !pcPaused) {
  //      offloadRateArray(portId-3) := offloadRateArray(portId-3) + (1).U((Pcounters.PCWIDTH).W)
  //    }
  //  }
  //  if (n == "ipv4Lookup2") {
  //    when (IsPcReset) {
  //      offloadRateArray(portId-3) := (0).U((Pcounters.PCWIDTH).W)
  //    } .elsewhen (i.asInstanceOf[gOffBundle[Bundle, Bundle]].req.ready &&
  //     (ipv4Lookup2PortHadValidRequest(0) || ipv4Lookup2Port.req.valid) && !pcPaused) {
  //      offloadRateArray(portId-3) := offloadRateArray(portId-3) + (1).U((Pcounters.PCWIDTH).W)
  //    }
  //  }
  //  if (n == "qosCount") {
  //    when (IsPcReset) {
  //      offloadRateArray(portId-3) := (0).U((Pcounters.PCWIDTH).W)
  //    } .elsewhen (i.asInstanceOf[gOffBundle[Bundle, Bundle]].req.ready &&
  //     (qosCountPortHadValidRequest(0) || qosCountPort.req.valid) && !pcPaused) {
  //      offloadRateArray(portId-3) := offloadRateArray(portId-3) + (1).U((Pcounters.PCWIDTH).W)
  //    }
  //  }
  //  portId = portId + 1
  //}
}
