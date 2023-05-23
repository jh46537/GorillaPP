import chisel3._
import chisel3.util._

class inputUnit(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val in_valid     = Input(Bool())
    val in_tag       = Input(UInt(log2Up(num_threads).W))
    val in_data      = Input(UInt(512.W))
    val in_empty     = Input(UInt(6.W))
    val in_last      = Input(Bool())
    val in_ready     = Output(Bool())

    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_flag     = Output(UInt(ip_width.W))
    val out_wen      = Output(Vec(2, Bool()))
    val out_addr     = Output(Vec(2, UInt(num_regs_lg.W)))
    val out_data     = Output(Vec(2, UInt(reg_width.W)))

    val idle_threads = Input(Vec(num_threads, Bool()))
    val new_thread   = Output(Bool())
    val new_tag      = Output(UInt(log2Up(num_threads).W))

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rd        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(32.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())

    // To output unit
    val pkt_buf_data  = Output(new pkt_buf_t(num_threads))
    val pkt_buf_valid = Output(Bool())
    val pkt_buf_ready = Input(Bool())
  })
  // opcode(0) = 0: not write back, 1: write back
  // opcode(1) = 0: not shift, 1: shift
  // opcode(2) = 0: parse not done, 1: parse done
  // opcode(3) = 0: select imm, 1: select reg

  val threadState = RegInit(0.U(1.W))
  val sThreadEncoder = Module(new RREncode(num_threads))
  val sThread = sThreadEncoder.io.chosen

  sThreadEncoder.io.valid := io.idle_threads
  sThreadEncoder.io.ready := sThread =/= (num_threads.U)
  io.new_thread := false.B
  io.new_tag := sThread
  when (threadState === 0.U) {
    when (io.in_valid && io.in_ready && (sThread =/= (num_threads.U))) {
      io.new_thread := true.B
      when (!io.in_last) {
        threadState := 1.U
      }
    }
  } .otherwise {
    when (io.ar_valid && (io.ar_opcode(2) === 1.U)) {
      threadState := 0.U
    }
  }

  val inputCore = Module(new inputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads))
  inputCore.io.in_valid := io.in_valid
  inputCore.io.in_tag := io.in_tag
  inputCore.io.in_data := io.in_data
  inputCore.io.in_empty := io.in_empty
  inputCore.io.in_last := io.in_last
  io.in_ready := inputCore.io.in_ready
  inputCore.io.ar_valid := io.ar_valid
  inputCore.io.ar_tag := io.ar_tag
  inputCore.io.ar_opcode := io.ar_opcode
  inputCore.io.ar_rd := io.ar_rd
  inputCore.io.ar_bits := io.ar_bits
  inputCore.io.ar_imm := io.ar_imm
  io.ar_ready := inputCore.io.ar_ready
  inputCore.io.out_ready := io.out_ready
  io.out_valid := inputCore.io.out_valid
  io.out_tag   := inputCore.io.out_tag
  io.out_wen(0)   := inputCore.io.out_wen
  io.out_addr(0)  := inputCore.io.out_addr
  io.out_data(0)  := inputCore.io.out_data
  io.out_wen(1) := false.B
  io.out_addr(1) := 0.U
  io.out_data(1) := DontCare
  io.out_flag := 0.U

  io.pkt_buf_data := inputCore.io.pkt_buf_data
  io.pkt_buf_valid := inputCore.io.pkt_buf_valid
  inputCore.io.pkt_buf_ready := io.pkt_buf_ready

}