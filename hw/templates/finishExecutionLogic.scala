  // /****************** Finish execution *********************************/
  // val fThreadEncoder = Module(new Scheduler(NUM_THREADS, NUM_WR_BANKS))  // local module
  // val fThread = fThreadEncoder.io.chosen // output
  // val execDone = Wire(Vec(NUM_THREADS, Bool())) // local
  // Range(0, NUM_THREADS, 1).foreach(i =>
  //   execDone(i) := (threadStates(i).execValids.asUInt | (~threadStates(i).bfuValids.asUInt)).andR // pass all threadStates(i) as inputs
  // )

  // Range(0, NUM_THREADS, 1).map(i =>
  //   fThreadEncoder.io.valid(i) := (execDone(i) === true.B && threadStages(i) === ThreadStageEnum.exec)) /// all threadStages(i) as inputs

  // when (fThread =/= NONE_SELECTED) {
  //   threadStages(fThread) := ThreadStageEnum.branch
  //   for (destMem <- destMems) {  // where val destMems = Seq.fill(NUM_WR)(Module(new ram_simple2port(NUM_THREADS, (new DestMemT).getWidth)))
  //     destMem.io.rden := true.B   // make destMem.io.rden as output as destMem.rden
  //     destMem.io.rdaddress := fThread // make  destMem.io.rdaddress as output
  //   }
  //   threadMem.io.rden := true.B // output
  //   threadMem.io.rdaddress := fThread  //output
  // }

import chisel3._
import chisel3.util._
import chisel3.util.Fill

class FinishExecutionLogic(
    NUM_THREADS: Int,
    NUM_WR: Int,
    NUM_WR_BANKS: Int,
    NUM_BFUS: Int,
    NONE_SELECTED: UInt
) extends Module {
  val io = IO(new Bundle {
    // Inputs
    val threadStates_bfuValids = Input(Vec(NUM_THREADS, Vec(NUM_BFUS, Bool())))
    val threadStates_execValids = Input(Vec(NUM_THREADS, Vec(NUM_BFUS, Bool())))
    val threadStages = Input(Vec(NUM_THREADS, ThreadStageEnum.Type())) // Thread stages
    // Outputs
    val fThread = Output(UInt(log2Up(NUM_THREADS + 1).W)) // Chosen thread 
    val threadMem_rden = Output(Bool()) // Thread memory read enable
    val threadMem_rdaddress = Output(UInt(log2Up(NUM_THREADS + 1).W)) // Thread memory read address
    val destMems_rden = Output(Vec(NUM_WR, Bool())) // Destination memory read enable
    val destMems_rdaddress = Output(Vec(NUM_WR, UInt(log2Up(NUM_THREADS + 1).W))) // Destination memory read address
  })

  // Scheduler instantiation
  val fThreadEncoder = Module(new Scheduler(NUM_THREADS, NUM_WR_BANKS))
  io.fThread := fThreadEncoder.io.chosen

  // Compute execDone for each thread
  val execDone = Wire(Vec(NUM_THREADS, Bool()))
  for (i <- 0 until NUM_THREADS) {
    execDone(i) := (io.threadStates_execValids(i).asUInt | (~io.threadStates_bfuValids(i).asUInt)).andR
  }

  // Set valid signals for the scheduler
  for (i <- 0 until NUM_THREADS) {
    fThreadEncoder.io.valid(i) := (execDone(i) === true.B && io.threadStages(i) === ThreadStageEnum.exec)
  }

  // Default outputs
  io.threadMem_rden := false.B
  io.threadMem_rdaddress := DontCare
  io.destMems_rden := VecInit(Seq.fill(NUM_WR)(false.B))
  io.destMems_rdaddress := VecInit(Seq.fill(NUM_WR)(io.fThread))

  // If a thread is selected, update outputs
  when(io.fThread =/= NONE_SELECTED) {
    io.threadMem_rden := true.B
    io.threadMem_rdaddress := io.fThread
    for (i <- 0 until NUM_WR) {
      io.destMems_rden(i) := true.B
      io.destMems_rdaddress(i) := io.fThread
    }
  }
}
