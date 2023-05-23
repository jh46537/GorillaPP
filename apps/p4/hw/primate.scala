import chisel3._
import chisel3.util._
import chisel3.util.Fill
import chisel3.util.PriorityEncoder
import chisel3.experimental.ChiselEnum
import chisel3.util.experimental.loadMemoryFromFileInline

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap
import scala.io.Source

// BFU regfile dump interface
class BFU_regfile_req_t(num_threads_lg: Int, num_regs_lg: Int) extends Bundle {
  val tag = UInt(num_threads_lg.W)
  val rdAddr1 = UInt(num_regs_lg.W)
  val rdAddr2 = UInt(num_regs_lg.W)

  override def cloneType = (new BFU_regfile_req_t(num_threads_lg, num_regs_lg).asInstanceOf[this.type])
}

class BFU_regfile_rsp_t(reg_width: Int) extends Bundle {
  val rdData1 = UInt(reg_width.W)
  val rdData2 = UInt(reg_width.W)

  override def cloneType = (new BFU_regfile_rsp_t(reg_width).asInstanceOf[this.type])
}

class Fetch(num: Int, ipWidth: Int, instrWidth: Int, inst_ram_size: Int) extends Module {
  val io = IO(new Bundle {
    val ip         = Input(UInt(ipWidth.W))
    val instr      = Output(UInt(instrWidth.W))
  })

  // FIXME: implement i$

  // var mem_array = Array.fill[UInt](1 << ipWidth)(0.U(instrWidth.W))

  val mem = SyncReadMem(inst_ram_size, UInt(instrWidth.W))
  loadMemoryFromFileInline(mem, "./primate_pgm.bin")

  // val mem = RegInit(VecInit(mem_array.toSeq))
  //val mem = SyncReadMem(1 << ipWidth, UInt(instrWidth.W))
  //loadMemoryFromFileInline(mem, "../assembler/npu.bin")

  io.instr := mem(io.ip)
}

class primate(extCompName: String) extends gComponentLeaf(new input_t, new output_t, ArrayBuffer(), extCompName + "__type__engine__MT__16__") {
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
  val NUM_WB_ENS = knobs.apply("NUM_WB_ENS").toInt
  val MAX_FIELD_WIDTH = knobs.apply("MAX_FIELD_WIDTH").toInt
  val IP_WIDTH = knobs.apply("IP_WIDTH").toInt
  val REG_BLOCK_WIDTH:Array[Int] = knobs.apply("REG_BLOCK_WIDTH").split(" ").map(_.toInt)
  val src_pos:Array[Int] = knobs.apply("SRC_POS").split(" ").map(_.toInt)
  val src_mode:Array[Int] = knobs.apply("SRC_MODE").split(" ").map(_.toInt)
  val dst_encode:Array[Int] = knobs.apply("DST_ENCODE").split(" ").map(_.toInt)
  val dst_pos:Array[Int] = knobs.apply("DST_POS").split(" ").map(_.toInt)
  val wbens:Array[Int] = knobs.apply("DST_EN").split(" ").map(_.toInt)
  val dst_en_encode:Array[(Int, Int)] = knobs.apply("DST_EN_ENCODE").split(";").map(_.split(" ") match {case Array(a1, a2) => (a1.toInt, a2.toInt)})

  val LSU_EN = 0
  val NUM_THREADS_LG = log2Up(NUM_THREADS)
  val NUM_REGS_LG = log2Up(NUM_REGS)
  val NUM_FUOPS_LG = 6 // currently fixed to 6 due to the risc-v encoding
  val NUM_FUS = NUM_BFUS + NUM_ALUS
  val NUM_FUS_LG = log2Up(NUM_FUS)
  val NUM_DST = 1
  val NUM_RD_BANKS = scala.math.pow(2, log2Up(NUM_ALUS)).toInt
  val NUM_RF_RD_PORTS = NUM_ALUS
  val NUM_WR = NUM_FUS+LSU_EN
  val NUM_RF_WR_PORTS = (NUM_WR+1)/2
  val NUM_WR_BANKS = scala.math.pow(2, log2Up(NUM_RF_WR_PORTS)).toInt
  val NUM_BTS = 3
  val NUM_SRC_POS_LG = log2Up(NUM_SRC_POS)
  val NUM_SRC_MODES_LG = log2Up(NUM_SRC_MODES)
  val NUM_DST_POS_LG = log2Up(NUM_DST_POS)
  val NUM_DST_MODES_LG = log2Up(NUM_SRC_MODES)
  val INST_RAM_SIZE = 512
  // FIXME
  val ALU_SRC_WIDTH = NUM_REGS_LG + NUM_SRC_POS_LG + NUM_SRC_MODES_LG
  // val ALU_INST_WIDTH = 7 + NUM_REGS_LG + NUM_DST_POS_LG + NUM_DST_MODES_LG + (3 + ALU_SRC_WIDTH + ALU_SRC_WIDTH.max(12)).max(20)
  val ALU_INST_WIDTH = 64
  val INSTR_WIDTH = 32 * (NUM_BFUS + 2 + LSU_EN) + ALU_INST_WIDTH * NUM_ALUS

  val NONE_SELECTED = (NUM_THREADS).U((log2Up(NUM_THREADS+1)).W)

  val AllOffloadsReady = Reg(Bool())
  val AllOffloadsValid  = Reg(Vec(NUM_THREADS, Bool()))

  /*******************Thread states*********************************/

