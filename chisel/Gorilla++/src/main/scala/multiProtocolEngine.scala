import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum
import chisel3.util.experimental.loadMemoryFromFileInline

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class Regfile(num: Int, width: Int) extends Module {
  val io = IO(new Bundle {
    val rdAddr1 = Input(UInt(log2Up(num).W))
    val rdAddr2 = Input(UInt(log2Up(num).W))
    val rdData1 = Output(UInt(width.W))
    val rdData2 = Output(UInt(width.W))

    val wrEn1   = Input(Bool())
    val wrEn2   = Input(Bool())
    val wrAddr1 = Input(UInt(log2Up(num).W))
    val wrAddr2 = Input(UInt(log2Up(num).W))
    val wrData1 = Input(UInt(width.W))
    val wrData2 = Input(UInt(width.W))
  })

  val wrAddr1_reg = Reg(UInt(log2Up(num).W))
  val wrAddr2_reg = Reg(UInt(log2Up(num).W))
  val wrData1_reg = Reg(UInt(width.W))
  val wrData2_reg = Reg(UInt(width.W))
  val wrEn1_reg = Reg(Bool())
  val wrEn2_reg = Reg(Bool())

  val mem = Reg(Vec(num, UInt(width.W)))

  io.rdData1 := mem(io.rdAddr1)
  io.rdData2 := mem(io.rdAddr2)

  when (io.wrEn1) {
    mem(io.wrAddr1) := io.wrData1
  }

  when (io.wrEn2) {
    mem(io.wrAddr2) := io.wrData2
  }

  // wrAddr1_reg := io.wrAddr1
  // wrAddr2_reg := io.wrAddr2
  // wrData1_reg := io.wrData1
  // wrData2_reg := io.wrData2
  // wrEn1_reg := io.wrEn1
  // wrEn2_reg := io.wrEn2

  // when (wrEn1_reg) {
  //   mem(wrAddr1_reg) := wrData1_reg
  // }
  // when (wrEn2_reg) {
  //   mem(wrAddr2_reg) := wrData2_reg
  // }
}

class Fetch(num: Int, ipWidth: Int, instrWidth: Int) extends Module {
  val io = IO(new Bundle {
    val ips         = Input(Vec(num, UInt(log2Up(num).W)))
    val ipValids    = Input(Vec(num, UInt(log2Up(num).W)))
    val instrs      = Output(Vec(num, UInt(instrWidth.W)))
    val instrReadys = Output(Vec(num, UInt(instrWidth.W)))
  })

  // FIXME: implement i$

  var mem_array = Array.fill[UInt](1 << ipWidth)(0.U(instrWidth.W))
  mem_array(0) = "h0000000182c6f801".U
  mem_array(1) = "h0000020190c6f801".U
  mem_array(2) = "h0000000000000006".U
  mem_array(3) = "h0000002000002005".U
  mem_array(4) = "h00000025a1904301".U
  mem_array(5) = "h0000008600006003".U
  mem_array(6) = "h0000006200008402".U
  mem_array(7) = "h000000028086a802".U
  mem_array(8) = "h000000008186c800".U
  mem_array(9) = "h0000002600010000".U

  val mem = RegInit(VecInit(mem_array.toSeq))
  //val mem = SyncReadMem(1 << ipWidth, UInt(instrWidth.W))
  //loadMemoryFromFileInline(mem, "../assembler/npu.bin")

  for (i <- 0 to num - 1) {
    io.instrs(i) := mem(io.ips(i))
    io.instrReadys(i) := io.ipValids(i)
  }
}

