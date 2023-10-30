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
  // opcode(4) = 0: select generalized unit, 1: select specialized unit

  val inputCore = Module(new inputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads))
  val inputSpec = Module(new inputUnit_spec(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))
  val coreFifo = Module(new Queue(new pkt_buf_t(num_threads), 4))
  val threadState = RegInit(0.U(1.W))
  val parseState = RegInit(0.U(3.W))
  val sThreadEncoder = Module(new RREncode(num_threads))
  val sThread = sThreadEncoder.io.chosen

  sThreadEncoder.io.valid := io.idle_threads
  sThreadEncoder.io.ready := sThread =/= (num_threads.U)
  io.new_thread := false.B
  io.new_tag := sThread
  when (threadState === 0.U) {
    when (io.in_valid && (sThread =/= (num_threads.U))) {
      io.new_thread := true.B
      threadState := 1.U
    }
  } .otherwise {
    when (io.in_last && io.in_ready) {
      threadState := 0.U
    }
  }

  val ar_tag = Reg(UInt(log2Up(num_threads).W))
  val isLast = Reg(Bool())
  val parseDone = RegInit(false.B)

  inputCore.io.in_valid := coreFifo.io.deq.valid
  inputCore.io.in_tag := DontCare
  inputCore.io.in_data := coreFifo.io.deq.bits.data
  inputCore.io.in_empty := coreFifo.io.deq.bits.empty
  inputCore.io.in_last := coreFifo.io.deq.bits.last
  coreFifo.io.deq.ready := inputCore.io.in_ready
  inputCore.io.ar_valid := false.B
  inputCore.io.ar_tag := DontCare
  inputCore.io.ar_opcode := 0.U
  inputCore.io.ar_rd := io.ar_rd
  inputCore.io.ar_bits := io.ar_bits
  inputCore.io.ar_imm := io.ar_imm
  inputCore.io.out_ready := io.out_ready

  io.pkt_buf_data := inputCore.io.pkt_buf_data
  io.pkt_buf_valid := inputCore.io.pkt_buf_valid
  inputCore.io.pkt_buf_ready := io.pkt_buf_ready

  inputSpec.io.in_valid := io.in_valid
  inputSpec.io.in_tag := io.in_tag
  inputSpec.io.in_data :=  io.in_data
  inputSpec.io.in_empty := io.in_empty
  inputSpec.io.in_last := io.in_last
  inputSpec.io.ar_valid := false.B
  inputSpec.io.ar_tag := io.ar_tag
  inputSpec.io.ar_opcode:= io.ar_opcode
  inputSpec.io.ar_rd := io.ar_rd
  inputSpec.io.ar_bits := io.ar_bits
  inputSpec.io.ar_imm := io.ar_imm
  inputSpec.io.out_ready := io.out_ready
  inputSpec.io.pkt_buf_ready := coreFifo.io.enq.ready

  io.ar_ready := false.B
  io.in_ready := false.B
  io.out_valid := false.B
  io.out_tag := DontCare
  io.out_flag := 0.U
  io.out_wen(0) := false.B
  io.out_wen(1) := false.B
  io.out_addr := DontCare
  io.out_data := DontCare
  coreFifo.io.enq.valid := false.B
  coreFifo.io.enq.bits := DontCare
  when (parseState === 0.U) {
    // IDLE
    isLast := false.B
    parseDone := false.B
    // when (io.ar_opcode(4) === 1.U) {
      io.ar_ready := inputSpec.io.ar_ready
    // } .otherwise {
      // io.ar_ready := inputCore.io.ar_ready
    // }
    when (io.ar_valid) {
      ar_tag := io.ar_tag
      // when (io.ar_opcode(4) === 1.U) {
        inputSpec.io.ar_valid := true.B
        when (inputSpec.io.ar_ready) {
          parseState := 1.U
        }
      // } .otherwise {
      //   inputCore.io.ar_valid := true.B
      //   inputCore.io.ar_tag := io.ar_tag
      //   inputCore.io.ar_opcode := io.ar_opcode
      //   when (inputCore.io.ar_ready) {
      //     parseState := 3.U
      //   }
      // }
    }
  } .elsewhen (parseState === 1.U) {
    io.out_tag  := inputSpec.io.out_tag
    io.out_flag := inputSpec.io.out_flag
    io.out_wen  := inputSpec.io.out_wen
    io.out_addr := inputSpec.io.out_addr
    io.out_data := inputSpec.io.out_data
    io.in_ready := inputSpec.io.in_ready
    coreFifo.io.enq.valid := inputSpec.io.pkt_buf_valid
    coreFifo.io.enq.bits := inputSpec.io.pkt_buf_data
    when (inputSpec.io.out_valid) {
      when (!inputSpec.io.out_early) {
        // Parse done
        io.out_valid := false.B
        isLast := inputSpec.io.pkt_buf_data.last
        parseState := 2.U
      } .otherwise {
        io.out_valid := true.B
        parseState := 3.U
      }
    }
  } .elsewhen (parseState === 2.U) {
    inputCore.io.ar_valid := true.B
    inputCore.io.ar_tag := ar_tag
    inputCore.io.ar_opcode := 4.U
    parseDone := true.B
    when (inputCore.io.ar_ready) {
      when (isLast) {
        parseState := 5.U
      } .otherwise {
        parseState := 3.U
      }
    }
  } .elsewhen (parseState === 3.U) {
    // Use the inputCore and stream in the packet
    inputCore.io.ar_valid := io.ar_valid
    inputCore.io.ar_tag := io.ar_tag
    inputCore.io.ar_opcode := io.ar_opcode
    io.ar_ready := inputCore.io.ar_ready
    when (io.ar_valid && inputCore.io.ar_ready) {
      parseDone := io.ar_opcode(2)
    }

    io.out_valid := inputCore.io.out_valid
    io.out_tag := inputCore.io.out_tag
    io.out_wen(0) := inputCore.io.out_wen
    io.out_addr(0) := inputCore.io.out_addr
    io.out_data(0) := inputCore.io.out_data
    io.out_wen(1) := false.B

    io.in_ready := coreFifo.io.enq.ready
    when (io.in_valid) {
      val coreFifo_in = Wire(new pkt_buf_t(num_threads))
      coreFifo_in.data := io.in_data
      coreFifo_in.tag := io.in_tag
      coreFifo_in.empty := io.in_empty
      coreFifo_in.last := io.in_last
      coreFifo.io.enq.bits := coreFifo_in
      coreFifo.io.enq.valid := true.B
      when (coreFifo.io.enq.ready) {
        when (io.in_last) {
          when (parseDone) {
            parseState := 5.U
          } .otherwise {
            parseState := 4.U
          }
        }
      }
    }
  } .elsewhen (parseState === 4.U) {
    // Use the inputCore and wait for processing the current packet
    inputCore.io.ar_valid := io.ar_valid
    inputCore.io.ar_tag := io.ar_tag
    inputCore.io.ar_opcode := io.ar_opcode
    io.ar_ready := inputCore.io.ar_ready
    when (io.ar_valid && inputCore.io.ar_ready) {
      parseDone := io.ar_opcode(2)
    }

    io.out_valid := inputCore.io.out_valid
    io.out_tag := inputCore.io.out_tag
    io.out_wen(0) := inputCore.io.out_wen
    io.out_addr(0) := inputCore.io.out_addr
    io.out_data(0) := inputCore.io.out_data
    io.out_wen(1) := false.B
    when (inputCore.io.out_valid && parseDone) {
      parseState := 5.U
    }
  } .elsewhen (parseState === 5.U) {
    // Wait for the inputCore
    io.out_valid := inputCore.io.out_valid
    io.out_tag := inputCore.io.out_tag
    io.out_wen(0) := inputCore.io.out_wen
    io.out_addr(0) := inputCore.io.out_addr
    io.out_data(0) := inputCore.io.out_data
    io.out_wen(1) := false.B
    when (inputCore.io.out_valid) {
      parseState := 0.U
    }
  }

}