  // set up function units
  val ioUnit = Module(new inOutUnit(REG_WIDTH, NUM_REGS_LG, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH))
  val matchTablePort = Module(new matchTable(NUM_THREADS_LG, REG_WIDTH, 1, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH))
  val loadStorePort = Module(new loadStoreUnit(NUM_THREADS_LG, REG_WIDTH, 2, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH))
  // def functionalUnits = io.elements("off")
  // def dynamicMemPort = functionalUnits.asInstanceOf[Bundle].elements("dynamicMem").asInstanceOf[gOffBundle[dyMemInput_t, llNode_t]]
  // val flowTablePort = Module(new flowTable(TAGWIDTH, NUM_THREADS))
  io.mem.mem_addr   := matchTablePort.io.mem.mem_addr
  io.mem.read       := matchTablePort.io.mem.read
  io.mem.write      := matchTablePort.io.mem.write
  io.mem.writedata  := matchTablePort.io.mem.writedata
  io.mem.byteenable := matchTablePort.io.mem.byteenable
  matchTablePort.io.mem.waitrequest    := io.mem.waitrequest
  matchTablePort.io.mem.readdatavalid  := io.mem.readdatavalid
  matchTablePort.io.mem.readdata       := io.mem.readdata

  object ThreadStageEnum extends ChiselEnum {
    val idle   = Value
    val order_fetch = Value
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
    val invalid     = Bool()
    // FIXME: input -> rf & rf -> output
    val ip          = UInt((IP_WIDTH+2).W)

    val bfuValids   = Vec(NUM_BFUS+LSU_EN+1, Bool())
    val execValids  = Vec(NUM_BFUS+LSU_EN+1, Bool())
    val io_dstPC    = UInt(IP_WIDTH.W)
    val execDone    = Bool()
    val finish      = Bool()
  }
  val threadStates  = Reg(Vec(NUM_THREADS, ThreadStateT))

  val regfile = Module(new RegRead(NUM_THREADS, NUM_RF_RD_PORTS, NUM_RF_WR_PORTS, NUM_REGS, REG_WIDTH, NUM_REGBLOCKS, REG_BLOCK_WIDTH))

  class ThreadMemT extends Bundle {
    val brUcodes   = new BRMicrocodes(NUM_ALUS, NUM_BFUS+LSU_EN+1)
    val rdWrEn     = Vec(NUM_ALUS+NUM_BFUS+LSU_EN+2, Bool())
    val rd         = Vec(NUM_ALUS+NUM_BFUS+LSU_EN+2, UInt(NUM_REGS_LG.W))
  }

  class DestMemT extends Bundle {
    val dstPC      = UInt(IP_WIDTH.W)
    val wben       = UInt(NUM_REGBLOCKS.W)
    val dest       = UInt(REG_WIDTH.W)
  }

  val threadMem = Module(new ram_simple2port(NUM_THREADS, (new ThreadMemT).getWidth))
  val destMems = Seq.fill(NUM_WR)(Module(new ram_simple2port(NUM_THREADS, (new DestMemT).getWidth)))
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
  val vThreadEncoder = Module(new Scheduler_order(NUM_THREADS))
  Range(0, NUM_THREADS, 1).map(i =>
    ioUnit.io.idle_threads(i) := threadStages(i) === ThreadStageEnum.idle)

  ioUnit.io.in_valid := io.in.valid
  ioUnit.io.in_tag := io.in.tag
  ioUnit.io.in_data := io.in.bits.data
  ioUnit.io.in_empty := io.in.bits.empty
  ioUnit.io.in_last := io.in.last
  io.in.ready := ioUnit.io.in_ready

  when (ioUnit.io.new_thread) {
    // spawn new thread
    threadStages(ioUnit.io.new_tag) := ThreadStageEnum.order_fetch
    threadStates(ioUnit.io.new_tag).ip := 0.U((IP_WIDTH+2).W)
    vThreadEncoder.io.valid := true.B
    vThreadEncoder.io.tag := ioUnit.io.new_tag
  } .otherwise {
    vThreadEncoder.io.valid := false.B
    vThreadEncoder.io.tag := DontCare
  }

  /****************** Scheduler logic *********************************/
  // select valid thread
  // val vThreadEncoder = Module(new RREncode(NUM_THREADS))
  // val vThreadEncoder = Module(new Scheduler(NUM_THREADS, scala.math.pow(2, log2Up(NUM_ALUS)).toInt))
  val vThread = vThreadEncoder.io.chosen
  // Range(0, NUM_THREADS, 1).map(i =>
  //   vThreadEncoder.io.valid(i) := (threadStages(i) === ThreadStageEnum.fetch))
  Range(0, NUM_THREADS, 1).map(i =>
    vThreadEncoder.io.order_ready(i) := (threadStages(i) === ThreadStageEnum.order_fetch))
  Range(0, NUM_THREADS, 1).map(i =>
    vThreadEncoder.io.ready(i) := (threadStages(i) === ThreadStageEnum.fetch))

  /****************** Fetch logic *********************************/
  val fetchUnit = Module(new Fetch(NUM_THREADS, IP_WIDTH, INSTR_WIDTH, INST_RAM_SIZE))
  val instr = Wire(UInt(INSTR_WIDTH.W))
  fetchUnit.io.ip := (threadStates(vThread).ip >> 2)
  instr := fetchUnit.io.instr

  when (vThread =/= NONE_SELECTED) {
      threadStages(vThread) := ThreadStageEnum.decode
  }

  /****************** Decode logic *********************************/
  val decodeThread = RegInit(NONE_SELECTED)
  decodeThread := vThread

