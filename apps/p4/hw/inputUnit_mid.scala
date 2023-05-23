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

  class coreFifo_t extends Bundle {
    val data = UInt(512.W)
    val empty = UInt(6.W)
    val last = Bool()
  }

  val PKT_BUF_DEPTH = 512

  val inputCore = Module(new inputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads))
  val coreFifo = Module(new Queue(new coreFifo_t, 4))
  val threadState = RegInit(0.U(1.W))
  val parseState = RegInit(0.U(3.W))
  val opcode = Reg(UInt(opcode_width.W))
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

  val wen = RegInit(VecInit(Seq.fill(2)(false.B)))
  val wrData = Reg(Vec(2, UInt(reg_width.W)))
  val wrAddr = Reg(Vec(2, UInt(num_regs_lg.W)))
  val out_valid = RegInit(false.B)
  val out_flag = Reg(UInt(ip_width.W))
  val out_tag = Reg(UInt(log2Up(num_threads).W))
  val in_data_buf = Reg(UInt(512.W))
  val pkt_data_buf = Reg(UInt(512.W))
  val pkt_empty = Reg(UInt(7.W))
  val last_buf = Reg(Bool())
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

  io.ar_ready := false.B
  io.in_ready := false.B
  out_flag := 0.U
  coreFifo.io.enq.valid := false.B
  coreFifo.io.enq.bits := DontCare
  when (parseState === 0.U) {
    // IDLE
    io.ar_ready := io.in_valid
    io.in_ready := io.ar_valid
    when (io.out_ready) {
      wen(0) := false.B
      wen(1) := false.B
      out_valid := false.B
    }
    when (io.in_valid && io.ar_valid) {
      in_data_buf := io.in_data
      last_buf := io.in_last
      parseDone := io.ar_opcode(2)
      when (io.in_data(111, 96) === 0x88f7.U) {
        // parse ethernet
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 1.U
        wrAddr(1) := 2.U
        wrData(0) := io.in_data(111, 0)
        wrData(1) := io.in_data(271, 112)
        out_valid := false.B
        out_tag := io.ar_tag
        parseState := 1.U
      } .otherwise {
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 1.U
        wrAddr(1) := 8.U
        wrData(0) := io.in_data(111, 0)
        wrData(1) := 1.U
        out_valid := io.in_last
        out_tag := io.ar_tag
        pkt_data_buf := io.in_data(511, 112)
        pkt_empty := 14.U
        parseState := 4.U
      }
    }
  } .elsewhen (parseState === 1.U) {
    // parse ptp
    when (io.out_ready) {
      wen(0) := false.B
      wen(1) := false.B
      when (in_data_buf(159, 152) === 1.U) {
        out_valid := false.B
        io.in_ready := true.B
        when (io.in_valid) {
          in_data_buf := io.in_data
          last_buf := io.in_last
          wen(0) := true.B
          wen(1) := true.B
          wrAddr(0) := 3.U
          wrAddr(1) := 4.U
          wrData(0) := in_data_buf(463, 272)
          wrData(1) := Cat(io.in_data(15, 0), in_data_buf(511, 464))
          when (in_data_buf(479, 464) =/= 0.U) {
            parseState := 2.U
          } .otherwise {
            parseState := 3.U
          }
        }
      } .otherwise {
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 3.U
        wrAddr(1) := 8.U
        wrData(0) := in_data_buf(463, 272)
        wrData(1) := 2.U
        out_valid := last_buf
        pkt_data_buf := in_data_buf(511, 464)
        pkt_empty := 58.U
        parseState := 4.U
      }
    }
  } .elsewhen (parseState === 2.U) {
    // output header_0
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := false.B
      wrAddr(0) := 8.U
      wrData(0) := 3.U
      out_valid := last_buf
      pkt_data_buf := in_data_buf(511, 16)
      pkt_empty := 2.U
      parseState := 4.U
    }
  } .elsewhen (parseState === 3.U) {
    // output header_1
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := true.B
      wrAddr(0) := 5.U
      wrAddr(1) := 8.U
      wrData(0) := in_data_buf(79, 16)
      wrData(1) := 4.U
      out_valid := last_buf
      pkt_data_buf := in_data_buf(511, 80)
      pkt_empty := 10.U
      parseState := 4.U
    }
  } .elsewhen (parseState === 4.U) {
    // drain buf
    when (io.out_ready) {
      out_valid := false.B
      wen(0) := false.B
      wen(1) := false.B
      when (coreFifo.io.enq.ready) {
        val coreFifo_in = Wire(new coreFifo_t)
        coreFifo_in.data := pkt_data_buf
        coreFifo_in.last := last_buf
        coreFifo_in.empty := pkt_empty
        coreFifo.io.enq.bits := coreFifo_in
        coreFifo.io.enq.valid := true.B
        inputCore.io.ar_valid := true.B
        inputCore.io.ar_tag := out_tag
        inputCore.io.ar_opcode := 4.U
        when (inputCore.io.ar_ready) {
          parseState := 5.U
        }
      }
    }
  } .elsewhen (parseState === 5.U) {
    // drain packet
    inputCore.io.ar_valid := io.ar_valid
    inputCore.io.ar_tag := io.ar_tag
    inputCore.io.ar_opcode := io.ar_opcode
    io.ar_ready := inputCore.io.ar_ready
    out_valid := inputCore.io.out_valid
    out_tag := inputCore.io.out_tag
    wen(0) := inputCore.io.out_wen
    wrAddr(0) := inputCore.io.out_addr
    wrData(0) := inputCore.io.out_data
    wen(1) := false.B
    wrAddr(1) := DontCare
    wrData(1) := DontCare
    when (io.in_valid) {
      val coreFifo_in = Wire(new coreFifo_t)
      coreFifo_in.data := io.in_data
      coreFifo_in.last := io.in_last
      coreFifo_in.empty := io.in_empty
      coreFifo.io.enq.bits := coreFifo_in
      coreFifo.io.enq.valid := true.B
      when (coreFifo.io.enq.ready) {
        io.in_ready := true.B
        when (io.in_last) {
          when (parseDone) {
            parseState := 7.U
          } .otherwise {
            parseState := 6.U
          }
        }
      }
    }
  } .elsewhen (parseState === 6.U) {
    inputCore.io.ar_valid := io.ar_valid
    inputCore.io.ar_tag := io.ar_tag
    inputCore.io.ar_opcode := io.ar_opcode
    io.ar_ready := inputCore.io.ar_ready
    out_valid := inputCore.io.out_valid
    out_tag := inputCore.io.out_tag
    wen(0) := inputCore.io.out_wen
    wrAddr(0) := inputCore.io.out_addr
    wrData(0) := inputCore.io.out_data
    wen(1) := false.B
    wrAddr(1) := DontCare
    wrData(1) := DontCare
    when (io.ar_valid && (io.ar_opcode(2) === 1.U)) {
      parseState := 7.U
    }
  } .elsewhen (parseState === 7.U) {
    inputCore.io.ar_valid := io.ar_valid
    inputCore.io.ar_tag := io.ar_tag
    inputCore.io.ar_opcode := io.ar_opcode
    io.ar_ready := inputCore.io.ar_ready
    out_valid := inputCore.io.out_valid
    out_tag := inputCore.io.out_tag
    wen(0) := inputCore.io.out_wen
    wrAddr(0) := inputCore.io.out_addr
    wrData(0) := inputCore.io.out_data
    wen(1) := false.B
    wrAddr(1) := DontCare
    wrData(1) := DontCare
    when (inputCore.io.out_valid) {
      parseState := 0.U
    }
  }

  io.out_valid := out_valid
  io.out_wen := wen
  io.out_tag := out_tag
  io.out_addr := wrAddr
  io.out_flag := out_flag
  io.out_data := wrData

  io.pkt_buf_data := inputCore.io.pkt_buf_data
  io.pkt_buf_valid := inputCore.io.pkt_buf_valid
  inputCore.io.pkt_buf_ready := io.pkt_buf_ready

}