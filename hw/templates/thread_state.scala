//////////////////////////////////////////////////////////////////////////
///
///  Module thread_state
///
///  responsible for managing thread states
///  Contains a memory for storing idle threads
///  Provides an interface for the scheduler to select a thread to run down the pipe
//////////////////////////////////////////////////////////////////////////

import chisel3._

// possible states a thread can be in. used for scheduling decisions
object ThreadStageEnum extends ChiselEnum {
    val idle   = Value         // thread is idle
    val order_fetch = Value    
    val fetch  = Value
    val decode = Value
    val read   = Value
    val pre    = Value
    val exec   = Value
    //val post   = Value
    val branch = Value
  }

class ThreadState(tag_width: Int, ip_width: Int) extends Bundle {
    val tag         = UInt((tag_width*2).W) // tag used to ID the current thread 
    val invalid     = Bool()                // 
    // FIXME: input -> rf & rf -> output            
    val ip          = UInt((ip_width+2).W)          // current instruction pointer

    val bfuValids   = Vec(NUM_BFUS, Bool())         // BFU decode valids
    val execValids  = Vec(NUM_BFUS, Bool())         // BFU result valids
    val io_dstPC    = UInt(ip_width.W)         // Branch target
    val execDone    = Bool()
    val finish      = Bool()
}

class ThreadMem(num_alu: Int, num_bfu: Int, num_fu: Int) extends Bundle {
    val brUcodes   = new BRMicrocodes(num_alu, num_fu)
    val rdWrEn     = Vec(num_fu, Bool())
    val rd         = Vec(num_fu, UInt(NUM_REGS_LG.W))
    val rd_pos     = Vec(num_alu, UInt(NUM_DST_POS_LG.W))
    val rd_mode    = Vec(num_alu, UInt(NUM_DST_MODES_LG.W))
}

class ThreadStateIO(tag_width: Int, ip_width: Int) extends Bundle {
    val threadState = Output(ThreadState(tag_width, ip_width))
}

class ThreadMemIO(num_alu: Int, num_bfu: Int) extends Bundle {
    val threadMem = Output(ThreadMem(num_alu, num_bfu))
}

class ThreadStateManager(tag_width: Int, ip_width: Int, num_threads: Int) extends Module{
    val threadStateOut = IO(new ThreadStateIO)
    val threadMemOut   = IO(new ThreadMemIO)

    val threadStates = Reg(Vec(num_threads, ThreadState))
    val threadStages = RegInit(VecInit(Seq.fill(num_threads)(ThreadStageEnum.idle)))
    val threadMem = Module(new ram_simple2port(num_threads, (new ThreadMem).getWidth))
}