  val decodeUnit = Module(new Decode(NUM_ALUS, NUM_BFUS+LSU_EN+1, ALU_INST_WIDTH, NUM_REGS_LG, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_DST_POS_LG, NUM_DST_MODES_LG))
  val aluMicrocodes_in = Wire(new ALUMicrocodes(NUM_ALUS, NUM_SRC_POS_LG, NUM_SRC_MODES_LG))
  val alu_rd_pos_in = Wire(Vec(NUM_ALUS, UInt(NUM_DST_POS_LG.W)))
  val alu_rd_mode_in = Wire(Vec(NUM_ALUS, UInt(NUM_DST_MODES_LG.W)))
  val bfuMicrocodes_in = Wire(new BFUMicrocodes(NUM_ALUS, NUM_BFUS+LSU_EN+1))
  val rdWrEn_in = Wire(Vec(NUM_FUS+LSU_EN+2, Bool()))
  val bfuValids_in = Wire(Vec(NUM_BFUS+LSU_EN+1, Bool()))
  decodeUnit.io.instr := instr

  val BFU_RSPQ_DEPTH_LG = 3
  val BFU_RSPQ_DEPTH = 8 // (BFU_RSPQ_DEPTH/2 must be equal or greater than NUM_RF_RD_PORTS+1)
  val bfuRdReqQ = Module(new Queue(new BFU_regfile_req_t(NUM_THREADS_LG, NUM_REGS_LG), 4))
  val bfuRdRspQ = Module(new Queue(new BFU_regfile_rsp_t(REG_WIDTH), BFU_RSPQ_DEPTH))
  val bfuRdRspQ_almFull = Wire(Bool())
  val bfuRdRspQ_enq_in = Wire(Bool())
  val decode_valid = RegInit(false.B)
  val decodeThread_d1 = RegNext(decodeThread)

  bfuRdReqQ.io.deq.ready := false.B
  bfuRdReqQ.io.enq.valid := ioUnit.io.rd_req_valid
  bfuRdReqQ.io.enq.bits := ioUnit.io.rd_req
  ioUnit.io.rd_req_ready := bfuRdReqQ.io.enq.ready

  bfuRdRspQ_almFull := bfuRdRspQ.io.count(2).asBool
  bfuRdRspQ.io.enq.valid := false.B
  bfuRdRspQ_enq_in := false.B
  ioUnit.io.rd_rsp_valid := bfuRdRspQ.io.deq.valid
  ioUnit.io.rd_rsp := bfuRdRspQ.io.deq.bits
  bfuRdRspQ.io.deq.ready := ioUnit.io.rd_rsp_ready

  decode_valid := false.B
  when (decodeThread =/= NONE_SELECTED) {
    threadStates(decodeThread).bfuValids := decodeUnit.io.bfuValids
    threadStates(decodeThread).invalid := false.B
    threadStates(decodeThread).execValids := VecInit(Seq.fill(NUM_BFUS+LSU_EN+1)(false.B))
    decode_valid := true.B

    aluMicrocodes_in := decodeUnit.io.aluUcodes
    alu_rd_pos_in := decodeUnit.io.rd_pos
    alu_rd_mode_in := decodeUnit.io.rd_mode
    bfuMicrocodes_in := decodeUnit.io.bfuUcodes
    rdWrEn_in := decodeUnit.io.rdWrEn
    bfuValids_in := decodeUnit.io.bfuValids

    val threadMem_in = Wire(new ThreadMemT)
    threadMem_in.brUcodes  := decodeUnit.io.brUcodes
    threadMem_in.rdWrEn    := decodeUnit.io.rdWrEn
    threadMem_in.rd        := decodeUnit.io.rd
    threadMem.io.wraddress := decodeThread
    threadMem.io.wren      := true.B
    threadMem.io.data      := threadMem_in.asUInt
    regfile.io.thread_rd   := decodeThread
    regfile.io.rdEn        := true.B
    for (i <- 0 until NUM_RF_RD_PORTS) {
      regfile.io.rdAddr1(i) := decodeUnit.io.rs1(i)
      regfile.io.rdAddr2(i) := decodeUnit.io.rs2(i)
    }

    threadStages(decodeThread) := ThreadStageEnum.read
  }
  .otherwise {
    val initVec = RegInit(VecInit(Seq.fill(NUM_FUS+LSU_EN+2)(false.B)))
    val initVecALU = RegInit(VecInit(Seq.fill(NUM_ALUS)(false.B)))
    val initVecBFU = RegInit(VecInit(Seq.fill(NUM_BFUS+LSU_EN+1)(false.B)))
    aluMicrocodes_in.rs1_pos := DontCare
    aluMicrocodes_in.rs1_mode := DontCare
    aluMicrocodes_in.rs2_pos := DontCare
    aluMicrocodes_in.rs2_mode := DontCare
    aluMicrocodes_in.addEn  := initVecALU
    aluMicrocodes_in.subEn  := initVecALU
    aluMicrocodes_in.sltEn  := initVecALU
    aluMicrocodes_in.sltuEn := initVecALU
    aluMicrocodes_in.andEn  := initVecALU
    aluMicrocodes_in.orEn   := initVecALU
    aluMicrocodes_in.xorEn  := initVecALU
    aluMicrocodes_in.sllEn  := initVecALU
    aluMicrocodes_in.srEn   := initVecALU
    aluMicrocodes_in.srMode := initVecALU
    aluMicrocodes_in.luiEn  := initVecALU
    aluMicrocodes_in.catEn  := initVecALU
    aluMicrocodes_in.immSel := initVecALU
    aluMicrocodes_in.imm    := DontCare
    alu_rd_pos_in := DontCare
    alu_rd_mode_in := DontCare

    bfuMicrocodes_in := DontCare

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

    val bfuRdTag = bfuRdReqQ.io.deq.bits.tag
    regfile.io.thread_rd := bfuRdReqQ.io.deq.bits.tag
    regfile.io.rdAddr1(0) := bfuRdReqQ.io.deq.bits.rdAddr1
    regfile.io.rdAddr2(0) := bfuRdReqQ.io.deq.bits.rdAddr2
    when (bfuRdReqQ.io.deq.valid && (!bfuRdRspQ_almFull) && ((!decode_valid) || 
      (bfuRdTag(log2Up(NUM_RF_RD_PORTS)-1, 0) =/= decodeThread_d1(log2Up(NUM_RF_RD_PORTS)-1, 0)))) {
      bfuRdRspQ_enq_in := true.B
      bfuRdReqQ.io.deq.ready := true.B
    }
  }