class Decode(instrWidth: Int, num_regs_lg: Int, num_fus: Int, num_preops_lg: Int, ip_width: Int, imm_width: Int) extends Module {
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
    val fuValids  = Output(Vec(num_fus, Bool()))
    // val brMask    = Output(Vec(num_fus + 1, Bool()))
    val brTarget  = Output(UInt(ip_width.W))
  })

  io.imm       := io.instr(48, 41)
  io.srcBId    := io.instr(40, 37)
  io.srcAId    := io.instr(36, 33)
  io.destBEn   := io.instr(32, 32)
  io.destAEn   := io.instr(31, 31)
  io.destBId   := io.instr(30, 27)
  io.destAId   := io.instr(26, 23)
  io.destBLane := io.instr(22, 20)
  io.destALane := io.instr(19, 17)
  io.preOp     := io.instr(16, 13)
  io.fuValids  := io.instr(12,  8).asBools
  // io.brMask    := io.instr(13,  8).asBools
  io.brTarget  := io.instr( 7,  0)
}


class multiProtocolEngine(extCompName: String) extends gComponentLeaf(new NP_EthMpl3Header_t, new NP_EthMpl3Header_t, ArrayBuffer(("ipv4Lookup1", UInt((32).W), UInt((8).W)), ("ipv4Lookup2", UInt((32).W), UInt((8).W)), ("qosCount", UInt((32).W), UInt((8).W))), extCompName + "__type__engine__MT__1__") {
  val NUM_THREADS = 16
  val NUM_THREADS_LG = log2Up(NUM_THREADS)
  val REG_WIDTH = 128
  val NUM_REGS = 16
  val NUM_REGS_LG = log2Up(NUM_REGS)
  val NUM_FUS = 5
  val NUM_FUS_LG = log2Up(NUM_FUS)
  val VLIW_OPS = 2
  val NUM_PREOPS = 9
  val NUM_PREOPS_LG = log2Up(NUM_PREOPS)
  val IMM_WIDTH = 8
  // FIXME
  //val BR_INSTR_WIDTH = 8
  //val INSTR_WIDTH = NUM_PREOPS_LG + VLIW_OPS * (NUM_FUS_LG + 2 * NUM_REGS_LG) + BR_INSTR_WIDTH
  val IP_WIDTH = 8
  val INSTR_WIDTH = NUM_PREOPS_LG + VLIW_OPS * (NUM_FUS_LG + 2 * NUM_REGS_LG + 1) + NUM_FUS * 2 + IP_WIDTH + IMM_WIDTH + 1
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
  def ipv4Lookup1Port = functionalUnits.asInstanceOf[Bundle].elements("ipv4Lookup1").asInstanceOf[gOffBundle[UInt, UInt]]
  def ipv4Lookup2Port = functionalUnits.asInstanceOf[Bundle].elements("ipv4Lookup2").asInstanceOf[gOffBundle[UInt, UInt]]
  def qosCountPort = functionalUnits.asInstanceOf[Bundle].elements("qosCount").asInstanceOf[gOffBundle[UInt, UInt]]

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
    val input       = new NP_EthMpl3Header_t
    val output      = new NP_EthMpl3Header_t

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
    val preOp       = UInt(NUM_PREOPS_LG.W)
    val fuValids    = Vec(NUM_FUS, Bool())
    // val brMask      = Vec(NUM_FUS + 1, Bool())
    val brTarget    = UInt(IP_WIDTH.W)

    val srcA        = UInt(REG_WIDTH.W)
    val srcB        = UInt(REG_WIDTH.W)

    val preOpBranch = Bool()
    val preOpA      = UInt(REG_WIDTH.W)
    val preOpB      = UInt(REG_WIDTH.W)

