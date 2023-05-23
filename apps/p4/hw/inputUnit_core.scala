import chisel3._
import chisel3.util._

class Shifter(num_bytes: Int) extends Module {
  val io = IO(new Bundle{
    val fifo_valid       = Input(Bool())
    val fifo_in          = Input(Vec(num_bytes, UInt(8.W)))
    val fifo_in_last     = Input(Bool())
    val fifo_in_empty    = Input(UInt(log2Up(num_bytes).W))
    val shift_read_width = Input(UInt((log2Up(num_bytes)+1).W))
    val in_valid         = Input(Bool())
    val shift_en         = Input(Bool())
    val read_en          = Input(Bool())
    val clear            = Input(Bool())
    val in_ready         = Output(Bool())
    val fifo_ready       = Output(Bool())
    val out_valid        = Output(Bool())
    val out_data         = Output(UInt((num_bytes*8).W))
    val buf_data         = Output(UInt((num_bytes*8).W))
    val buf_length       = Output(UInt((log2Up(num_bytes)+1).W))
    val buf_last         = Output(Bool())
  })

  val buf_r = Reg(Vec(num_bytes, UInt(8.W)))
  val fifo_in_r = Reg(Vec(num_bytes, UInt(8.W)))
  val out_buf = Reg(Vec(num_bytes, UInt(8.W)))
  val length_buf = RegInit(0.U((log2Up(num_bytes)+1).W))
  val empty_fifo = RegInit(0.U((log2Up(num_bytes)+1).W))
  val valid_r = RegInit(false.B)
  val buf_out = Wire(Vec(num_bytes, UInt(8.W)))
  val shift = Wire(UInt((log2Up(num_bytes)+1).W))
  val remain_r = Reg(UInt((log2Up(num_bytes)+1).W))
  val fifo_shift_r = Reg(SInt((log2Up(num_bytes)+1).W))
  val shift_r = RegInit(0.U((log2Up(num_bytes)+1).W))
  val isLast = RegInit(false.B)

  shift_r := shift
  remain_r := length_buf - shift
  fifo_in_r := io.fifo_in
  fifo_shift_r := length_buf.asSInt - shift.asSInt - empty_fifo.asSInt
  for (i <- 0 until num_bytes) {
    when (i.U < remain_r) {
      buf_out(i) := buf_r(i.U + shift_r)
    } .otherwise {
      buf_out(i) := fifo_in_r((i.S - fifo_shift_r).asUInt)
    }
  }

  val shift_state = RegInit(0.U(1.W))

  io.fifo_ready := false.B
  io.out_valid := false.B
  valid_r := false.B
  shift := 0.U
  io.in_ready := false.B
  when (shift_state === 0.U) {
    when (io.in_valid && (io.shift_read_width <= length_buf)) {
      io.in_ready := true.B
      valid_r := true.B
      out_buf := buf_r
      when (io.shift_en) {
        shift_state := 1.U
        shift := io.shift_read_width
        when (io.fifo_valid) {
          when (length_buf - io.shift_read_width <= empty_fifo + io.fifo_in_empty) {
            length_buf := length_buf - io.shift_read_width + 32.U - empty_fifo - io.fifo_in_empty
            empty_fifo := 0.U
            isLast := io.fifo_in_last
            io.fifo_ready := true.B
          } .otherwise {
            length_buf := 32.U
            empty_fifo := empty_fifo + (32.U - length_buf + io.shift_read_width)
          }
        } .otherwise {
          length_buf := length_buf - io.shift_read_width
        }
      }
    } .elsewhen(!io.clear) {
      shift := 0.U
      valid_r := false.B
      io.in_ready := false.B
      when (io.fifo_valid) {
        when (length_buf =/= 32.U) {
          shift_state := 1.U
        }
        when (length_buf <= empty_fifo) {
          length_buf := length_buf + 32.U - empty_fifo
          empty_fifo := 0.U
          isLast := io.fifo_in_last
          io.fifo_ready := true.B
        } .otherwise {
          length_buf := 32.U
          empty_fifo := empty_fifo + (32.U - length_buf)
        }
      }
    } .otherwise {
      isLast := false.B
      length_buf := 0.U
      empty_fifo := 0.U
    }
  } .otherwise {
    buf_r := buf_out
    shift_state := 0.U
  }

  io.out_valid := valid_r
  io.out_data := out_buf.asUInt
  io.buf_data := buf_r.asUInt
  io.buf_length := length_buf - empty_fifo
  io.buf_last := isLast

}

