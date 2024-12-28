  // /****************** Decode logic *********************************/
  // val decodeThread = RegInit(NONE_SELECTED) //assume this declared outside, make this as the input
  // decodeThread := vThread
  // val decodeThread_d1 = RegNext(decodeThread)  //assume this declared outside, make this as the input

  // val decodeUnit = Module(new Decode(NUM_ALUS, NUM_BFUS, NUM_FUS, SUBINSTR_WIDTH, ALU_SRC_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_DST_POS_LG, NUM_DST_MODES_LG))  // local
  // val aluMicrocodes_in = Wire(new ALUMicrocodes(NUM_ALUS, ALU_SRC_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG)) // local output
  // val bfuMicrocodes_in = Wire(new BFUMicrocodes(NUM_FUS-NUM_ALUS, ALU_SRC_WIDTH))  // local output
  // val rdWrEn_in = Wire(Vec(NUM_FUS, Bool()))   //  local output
  // val bfuValids_in = Wire(Vec(NUM_BFUS, Bool()))    // local output
  // decodeUnit.io.instr := instr            // instr as input

  // val BFU_RSPQ_DEPTH_LG = 3
  // val BFU_RSPQ_DEPTH = 8 // (BFU_RSPQ_DEPTH/2 must be equal or greater than NUM_RF_RD_PORTS+1)
  // val bfuRdReqQ = Module(new Queue(new BFU_regfile_req_t(NUM_THREADS_LG, NUM_REGS_LG), 4))   // local module 
  // val bfuRdRspQ = Module(new Queue(new BFU_regfile_rsp_t(REG_WIDTH), BFU_RSPQ_DEPTH))  // local module
  // val bfuRdRspQ_almFull = Wire(Bool())  // local module
  // val bfuRdRspQ_enq_in = Wire(Bool())  // output
  // val decode_valid = RegInit(false.B)  // local
  

  // bfuRdReqQ.io.deq.ready := false.B
  // bfuRdReqQ.io.enq.valid := ioUnit.io.rd_req_valid // ioUnit.io.rd_req_valid is input name it as ioUnit_rd_req_valid
  // bfuRdReqQ.io.enq.bits := ioUnit.io.rd_req  // ioUnit.io.rd_req is input name it as ioUnit_rd_req
  // ioUnit.io.rd_req_ready := bfuRdReqQ.io.enq.ready // ioUnit.io.rd_req_ready is output, name it as ioUnit_rd_req_ready

  // bfuRdRspQ_almFull := bfuRdRspQ.io.count(2).asBool
  // bfuRdRspQ.io.enq.valid := false.B
  // bfuRdRspQ_enq_in := false.B
  // ioUnit.io.rd_rsp_valid := bfuRdRspQ.io.deq.valid  // ioUnit.io.rd_rsp_valid is output
  // ioUnit.io.rd_rsp := bfuRdRspQ.io.deq.bits   // ioUnit.io.rd_rsp is output
  // bfuRdRspQ.io.deq.ready := ioUnit.io.rd_rsp_ready  // ioUnit.io.rd_rsp_ready is input

  // decode_valid := false.B
  // when (decodeThread =/= NONE_SELECTED) {
  //     ///exclude start
  //   threadStates(decodeThread).bfuValids := decodeUnit.io.bfuValids   // make decodeUnit.io.bfuValids as an output
  //   threadStates(decodeThread).invalid := false.B    // exclude the threadStates in the extract block, I will define them outside. 
  //   threadStates(decodeThread).execValids := VecInit(Seq.fill(NUM_BFUS)(false.B))   // exclude the threadStates in the extract block, I will define them outside. 
  //     ///exclude end
  //   decode_valid := true.B   // something local

  //   println("Got a valid decode thread!")

  //   aluMicrocodes_in := decodeUnit.io.aluUcodes // local
  //   bfuMicrocodes_in := decodeUnit.io.bfuUcodes
  //   rdWrEn_in := decodeUnit.io.rdWrEn
  //   bfuValids_in := decodeUnit.io.bfuValids

  //   val threadMem_in = Wire(new ThreadMemT)  // ZX: what is threadMem_in connected to 
  //   threadMem_in.brUcodes  := decodeUnit.io.brUcodes
  //   threadMem_in.rdWrEn    := decodeUnit.io.rdWrEn
  //   threadMem_in.rd        := decodeUnit.io.rd
  //   threadMem_in.rd_pos    := decodeUnit.io.rd_pos
  //   threadMem_in.rd_mode   := decodeUnit.io.rd_mode
      
  //   threadMem.io.wraddress := decodeThread   // threadMem.io.wraddress is output
  //   threadMem.io.wren      := true.B     // threadMem.io.wren is output
  //   threadMem.io.data      := threadMem_in.asUInt  // threadMem.io.data is output
      
  //   regfile.io.thread_rd   := decodeThread  // regfile.io.thread_rd is output
  //   regfile.io.rdEn        := true.B  // regfile.io.rdEn is output
      
  //   for (i <- 0 until NUM_RF_RD_PORTS) {
  //     regfile.io.rdAddr1(i) := decodeUnit.io.rs1(i)  // regfile.io.rdAddr1 output
  //     regfile.io.rdAddr2(i) := decodeUnit.io.rs2(i)  // regfile.io.rdAddr2 output
  //   }
  //   /// execlude start
  //   threadStages(decodeThread) := ThreadStageEnum.read
  //   /// execlude end
  // }
  // .otherwise {
  //   val initVec = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))     // local reg
  //   val initVecALU = RegInit(VecInit(Seq.fill(NUM_ALUS)(false.B))) // local reg
  //   val initVecBFU = RegInit(VecInit(Seq.fill(NUM_BFUS)(false.B))) // local reg
  //   aluMicrocodes_in.bfu_valid := initVecALU
  //   aluMicrocodes_in.opcode := DontCare
  //   aluMicrocodes_in.rs1_pos := DontCare
  //   aluMicrocodes_in.rs1_mode := DontCare
  //   aluMicrocodes_in.rs2_pos := DontCare
  //   aluMicrocodes_in.rs2_mode := DontCare
  //   aluMicrocodes_in.rd     := DontCare
  //   aluMicrocodes_in.addEn  := initVecALU 
  //   aluMicrocodes_in.subEn  := initVecALU
  //   aluMicrocodes_in.sltEn  := initVecALU
  //   aluMicrocodes_in.sltuEn := initVecALU
  //   aluMicrocodes_in.andEn  := initVecALU
  //   aluMicrocodes_in.orEn   := initVecALU
  //   aluMicrocodes_in.xorEn  := initVecALU
  //   aluMicrocodes_in.sllEn  := initVecALU
  //   aluMicrocodes_in.srEn   := initVecALU
  //   aluMicrocodes_in.srMode := initVecALU
  //   aluMicrocodes_in.luiEn  := initVecALU
  //   aluMicrocodes_in.catEn  := initVecALU
  //   aluMicrocodes_in.immSel := initVecALU
  //   aluMicrocodes_in.imm    := DontCare

  //   bfuMicrocodes_in := DontCare

  //   rdWrEn_in := initVec
  //   bfuValids_in := initVecBFU

  //   threadMem.io.wraddress := DontCare
  //   threadMem.io.wren      := false.B
  //   threadMem.io.data      := DontCare
  //   threadStates(decodeThread).bfuValids := DontCare
  //   threadStates(decodeThread).execValids := DontCare

  //   regfile.io.thread_rd := DontCare
  //   regfile.io.rdEn := false.B
  //   regfile.io.rdAddr1 := DontCare
  //   regfile.io.rdAddr2 := DontCare

  //   val bfuRdTag = bfuRdReqQ.io.deq.bits.tag
  //   regfile.io.thread_rd := bfuRdReqQ.io.deq.bits.tag
  //   regfile.io.rdAddr1(0) := bfuRdReqQ.io.deq.bits.rdAddr1
  //   regfile.io.rdAddr2(0) := bfuRdReqQ.io.deq.bits.rdAddr2
  //   when (bfuRdReqQ.io.deq.valid && (!bfuRdRspQ_almFull) && ((!decode_valid) || 
  //     (bfuRdTag(log2Up(NUM_RF_RD_PORTS)-1, 0) =/= decodeThread_d1(log2Up(NUM_RF_RD_PORTS)-1, 0)))) {
  //     bfuRdRspQ_enq_in := true.B
  //     bfuRdReqQ.io.deq.ready := true.B
  //   }
  // }
  