    val dests       = Vec(NUM_FUS, UInt(REG_WIDTH.W))
    val execValids  = Vec(NUM_FUS, Bool())
    val execDone    = Bool()
    val finish      = Bool()
  }
  val threadStates  = Reg(Vec(NUM_THREADS, ThreadStateT))

  val GS_ETHERNET    = 0.U
  val GS_IPV4        = 1.U
  val GS_LOOKUP      = 2.U
  val GS_LOOKUP_POST = 3.U
  val GS_UPDATE      = 4.U
  val GS_UPDATE_POST = 5.U
  val GS_EXCEPTION   = 6.U
  val GS_INPUT       = 7.U
  val GS_OUTPUT      = 8.U

  val regfile = Module(new Regfile(NUM_REGS*NUM_THREADS, REG_WIDTH))

  /****************** Start Thread *********************************/
  // select idle thread
  val sThreadEncoder = Module(new RREncode(NUM_THREADS))
  val sThread = sThreadEncoder.io.chosen
  val in_bits_d0 = Reg(new NP_EthMpl3Header_t)
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

  val decodeUnit = Module(new Decode(INSTR_WIDTH, NUM_REGS_LG, NUM_FUS, NUM_PREOPS_LG, IP_WIDTH, IMM_WIDTH))
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
    threadStates(decodeThread).fuValids  := decodeUnit.io.fuValids
    // threadStates(decodeThread).brMask    := decodeUnit.io.brMask
    threadStates(decodeThread).brTarget  := decodeUnit.io.brTarget

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
    threadStates(decodeThread).fuValids  := DontCare
    // threadStates(decodeThread).brMask    := DontCare
    threadStates(decodeThread).brTarget  := DontCare
  }

  val regfile_rdAddr1 = Reg(UInt(NUM_REGS_LG.W))
  val regfile_rdAddr2 = Reg(UInt(NUM_REGS_LG.W))
  regfile_rdAddr1 := decodeUnit.io.srcAId
  regfile_rdAddr2 := decodeUnit.io.srcBId

  /****************** Register read *********************************/
  val readThread = RegInit(NONE_SELECTED)
  readThread := decodeThread

  val srcA = Reg(UInt(REG_WIDTH.W))
  val srcB = Reg(UInt(REG_WIDTH.W))
  srcA := regfile.io.rdData1
  srcB := regfile.io.rdData2

  when (readThread =/= NONE_SELECTED) {
    regfile.io.rdAddr1 := Cat(readThread, regfile_rdAddr1)
    regfile.io.rdAddr2 := Cat(readThread, regfile_rdAddr2)
    // threadStates(readThread).srcA := regfile.io.rdData1
    // threadStates(readThread).srcB := regfile.io.rdData2

    threadStages(readThread) := ThreadStageEnum.pre
  }
  .otherwise {
    regfile.io.rdAddr1 := DontCare
    regfile.io.rdAddr2 := DontCare
    // regfile.io.rdData1 := DontCare
    // regfile.io.rdData2 := DontCare
    // threadStates(readThread).srcA := DontCare
    // threadStates(readThread).srcB := DontCare
  }

  /****************** Pre logic *********************************/
  val preOpThread = RegInit(NONE_SELECTED)
  preOpThread := readThread

  // input / output format
  //  * val l2Protocol = UInt((8).W)         0 [127, 120]
  //  * val outPort = UInt((8).W)            0 [119, 112]
  //  * val eth = new EthernetHeader_t
  //    * val dstAddr = UInt((48).W)         0 [111,  64]
  //    * val srcAddr = UInt((48).W)         0 [ 63,  16]
  //    * val l3Type = UInt((8).W)           0 [ 15,   8]
  //    * val length = UInt((8).W)           0 [  7,   0]
  //  * val l3 = new mpl3Header_t
  //    * val version = UInt((4).W)          1 [127, 124]
  //    * val hLength = UInt((4).W)          1 [123, 120]
  //    * val tos = UInt((8).W)              1 [119, 112]
  //    * val length = UInt((16).W)          1 [111,  96]
  //    * val identification = UInt((16).W)  1 [ 95,  80]
  //    * val flagsOffset = UInt((16).W)     1 [ 79,  64]
  //    * val ttl = UInt((8).W)              1 [ 63,  56]
  //    * val protocol = UInt((8).W)         1 [ 55,  48]
  //    * val chksum = UInt((16).W)          1 [ 47,  32]
  //    * val srcAddr = UInt((32).W)         1 [ 31,   0]
  //    * val dstAddr = UInt((32).W)         2 [127,  96]
  //    * val h1 = UInt((128).W)             1 [127,   0]
  //    * val h2 = UInt((128).W)             2 [127,   0]
  //    * val h3 = UInt((128).W)             3 [127,   0]
  //    * val h4 = UInt((128).W)             4 [127,   0]
  //    * val h5 = UInt((128).W)             5 [127,   0]
  //    * val h6 = UInt((128).W)             6 [127,   0]
  //    * val h7 = UInt((128).W)             7 [127,   0]
  //    * val h8 = UInt((128).W)             8 [127,   0]

  val execBundle = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val bits = UInt(128.W)
  }
  val fuFifos_0 = Module(new Queue(execBundle, NUM_THREADS - 1))  // ipv4Lookup1
  val fuFifos_1 = Module(new Queue(execBundle, NUM_THREADS - 1))  // ipv4Lookup2
  val fuFifos_2 = Module(new Queue(execBundle, NUM_THREADS - 1))  // qosCount

  fuFifos_0.io.enq.valid := false.B
  fuFifos_1.io.enq.valid := false.B
  fuFifos_2.io.enq.valid := false.B
  fuFifos_0.io.enq.bits := DontCare
  fuFifos_1.io.enq.bits := DontCare
  fuFifos_2.io.enq.bits := DontCare

  io.out.tag := DontCare
  io.out.bits := DontCare
  io.out.valid := false.B
  threadStates(preOpThread).finish := false.B

  when (preOpThread =/= NONE_SELECTED) {
    val preOpA = Wire(UInt(REG_WIDTH.W))
    val preOpB = Wire(UInt(REG_WIDTH.W))
    preOpA := srcA
    preOpB := srcB
    threadStates(preOpThread).preOpBranch := false.B

    when (threadStates(preOpThread).preOp === GS_INPUT) {
      val input_u = Wire(UInt(1152.W))
      val shift_w = Wire(UInt(4.W))
      input_u := threadStates(preOpThread).input.asUInt
      shift_w := threadStates(preOpThread).imm(3, 0)

      val tmp = Wire(UInt(1152.W))
      tmp := input_u >> ((4.U-shift_w)*256.U)

      preOpA := tmp(255, 128)
      preOpB := tmp(127, 0)
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_ETHERNET) {
      // SrcA = in[0]
      threadStates(preOpThread).preOpBranch := (srcA(127, 120) =/= ETHERNET)  // branch to exception
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_IPV4) {
      // SrcA = in[0]; SrcB = in[1]
      threadStates(preOpThread).preOpBranch := (srcA(15, 8) =/= IPV4) || (srcB(111, 96) < 20.U) || (srcB(127, 124) =/= 4.U) // branch to exception
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_LOOKUP) {  // 2 calls
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_LOOKUP_POST) {
      // preOpA := threadStates(preOpThread).srcA + threadStates(preOpThread).srcB
      threadStates(preOpThread).preOpBranch := (srcA(7, 0) === INVALID_ADDRESS) || (srcB(7, 0) === INVALID_ADDRESS)  // branch to exception
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_UPDATE) {
      threadStates(preOpThread).preOpBranch := (srcA(63, 56) === 1.U)  // branch to exception
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_UPDATE_POST) {
      val ttl = Wire(UInt(8.W))
      val chksum = Wire(UInt(16.W))

      ttl := srcA(63, 56) - 1.U
      chksum := srcA(47, 32) + 0x80.U

      preOpA := Cat(srcA(127, 64), ttl, srcA(55, 48), chksum, srcA(31, 0))
      threadStates(preOpThread).preOpBranch := true.B
      // preOpA := (threadStates(preOpThread).srcA(63, 56) - 1.U)
      // preOpB := (threadStates(preOpThread).srcA(47, 32) + 0x80.U)
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_EXCEPTION) {
      preOpA := CONTROL_PLANE
    }

    .elsewhen (threadStates(preOpThread).preOp === GS_OUTPUT) {
      io.out.tag := threadStates(preOpThread).tag
      io.out.bits := threadStates(preOpThread).input
      io.out.bits.outPort := srcA(7, 0)
      io.out.bits.l3.h1 := srcB
      io.out.valid := true.B
      threadStates(preOpThread).finish := true.B
    }

    threadStates(preOpThread).preOpA := preOpA
    threadStates(preOpThread).preOpB := preOpB

    // FIXME: choose which preOp vals to send to functional units
    threadStates(preOpThread).execValids := VecInit(Seq.fill(NUM_FUS)(false.B))
    when (threadStates(preOpThread).fuValids(0) === true.B) {
      // fuFifos_0.io.enq := (new Bundle { val tag = preOpThread; val bits = preOpA; }).asUInt
      fuFifos_0.io.enq.bits.tag := preOpThread
      fuFifos_0.io.enq.bits.bits := preOpA
      fuFifos_0.io.enq.valid := true.B
    }
    when (threadStates(preOpThread).fuValids(1) === true.B) {
      // fuFifos_1.io.enq := (new Bundle { val tag = preOpThread; val bits = preOpA; }).asUInt
      fuFifos_1.io.enq.bits.tag := preOpThread
      fuFifos_1.io.enq.bits.bits := preOpB
      fuFifos_1.io.enq.valid := true.B
    }
    when (threadStates(preOpThread).fuValids(2) === true.B) {
      // fuFifos_2.io.enq := (new Bundle { val tag = preOpThread; val bits = preOpA; }).asUInt
      fuFifos_2.io.enq.bits.tag := preOpThread
      fuFifos_2.io.enq.bits.bits := preOpB
      fuFifos_2.io.enq.valid := true.B
    }

    // Bypass
    when (threadStates(preOpThread).fuValids(3) === true.B) {
      threadStates(preOpThread).dests(3) := preOpA
      threadStates(preOpThread).execValids(3) := true.B
    }

    when (threadStates(preOpThread).fuValids(4) === true.B) {
      threadStates(preOpThread).dests(4) := preOpB
      threadStates(preOpThread).execValids(4) := true.B
    }

    threadStages(preOpThread) := ThreadStageEnum.exec
  }

  /****************** Function unit execution *********************************/
  val fuReqReadys = new Array[Bool](NUM_FUS)
  fuReqReadys(0) = ipv4Lookup1Port.req.ready
  fuReqReadys(1) = ipv4Lookup2Port.req.ready
  fuReqReadys(2) = qosCountPort.req.ready

  when (fuFifos_0.io.count > 0.U && fuReqReadys(0) === true.B) {
    val deq = fuFifos_0.io.deq
    ipv4Lookup1Port.req.valid := true.B
    ipv4Lookup1Port.req.tag := deq.bits.tag
    ipv4Lookup1Port.req.bits := deq.bits.bits(127, 96)
    fuFifos_0.io.deq.ready := true.B
  }
  .otherwise {
    ipv4Lookup1Port.req.valid := false.B
    ipv4Lookup1Port.req.tag := 0.U(NUM_THREADS_LG.W)
    ipv4Lookup1Port.req.bits := 0.U
    fuFifos_0.io.deq.ready := false.B
  }

  when (fuFifos_1.io.count > 0.U && fuReqReadys(1) === true.B) {
    val deq = fuFifos_1.io.deq
    ipv4Lookup2Port.req.valid := true.B
    ipv4Lookup2Port.req.tag := deq.bits.tag
    ipv4Lookup2Port.req.bits := deq.bits.bits(31, 0)
    fuFifos_1.io.deq.ready := true.B
  }
  .otherwise {
    ipv4Lookup2Port.req.valid := false.B
    ipv4Lookup2Port.req.tag := 0.U(NUM_THREADS_LG.W)
    ipv4Lookup2Port.req.bits := 0.U
    fuFifos_1.io.deq.ready := false.B
  }

  when (fuFifos_2.io.count > 0.U && fuReqReadys(0) === true.B) {
    val deq = fuFifos_2.io.deq
    qosCountPort.req.valid := true.B
    qosCountPort.req.tag := deq.bits.tag
    qosCountPort.req.bits := deq.bits.bits(7, 0)
    fuFifos_2.io.deq.ready := true.B
  }
  .otherwise {
    qosCountPort.req.valid := false.B
    qosCountPort.req.tag := 0.U(NUM_THREADS_LG.W)
    qosCountPort.req.bits := 0.U
    fuFifos_2.io.deq.ready := false.B
  }

  ipv4Lookup1Port.rep.ready := true.B
  when (ipv4Lookup1Port.rep.valid) {
    threadStates(ipv4Lookup1Port.rep.tag).dests(0) := ipv4Lookup1Port.rep.bits
    threadStates(ipv4Lookup1Port.rep.tag).execValids(0) := true.B
  }

  ipv4Lookup2Port.rep.ready := true.B
  when (ipv4Lookup2Port.rep.valid) {
    threadStates(ipv4Lookup2Port.rep.tag).dests(1) := ipv4Lookup2Port.rep.bits
    threadStates(ipv4Lookup2Port.rep.tag).execValids(1) := true.B
  }

  qosCountPort.rep.ready := true.B
  when (qosCountPort.rep.valid) {
    threadStates(qosCountPort.rep.tag).dests(2) := qosCountPort.rep.bits
    threadStates(qosCountPort.rep.tag).execValids(2) := true.B
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
  branchThread := fThread

  val branchThread_d0 = RegInit(NONE_SELECTED)
  val dests_wb = Reg(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
  val destALane_wb = Reg(UInt(NUM_FUS_LG.W))
  val destBLane_wb = Reg(UInt(NUM_FUS_LG.W))
  val destAId_wb = Reg(UInt(NUM_REGS_LG.W))
  val destBId_wb = Reg(UInt(NUM_REGS_LG.W))
  val destAEn_wb = Reg(Bool())
  val destBEn_wb = Reg(Bool())

  // delay 1 cycle
  branchThread_d0 := branchThread
  regfile.io.wrEn1 := destAEn_wb
  regfile.io.wrEn2 := destBEn_wb
  regfile.io.wrAddr1 := Cat(branchThread_d0, destAId_wb)
  regfile.io.wrAddr2 := Cat(branchThread_d0, destBId_wb)
  regfile.io.wrData1 := dests_wb(destALane_wb)
  regfile.io.wrData2 := dests_wb(destBLane_wb)

  when (branchThread =/= NONE_SELECTED) {
    // writeback
    // regfile.io.wrEn1 := threadStates(branchThread).destAEn
    // regfile.io.wrEn2 := threadStates(branchThread).destBEn
    // regfile.io.wrAddr1 := Cat(branchThread, threadStates(branchThread).destAId)
    // regfile.io.wrAddr2 := Cat(branchThread, threadStates(branchThread).destBId)
    // regfile.io.wrData1 := threadStates(branchThread).dests(threadStates(branchThread).destALane)
    // regfile.io.wrData2 := threadStates(branchThread).dests(threadStates(branchThread).destBLane)
    dests_wb := threadStates(branchThread).dests
    destALane_wb := threadStates(branchThread).destALane
    destBLane_wb := threadStates(branchThread).destBLane
    destAId_wb := threadStates(branchThread).destAId
    destBId_wb := threadStates(branchThread).destBId
    destAEn_wb := threadStates(branchThread).destAEn
    destBEn_wb := threadStates(branchThread).destBEn

    // branch
    // FIXME: take all branch bits and properly mask
    when (threadStates(branchThread).preOpBranch) {
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
    // regfile.io.wrEn1 := false.B
    // regfile.io.wrEn2 := false.B
    // regfile.io.wrAddr1 := 0.U((NUM_REGS_LG+NUM_THREADS_LG).W)
    // regfile.io.wrAddr2 := 0.U((NUM_REGS_LG+NUM_THREADS_LG).W)
    // regfile.io.wrData1 := 0.U(REG_WIDTH.W)
    // regfile.io.wrData2 := 0.U(REG_WIDTH.W)
    destAEn_wb := false.B
    destBEn_wb := false.B
  }

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