class inputUnit_core(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int) extends Module {
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
    val out_wen      = Output(Bool())
    val out_addr     = Output(UInt(num_regs_lg.W))
    val out_data     = Output(UInt(reg_width.W))

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

  val PKT_BUF_DEPTH = 512

  val parseFifo_t = new Bundle {
    val bits = UInt(256.W)
    val empty = UInt(6.W)
    val last = Bool()
  }

  val pktFifo = Module(new Queue(new pkt_buf_t(num_threads), PKT_BUF_DEPTH))
  val parseFifo = Module(new Queue(parseFifo_t, 2))
  val parseDone = RegInit(false.B)
  val parseFifoEnqState = RegInit(0.U(1.W))
  val shifter = Module(new Shifter(32))
  val length_buf = RegInit(0.U(7.W))
  val length_fifo = RegInit(0.U(7.W))
  val isLast = RegInit(false.B)

  io.in_ready := false.B
  parseFifo.io.enq.valid := false.B
  parseFifo.io.enq.bits := DontCare
  when (!parseDone || (parseFifoEnqState === 1.U)) {
    when (io.in_valid && parseFifo.io.enq.ready) {
      when (parseFifoEnqState === 0.U) {
        parseFifo.io.enq.valid := true.B
        parseFifo.io.enq.bits.bits := io.in_data(255, 0)
        when (io.in_empty >= 32.U) {
          parseFifo.io.enq.bits.last := io.in_last
          parseFifo.io.enq.bits.empty := io.in_empty - 32.U
        } .otherwise {
          parseFifo.io.enq.bits.last := false.B
          parseFifo.io.enq.bits.empty := 0.U
        }
        parseFifoEnqState := 1.U
      } .otherwise {
        parseFifo.io.enq.bits.bits := io.in_data(511, 256)
        parseFifo.io.enq.bits.empty := io.in_empty
        when (io.in_empty < 32.U) {
          parseFifo.io.enq.valid := true.B
        }
        parseFifo.io.enq.bits.last := io.in_last
        io.in_ready := true.B
        parseFifoEnqState := 0.U
      }
    }
  }

  val seek_valid = RegInit(false.B)
  val seekState = RegInit(0.U(3.W))
  val tag = Reg(UInt(log2Up(num_threads).W))
  val addr = Reg(UInt(num_regs_lg.W))
  val headerLen = Reg(UInt(6.W))
  val opcode = Reg(UInt(opcode_width.W))
  val fillEn = Reg(Bool())
  val pktFifo_in_r = Reg(UInt(256.W))
  val pktFifo_empty_r = Reg(UInt(6.W))
  val lastSeen = RegInit(false.B)

  shifter.io.fifo_in := parseFifo.io.deq.bits.bits.asTypeOf(chiselTypeOf(shifter.io.fifo_in))
  shifter.io.fifo_in_last := parseFifo.io.deq.bits.last
  shifter.io.fifo_in_empty := parseFifo.io.deq.bits.empty
  shifter.io.fifo_valid := parseFifo.io.deq.valid
  parseFifo.io.deq.ready := shifter.io.fifo_ready
  shifter.io.shift_read_width := 0.U
  shifter.io.in_valid := false.B
  shifter.io.shift_en := false.B
  shifter.io.read_en := false.B
  shifter.io.clear := false.B

