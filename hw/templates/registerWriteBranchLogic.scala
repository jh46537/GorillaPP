
  //   /****************** Finish execution *********************************/
  //   val finishExecutionLogicBlock = Module(new FinishExecutionLogic(NUM_THREADS, NUM_WR, NUM_WR_BANKS, NUM_BFUS, NONE_SELECTED))

  //   // Provide inputs to the extracted module
  //   finishExecutionLogicBlock.io.threadStates_execValids := threadStates.map(_.execValids)
  //   finishExecutionLogicBlock.io.threadStates_bfuValids := threadStates.map(_.bfuValids)
  //   finishExecutionLogicBlock.io.threadStages := threadStages
    
  //   // Extract outputs from the module
  //   val fThread = finishExecutionLogicBlock.io.fThread
  //   threadMem.io.rden := finishExecutionLogicBlock.io.threadMem_rden
  //   threadMem.io.rdaddress := finishExecutionLogicBlock.io.threadMem_rdaddress
    
  //   for (i <- 0 until NUM_WR) {
  //       destMems(i).io.rden := finishExecutionLogicBlock.io.destMems_rden(i)
  //       destMems(i).io.rdaddress := finishExecutionLogicBlock.io.destMems_rdaddress(i)
  //   }

  //   when (fThread =/= NONE_SELECTED) {
  //       threadStages(fThread) := ThreadStageEnum.branch
  //   }


  // /****************** Register write & branch *********************************/
  // val WB_DELAY = NUM_RF_WR_PORTS.max(3)
  // val branchThread_out = RegInit(NONE_SELECTED)
  // val branchThread_vec = RegInit(VecInit(Seq.fill(WB_DELAY)(NONE_SELECTED)))
  // branchThread_out := branchThread_vec(0)
  // val branchU = Module(new BranchUnit)  // local module, define it in the submodule

  // branchThread_vec(WB_DELAY-1) := fThread
  // for (i <- 0 until WB_DELAY-1) {
  //   branchThread_vec(i) := branchThread_vec(i+1)   // Ater update the value make branchThread_vec as an input
  // }
    
  // //// excluded and remain on the top level, start (this part is assign values to the input)
  // val threadMem_out = Wire(new ThreadMemT)  // defined at the top level, but also a input
  // val destMems_out = Wire(Vec(NUM_WR, (new DestMemT))) // execluded from module, live at top level
  // val destWbens_wb = RegInit(VecInit(Seq.fill(NUM_WR)(0.U(NUM_REGBLOCKS.W)))) // input
  // val dests_wb = Wire(Vec(NUM_WR, UInt(REG_WIDTH.W)))  // input
  // val dstPCs = Wire(Vec(NUM_FUS+3*NUM_ALUS, UInt(32.W)))  // input

  
  // dstPCs := DontCare
  // if (NUM_ALUS < NUM_FUS) {
  //   // The last unit is the IO unit
  //   for (i <- 0 until NUM_FUS-1) {
  //     destMems_out(i) := destMems(i).io.q.asTypeOf(new DestMemT) 
  //     dests_wb(i) := destMems_out(i).dest
  //     destWbens_wb(i) := destMems_out(i).wben
  //   }
  //   for (i <- 0 until NUM_ALUS) {
  //     dstPCs(4*i+2) := destMems_out(i).dstPC
  //   }
  //   for (i <- 0 until NUM_FUS-NUM_ALUS-1) {
  //     dstPCs(4*NUM_ALUS+i) := destMems_out(NUM_ALUS+i).dstPC
  //   }
  //   dstPCs(NUM_FUS+3*NUM_ALUS-1) := threadStates(branchThread_vec(WB_DELAY-2)).io_dstPC
  // } else {
  //   // The IO unit is combined with an ALU unit
  //   for (i <- 0 until NUM_FUS) {
  //     destMems_out(i) := destMems(i).io.q.asTypeOf(new DestMemT)
  //     dests_wb(i) := destMems_out(i).dest
  //     destWbens_wb(i) := destMems_out(i).wben
  //   }
  //   for (i <- 0 until NUM_ALUS) {
  //     dstPCs(4*i+2) := destMems_out(i).dstPC
  //   }
  //   dstPCs(4*(NUM_BFUS-1)+2) := threadStates(branchThread_vec(WB_DELAY-2)).io_dstPC
  // }
    
  // threadMem_out := threadMem.io.q.asTypeOf(chiselTypeOf(threadMem_out)) 

  // val pc = Reg(UInt((IP_WIDTH+2).W))  // pc as an input
  // val threadValid = RegInit(false.B)  // tthreadValid as input

  // when (branchThread_vec(WB_DELAY-1) =/= NONE_SELECTED) {
  //   threadValid := true.B
  //   pc := threadStates(branchThread_vec(WB_DELAY-1)).ip
  // } .otherwise {
  //   threadValid := false.B
  //   pc := DontCare
  // }
  // ///// execluded end


  // ////extract as module, make sure include val branchU = Module(new BranchUnit)

  // val dests_wb_s1 = Reg(Vec(NUM_WR, UInt(REG_WIDTH.W)))   // dests_wb_s1 at local module
  // val rdWrEn_wb = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))  // local
  // val rd_wb = Reg(Vec(NUM_FUS, UInt(NUM_REGS_LG.W)))  // local
  // val brUcodes_wb = Wire(new BRMicrocodes(NUM_ALUS, NUM_FUS))  // local
    
  // brUcodes_wb := threadMem_out.brUcodes   // local assign for brUcodes_wb  threadMem_out is input
  // rdWrEn_wb := threadMem_out.rdWrEn  // local assign for rdWrEn_wb
  // rd_wb := threadMem_out.rd  // local assign for rd_wb
  // dests_wb_s1 := dests_wb  // dests_wb_s1 at local module

    
  // val thread_finish = Wire(Bool())
  // val thread_new_pc = Wire(UInt((IP_WIDTH+2).W))
  // val threadValid_s1 = RegNext(threadValid)
  // val threadValid_s2 = RegNext(threadValid_s1)

  // val caseFU = (0 until (NUM_FUS+3*NUM_ALUS)).map(i => (i.U -> dstPCs(i)))  // dstPCs is input
  // val branchU_rs1 = Wire(UInt(32.W))
  // val branchU_rs2 = Wire(UInt(32.W))
  // branchU_rs1 := MuxLookup(brUcodes_wb.rs1, DontCare, caseFU)  // brUcodes_wb is input
  // branchU_rs2 := MuxLookup(brUcodes_wb.rs2, DontCare, caseFU)
  // branchU.io.brValid := threadValid && brUcodes_wb.brValid  // threadValid is input
  // branchU.io.rs1 := branchU_rs1.asSInt
  // branchU.io.rs2 := branchU_rs2.asSInt
  // branchU.io.brMode := brUcodes_wb.brMode 
  // branchU.io.pc := pc.asSInt  //  pc is input
  // branchU.io.pcOffset := brUcodes_wb.pcOffset  

  // // scatter
  // val scatter = Seq.fill(NUM_ALUS)(Module(new Scatter(REG_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_REGBLOCKS, NUM_DST_POS, dst_encode, dst_pos, NUM_WB_ENS, dst_en_encode, wbens)))
  // for (i <- 0 until NUM_ALUS) {
  //   scatter(i).io.din := dests_wb(i)  // dests_wb is input
  //   scatter(i).io.shift := threadMem_out.rd_pos(i)  // threadMem_out is input
  //   scatter(i).io.mode := threadMem_out.rd_mode(i)
  // }

  // when (threadValid_s1) {
  //   // writeback
  //   regfile.io.wrEn := true.B  // regfile.io.wrEn as output, make following regfile.io. as output as regfile_
  //   regfile.io.thread_wr := branchThread_vec(WB_DELAY-3)
  //   for (i <- 0 until NUM_RF_WR_PORTS) {
  //     if (i*2 < NUM_ALUS) {
  //       regfile.io.wrEn1(i) := rdWrEn_wb(i*2)
  //       regfile.io.wrAddr1(i) := rd_wb(i*2)
  //       regfile.io.wrBen1(i) := scatter(i*2).io.wren
  //       regfile.io.wrData1(i) := scatter(i*2).io.dout
  //     } else {
  //       regfile.io.wrEn1(i) := rdWrEn_wb(i*2)
  //       regfile.io.wrAddr1(i) := rd_wb(i*2)
  //       regfile.io.wrBen1(i) := destWbens_wb(i*2)  // destWbens_wb is input
  //       regfile.io.wrData1(i) := dests_wb_s1(i*2)  // dests_wb_s1 is local
  //     }
  //     if (i*2+1 < NUM_ALUS) {
  //       regfile.io.wrEn2(i) := rdWrEn_wb(i*2+1)
  //       regfile.io.wrAddr2(i) := rd_wb(i*2+1)
  //       regfile.io.wrBen2(i) := scatter(i*2+1).io.wren
  //       regfile.io.wrData2(i) := scatter(i*2+1).io.dout
  //     } else if (i*2+1 < NUM_WR) {
  //       regfile.io.wrEn2(i) := rdWrEn_wb(i*2+1)
  //       regfile.io.wrAddr2(i) := rd_wb(i*2+1)
  //       regfile.io.wrBen2(i) := destWbens_wb(i*2+1)
  //       regfile.io.wrData2(i) := dests_wb_s1(i*2+1)
  //     } else {
  //       regfile.io.wrEn2(i) := false.B
  //       regfile.io.wrAddr2(i) := DontCare
  //       regfile.io.wrBen2(i) := DontCare
  //       regfile.io.wrData2(i) := DontCare
  //     }
  //   }
  // } .otherwise {
  //   regfile.io.wrEn := false.B
  //   regfile.io.thread_wr := ioUnit.io.w_tag   // make ioUnit.io. as input as ioUnit_
  //   regfile.io.wrEn1(0) := ioUnit.io.w_wen(0)
  //   regfile.io.wrAddr1(0) := ioUnit.io.w_addr(0)
  //   regfile.io.wrBen1(0) := Fill(NUM_REGBLOCKS, 1.U)
  //   regfile.io.wrData1(0) := ioUnit.io.w_data(0)(REG_WIDTH-1, 0)
  //   regfile.io.wrEn2(0) := ioUnit.io.w_wen(1)
  //   regfile.io.wrAddr2(0) := ioUnit.io.w_addr(1)
  //   regfile.io.wrBen2(0) := Fill(NUM_REGBLOCKS, 1.U)
  //   regfile.io.wrData2(0) := ioUnit.io.w_data(1)(REG_WIDTH-1, 0)
  //   for (i <- 1 until NUM_RF_WR_PORTS) {
  //     regfile.io.wrEn1(i) := false.B
  //     regfile.io.wrAddr1(i) := DontCare
  //     regfile.io.wrBen1(i) := Fill(NUM_REGBLOCKS, 0.U)
  //     regfile.io.wrData1(i) := DontCare
  //     regfile.io.wrEn2(i) := false.B
  //     regfile.io.wrAddr2(i) := DontCare
  //     regfile.io.wrBen2(i) := Fill(NUM_REGBLOCKS, 0.U)
  //     regfile.io.wrData2(i) := DontCare
  //   }
  // }


  // thread_finish := branchU.io.finish  // branchU.io.finish as output
  // thread_new_pc := branchU.io.pcOut.asUInt // branchU.io.pcOut as output

  //   /////////////// end extract
