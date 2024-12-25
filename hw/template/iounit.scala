// primate IO Unit
// This unit needs to be very modular to support the various applications of primate
// ex: streaming processor that loads packets from IO into the pipeline
// or: accelerator/co-processor that performs operations on memory after receiving instruction from the CPU

// This module will either need to interface with hardware IO functions, or be directly modified to support a particular app
// maybe this module should exist outside of the top primate module?

import chisel3._
import chisel3.util._


class IO_Extern_Input extends Bundle {

}

class IO_Extern_Output extends Bundle {

}

class IOUnit(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val ex_input = Input(new IO_Extern_Input)
    val ex_output = Output(new IO_Extern_Output)
    val valid_io = Output(Bool())
  })

  io.valid_io := true.B
  // TODO

}
