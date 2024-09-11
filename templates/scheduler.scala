import chisel3._
import chisel3.util._
import chisel3.util.Fill

class Scheduler(num_threads: Int, num_regfile: Int) extends Module {
  val io = IO(new Bundle {
    val valid = Input(Vec(num_threads, Bool()))
    val chosen = Output(UInt((log2Up(num_threads)+1).W))
  })
  val thread = RegInit(0.U(log2Up(num_regfile).W))
  val chosen_i = Wire(Vec(num_regfile, UInt((log2Up(num_threads)+1).W)))
  for (i <- 0 until num_regfile) {
    val cases = (0 until (num_threads/num_regfile)).map( x => io.valid(x * num_regfile + i) -> (x * num_regfile + i).U)
    chosen_i(i) := MuxCase(num_threads.U, cases)
  }
  thread := thread + 1.U

  io.chosen := chosen_i(thread)
}

class Scheduler_order(num_threads: Int, num_regfile: Int) extends Module {
  val io = IO(new Bundle {
    val valid = Input(Bool())
    val tag = Input(UInt((log2Up(num_threads)).W))
    val order_ready = Input(Vec(num_threads, Bool()))
    val ready = Input(Vec(num_threads, Bool()))
    val chosen = Output(UInt((log2Up(num_threads)+1).W))
  })
  val thread = RegInit(0.U(log2Up(num_regfile).W))
  val thread_count = RegInit(0.U((log2Up(num_threads) + 1).W))
  val fifo = Module(new Queue(UInt((log2Up(num_threads)).W), num_threads))
  thread := thread + 1.U
  val chosen_i = Wire(Vec(num_regfile, UInt((log2Up(num_threads)+1).W)))
  for (i <- 0 until num_regfile) {
    val cases = (0 until (num_threads/num_regfile)).map( x => io.ready(x * num_regfile + i) -> (x * num_regfile + i).U)
    chosen_i(i) := MuxCase(num_threads.U, cases)
  }
  thread := thread + 1.U

  fifo.io.enq.valid := false.B
  fifo.io.enq.bits := DontCare
  when (io.valid) {
    fifo.io.enq.valid := true.B
    fifo.io.enq.bits := io.tag
  }

  io.chosen := num_threads.U
  fifo.io.deq.ready := false.B
  // deq fifo
  val tag = fifo.io.deq.bits
  when (fifo.io.count > 0.U && (tag(log2Up(num_regfile)-1, 0) === thread) && io.order_ready(tag)) {
    io.chosen := fifo.io.deq.bits
    fifo.io.deq.ready := true.B
  } .otherwise {
    io.chosen := chosen_i(thread)
  }
}