  /************************* Register read  *******************************/
  val REG_DELAY = NUM_RF_RD_PORTS + 1
  val ALU_DELAY = 4 // 3 (gather) + 1 (alu)
  val readThread_vec = RegInit(VecInit(Seq.fill(REG_DELAY+ALU_DELAY)(NONE_SELECTED)))
  val aluMicrocodes_vec = Reg(Vec(REG_DELAY, new ALUMicrocodes(NUM_ALUS, NUM_SRC_POS_LG, NUM_SRC_MODES_LG)))
  val alu_rd_pos_vec = Reg(Vec(REG_DELAY+ALU_DELAY, Vec(NUM_ALUS, UInt(NUM_DST_POS_LG.W))))
  val alu_rd_mode_vec = Reg(Vec(REG_DELAY+ALU_DELAY, Vec(NUM_ALUS, UInt(NUM_DST_MODES_LG.W))))
  val bfuMicrocodes_vec = Reg(Vec(REG_DELAY+ALU_DELAY, new BFUMicrocodes(NUM_ALUS, NUM_BFUS+LSU_EN+1)))
  val bfuValids_vec = RegInit(VecInit(Seq.fill(REG_DELAY+ALU_DELAY)(VecInit(Seq.fill(NUM_BFUS+LSU_EN+1)(false.B)))))
  val rdWrEn_vec = RegInit(VecInit(Seq.fill(REG_DELAY+ALU_DELAY)(VecInit(Seq.fill(NUM_FUS+LSU_EN+2)(false.B)))))
  val bfuRdRspQ_enq_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(false.B)))

  readThread_vec(REG_DELAY+ALU_DELAY-1) := decodeThread
  aluMicrocodes_vec(REG_DELAY-1) := aluMicrocodes_in
  alu_rd_pos_vec(REG_DELAY+ALU_DELAY-1) := alu_rd_pos_in
  alu_rd_mode_vec(REG_DELAY+ALU_DELAY-1) := alu_rd_mode_in
  bfuMicrocodes_vec(REG_DELAY+ALU_DELAY-1) := bfuMicrocodes_in
  bfuValids_vec(REG_DELAY+ALU_DELAY-1) := bfuValids_in
  rdWrEn_vec(REG_DELAY+ALU_DELAY-1) := rdWrEn_in
  bfuRdRspQ_enq_vec(REG_DELAY-1) := bfuRdRspQ_enq_in

  for (i <- 0 until REG_DELAY+ALU_DELAY-1) {
    readThread_vec(i) := readThread_vec(i+1)
    alu_rd_pos_vec(i) := alu_rd_pos_vec(i+1)
    alu_rd_mode_vec(i) := alu_rd_mode_vec(i+1)
    bfuMicrocodes_vec(i) := bfuMicrocodes_vec(i+1)
    bfuValids_vec(i) := bfuValids_vec(i+1)
    rdWrEn_vec(i) := rdWrEn_vec(i+1)
  }
  for (i <- 0 until REG_DELAY-1) {
    aluMicrocodes_vec(i) := aluMicrocodes_vec(i+1)
    bfuRdRspQ_enq_vec(i) := bfuRdRspQ_enq_vec(i+1)
  }

  val srcA = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  val srcB = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  srcA := regfile.io.rdData1
  srcB := regfile.io.rdData2

  /****************** Gather Stage 0-2 *************************/
  val aluMicrocodes_out = aluMicrocodes_vec(0)

  val gather_aluA = Seq.fill(NUM_ALUS)(Module(new Gather(REG_WIDTH, NUM_SRC_POS, src_pos, MAX_FIELD_WIDTH, NUM_SRC_MODES, src_mode)))
  val gather_aluB = Seq.fill(NUM_ALUS)(Module(new Gather(REG_WIDTH, NUM_SRC_POS, src_pos, MAX_FIELD_WIDTH, NUM_SRC_MODES, src_mode)))
  for (i <- 0 until NUM_ALUS) {
    gather_aluA(i).io.din := srcA(i)
    gather_aluA(i).io.shift := aluMicrocodes_out.rs1_pos(i)
    gather_aluA(i).io.mode := aluMicrocodes_out.rs1_mode(i)
    gather_aluB(i).io.din := srcB(i)
    gather_aluB(i).io.shift := aluMicrocodes_out.rs2_pos(i)
    gather_aluB(i).io.mode := aluMicrocodes_out.rs2_mode(i)
  }

  val bfuRdRspQ_enq_valid = bfuRdRspQ_enq_vec(0)
  val bfuRdRspQ_enq_bits = Wire(new BFU_regfile_rsp_t(REG_WIDTH))

  // BFU regfile dump rsp queue
  bfuRdRspQ_enq_bits.rdData1 := srcA(0)
  bfuRdRspQ_enq_bits.rdData2 := srcB(0)
  bfuRdRspQ.io.enq.valid := bfuRdRspQ_enq_valid
  bfuRdRspQ.io.enq.bits := bfuRdRspQ_enq_bits

  /****************** ALU Stage 0 *************************/
  val alus = Seq.fill(NUM_ALUS)(Module(new ALU(REG_WIDTH)))
  val aluMicrocodes_out_d0 = RegNext(aluMicrocodes_out)
  val aluMicrocodes_out_d1 = RegNext(aluMicrocodes_out_d0)
  val aluMicrocodes_out_d2 = RegNext(aluMicrocodes_out_d1)

  for (i <- 0 until NUM_ALUS) {
    alus(i).io.rs1 := gather_aluA(i).io.dout
    alus(i).io.rs2 := gather_aluB(i).io.dout
    alus(i).io.addEn  := aluMicrocodes_out_d2.addEn(i)
    alus(i).io.subEn  := aluMicrocodes_out_d2.subEn(i)
    alus(i).io.sltEn  := aluMicrocodes_out_d2.sltEn(i)
    alus(i).io.sltuEn := aluMicrocodes_out_d2.sltuEn(i)
    alus(i).io.andEn  := aluMicrocodes_out_d2.andEn(i)
    alus(i).io.orEn   := aluMicrocodes_out_d2.orEn(i)
    alus(i).io.xorEn  := aluMicrocodes_out_d2.xorEn(i)
    alus(i).io.sllEn  := aluMicrocodes_out_d2.sllEn(i)
    alus(i).io.srEn   := aluMicrocodes_out_d2.srEn(i)
    alus(i).io.srMode := aluMicrocodes_out_d2.srMode(i)
    alus(i).io.luiEn  := aluMicrocodes_out_d2.luiEn(i)
    alus(i).io.catEn  := aluMicrocodes_out_d2.catEn(i)
    alus(i).io.immSel := aluMicrocodes_out_d2.immSel(i)
    alus(i).io.imm    := aluMicrocodes_out_d2.imm(i)
  }

  /****************** Pre-BFU/Scatter Stage *************************/
  val preOpThread = readThread_vec(0)
  val bfuMicrocodes_out = bfuMicrocodes_vec(0)
  val bfuValids_out = bfuValids_vec(0)
  val rdWrEn_out = rdWrEn_vec(0)

  val preOpRes = Wire(Vec(NUM_ALUS, UInt(REG_WIDTH.W)))
  for (i <- 0 until NUM_ALUS) {
    preOpRes(i) := alus(i).io.dout
  }

  // scatter
  val scatter = Seq.fill(NUM_ALUS)(Module(new Scatter(REG_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_REGBLOCKS, NUM_DST_POS, dst_encode, dst_pos, NUM_WB_ENS, dst_en_encode, wbens)))
  for (i <- 0 until NUM_ALUS) {
    scatter(i).io.din := RegNext(preOpRes(i))
    scatter(i).io.shift := RegNext(alu_rd_pos_vec(0)(i))
    scatter(i).io.mode := RegNext(alu_rd_mode_vec(0)(i))
  }

  // FIFOs
  val execBundle_io = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val opcode = UInt(NUM_FUOPS_LG.W)
    val rd = UInt(NUM_REGS_LG.W)
    val imm = UInt(12.W)
    val bits = UInt(REG_WIDTH.W)
  }
  val fuFifos_iou = Module(new Queue(execBundle_io, NUM_THREADS-1))
  fuFifos_iou.io.enq.valid := false.B
  fuFifos_iou.io.enq.bits := DontCare

  val execBundle_mem = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val opcode = UInt(NUM_FUOPS_LG.W)
    val rd = UInt(NUM_REGS_LG.W)
    val imm = UInt(12.W)
    val bits = Vec(2, UInt(REG_WIDTH.W))
  }
  val fuFifos_mem = Module(new Queue(execBundle_mem, NUM_THREADS-1))
  fuFifos_mem.io.enq.valid := false.B
  fuFifos_mem.io.enq.bits := DontCare

  val execBundle_0 = new Bundle {
    val tag = UInt(NUM_THREADS_LG.W)
    val opcode = UInt(NUM_FUOPS_LG.W)
    val imm = UInt(12.W)
    val bits = UInt((1*REG_WIDTH).W)
  }
  val fuFifos_0 = Module(new Queue(execBundle_0, NUM_THREADS-1))
  fuFifos_0.io.enq.valid := false.B
  fuFifos_0.io.enq.bits := DontCare

  when (preOpThread =/= NONE_SELECTED) {
    threadStates(preOpThread).finish := false.B

    if (LSU_EN == 1) {
      // load store unit
      when (bfuValids_out(NUM_BFUS) === true.B) {
        fuFifos_mem.io.enq.valid := true.B
        fuFifos_mem.io.enq.bits.tag := preOpThread
        fuFifos_mem.io.enq.bits.opcode := bfuMicrocodes_out.opcode(NUM_BFUS)
        fuFifos_mem.io.enq.bits.rd := bfuMicrocodes_out.rd(NUM_BFUS)
        fuFifos_mem.io.enq.bits.imm := bfuMicrocodes_out.bimm(NUM_BFUS)
        fuFifos_mem.io.enq.bits.bits(0) := preOpRes(0)
        fuFifos_mem.io.enq.bits.bits(1) := preOpRes(1)
      }

      // input/output unit
      when (bfuValids_out(NUM_BFUS+1) === true.B) {
        fuFifos_iou.io.enq.valid := true.B
        fuFifos_iou.io.enq.bits.tag := preOpThread
        fuFifos_iou.io.enq.bits.opcode := bfuMicrocodes_out.opcode(NUM_BFUS+1)
        fuFifos_iou.io.enq.bits.rd := bfuMicrocodes_out.rd(NUM_BFUS+1)
        fuFifos_iou.io.enq.bits.imm := bfuMicrocodes_out.bimm(NUM_BFUS+1)
        // fuFifos_iou.io.enq.bits.bits := MuxLookup(bfuMicrocodes_out.rs(NUM_BFUS+1)(0), DontCare, Array(0.U -> preOpRes(1), 1.U -> preOpRes(1)))
        fuFifos_iou.io.enq.bits.bits := preOpRes(1)
      }
    } else {
      // input/output unit
      when (bfuValids_out(NUM_BFUS) === true.B) {
        fuFifos_iou.io.enq.valid := true.B
        fuFifos_iou.io.enq.bits.tag := preOpThread
        fuFifos_iou.io.enq.bits.opcode := bfuMicrocodes_out.opcode(NUM_BFUS)
        fuFifos_iou.io.enq.bits.rd := bfuMicrocodes_out.rd(NUM_BFUS)
        fuFifos_iou.io.enq.bits.imm := bfuMicrocodes_out.bimm(NUM_BFUS)
        // fuFifos_iou.io.enq.bits.bits := MuxLookup(bfuMicrocodes_out.rs(NUM_BFUS)(0), DontCare, Array(1.U -> preOpRes(1)))
        fuFifos_iou.io.enq.bits.bits := preOpRes(1)
      }
    }

    when (bfuValids_out(0) === true.B) {
      fuFifos_0.io.enq.valid := true.B
      fuFifos_0.io.enq.bits.tag := preOpThread
      fuFifos_0.io.enq.bits.opcode := bfuMicrocodes_out.opcode(0)
      fuFifos_0.io.enq.bits.imm := bfuMicrocodes_out.bimm(0)
      // fuFifos_0.io.enq.bits.bits := MuxLookup(bfuMicrocodes_out.rs(0)(0), DontCare, Array(0.U -> preOpRes(0), 1.U -> DontCare))
      fuFifos_0.io.enq.bits.bits := preOpRes(0)
    }

    // threadStages(preOpThread) := ThreadStageEnum.exec
  }

  /****************** Function unit execution *********************************/
  val execThread = RegInit(NONE_SELECTED)
  val execThread_d0 = RegInit(NONE_SELECTED)
  val rdWrEn_exe = RegNext(rdWrEn_out)
  val rdWrEn_exe_d0 = RegNext(rdWrEn_exe)
  execThread := preOpThread
  execThread_d0 := execThread

  // Bypass ALU results
  when (execThread_d0 =/= NONE_SELECTED) {
    for (i <- 0 until NUM_ALUS) {
      // when (rdWrEn_exe_d0(i)) {
      val destMem_in = Wire(new DestMemT)
      destMem_in.dstPC := 0.U
      destMem_in.dest := scatter(i).io.dout
      destMem_in.wben := scatter(i).io.wren
      destMems(i).io.wren := true.B
      destMems(i).io.wraddress := execThread_d0
      destMems(i).io.data := destMem_in.asUInt
      // }
    }
    threadStages(execThread_d0) := ThreadStageEnum.exec
  }

  // FUs input
  if (LSU_EN == 1) {
    fuFifos_mem.io.deq.ready := false.B
    when (fuFifos_mem.io.deq.valid) {
      val deq = fuFifos_mem.io.deq
      loadStorePort.io.in_valid := true.B
      loadStorePort.io.in_tag := deq.bits.tag
      loadStorePort.io.in_opcode := deq.bits.opcode
      loadStorePort.io.in_bits := deq.bits.bits
      loadStorePort.io.in_imm := deq.bits.imm
      when (loadStorePort.io.in_ready) {
        fuFifos_mem.io.deq.ready := true.B
      }
    } .otherwise {
      loadStorePort.io.in_valid := false.B
      loadStorePort.io.in_tag := DontCare
      loadStorePort.io.in_opcode := DontCare
      loadStorePort.io.in_bits := DontCare
      loadStorePort.io.in_imm := DontCare
    }
  } else {
    fuFifos_mem.io.deq.ready := false.B
    loadStorePort.io.in_valid := false.B
    loadStorePort.io.in_tag := DontCare
    loadStorePort.io.in_opcode := DontCare
    loadStorePort.io.in_bits := DontCare
    loadStorePort.io.in_imm := DontCare
  }

  fuFifos_iou.io.deq.ready := false.B
  when (fuFifos_iou.io.deq.valid) {
    val deq = fuFifos_iou.io.deq
    ioUnit.io.ar_valid := true.B
    ioUnit.io.ar_tag := deq.bits.tag
    ioUnit.io.ar_opcode := deq.bits.opcode
    ioUnit.io.ar_rd := deq.bits.rd
    ioUnit.io.ar_bits := deq.bits.bits
    ioUnit.io.ar_imm := deq.bits.imm
    when (ioUnit.io.ar_ready) {
      fuFifos_iou.io.deq.ready := true.B
    }
  } .otherwise {
    ioUnit.io.ar_valid := false.B
    ioUnit.io.ar_tag := DontCare
    ioUnit.io.ar_opcode := DontCare
    ioUnit.io.ar_rd := DontCare
    ioUnit.io.ar_bits := DontCare
    ioUnit.io.ar_imm := DontCare
  }

  when (fuFifos_0.io.deq.valid && matchTablePort.io.in_ready) {
    val deq = fuFifos_0.io.deq
    matchTablePort.io.in_valid := true.B
    matchTablePort.io.in_tag := deq.bits.tag
    matchTablePort.io.in_opcode := deq.bits.opcode
    matchTablePort.io.in_imm := deq.bits.imm
    matchTablePort.io.in_bits(0) := deq.bits.bits
    fuFifos_0.io.deq.ready := true.B
  } .otherwise {
    matchTablePort.io.in_valid := false.B
    matchTablePort.io.in_tag := DontCare
    matchTablePort.io.in_opcode := DontCare
    matchTablePort.io.in_imm := DontCare
    matchTablePort.io.in_bits(0) := DontCare
    fuFifos_0.io.deq.ready := false.B
  }

  // FUs output
  if (LSU_EN == 1) {
    loadStorePort.io.out_ready := true.B
    when (loadStorePort.io.out_valid) {
      val destMem_in = Wire(new DestMemT)
      destMem_in.dstPC := loadStorePort.io.out_flag
      destMem_in.dest := loadStorePort.io.out_bits
      destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
      destMems(NUM_ALUS+NUM_BFUS).io.wren := true.B
      destMems(NUM_ALUS+NUM_BFUS).io.wraddress := loadStorePort.io.out_tag
      destMems(NUM_ALUS+NUM_BFUS).io.data := destMem_in.asUInt
      threadStates(loadStorePort.io.out_tag).execValids(NUM_BFUS) := true.B
    }

    when (ioUnit.io.w_valid) {
      threadStates(ioUnit.io.w_tag).execValids(NUM_BFUS+1) := true.B
      threadStates(ioUnit.io.w_tag).io_dstPC := ioUnit.io.w_flag
    }
    when (ioUnit.io.r_valid) {
      threadStates(ioUnit.io.r_tag).execValids(NUM_BFUS+1) := true.B
      threadStates(ioUnit.io.r_tag).io_dstPC := ioUnit.io.r_flag
    }
  } else {
    loadStorePort.io.out_ready := true.B

    when (ioUnit.io.w_valid) {
      threadStates(ioUnit.io.w_tag).execValids(NUM_BFUS) := true.B
      threadStates(ioUnit.io.w_tag).io_dstPC := ioUnit.io.w_flag
    }
    when (ioUnit.io.r_valid) {
      threadStates(ioUnit.io.r_tag).execValids(NUM_BFUS) := true.B
      threadStates(ioUnit.io.r_tag).io_dstPC := ioUnit.io.r_flag
    }
  }

  matchTablePort.io.out_ready := true.B
  when (matchTablePort.io.out_valid) {
    val destMem_in = Wire(new DestMemT)
    destMem_in.dstPC := matchTablePort.io.out_flag
    destMem_in.dest := matchTablePort.io.out_bits
    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)
    destMems(NUM_ALUS+0).io.wren := true.B
    destMems(NUM_ALUS+0).io.wraddress := matchTablePort.io.out_tag
    destMems(NUM_ALUS+0).io.data := destMem_in.asUInt
    threadStates(matchTablePort.io.out_tag).execValids(0) := true.B
  }

  /****************** Finish execution *********************************/
  val fThreadEncoder = Module(new Scheduler(NUM_THREADS, NUM_WR_BANKS))
  val fThread = fThreadEncoder.io.chosen
  val execDone = Wire(Vec(NUM_THREADS, Bool()))
  Range(0, NUM_THREADS, 1).foreach(i =>
    execDone(i) := (threadStates(i).execValids.asUInt | (~threadStates(i).bfuValids.asUInt)).andR
  )

  Range(0, NUM_THREADS, 1).map(i =>
    fThreadEncoder.io.valid(i) := (execDone(i) === true.B && threadStages(i) === ThreadStageEnum.exec))

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
  val WB_DELAY = NUM_RF_WR_PORTS.max(3)
  val branchThread_out = RegInit(NONE_SELECTED)
  val branchThread_vec = RegInit(VecInit(Seq.fill(WB_DELAY)(NONE_SELECTED)))
  branchThread_out := branchThread_vec(0)
  val branchU = Module(new BranchUnit)

  branchThread_vec(WB_DELAY-1) := fThread
  for (i <- 0 until WB_DELAY-1) {
    branchThread_vec(i) := branchThread_vec(i+1)
  }

  val threadMem_out = Wire(new ThreadMemT)
  val destMems_out = Wire(Vec(NUM_WR, (new DestMemT)))
  val destWbens_wb = Wire(Vec(NUM_WR, UInt(NUM_REGBLOCKS.W)))
  val dests_wb = Wire(Vec(NUM_WR, UInt(REG_WIDTH.W)))
  val rdWrEn_wb = Wire(Vec(NUM_WR+2, Bool()))
  val rd_wb = Wire(Vec(NUM_WR+2, UInt(NUM_REGS_LG.W)))
  val brUcodes_wb = Wire(new BRMicrocodes(NUM_ALUS, NUM_BFUS+2))
  val dstPCs = Wire(Vec(NUM_WR+1, UInt(IP_WIDTH.W)))

  for (i <- 0 until NUM_WR) {
    destMems_out(i) := destMems(i).io.q.asTypeOf(new DestMemT)
    dests_wb(i) := destMems_out(i).dest
    destWbens_wb(i) := destMems_out(i).wben
    dstPCs(i) := destMems_out(i).dstPC
  }
  dstPCs(NUM_WR) := threadStates(branchThread_vec(WB_DELAY-2)).io_dstPC

  threadMem_out := threadMem.io.q.asTypeOf(chiselTypeOf(threadMem_out))
  brUcodes_wb := threadMem_out.brUcodes
  rdWrEn_wb := threadMem_out.rdWrEn
  rd_wb := threadMem_out.rd
  val pc = Reg(UInt((IP_WIDTH+2).W))
  val threadValid = RegInit(false.B)

  when (branchThread_vec(WB_DELAY-1) =/= NONE_SELECTED) {
    threadValid := true.B
    pc := threadStates(branchThread_vec(WB_DELAY-1)).ip
  } .otherwise {
    threadValid := false.B
    pc := DontCare
  }

  val thread_finish = Wire(Bool())
  val thread_new_pc = Wire(UInt((IP_WIDTH+2).W))
  val threadValid_s1 = RegNext(threadValid)

  val caseALU = (0 until NUM_ALUS).map(i => (i.U -> dests_wb(i)))
  val caseBFU = (NUM_ALUS until NUM_FUS+1).map(i => (i.U -> (dstPCs(i) << 2)))
  val caseBRU = caseALU ++ caseBFU
  val branchU_rs1 = Wire(UInt(REG_WIDTH.W))
  val branchU_rs2 = Wire(UInt(REG_WIDTH.W))
  branchU_rs1 := MuxLookup(threadMem_out.brUcodes.rs1, DontCare, caseBRU)
  branchU_rs2 := MuxLookup(threadMem_out.brUcodes.rs2, DontCare, caseALU)
  branchU.io.brValid := threadValid && brUcodes_wb.brValid
  branchU.io.rs1 := branchU_rs1.asSInt
  branchU.io.rs2 := branchU_rs2.asSInt
  branchU.io.brMode := threadMem_out.brUcodes.brMode
  branchU.io.pc := pc.asSInt
  branchU.io.pcOffset := threadMem_out.brUcodes.pcOffset

  when (threadValid) {
    // writeback
    regfile.io.wrEn := true.B
    regfile.io.thread_wr := branchThread_vec(WB_DELAY-2)
    for (i <- 0 until NUM_RF_WR_PORTS) {
      regfile.io.wrEn1(i) := rdWrEn_wb(i*2)
      regfile.io.wrAddr1(i) := rd_wb(i*2)
      regfile.io.wrBen1(i) := destWbens_wb(i*2)
      regfile.io.wrData1(i) := dests_wb(i*2)
      if (i*2+1 < NUM_WR) {
        regfile.io.wrEn2(i) := rdWrEn_wb(i*2+1)
        regfile.io.wrAddr2(i) := rd_wb(i*2+1)
        regfile.io.wrBen2(i) := destWbens_wb(i*2+1)
        regfile.io.wrData2(i) := dests_wb(i*2+1)
      } else {
        regfile.io.wrEn2(i) := false.B
        regfile.io.wrAddr2(i) := DontCare
        regfile.io.wrBen2(i) := DontCare
        regfile.io.wrData2(i) := DontCare
      }
    }
  } .otherwise {
    regfile.io.wrEn := false.B
    regfile.io.thread_wr := ioUnit.io.w_tag
    regfile.io.wrEn1(0) := ioUnit.io.w_wen(0)
    regfile.io.wrAddr1(0) := ioUnit.io.w_addr(0)
    regfile.io.wrBen1(0) := Fill(NUM_REGBLOCKS, 1.U)
    regfile.io.wrData1(0) := ioUnit.io.w_data(0)(REG_WIDTH-1, 0)
    regfile.io.wrEn2(0) := ioUnit.io.w_wen(1)
    regfile.io.wrAddr2(0) := ioUnit.io.w_addr(1)
    regfile.io.wrBen2(0) := Fill(NUM_REGBLOCKS, 1.U)
    regfile.io.wrData2(0) := ioUnit.io.w_data(1)(REG_WIDTH-1, 0)
    for (i <- 1 until NUM_RF_WR_PORTS) {
      regfile.io.wrEn1(i) := false.B
      regfile.io.wrAddr1(i) := DontCare
      regfile.io.wrBen1(i) := Fill(NUM_REGBLOCKS, 0.U)
      regfile.io.wrData1(i) := DontCare
      regfile.io.wrEn2(i) := false.B
      regfile.io.wrAddr2(i) := DontCare
      regfile.io.wrBen2(i) := Fill(NUM_REGBLOCKS, 0.U)
      regfile.io.wrData2(i) := DontCare
    }
  }


  thread_finish := branchU.io.finish
  thread_new_pc := branchU.io.pcOut.asUInt
  when (threadValid_s1) {
    threadStates(branchThread_vec(WB_DELAY-3)).ip := thread_new_pc
    when (thread_finish) {
      threadStages(branchThread_vec(WB_DELAY-3)) := ThreadStageEnum.idle
    } .otherwise {
      threadStages(branchThread_vec(WB_DELAY-3)) := ThreadStageEnum.fetch
    }
  } .elsewhen (branchThread_vec(WB_DELAY-3) =/= NONE_SELECTED) {
    threadStages(branchThread_vec(WB_DELAY-3)) := ThreadStageEnum.fetch
  }

  // Output
  io.out.valid := ioUnit.io.out_valid
  io.out.tag := ioUnit.io.out_tag
  io.out.bits.data := ioUnit.io.out_data
  io.out.bits.empty := ioUnit.io.out_empty
  io.out.last := ioUnit.io.out_last
  ioUnit.io.out_ready := io.out.ready

  // Input unit output ready
  val w_tag = ioUnit.io.w_tag
  ioUnit.io.w_ready := (!threadValid) && ((!threadValid_s1) || (w_tag(log2Up(NUM_RF_WR_PORTS)-1, 0) =/= branchThread_vec(WB_DELAY-3)(log2Up(NUM_RF_WR_PORTS)-1, 0)))

}
