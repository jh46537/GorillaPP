import chisel3._
import chisel3.util._

class inputUnit_spec(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val in_valid     = Input(Bool())
    val in_tag       = Input(UInt(log2Up(num_threads).W))
    val in_data      = Input(UInt(512.W))
    val in_empty     = Input(UInt(6.W))
    val in_last      = Input(Bool())
    val in_ready     = Output(Bool())

    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_early    = Output(Bool())
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_flag     = Output(UInt(ip_width.W))
    val out_wen      = Output(Vec(2, Bool()))
    val out_addr     = Output(Vec(2, UInt(num_regs_lg.W)))
    val out_data     = Output(Vec(2, UInt(reg_width.W)))

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

  val parseState = RegInit(0.U(4.W))
  val opcode = Reg(UInt(opcode_width.W))

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
  val is_early = RegInit(false.B)

  io.ar_ready := false.B
  io.in_ready := false.B
  out_flag := 0.U
  io.pkt_buf_valid := false.B
  io.pkt_buf_data := DontCare
  when (parseState === 0.U) {
    // IDLE
    io.ar_ready := io.in_valid
    io.in_ready := io.ar_valid
    is_early := false.B
    out_flag := 0.U
    when (io.out_ready) {
      wen(0) := false.B
      wen(1) := false.B
      out_valid := false.B
    }
    when (io.in_valid && io.ar_valid) {
      in_data_buf := io.in_data
      last_buf := io.in_last
      wen(0) := true.B
      wen(1) := true.B
      wrAddr(0) := 1.U
      wrAddr(1) := 2.U
      wrData(0) := io.in_data(47, 0)
      wrData(1) := io.in_data(95, 48)
      out_valid := false.B
      out_tag := io.ar_tag
      parseState := 1.U
    }
  } .elsewhen (parseState === 1.U) {
    when (io.out_ready) {
      when (in_data_buf(111, 96) === 0x88f7.U) {
        // parse ethernet
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 3.U
        wrAddr(1) := 4.U
        wrData(0) := in_data_buf(111, 96)
        wrData(1) := in_data_buf(175, 112)
        out_valid := false.B
        parseState := 2.U
      } .otherwise {
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 3.U
        wrAddr(1) := 22.U
        wrData(0) := in_data_buf(111, 96)
        wrData(1) := 1.U
        out_valid := last_buf
        pkt_data_buf := in_data_buf(511, 112)
        pkt_empty := 14.U
        is_early := true.B
        out_flag := 108.U
        parseState := 11.U
      }
    }
  } .elsewhen (parseState === 2.U) {
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := true.B
      wrAddr(0) := 5.U
      wrAddr(1) := 6.U
      wrData(0) := in_data_buf(239, 176)
      wrData(1) := in_data_buf(303, 240)
      out_valid := false.B
      parseState := 3.U
    }
  } .elsewhen (parseState === 3.U) {
    when (io.out_ready) {
      wen(0) := true.B
      wen(1) := true.B
      wrAddr(0) := 7.U
      wrAddr(1) := 8.U
      wrData(0) := in_data_buf(367, 304)
      wrData(1) := in_data_buf(431, 368)
      out_valid := false.B
      parseState := 4.U
    }
  } .elsewhen (parseState === 4.U) {
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
          wrAddr(0) := 9.U
          wrAddr(1) := 10.U
          wrData(0) := in_data_buf(463, 432)
          wrData(1) := Cat(io.in_data(15, 0), in_data_buf(511, 464))
          when (in_data_buf(479, 464) === 0.U) {
            parseState := 5.U
          } .otherwise {
            parseState := 6.U
          }
        }
      } .otherwise {
        wen(0) := true.B
        wen(1) := true.B
        wrAddr(0) := 9.U
        wrAddr(1) := 22.U
        wrData(0) := in_data_buf(463, 432)
        wrData(1) := 2.U
        out_valid := last_buf
        pkt_data_buf := in_data_buf(511, 464)
        pkt_empty := 58.U
        parseState := 11.U
      }
    }
  } .elsewhen (parseState === 5.U) {
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
  } .elsewhen (parseState === 6.U) {
    // output header_1, header_2
    when (io.out_ready) {
      wen(0) := true.B
      wrData(0) := in_data_buf(79, 16)
      wrAddr(0) := 11.U // header_1
      when (in_data_buf(31, 16) === 0.U) {
        // header_1
        pkt_data_buf := in_data_buf(511, 80)
        wen(1) := true.B
        wrData(1) := 4.U
        wrAddr(1) := 22.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(95, 80) === 0.U) {
        // header_1, header_2
        pkt_data_buf := in_data_buf(511, 144)
        pkt_empty := 18.U
        hdr_count := 5.U
        wen(1) := true.B
        wrAddr(1) := 12.U
        wrData(1) := in_data_buf(143, 80)
        parseState := 10.U
      } .otherwise {
        // header_1, header_2
        wen(1) := true.B
        wrAddr(1) := 12.U
        wrData(1) := in_data_buf(143, 80)
        parseState := 7.U
      }
    }
  } .elsewhen (parseState === 7.U) {
    // output header_3, header_4
    when (io.out_ready) {
      wen(0) := true.B
      wrData(0) := in_data_buf(207, 144)
      wrAddr(0) := 13.U // header_3
      when (in_data_buf(159, 144) === 0.U) {
        // header_3
        pkt_data_buf := in_data_buf(511, 208)
        pkt_empty := 26.U
        wen(1) := true.B
        wrData(1) := 6.U
        wrAddr(1) := 22.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(223, 208) === 0.U) {
        pkt_data_buf := in_data_buf(511, 272)
        pkt_empty := 34.U
        hdr_count := 7.U
        wen(1) := true.B
        wrData(1) := in_data_buf(271, 208)
        wrAddr(1) := 14.U
        parseState := 10.U
      } .otherwise {
        // header_3, header_4
        wen(1) := true.B
        wrData(1) := in_data_buf(271, 208)
        wrAddr(1) := 14.U
        parseState := 8.U
      }
    }
  } .elsewhen (parseState === 8.U) {
    // output header_5, header_6
    when (io.out_ready) {
      wen(0) := true.B
      wrData(0) := in_data_buf(335, 272)
      wrAddr(0) := 15.U
      when (in_data_buf(287, 272) === 0.U) {
        // header_5
        pkt_data_buf := in_data_buf(511, 336)
        pkt_empty := 42.U
        wen(1) := true.B
        wrData(1) := 8.U
        wrAddr(1) := 22.U
        out_valid := last_buf
        parseState := 11.U
      } .elsewhen (in_data_buf(351, 336) === 0.U) {
        pkt_data_buf := in_data_buf(511, 400)
        pkt_empty := 50.U
        hdr_count := 9.U
        wen(1) := true.B
        wrData(1) := in_data_buf(399, 336)
        wrAddr(1) := 16.U
        parseState := 10.U
      } .otherwise {
        // header_5, header_6
        wen(1) := true.B
        wrData(1) := in_data_buf(399, 336)
        wrAddr(1) := 16.U
        parseState := 9.U
      }
    }
  } .elsewhen (parseState === 9.U) {
    // output header_7
    when (io.out_ready) {
      pkt_data_buf := in_data_buf(511, 464)
      pkt_empty := 58.U
      wen(0) := true.B
      wrData(0) := in_data_buf(463, 400)
      wrAddr(0) := 17.U
      wen(1) := true.B
      wrData(1) := 10.U
      wrAddr(1) := 22.U
      out_valid := last_buf
      when (in_data_buf(407, 400) === 0.U) {
        is_early := false.B
      } .otherwise {
        is_early := true.B
        out_flag := 80.U
      }
      parseState := 11.U
    }
  } .elsewhen (parseState === 10.U) {
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
      io.pkt_buf_valid := true.B
      val pktFifo_in = Wire(new pkt_buf_t(num_threads))
      pktFifo_in.data := pkt_data_buf
      pktFifo_in.last := last_buf
      pktFifo_in.tag := out_tag
      pktFifo_in.empty := pkt_empty
      io.pkt_buf_data := pktFifo_in
      when (io.pkt_buf_ready) {
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
      io.pkt_buf_valid := true.B
      io.pkt_buf_data.data := io.in_data
      io.pkt_buf_data.empty := io.in_empty
      io.pkt_buf_data.last := io.in_last
      io.pkt_buf_data.tag := out_tag
      when (io.pkt_buf_ready) {
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
  io.out_early := is_early
  io.out_addr := wrAddr
  io.out_flag := out_flag
  io.out_data := wrData

}