  io.out_valid := false.B
  io.out_wen := false.B
  io.out_tag := tag
  io.out_addr := addr
  io.out_data := shifter.io.out_data
  io.ar_ready := false.B
  pktFifo.io.enq.valid := false.B
  pktFifo.io.enq.bits := DontCare
  when (seekState === 0.U) {
    // IDLE
    io.ar_ready := true.B
    when (io.ar_valid) {
      tag := io.ar_tag
      addr := io.ar_rd
      // val ar_src = Mux(io.ar_opcode(3).asBool, io.ar_bits, io.ar_imm)
      val ar_src = io.ar_imm
      headerLen := ar_src(5, 0)
      opcode := io.ar_opcode
      shifter.io.shift_read_width := ar_src(5, 0)
      shifter.io.shift_en := io.ar_opcode(1).asBool
      shifter.io.read_en := io.ar_opcode(0).asBool
      when (io.ar_opcode(1, 0) =/= 0.U) {
        shifter.io.in_valid := true.B
        when (shifter.io.in_ready) {
          seekState := 2.U
        } .otherwise {
          seekState := 1.U
        }
      } .elsewhen (io.ar_opcode(2) === 1.U) {
        parseDone := true.B
        seekState := 4.U
      }
    }
  } .elsewhen (seekState === 1.U) {
    // Resume
    shifter.io.shift_read_width := headerLen
    shifter.io.shift_en := opcode(1).asBool
    shifter.io.read_en := opcode(0).asBool
    shifter.io.in_valid := true.B
    when (shifter.io.in_ready) {
      seekState := 2.U
    }
  } .elsewhen (seekState === 2.U) {
    // Output, shift
    when (opcode(0) === 1.U) {
      io.out_wen := true.B
    }
    when (opcode(0) === 0.U || io.out_ready) {
      when (opcode(2) === 1.U) {
        parseDone := true.B
        seekState := 4.U
      } .otherwise {
        io.out_valid := true.B
        seekState := 0.U
      }
    }
  } .elsewhen (seekState === 4.U) {
    // dump out the remaining data in the buffer
    val pktFifo_in = Wire(new pkt_buf_t(num_threads))
    pktFifo_in.data := shifter.io.buf_data
    pktFifo_in.last := shifter.io.buf_last
    pktFifo_in.tag := tag
    pktFifo_in.empty := 64.U - shifter.io.buf_length
    when (shifter.io.buf_length =/= 0.U) {
      pktFifo.io.enq.valid := true.B
    }
    pktFifo.io.enq.bits := pktFifo_in
    when (pktFifo.io.enq.ready) {
      shifter.io.clear := true.B
      when (shifter.io.buf_last) {
        parseDone := false.B
        seekState := 0.U
      } .otherwise {
        seekState := 5.U
      }
    }
  } .elsewhen (seekState === 5.U) {
    // drain parseFifo
    shifter.io.clear := true.B
    when (parseFifo.io.deq.valid) {
      pktFifo_in_r := parseFifo.io.deq.bits.bits
      pktFifo_empty_r := parseFifo.io.deq.bits.empty
      parseFifo.io.deq.ready := true.B
      seekState := 6.U
      when (parseFifo.io.deq.bits.last) {
        lastSeen := true.B
      }
    } .otherwise {
      seekState := 7.U
    }
  } .elsewhen (seekState === 6.U) {
    shifter.io.clear := true.B
    when (lastSeen || (!parseFifo.io.deq.valid) || (pktFifo_empty_r =/= 0.U)) {
      pktFifo.io.enq.bits.data := pktFifo_in_r
      pktFifo.io.enq.bits.tag := tag
      pktFifo.io.enq.bits.last := lastSeen
      pktFifo.io.enq.bits.empty := 32.U + pktFifo_empty_r
      pktFifo.io.enq.valid := true.B
      when (pktFifo.io.enq.ready) {
        when (lastSeen) {
          parseDone := false.B
          lastSeen := false.B
          seekState := 0.U
        } .elsewhen (!parseFifo.io.deq.valid) {
          seekState := 7.U
        } .otherwise {
          seekState := 5.U
        }
      }
    } .elsewhen (parseFifo.io.deq.valid) {
      pktFifo.io.enq.bits.data := Cat(parseFifo.io.deq.bits.bits, pktFifo_in_r)
      pktFifo.io.enq.bits.tag := tag
      pktFifo.io.enq.bits.last := parseFifo.io.deq.bits.last
      pktFifo.io.enq.bits.empty := pktFifo_empty_r
      pktFifo.io.enq.valid := true.B
      when (pktFifo.io.enq.ready) {
        parseFifo.io.deq.ready := true.B
        when (parseFifo.io.deq.bits.last) {
          parseDone := false.B
          seekState := 0.U
        } .otherwise {
          seekState := 5.U
        }
      }
    }
  } .elsewhen (seekState === 7.U) {
    // drain remaining flits
    shifter.io.clear := true.B
    io.in_ready := pktFifo.io.enq.ready
    when (io.in_valid) {
      pktFifo.io.enq.bits.data := io.in_data
      pktFifo.io.enq.bits.tag := tag
      pktFifo.io.enq.bits.last := io.in_last
      pktFifo.io.enq.bits.empty := io.in_empty
      pktFifo.io.enq.valid := true.B
      when (pktFifo.io.enq.ready) {
        when (io.in_last) {
          io.out_valid := true.B
          parseDone := false.B
          seekState := 0.U
        }
      }
    }
  }

  io.pkt_buf_data := pktFifo.io.deq.bits
  io.pkt_buf_valid := pktFifo.io.deq.valid
  pktFifo.io.deq.ready := io.pkt_buf_ready

}