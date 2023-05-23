import chisel3._
import chisel3.util._

class outputUnit(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
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
  // opcode(1) = 0: deparse not done, 1: deparse done
  // imm(5, 0): length

  val outputCore = Module(new outputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  outputCore.io.out_ready     := io.out_ready

  outputCore.io.ar_valid      := false.B
  outputCore.io.ar_tag        := io.ar_tag
  outputCore.io.ar_opcode     := io.ar_opcode
  outputCore.io.ar_rs         := io.ar_rs
  outputCore.io.ar_bits       := io.ar_bits
  outputCore.io.ar_imm        := io.ar_imm
  io.r_valid                     := outputCore.io.r_valid
  io.r_flag                      := outputCore.io.r_flag
  io.r_tag                       := outputCore.io.r_tag
  outputCore.io.pkt_buf_data  := io.pkt_buf_data
  outputCore.io.pkt_buf_valid := io.pkt_buf_valid
  io.pkt_buf_ready               := outputCore.io.pkt_buf_ready
  outputCore.io.rd_req_ready  := io.rd_req_ready
  outputCore.io.rd_rsp_valid  := false.B
  outputCore.io.rd_rsp        := io.rd_rsp

  val outReqState = RegInit(0.U(3.W))
  val outRspState = RegInit(0.U(3.W))
  val threadDone = RegInit(VecInit(Seq.fill(num_threads)(false.B)))
  val hdrModeMem = Reg(Vec(num_threads, UInt(8.W)))
  
  val r_valid_r = RegInit(false.B)
  val hdr_mode = RegInit(0.U(8.W))
  val tag_r = Reg(UInt(log2Up(num_threads).W))
  val ar_tag_r = Reg(UInt(log2Up(num_threads).W))
  val out_hdr_mode = RegInit(0.U(8.W))
  val out_tag = Reg(UInt(log2Up(num_threads).W))
  val out_buf = Reg(UInt(512.W))
  val out_valid = RegInit(false.B)
  val out_last = RegInit(false.B)
  val out_empty = Reg(UInt(6.W))

  io.r_flag := 0.U
  io.ar_ready := true.B
  r_valid_r := false.B
  when (io.ar_valid) {
    when (io.ar_opcode(1)) {
      threadDone(io.ar_tag) := true.B
      hdrModeMem(io.ar_tag) := io.ar_bits(7, 0)
    } .otherwise {
      outputCore.io.ar_valid := true.B
      ar_tag_r := io.ar_tag
      r_valid_r := true.B
    }
  }


  io.rd_req_valid := false.B
  io.rd_req := DontCare
  io.rd_req.tag := io.pkt_buf_data.tag
  when (outReqState === 0.U) {
    when (io.pkt_buf_valid) {
      hdr_mode := hdrModeMem(io.pkt_buf_data.tag)
      when (threadDone(io.pkt_buf_data.tag)) {
        tag_r := io.pkt_buf_data.tag
        io.rd_req_valid := true.B
        io.rd_req.rdAddr1 := 1.U
        io.rd_req.rdAddr2 := 2.U
        when (io.rd_req_ready) {
          when (hdrModeMem(io.pkt_buf_data.tag) > 1.U) {
            outReqState := 1.U
          } .otherwise {
            outReqState := 3.U
          }
        }
      }
    }
  } .elsewhen (outReqState === 1.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 3.U
    io.rd_req.rdAddr2 := 4.U
    when (io.rd_req_ready) {
      when (hdr_mode < 3.U) {
        outReqState := 3.U
      } .otherwise {
        outReqState := 2.U
      }
    }
  } .elsewhen (outReqState === 2.U) {
    io.rd_req_valid := true.B
    io.rd_req.rdAddr1 := 4.U
    io.rd_req.rdAddr2 := 5.U
    when (io.rd_req_ready) {
      outReqState := 3.U
    }
  } .elsewhen (outReqState === 3.U) {
    threadDone(io.pkt_buf_data.tag) := false.B
    when (!io.ar_valid && (outRspState === 3.U)) {
      outReqState := 4.U
      outputCore.io.ar_valid := true.B
      outputCore.io.ar_tag := io.pkt_buf_data.tag
      outputCore.io.ar_opcode := 2.U
    }
  } .elsewhen (outReqState === 4.U) {
    io.rd_req_valid := outputCore.io.rd_req_valid
    io.rd_req := outputCore.io.rd_req
    when (outputCore.io.r_valid && outputCore.io.r_tag === tag_r) {
      outReqState := 0.U
    }
  }

  io.r_valid := r_valid_r
  io.r_tag := ar_tag_r
  io.rd_rsp_ready := false.B
  when (outRspState === 0.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    out_hdr_mode := hdrModeMem(io.pkt_buf_data.tag)
    when (io.rd_rsp_valid) {
      out_tag := io.pkt_buf_data.tag
      out_buf := Cat(0.U, io.rd_rsp.rdData2(159, 0), io.rd_rsp.rdData1(111, 0))
      out_last := false.B
      out_empty := 50.U
      when (out_hdr_mode < 2.U) {
        out_valid := true.B
        outRspState := 3.U
      } .otherwise {
        outRspState := 1.U
      }
    }
  } .elsewhen (outRspState === 1.U) {
    out_valid := false.B
    io.rd_rsp_ready := true.B
    when (io.rd_rsp_valid) {
      out_buf := Cat(io.rd_rsp.rdData2(47, 0), io.rd_rsp.rdData1(191, 0), out_buf(271, 0))
      out_last := false.B
      out_valid := true.B
      when (out_hdr_mode < 3.U) {
        out_empty := 6.U
        outRspState := 3.U
      } .otherwise {
        out_empty := 0.U
        outRspState := 2.U
      }
    }
  } .elsewhen (outRspState === 2.U) {
    when (io.out_ready) {
      out_valid := false.B
      io.rd_rsp_ready := true.B
      when (io.rd_rsp_valid) {
        out_valid := true.B
        out_buf := Cat(0.U, io.rd_rsp.rdData2(63, 0), io.rd_rsp.rdData1(15, 0))
        out_last := false.B
        when (out_hdr_mode < 4.U) {
          out_empty := 62.U
        } .otherwise {
          out_empty := 54.U
        }
        outRspState := 3.U
      }
    }
  } .elsewhen (outRspState === 3.U) {
    // dump out pkt_buf
    outputCore.io.rd_rsp_valid := io.rd_rsp_valid
    io.rd_rsp_ready := outputCore.io.rd_rsp_ready
    out_valid := outputCore.io.out_valid
    out_tag := outputCore.io.out_tag
    out_empty := outputCore.io.out_empty
    out_last := outputCore.io.out_last
    out_buf := outputCore.io.out_data
    when (outputCore.io.r_valid && outputCore.io.r_tag === tag_r) {
      outRspState := 4.U
    }
  } .elsewhen (outRspState === 4.U) {
    when (io.out_ready || !out_valid) {
      out_valid := false.B
      when (!r_valid_r) {
        io.r_valid := true.B
        io.r_tag := out_tag
        outRspState := 0.U
      }
    }
  }

  io.out_valid := out_valid
  io.out_tag := out_tag
  io.out_empty := out_empty
  io.out_last := out_last
  io.out_data := out_buf

}