import chisel3._
import chisel3.util._
import chisel3.util.Fill

class RegisterWriteAndBranchLogic(
    NUM_THREADS: Int,
    NUM_WR: Int,
    NUM_FUS: Int,
    NUM_ALUS: Int,
    NUM_REGS: Int,
    NUM_RF_WR_PORTS: Int,
    NUM_REGBLOCKS: Int,
    NUM_SRC_POS_LG: Int,
    NUM_DST_POS_LG: Int,
    NUM_SRC_MODES_LG: Int,
    REG_WIDTH: Int,
    IP_WIDTH: Int,
    NUM_REGS_LG: Int,
    NUM_DST_MODES_LG: Int,
    NUM_DST_POS: Int,
    WB_DELAY: Int,
    dst_encode: Array[Long],
    dst_pos: Array[Long],
    NUM_WB_ENS: Int,
    dst_en_encode: Array[(Int, Int)],
    wbens: Array[Long]
) extends Module {
    
  class ThreadMemT extends Bundle {
    val brUcodes   = new BRMicrocodes(NUM_ALUS, NUM_FUS)
    val rdWrEn     = Vec(NUM_FUS, Bool())
    val rd         = Vec(NUM_FUS, UInt(NUM_REGS_LG.W))
    val rd_pos     = Vec(NUM_ALUS, UInt(NUM_DST_POS_LG.W))
    val rd_mode    = Vec(NUM_ALUS, UInt(NUM_DST_MODES_LG.W))
  }
    
  val io = IO(new Bundle {
    // Inputs
    val branchThread_vec = Input(Vec(WB_DELAY, UInt(log2Up(NUM_THREADS + 1).W))) // Branch thread vector  //log2Up(NUM_THREADS + 1).W
    // val branchThread_vec = RegInit(VecInit(Seq.fill(WB_DELAY)(NONE_SELECTED)))  // this is the code in primate
    val threadMem_out = Input(new ThreadMemT)
    // val destMems_out = Input(Vec(NUM_WR, new DestMemT))
    val destWbens_wb = Input(Vec(NUM_WR, UInt(NUM_REGBLOCKS.W)))
    val dests_wb = Input(Vec(NUM_WR, UInt(REG_WIDTH.W)))
    val dstPCs = Input(Vec(NUM_FUS + 3 * NUM_ALUS, UInt(32.W)))
    val threadValid = Input(Bool())
    val pc = Input(UInt((IP_WIDTH + 2).W))
    val ioUnit_w_tag = Input(UInt(log2Up(NUM_THREADS).W))               
    val ioUnit_w_wen = Input(Vec(2, Bool()))
    val ioUnit_w_addr = Input(Vec(2, UInt(NUM_REGS_LG.W)))          // val w_addr       = Output(Vec(2, UInt(NUM_REGS_LG.W)))
    val ioUnit_w_data = Input(Vec(2, UInt(REG_WIDTH.W)))               

    // Outputs
    val thread_finish = Output(Bool())
    val thread_new_pc = Output(UInt((IP_WIDTH + 2).W))
    // val branchU_finish = Output(Bool())
    // val branchU_pcOut = Output(UInt((IP_WIDTH + 2).W))
        // val regfile = Module(new RegRead(NUM_THREADS,     NUM_RF_RD_PORTS, NUM_RF_WR_PORTS, NUM_REGS,      REG_WIDTH,  NUM_REGBLOCKS,   REG_BLOCK_WIDTH))
        //                                 (threadnum: Int, num_rd: Int,     num_wr: Int,      num_regs: Int, reg_w: Int, num_blocks: Int, block_widths: Array[Int])
    val regfile_wrEn = Output(Bool())
    val regfile_thread_wr = Output(UInt(log2Up(NUM_THREADS).W))  // (UInt(log2Up(NUM_THREADS).W))
    val regfile_wrEn1 = Output(Vec(NUM_RF_WR_PORTS, Bool()))   
    val regfile_wrAddr1 = Output(Vec(NUM_RF_WR_PORTS, UInt(log2Up(NUM_REGS).W))) // (Vec(NUM_RF_WR_PORTS, UInt(log2Up(NUM_REGS).W)))
    val regfile_wrBen1 = Output(Vec(NUM_RF_WR_PORTS, UInt(NUM_REGBLOCKS.W)))     // (Vec(NUM_RF_WR_PORTS, UInt(NUM_REGBLOCKS.W)))
    val regfile_wrData1 = Output(Vec(NUM_RF_WR_PORTS, UInt(REG_WIDTH.W)))        // (Vec(NUM_RF_WR_PORTS, UInt(REG_WIDTH.W)))
    val regfile_wrEn2 = Output(Vec(NUM_RF_WR_PORTS, Bool())) 
    val regfile_wrAddr2 = Output(Vec(NUM_RF_WR_PORTS, UInt(log2Up(NUM_REGS).W)))
    val regfile_wrBen2 = Output(Vec(NUM_RF_WR_PORTS, UInt(NUM_REGBLOCKS.W)))
    val regfile_wrData2 = Output(Vec(NUM_RF_WR_PORTS, UInt(REG_WIDTH.W)))
  })

  // Local signals
  val dests_wb_s1 = Reg(Vec(NUM_WR, UInt(REG_WIDTH.W)))
  val rdWrEn_wb = RegInit(VecInit(Seq.fill(NUM_FUS)(false.B)))
  val rd_wb = Reg(Vec(NUM_FUS, UInt(log2Up(NUM_THREADS).W)))
  val brUcodes_wb = Wire(new BRMicrocodes(NUM_ALUS, NUM_FUS))

  val branchU = Module(new BranchUnit)

  // Logic assignments
  brUcodes_wb := io.threadMem_out.brUcodes
  rdWrEn_wb := io.threadMem_out.rdWrEn
  rd_wb := io.threadMem_out.rd
  dests_wb_s1 := io.dests_wb

  val threadValid_s1 = RegNext(io.threadValid)
  val threadValid_s2 = RegNext(threadValid_s1)

  val caseFU = (0 until (NUM_FUS + 3 * NUM_ALUS)).map(i => (i.U -> io.dstPCs(i)))
  val branchU_rs1 = Wire(UInt(32.W))
  val branchU_rs2 = Wire(UInt(32.W))
  branchU_rs1 := MuxLookup(brUcodes_wb.rs1, DontCare, caseFU)
  branchU_rs2 := MuxLookup(brUcodes_wb.rs2, DontCare, caseFU)
  branchU.io.brValid := io.threadValid && brUcodes_wb.brValid
  branchU.io.rs1 := branchU_rs1.asSInt
  branchU.io.rs2 := branchU_rs2.asSInt
  branchU.io.brMode := brUcodes_wb.brMode
  branchU.io.pc := io.pc.asSInt
  branchU.io.pcOffset := brUcodes_wb.pcOffset
    
  val scatter = Seq.fill(NUM_ALUS)(Module(new Scatter(REG_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG, NUM_REGBLOCKS, NUM_DST_POS, dst_encode, dst_pos, NUM_WB_ENS, dst_en_encode, wbens)))
  for (i <- 0 until NUM_ALUS) {
    scatter(i).io.din := io.dests_wb(i)
    scatter(i).io.shift := io.threadMem_out.rd_pos(i)
    scatter(i).io.mode := io.threadMem_out.rd_mode(i)
  } 

  // Writeback logic
  when (threadValid_s1) {
    io.regfile_wrEn := true.B
    io.regfile_thread_wr := io.branchThread_vec(WB_DELAY-3)
    for (i <- 0 until NUM_RF_WR_PORTS) {
      if (i * 2 < NUM_ALUS) {
        io.regfile_wrEn1(i) := rdWrEn_wb(i * 2)
        io.regfile_wrAddr1(i) := rd_wb(i * 2)
        io.regfile_wrBen1(i) := scatter(i * 2).io.wren
        io.regfile_wrData1(i) := scatter(i * 2).io.dout
      } else {
        io.regfile_wrEn1(i) := rdWrEn_wb(i * 2)
        io.regfile_wrAddr1(i) := rd_wb(i * 2)
        io.regfile_wrBen1(i) := io.destWbens_wb(i * 2)
        io.regfile_wrData1(i) := dests_wb_s1(i * 2)
      }
      if (i * 2 + 1 < NUM_ALUS) {
        io.regfile_wrEn2(i) := rdWrEn_wb(i * 2 + 1)
        io.regfile_wrAddr2(i) := rd_wb(i * 2 + 1)
        io.regfile_wrBen2(i) := scatter(i * 2 + 1).io.wren
        io.regfile_wrData2(i) := scatter(i * 2 + 1).io.dout
      } else if (i * 2 + 1 < NUM_WR) {
        io.regfile_wrEn2(i) := rdWrEn_wb(i * 2 + 1)
        io.regfile_wrAddr2(i) := rd_wb(i * 2 + 1)
        io.regfile_wrBen2(i) := io.destWbens_wb(i * 2 + 1)
        io.regfile_wrData2(i) := dests_wb_s1(i * 2 + 1)
      } else {
        io.regfile_wrEn2(i) := false.B
        io.regfile_wrAddr2(i) := DontCare
        io.regfile_wrBen2(i) := DontCare
        io.regfile_wrData2(i) := DontCare
      }
    }
  }.otherwise {
    io.regfile_wrEn := false.B
    io.regfile_thread_wr := io.ioUnit_w_tag
    io.regfile_wrEn1(0) := io.ioUnit_w_wen(0)
    io.regfile_wrAddr1(0) := io.ioUnit_w_addr(0)
    io.regfile_wrBen1(0) := Fill(NUM_REGBLOCKS, 1.U)
    io.regfile_wrData1(0) := io.ioUnit_w_data(0)(REG_WIDTH - 1, 0)
    io.regfile_wrEn2(0) := io.ioUnit_w_wen(1)
    io.regfile_wrAddr2(0) := io.ioUnit_w_addr(1)
    io.regfile_wrBen2(0) := Fill(NUM_REGBLOCKS, 1.U)
    io.regfile_wrData2(0) := io.ioUnit_w_data(1)(REG_WIDTH - 1, 0)
    for (i <- 1 until NUM_RF_WR_PORTS) {
      io.regfile_wrEn1(i) := false.B
      io.regfile_wrAddr1(i) := DontCare
      io.regfile_wrBen1(i) := Fill(NUM_REGBLOCKS, 0.U)
      io.regfile_wrData1(i) := DontCare
      io.regfile_wrEn2(i) := false.B
      io.regfile_wrAddr2(i) := DontCare
      io.regfile_wrBen2(i) := Fill(NUM_REGBLOCKS, 0.U)
      io.regfile_wrData2(i) := DontCare
    }
  }

  io.thread_finish := branchU.io.finish
  io.thread_new_pc := branchU.io.pcOut.asUInt
}
