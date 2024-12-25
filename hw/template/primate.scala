// toplevel module of primate core (template)
// configuration happens with scm.py using configuration from primate.cfg

import chisel3._
import chisel3.util._

class Primate extends Module {
  val io = IO(new Bundle {
    val in = Input(new IO_Extern_Input)
    val out = Output(new IO_Extern_Output)
  })
  val conf = new PrimateConfig("./primate.cfg")

  /************** Front End Logic **************/
  // Front end consists of input from IO unit, a thread scheduler and instruction fetch
  // A new thread is spawned every time IO receives a packet
  // aggressive multi-threading (in applications that support it) negates the need for BP or I$
 
  val iounit = Module(new IOUnit(conf))
  val scheduler = Module(new Scheduler(conf))
  val fetch = Module(new Fetch(conf))

  iounit.io.ex_input := io.in
  io.out := iounit.io.ex_output

  // dummy scheduler logic hookup for now
  scheduler.io.retire := false.B
  scheduler.io.ret_tid := DontCare
  
  scheduler.io.out_ready := iounit.io.valid_io

  fetch.io.ip := scheduler.io.out_ip

  /******************* VLIW ********************/
  // instruction bundles are split into their respective pipelines and decoded
  // each slot has unique capabilities. ex:
  // slot 0: branch and integer
  // slot 1: load/store
  // slot 2+: BFU and integer
  

  // split VLIW slots
  val PipelineWideReg = Vec(conf.NUM_SLOTS, UInt(conf.INSTR_WIDTH.W))

  val instr_r_d = Reg(PipelineWideReg)
  val instr_r_e = Reg(PipelineWideReg)

  when (scheduler.io.out_valid) {
    instr_r_d := fetch.io.instr.asTypeOf(PipelineWideReg)
  }

  /**************** Decode Logic ****************/
  // single issue slots do not need decoders
  // may not be a need for a dedicated decode stage
  //im thinking about removing it alltogether
  
  // use scala collection Seq to hold array of decoders?

  // slot 0 : Branch Unit
  val br_decoder = Module(new BranchDecoder(conf))
  br_decoder.io.instr := instr_r_d(0)
  // slot 1 : Load/Store Unit
  // slot 2+ : merged ALU/BFUs (configurable)
  for (i <- 2 until conf.NUM_SLOTS+1){
    //val decode = Module(new Decode(conf))
    //decode
    //instr_r_e(i) :=
  }

  /****************** RegFile *******************/
  // this is gonna be a convoluted mess probably



  /*************** Execute Logic ****************/
  // TODO: every EX unit needs to keep track of the current thread id (pipes diverge here)
  // slot 0 : Branch Unit
  val br_unit = Module(new BRU(conf))
  br_unit.io <> br_decoder.io
  br_unit.io.r1 := 0.U // DUMMY TODO: connect to regfile
  br_unit.io.r2 := 0.U // DUMMY TODO: connect to regfile

  // update the IP for this thread in the scheduler
  scheduler.io.br_en := br_unit.io.branch
  scheduler.io.br_tid := 0.U// todo current tid
  scheduler.io.br_target := br_unit.io.br_target

  // slot 1 : Load/Store Unit
  // slot 2+ : merged ALU/BFUs (configurable)

}

import _root_.circt.stage.ChiselStage
object PrimateTop extends App {
  ChiselStage.emitSystemVerilogFile(new Primate, Array("--target-dir", "generated"))
}