//////////////////////////////////////////////////////////////////////////
///
///  Module thread_state
///
///  responsible for managing thread states
///  Contains a memory for storing idle threads
///  Provides an interface for the scheduler to select a thread to run down the pipe
//////////////////////////////////////////////////////////////////////////

// These classes (and most of the template) are convoluted trash.


import chisel3._

class ThreadState(config: PrimateConfig) extends Bundle {
    val tag         = UInt((config.TAGWIDTH*2).W) // tag used to ID the current thread 
    val invalid     = Bool()                // 
    // FIXME: input -> rf & rf -> output            
    val ip          = UInt((config.IP_WIDTH+2).W)          // current instruction pointer

    val bfuValids   = Vec(config.NUM_BFUS, Bool())         // BFU decode valids
    val execValids  = Vec(config.NUM_BFUS, Bool())         // BFU result valids
    val io_dstPC    = UInt(config.IP_WIDTH.W)         // Branch target
    val execDone    = Bool()
    val finish      = Bool()
}

class ThreadMem(config: PrimateConfig) extends Bundle {
    val brUcodes   = new BRMicrocodes(config.NUM_ALUS, config.NUM_FUS)
    val rdWrEn     = Vec(config.NUM_FUS, Bool())
    val rd         = Vec(config.NUM_FUS, UInt(config.NUM_REGS_LG.W))
    val rd_pos     = Vec(config.NUM_ALUS, UInt(config.NUM_DST_POS_LG.W))
    val rd_mode    = Vec(config.NUM_ALUS, UInt(config.NUM_DST_MODES_LG.W))
}

class ThreadStateIO(config: PrimateConfig) extends Bundle {
    val threadState = Output(new ThreadState(config))
}

class ThreadMemIO(config: PrimateConfig) extends Bundle {
    val threadMem = Output(new ThreadMem(config))
}

class ThreadStateManager(config: PrimateConfig) extends Module{
    val threadStateOut = IO(new ThreadStateIO(config))
    val threadMemOut   = IO(new ThreadMemIO(config))

    val threadStates = Reg(Vec(config.NUM_THREADS, new ThreadState(config)))
    val threadStages = RegInit(VecInit(Seq.fill(config.NUM_THREADS)(ThreadStages.idle)))
    val threadMem = Module(new ram_simple2port(config.NUM_THREADS, (new ThreadMem(config)).getWidth))
}