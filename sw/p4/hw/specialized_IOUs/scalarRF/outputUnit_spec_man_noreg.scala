import chisel3._
import chisel3.util._

class outputUnit_spec(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_data     = Output(UInt(512.W))
    val out_empty    = Output(UInt(6.W))
    val out_last     = Output(Bool())

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rs        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(32.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())

    val r_valid      = Output(Bool())
    val r_early      = Output(Bool())
    val r_flag       = Output(UInt(ip_width.W))
    val r_tag        = Output(UInt(log2Up(num_threads).W))

    // from input unit
    val pkt_buf_data  = Input(new pkt_buf_t(num_threads))
    val pkt_buf_valid = Input(Bool())
    val pkt_buf_ready = Output(Bool())

    // dump regfile interface
    val rd_req_valid  = Output(Bool())
    val rd_req_ready  = Input(Bool())
    val rd_req        = Output(new BFU_regfile_req_t(log2Up(num_threads), num_regs_lg))
    val rd_rsp_valid  = Input(Bool())
    val rd_rsp_ready  = Output(Bool())
    val rd_rsp        = Input(new BFU_regfile_rsp_t(reg_width))
  })
  // opcode(0) = 0: set meta, 1: emit hdr
  // imm(5, 0): length

  val port = RegInit(0.U(9.W))
  val mcast_grp = RegInit(0.U(16.W))
  val outReqState = RegInit(0.U(4.W))
  val outRspState = RegInit(0.U(4.W))
  val threadDone = RegInit(VecInit(Seq.fill(num_threads)(false.B)))
  val hdrModeMem = Reg(Vec(num_threads, UInt(8.W)))
  
  val hdr_mode = RegInit(0.U(8.W))
  val tag_r = Reg(UInt(log2Up(num_threads).W))
  val is_early = RegInit(false.B)
  val r_flag = Reg(UInt(ip_width.W))
  val out_hdr_mode = RegInit(0.U(8.W))
  val out_tag = Reg(UInt(log2Up(num_threads).W))
  val out_buf = Reg(UInt(512.W))
  val out_valid = RegInit(false.B)
  val out_last = RegInit(false.B)
  val out_empty = Reg(UInt(6.W))
  val rd_rsp_buf = Reg(UInt(reg_width.W))

  io.ar_ready := true.B
  when (io.ar_valid) {
    threadDone(io.ar_tag) := true.B
    hdrModeMem(io.ar_tag) := io.ar_bits(7, 0)
  }

  io.rd_req_valid := false.B
  io.rd_req := DontCare
  io.rd_req.tag := io.pkt_buf_data.tag
  when (outReqState === 0.U) {
    when (io.pkt_buf_valid) {
      hdr_mode := hdrModeMem(io.pkt_buf_data.tag)
      when (threadDone(io.pkt_buf_data.tag)) {
        io.rd_req_valid := true.B
        io.rd_req.rdAddr1 := 1.U
        io.rd_req.rdAddr2 := 2.U
        when (io.rd_req_ready) {
          outReqState := 1.U
        }
      }
    }
  } .elsewhen (outReqState === 1.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 3.U
    io.rd_req.rdAddr2 := 4.U
    when (io.rd_req_ready) {
      when (hdr_mode > 1.U) {
        outReqState := 2.U
      } .otherwise {
        outReqState := 9.U
      }
    }
  } .elsewhen (outReqState === 2.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 5.U
    io.rd_req.rdAddr2 := 6.U
    when (io.rd_req_ready) {
      outReqState := 3.U
    }
  } .elsewhen (outReqState === 3.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 7.U
    io.rd_req.rdAddr2 := 8.U
    when (io.rd_req_ready) {
      outReqState := 4.U
    }
  } .elsewhen (outReqState === 4.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 9.U
    io.rd_req.rdAddr2 := 10.U
    when (io.rd_req_ready) {
      when (hdr_mode > 3.U) {
        outReqState := 5.U
      } .otherwise {
        outReqState := 9.U
      }
    }
  } .elsewhen (outReqState === 5.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 11.U
    io.rd_req.rdAddr2 := 12.U
    when (io.rd_req_ready) {
      when (hdr_mode > 5.U) {
        outReqState := 6.U
      } .otherwise {
        outReqState := 9.U
      }
    }
  } .elsewhen (outReqState === 6.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 13.U
    io.rd_req.rdAddr2 := 14.U
    when (io.rd_req_ready) {
      when (hdr_mode > 7.U) {
        outReqState := 7.U
      } .otherwise {
        outReqState := 9.U
      }
    }
  } .elsewhen (outReqState === 7.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 15.U
    io.rd_req.rdAddr2 := 16.U
    when (io.rd_req_ready) {
      when (hdr_mode > 9.U) {
        outReqState := 8.U
      } .otherwise {
        outReqState := 9.U
      }
    }
  } .elsewhen (outReqState === 8.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 17.U
    io.rd_req.rdAddr1 := 17.U
    when (io.rd_req_ready) {
      outReqState := 9.U
    }
  } .elsewhen (outReqState === 9.U) {
    outReqState := 0.U
    threadDone(io.pkt_buf_data.tag) := false.B
  }

  io.r_valid := false.B
  io.r_flag := r_flag
  io.r_early := is_early
  io.r_tag := out_tag
  io.pkt_buf_ready := false.B
  io.rd_rsp_ready := false.B
  when (outRspState === 0.U) {
    is_early := false.B
    r_flag := 0.U
    out_valid := false.B
    io.rd_rsp_ready := true.B
    out_hdr_mode := hdrModeMem(io.pkt_buf_data.tag)
    when (io.rd_rsp_valid) {
      out_tag := io.pkt_buf_data.tag
      out_buf := Cat(0.U, io.rd_rsp.rdData2(47, 0), io.rd_rsp.rdData1(47, 0))
      outRspState := 1.U
    }
  } .elsewhen (outRspState === 1.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    when (io.rd_rsp_valid) {
      out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(15, 0), out_buf(95, 0))
      out_last := false.B
      out_empty := 50.U
      when (out_hdr_mode < 2.U) {
        is_early := true.B
        r_flag := 108.U
        out_valid := true.B
        outRspState := 11.U
      } .otherwise {
        outRspState := 2.U
      }
    }
  } .elsewhen (outRspState === 2.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    when (io.rd_rsp_valid) {
      out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(63, 0), out_buf(175, 0))
      outRspState := 3.U
    }
  } .elsewhen (outRspState === 3.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    when (io.rd_rsp_valid) {
      out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(63, 0), out_buf(303, 0))
      outRspState := 4.U
    }
  } .elsewhen (outRspState === 4.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    when (io.rd_rsp_valid) {
      out_buf := Cat(io.rd_rsp.rdData2(47, 0), io.rd_rsp.rdData1(31, 0), out_buf(431, 0))
      rd_rsp_buf := io.rd_rsp.rdData2
      out_last := false.B
      out_valid := true.B
      when (out_hdr_mode < 3.U) {
        out_empty := 6.U
        outRspState := 11.U
      } .otherwise {
        out_empty := 0.U
        outRspState := 5.U
      }
    }
  } .elsewhen (outRspState === 5.U) {
    when (io.out_ready) {
      out_valid := false.B
      io.rd_rsp_ready := true.B
      when (out_hdr_mode < 4.U) {
        out_buf := Cat(0.U, rd_rsp_buf(63, 48))
        out_empty := 54.U
        out_last := false.B
        out_valid := true.B
        outRspState := 11.U
      }.elsewhen (io.rd_rsp_valid) {
        out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(63, 0), rd_rsp_buf(63, 48))
        when (out_hdr_mode < 5.U) {
          out_empty := 46.U
          outRspState := 11.U
        } .otherwise {
          outRspState := 6.U
        }
      }
    }
  } .elsewhen (outRspState === 6.U) {
    when (io.out_ready) {
      out_valid := false.B
      io.rd_rsp_ready := true.B
      when (io.rd_rsp_valid) {
        out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(63, 0), out_buf(143, 0))
        out_last := false.B
        out_valid := true.B
        when (out_hdr_mode < 6.U) {
          out_empty := 38.U
          outRspState := 11.U
        } .elsewhen (out_hdr_mode < 7.U) {
          out_empty := 30.U
          outRspState := 11.U
        } .otherwise {
          outRspState := 7.U
        }
      }
    }
  } .elsewhen (outRspState === 7.U) {
    when (io.out_ready) {
      out_valid := false.B
      io.rd_rsp_ready := true.B
      when (io.rd_rsp_valid) {
        out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(63, 0), out_buf(271, 0))
        out_last := false.B
        out_valid := true.B
        when (out_hdr_mode < 8.U) {
          out_empty := 22.U
          outRspState := 11.U
        } .elsewhen (out_hdr_mode < 9.U) {
          out_empty := 14.U
          outRspState := 11.U
        } .otherwise {
          outRspState := 8.U
        }
      }
    }
  } .elsewhen (outRspState === 8.U) {
    when (io.out_ready) {
      out_valid := false.B
      io.rd_rsp_ready := true.B
      when (io.rd_rsp_valid) {
        out_buf := Cat(0.U, io.rd_rsp.rdData1(63, 0), out_buf(399, 0))
        out_last := false.B
        out_valid := true.B
        outRspState := 11.U
        out_empty := 6.U
      }
    }
  } .elsewhen (outRspState === 11.U) {
    when (io.out_ready || !out_valid) {
      out_valid := false.B
      io.r_valid := true.B
      io.r_tag := out_tag
      outRspState := 0.U
    }
  }

  io.out_valid := out_valid
  io.out_tag := out_tag
  io.out_empty := out_empty
  io.out_last := out_last
  io.out_data := out_buf

}