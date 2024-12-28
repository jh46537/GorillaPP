  // /****************** Start Thread *********************************/
  // /****************** Scheduler logic *********************************/
  // // select idle thread
  // val vThreadEncoder = Module(new Scheduler_order(NUM_THREADS, NUM_RD_BANKS))

  // when (ioUnit.io.new_thread) {  // make ioUnit.io.new_thread as an input 
  //   // spawn new thread
  //   threadStages(ioUnit.io.new_tag) := ThreadStageEnum.order_fetch  // threadStages and threadStates as output 
  //   threadStates(ioUnit.io.new_tag).ip := 0.U((IP_WIDTH+2).W)       // ioUnit.io.new_tag as input, name it as ioUnit_new_tag
  //   vThreadEncoder.io.valid := true.B
  //   vThreadEncoder.io.tag := ioUnit.io.new_tag                    
  //   println("Primate core spawning new thread!")
  // } .otherwise {
  //   vThreadEncoder.io.valid := false.B
  //   vThreadEncoder.io.tag := DontCare
  // }

  
  // // select valid thread
  // val vThread = vThreadEncoder.io.chosen              // vThread as output
  // Range(0, NUM_THREADS, 1).map(i =>
  //   vThreadEncoder.io.order_ready(i) := (threadStages(i) === ThreadStageEnum.order_fetch))  // no warries on ThreadStageEnum, it can be view gloabal
  // Range(0, NUM_THREADS, 1).map(i =>
  //   vThreadEncoder.io.ready(i) := (threadStages(i) === ThreadStageEnum.fetch))

import chisel3._
import chisel3.util._
import chisel3.util.Fill

class SchedulerLogic(NUM_THREADS: Int, NUM_RD_BANKS: Int, IP_WIDTH: Int) extends Module {
    val io = IO(new Bundle {
        // Inputs
        val ioUnit_new_thread = Input(Bool())                          // Signal to indicate a new thread spawn
        val ioUnit_new_tag = Input(UInt(log2Up(NUM_THREADS).W))        // Signal for the new thread's tag   // Output(UInt(log2Up(num_threads).W))
        val threadStages = Input(Vec(NUM_THREADS, ThreadStageEnum.Type()))   // To update thread stages
        // Outputs
        val vThread = Output(UInt((log2Up(NUM_THREADS)+1).W))        // Chosen valid thread   //Output(UInt((log2Up(num_threads)+1).W))
    })

    // Scheduler module instantiation
    val vThreadEncoder = Module(new Scheduler_order(NUM_THREADS, NUM_RD_BANKS))
    
    // New thread spawning logic
    when(io.ioUnit_new_thread) {
        // Configure vThreadEncoder for a new thread
        vThreadEncoder.io.valid := true.B
        vThreadEncoder.io.tag := io.ioUnit_new_tag
        println("Primate core spawning new thread!")
    }.otherwise {
        vThreadEncoder.io.valid := false.B
        vThreadEncoder.io.tag := DontCare
    }

    // Select a valid thread
    io.vThread := vThreadEncoder.io.chosen

    Range(0, NUM_THREADS, 1).map(i =>
      vThreadEncoder.io.order_ready(i) := (io.threadStages(i) === ThreadStageEnum.order_fetch))
    Range(0, NUM_THREADS, 1).map(i =>
      vThreadEncoder.io.ready(i) := (io.threadStages(i) === ThreadStageEnum.fetch))
}