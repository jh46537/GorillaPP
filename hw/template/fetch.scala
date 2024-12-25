// front-end of primate core
// currently only fetches instruction from imem

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFileInline

class Fetch(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    val ip    = Input(UInt(conf.IP_WIDTH.W))
    val instr = Output(UInt(conf.INSTR_WIDTH.W))
  })

  val mem = SyncReadMem(conf.INST_RAM_SIZE, UInt(conf.INSTR_WIDTH.W))
  loadMemoryFromFileInline(mem, "./primate_pgm.bin") // TODO: move filepath to a central config file

  io.instr := mem(io.ip)
}