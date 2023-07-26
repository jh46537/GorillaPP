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

  // opcode(2) = 0: parse not done, 1: parse done

  val PKT_BUF_DEPTH = 512

  val threadState = RegInit(0.U(1.W))
  val pktFifo = Module(new Queue(new pkt_buf_t(num_threads), PKT_BUF_DEPTH))
  val parseState = RegInit(0.U(4.W))
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
  val hdr_count = Reg(UInt(4.W))

  io.ar_ready := false.B
  io.in_ready := false.B
  out_flag := 0.U
  pktFifo.io.enq.valid := false.B
  pktFifo.io.enq.bits := DontCare
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
        wrAddr(1) := 22.U
        wrData(0) := io.in_data(111, 0)
        wrData(1) := 1.U
        out_valid := io.in_last
        out_tag := io.ar_tag
        pkt_data_buf := io.in_data(511, 112)
        pkt_empty := 14.U
        parseState := 11.U
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
          wrAddr(0) := 3.U
          wrAddr(1) := 4.U
          wrData(0) := in_data_buf(463, 272)
          wrData(1) := Cat(io.in_data(15, 0), in_data_buf(511, 464))
          when (in_data_buf(479, 464) === 0.U) {
            wen(1) := true.B
            parseState := 2.U
          } .otherwise {
            parseState := 3.U
          }
        }
      } .otherwise {
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 3.U
        wrAddr(1) := 22.U
        wrData(0) := in_data_buf(463, 272)
        wrData(1) := 2.U
        out_valid := last_buf
        pkt_data_buf := in_data_buf(511, 464)
        pkt_empty := 58.U
        parseState := 11.U
      }
    }
  } .elsewhen (parseState === 2.U) {
    // output header_0
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := false.B
      wrAddr(0) := 22.U
      wrData(0) := 3.U
      out_valid := last_buf
      pkt_data_buf := in_data_buf(511, 16)
      pkt_empty := 2.U
      parseState := 11.U
    }
  } .elsewhen (parseState === 3.U) {
    // output header_1, header_2, header_3
    when (io.out_ready) {
      wen(1) := true.B
      wrAddr(1) := 4.U
      wrData(1) := Cat(in_data_buf(79, 16), wrData(1)(63, 0))
      when (in_data_buf(31, 16) === 0.U) {
        // header_1
        pkt_data_buf := in_data_buf(511, 80)
        pkt_empty := 10.U
        wen(0) := true.B
        wrAddr(0) := 22.U
        wrData(0) := 4.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(95, 80) === 0.U) {
        // header_1, header_2
        pkt_data_buf := in_data_buf(511, 144)
        pkt_empty := 18.U
        hdr_count := 5.U
        wen(0) := true.B
        wrAddr(0) := 5.U
        wrData(0) := in_data_buf(207, 80)
        parseState := 5.U
      } .elsewhen (in_data_buf(159, 144) === 0.U) {
        // header_1, header_2, header_3
        pkt_data_buf := in_data_buf(511, 208)
        pkt_empty := 26.U
        hdr_count := 6.U
        wen(0) := true.B
        wrAddr(0) := 5.U
        wrData(0) := in_data_buf(207, 80)
        parseState := 5.U
      } .otherwise {
        wen(0) := true.B
        wrAddr(0) := 5.U
        wrData(0) := in_data_buf(207, 80)
        parseState := 4.U
      }
    }
  } .elsewhen (parseState === 4.U) {
    // output header_4, header_5, header_6, header_7
    when (io.out_ready) {
      wen(0) := true.B
      wrAddr(0) := 6.U
      wrData(0) := in_data_buf(335, 208)
      when (in_data_buf(223, 208) === 0.U) {
        pkt_data_buf := in_data_buf(511, 272)
        pkt_empty := 34.U
        wen(1) := true.B
        wrAddr(1) := 22.U
        wrData(1) := 7.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(287, 272) === 0.U) {
        pkt_data_buf := in_data_buf(511, 336)
        pkt_empty := 42.U
        wen(1) := true.B
        wrAddr(1) := 22.U
        wrData(1) := 8.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(351, 336) === 0.U) {
        pkt_data_buf := in_data_buf(511, 400)
        pkt_empty := 50.U
        hdr_count := 9.U
        wen(1) := true.B
        wrAddr(1) := 7.U
        wrData(1) := in_data_buf(463, 336)
        parseState := 5.U
      } .otherwise {
        pkt_data_buf := in_data_buf(511, 464)
        pkt_empty := 58.U
        hdr_count := 10.U
        wen(1) := true.B
        wrAddr(1) := 7.U
        wrData(1) := in_data_buf(463, 336)
        parseState := 5.U
      }
    }
  } .elsewhen (parseState === 5.U) {
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := false.B
      wrAddr(0) := 22.U
      wrData(0) := hdr_count
      out_valid := last_buf
      parseState := 11.U
    }
  } .elsewhen (parseState === 11.U) {
    // drain buf
    when (io.out_ready) {
      out_valid := false.B
      wen(0) := false.B
      wen(1) := false.B
      when (pktFifo.io.enq.ready) {
        val pktFifo_in = Wire(new pkt_buf_t(num_threads))
        pktFifo_in.data := pkt_data_buf
        pktFifo_in.last := last_buf
        pktFifo_in.tag := out_tag
        pktFifo_in.empty := pkt_empty
        pktFifo.io.enq.bits := pktFifo_in
        pktFifo.io.enq.valid := true.B
        when (last_buf) {
          parseState := 0.U
        } .otherwise {
          parseState := 12.U
        }
      }
    }
  } .elsewhen (parseState === 12.U) {
    // drain packet
    when (io.in_valid) {
      pktFifo.io.enq.valid := true.B
      pktFifo.io.enq.bits.data := io.in_data
      pktFifo.io.enq.bits.empty := io.in_empty
      pktFifo.io.enq.bits.last := io.in_last
      pktFifo.io.enq.bits.tag := out_tag
      when (pktFifo.io.enq.ready) {
        io.in_ready := true.B
        when (io.in_last) {
          out_valid := true.B
          parseState := 0.U
        }
      }
    }
  }

  io.out_valid := out_valid
  io.out_wen := wen
  io.out_tag := out_tag
  io.out_addr := wrAddr
  io.out_flag := out_flag
  io.out_data := wrData

  io.pkt_buf_data := pktFifo.io.deq.bits
  io.pkt_buf_valid := pktFifo.io.deq.valid
  pktFifo.io.deq.ready := io.pkt_buf_ready

}