import chisel3._
import chisel3.util._
import chisel3.util.Fill

class DecodeLogic(
    NUM_ALUS: Int,
    NUM_BFUS: Int,
    NUM_FUS: Int,
    INSTR_WIDTH: Int,
    SUBINSTR_WIDTH: Int,
    ALU_SRC_WIDTH: Int,
    NUM_SRC_POS_LG: Int,
    NUM_SRC_MODES_LG: Int,
    NUM_DST_POS_LG: Int,
    NUM_DST_MODES_LG: Int,
    NUM_THREADS: Int,
    NUM_THREADS_LG: Int,
    NUM_REGS_LG: Int,
    REG_WIDTH: Int,
    THREAD_MEM_WIDTH: Int,
    NUM_RF_RD_PORTS: Int
) extends Module {
  val io = IO(new Bundle {
    // Inputs
    val instr = Input(UInt(INSTR_WIDTH.W)) // Instruction
    val decodeThread = Input(UInt(log2Up(NUM_THREADS + 1).W))
    val decodeThread_d1 = Input(UInt((log2Up(NUM_THREADS+1)).W))
    val ioUnit_rd_req_valid = Input(Bool())
    val ioUnit_rd_req = Input(new BFU_regfile_req_t(log2Up(NUM_THREADS), NUM_REGS_LG))   // Output(new BFU_regfile_req_t(log2Up(num_threads), num_regs_lg))
    val ioUnit_rd_rsp_ready = Input(Bool())
    val bfuRdRspQ_enq_valid = Input(Bool())
    val bfuRdRspQ_enq_bits = Input(new BFU_regfile_rsp_t(REG_WIDTH))

    // Outputs
    val decodeUnit_bfuValids = Output(Vec(NUM_BFUS, Bool()))
    val aluMicrocodes_in = Output(new ALUMicrocodes(NUM_ALUS, ALU_SRC_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG))
    val bfuMicrocodes_in = Output(new BFUMicrocodes(NUM_FUS-NUM_ALUS, ALU_SRC_WIDTH))
    val rdWrEn_in = Output(Vec(NUM_FUS, Bool()))
    val bfuValids_in = Output(Vec(NUM_BFUS, Bool())) 
    val bfuRdRspQ_enq_in = Output(Bool())
    val ioUnit_rd_req_ready = Output(Bool())
    val ioUnit_rd_rsp_valid = Output(Bool())
    val ioUnit_rd_rsp = Output(new BFU_regfile_rsp_t(REG_WIDTH))  // (new BFU_regfile_rsp_t(REG_WIDTH))
    val threadMem_wraddress = Output(UInt(log2Up(NUM_THREADS).W)) // ram_simple2port: Input(UInt(log2Up(NUM_THREADS).W))
    val threadMem_wren = Output(Bool())
    val threadMem_data = Output(UInt(THREAD_MEM_WIDTH.W))  // ram_simple2port: Input(UInt(THREAD_MEM_WIDTH.W))
    val regfile_thread_rd = Output(UInt(NUM_THREADS_LG.W))   // ==Input(UInt(log2Up(NUM_THREADS).W))
    val regfile_rdEn = Output(Bool())
    val regfile_rdAddr1 = Output(Vec(NUM_RF_RD_PORTS, UInt(NUM_REGS_LG.W))) // ==Input(Vec(NUM_RF_RD_PORTS, UInt(log2Up(NUM_REGS).W)))
    val regfile_rdAddr2 = Output(Vec(NUM_RF_RD_PORTS, UInt(NUM_REGS_LG.W))) 
  })

  val NONE_SELECTED = (NUM_THREADS).U((log2Up(NUM_THREADS+1)).W)
  val BFU_RSPQ_DEPTH_LG = 3
  val BFU_RSPQ_DEPTH = 8 // (BFU_RSPQ_DEPTH/2 must be equal or greater than NUM_RF_RD_PORTS+1)
    
  val decodeUnit = Module(new Decode(NUM_ALUS, NUM_BFUS, NUM_FUS, SUBINSTR_WIDTH, ALU_SRC_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_DST_POS_LG, NUM_DST_MODES_LG))
  val bfuRdReqQ = Module(new Queue(new BFU_regfile_req_t(NUM_THREADS_LG, NUM_REGS_LG), 4))   // local module 
  val bfuRdRspQ = Module(new Queue(new BFU_regfile_rsp_t(REG_WIDTH), BFU_RSPQ_DEPTH))  // local module
  val bfuRdRspQ_almFull = Wire(Bool())  // local module
  val decode_valid = RegInit(false.B)

  bfuRdRspQ.io.enq.valid := io.bfuRdRspQ_enq_valid  
  bfuRdRspQ.io.enq.bits := io.bfuRdRspQ_enq_bits

  // Connections
  decodeUnit.io.instr := io.instr

  bfuRdReqQ.io.deq.ready := false.B
  bfuRdReqQ.io.enq.valid := io.ioUnit_rd_req_valid
  bfuRdReqQ.io.enq.bits := io.ioUnit_rd_req
  io.ioUnit_rd_req_ready := bfuRdReqQ.io.enq.ready

  bfuRdRspQ_almFull := bfuRdRspQ.io.count(2).asBool
  bfuRdRspQ.io.enq.valid := false.B
  io.bfuRdRspQ_enq_in := false.B
  io.ioUnit_rd_rsp_valid := bfuRdRspQ.io.deq.valid
  io.ioUnit_rd_rsp := bfuRdRspQ.io.deq.bits
  bfuRdRspQ.io.deq.ready := io.ioUnit_rd_rsp_ready

  decode_valid := false.B
  io.decodeUnit_bfuValids := decodeUnit.io.bfuValids 

  when(io.decodeThread =/= NONE_SELECTED) {
    decode_valid := true.B
    println("Got a valid decode thread!")
    io.aluMicrocodes_in := decodeUnit.io.aluUcodes
    io.bfuMicrocodes_in := decodeUnit.io.bfuUcodes
    io.rdWrEn_in := decodeUnit.io.rdWrEn
    io.bfuValids_in := decodeUnit.io.bfuValids

    class ThreadMemT extends Bundle {
        val brUcodes   = new BRMicrocodes(NUM_ALUS, NUM_FUS)
        val rdWrEn     = Vec(NUM_FUS, Bool())
        val rd         = Vec(NUM_FUS, UInt(NUM_REGS_LG.W))
        val rd_pos     = Vec(NUM_ALUS, UInt(NUM_DST_POS_LG.W))
        val rd_mode    = Vec(NUM_ALUS, UInt(NUM_DST_MODES_LG.W))
    }

    val threadMem_in = Wire(new ThreadMemT)  
    threadMem_in.brUcodes  := decodeUnit.io.brUcodes
    threadMem_in.rdWrEn    := decodeUnit.io.rdWrEn
    threadMem_in.rd        := decodeUnit.io.rd
    threadMem_in.rd_pos    := decodeUnit.io.rd_pos
    threadMem_in.rd_mode   := decodeUnit.io.rd_mode
      
    io.threadMem_wraddress := io.decodeThread
    io.threadMem_wren := true.B
    io.threadMem_data := threadMem_in.asUInt

    io.regfile_thread_rd := io.decodeThread
    io.regfile_rdEn := true.B
      
    for (i <- 0 until NUM_RF_RD_PORTS) {
      io.regfile_rdAddr1(i) := decodeUnit.io.rs1(i)
      io.regfile_rdAddr2(i) := decodeUnit.io.rs2(i)
    }
  }.otherwise {
    val initVec = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))     // local reg
    val initVecALU = RegInit(VecInit(Seq.fill(NUM_ALUS)(false.B))) // local reg
    val initVecBFU = RegInit(VecInit(Seq.fill(NUM_BFUS)(false.B))) // local reg
    io.aluMicrocodes_in.bfu_valid := initVecALU
    io.aluMicrocodes_in.opcode := DontCare
    io.aluMicrocodes_in.rs1_pos := DontCare
    io.aluMicrocodes_in.rs1_mode := DontCare
    io.aluMicrocodes_in.rs2_pos := DontCare
    io.aluMicrocodes_in.rs2_mode := DontCare
    io.aluMicrocodes_in.rd     := DontCare
    io.aluMicrocodes_in.addEn  := initVecALU 
    io.aluMicrocodes_in.subEn  := initVecALU
    io.aluMicrocodes_in.sltEn  := initVecALU
    io.aluMicrocodes_in.sltuEn := initVecALU
    io.aluMicrocodes_in.andEn  := initVecALU
    io.aluMicrocodes_in.orEn   := initVecALU
    io.aluMicrocodes_in.xorEn  := initVecALU
    io.aluMicrocodes_in.sllEn  := initVecALU
    io.aluMicrocodes_in.srEn   := initVecALU
    io.aluMicrocodes_in.srMode := initVecALU
    io.aluMicrocodes_in.luiEn  := initVecALU
    io.aluMicrocodes_in.catEn  := initVecALU
    io.aluMicrocodes_in.immSel := initVecALU
    io.aluMicrocodes_in.imm    := DontCare

    io.bfuMicrocodes_in := DontCare
    io.rdWrEn_in := initVec
    io.bfuValids_in := initVecBFU

    io.threadMem_wraddress := DontCare
    io.threadMem_wren := false.B
    io.threadMem_data := DontCare

    io.regfile_thread_rd := DontCare
    io.regfile_rdEn := false.B
    io.regfile_rdAddr1 := DontCare
    io.regfile_rdAddr2 := DontCare

    val bfuRdTag = bfuRdReqQ.io.deq.bits.tag
    io.regfile_thread_rd := bfuRdReqQ.io.deq.bits.tag
    io.regfile_rdAddr1(0) := bfuRdReqQ.io.deq.bits.rdAddr1
    io.regfile_rdAddr2(0) := bfuRdReqQ.io.deq.bits.rdAddr2

    when (bfuRdReqQ.io.deq.valid && (!bfuRdRspQ_almFull) && ((!decode_valid) || 
        (bfuRdTag(log2Up(NUM_RF_RD_PORTS)-1, 0) =/= io.decodeThread_d1(log2Up(NUM_RF_RD_PORTS)-1, 0)))) {
        io.bfuRdRspQ_enq_in := true.B
        bfuRdReqQ.io.deq.ready := true.B
    }
  }

}
