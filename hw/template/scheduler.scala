// primate scheduler logic

// keeps track of in-flight threads
// thread status
// thread instruction pointer

// dispatches a new thread each cycle that out_ready is asserted
// unless no idle threads are available

// threadstate register ports: 2 wr / 1 rd
// thread IP register ports: 2 wr / 1 rd

import chisel3._
import chisel3.util._

object ThreadState extends ChiselEnum {
  val free = Value // thread becomes free after thread terminates (how to determine?)
  val idle = Value // thread becomes idle after previous instr retires
  val inflight = Value // thread inflight while an instruction is un-retired in pipe
}

class Scheduler(conf: PrimateConfig) extends Module {
  val io = IO(new Bundle {
    // BR Unit
    val br_en     = Input(Bool())
    val br_tid    = Input(UInt(conf.TAGWIDTH.W))
    val br_target = Input(UInt(conf.IP_WIDTH.W))

    // retire (TODO: from which stage?)
    val retire    = Input(Bool())
    val ret_tid   = Input(UInt(conf.TAGWIDTH.W))
    
    // Fetch
    val out_tid   = Output(UInt(conf.TAGWIDTH.W))
    val out_ip    = Output(UInt(conf.IP_WIDTH.W))
    val out_valid = Output(Bool())
    val out_ready = Input(Bool())
  })

  // initial instruction pointer
  val init_ip = 0.U(conf.IP_WIDTH.W)

  // number of tags supported by TAGWIDTH (2 ^ TAGWIDTH)
  val num_tags = math.pow(2.0, conf.TAGWIDTH).toInt
  // num_tag registers of width IP_WIDTH initialized to 0
  val t_instr_p = RegInit(VecInit(Seq.fill(num_tags)(0.U(conf.IP_WIDTH.W))))
  // num_tag registers of enum ThreadState initialized to free
  val t_state = RegInit(VecInit(Seq.fill(num_tags)(ThreadState.free)))
  // current thread_id to dispatch
  val thread_id = RegInit(0.U(conf.TAGWIDTH.W))

  // update IP
  when (io.br_en) {
    t_instr_p(io.br_tid) := io.br_target
  }

  // update threadstate
  when (io.retire) {
    t_state(io.ret_tid) := ThreadState.idle
  }

  // output
  when(io.out_ready) {
    t_state(thread_id) := ThreadState.inflight
    thread_id := thread_id + 1.U
  }
  io.out_tid := thread_id
  io.out_ip := Mux(t_state(thread_id) === ThreadState.free, init_ip, t_instr_p(thread_id))
  io.out_valid := t_state(thread_id) === ThreadState.free || t_state(thread_id) === ThreadState.idle
}
