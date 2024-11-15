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
  val outputSpec = Module(new outputUnit_spec(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  outputCore.io.out_ready     := io.out_ready
  outputCore.io.ar_valid      := false.B
  outputCore.io.ar_tag        := io.ar_tag
  outputCore.io.ar_opcode     := io.ar_opcode
  outputCore.io.ar_rs         := io.ar_rs
  outputCore.io.ar_bits       := io.ar_bits
  outputCore.io.ar_imm        := io.ar_imm
  outputCore.io.pkt_buf_data  := io.pkt_buf_data
  outputCore.io.pkt_buf_valid := io.pkt_buf_valid
  outputCore.io.rd_req_ready  := io.rd_req_ready
  outputCore.io.rd_rsp_valid  := false.B
  outputCore.io.rd_rsp        := io.rd_rsp


  outputSpec.io.out_ready     := false.B
  outputSpec.io.ar_valid      := false.B
  outputSpec.io.ar_tag        := io.ar_tag
  outputSpec.io.ar_opcode     := io.ar_opcode
  outputSpec.io.ar_rs         := io.ar_rs
  outputSpec.io.ar_bits       := io.ar_bits
  outputSpec.io.ar_imm        := io.ar_imm
  outputSpec.io.pkt_buf_data  := io.pkt_buf_data
  outputSpec.io.pkt_buf_valid := io.pkt_buf_valid
  outputSpec.io.rd_req_ready  := io.rd_req_ready
  outputSpec.io.rd_rsp_valid  := false.B
  outputSpec.io.rd_rsp        := io.rd_rsp

  val arState = RegInit(0.U(4.W))
  val outState = RegInit(0.U(4.W))
  val tag_r = Reg(UInt(log2Up(num_threads).W))
  val coreFifo = Module(new Queue(UInt(log2Up(num_threads).W), num_threads))

  coreFifo.io.enq.valid := outputCore.io.r_valid
  coreFifo.io.enq.bits := outputCore.io.r_tag

  when (io.ar_opcode(2)) {
    io.ar_ready := outputSpec.io.ar_ready
  } .otherwise {
    io.ar_ready := true.B
  }
  when (io.ar_valid) {
    when (io.ar_opcode(2)) {
      outputSpec.io.ar_valid := true.B
    } .otherwise {
      outputCore.io.ar_valid := true.B
    }
  }


  io.rd_req_valid := false.B
  io.rd_req := DontCare
  io.rd_rsp_ready := false.B
  io.r_valid := coreFifo.io.deq.valid
  io.r_tag := coreFifo.io.deq.bits
  coreFifo.io.deq.ready := true.B
  io.r_flag := 0.U
  io.out_valid := false.B
  io.out_tag := DontCare
  io.out_data := DontCare
  io.out_empty := DontCare
  io.out_last := false.B
  io.pkt_buf_ready := outputCore.io.pkt_buf_ready
  when (outState === 0.U) {
    // Specialized output unit
    io.rd_req_valid := outputSpec.io.rd_req_valid
    io.rd_req := outputSpec.io.rd_req
    outputSpec.io.rd_rsp_valid := io.rd_rsp_valid
    io.rd_rsp_ready := outputSpec.io.rd_rsp_ready
    outputSpec.io.out_ready := io.out_ready
    io.out_valid := outputSpec.io.out_valid
    io.out_tag := outputSpec.io.out_tag
    io.out_data := outputSpec.io.out_data
    io.out_empty := outputSpec.io.out_empty
    io.out_last := outputSpec.io.out_last
    tag_r := outputSpec.io.r_tag
    when (outputSpec.io.r_valid) {
      coreFifo.io.deq.ready := false.B
      io.r_valid := true.B
      io.r_flag := outputSpec.io.r_flag
      io.r_tag := outputSpec.io.r_tag
      when (outputSpec.io.r_early) {
        outState := 2.U
      } .otherwise {
        outState := 1.U
      }
    }
  } .elsewhen (outState === 1.U) {
    // drain the pkt fifo
    io.rd_req_valid := outputSpec.io.rd_req_valid
    io.rd_req := outputSpec.io.rd_req
    outputSpec.io.rd_rsp_valid := io.rd_rsp_valid
    io.rd_rsp_ready := outputSpec.io.rd_rsp_ready
    io.out_valid := io.pkt_buf_valid
    io.out_tag := io.pkt_buf_data.tag
    io.out_data := io.pkt_buf_data.data
    io.out_empty := io.pkt_buf_data.empty
    io.out_last := io.pkt_buf_data.last
    io.pkt_buf_ready := io.out_ready
    when (io.pkt_buf_data.last) {
      outState := 0.U
    }
  } .elsewhen (outState === 2.U) {
    // Generalized output unit
    io.pkt_buf_ready := outputCore.io.pkt_buf_ready
    io.rd_req_valid := outputCore.io.rd_req_valid
    io.rd_req := outputCore.io.rd_req
    outputCore.io.rd_rsp_valid := io.rd_rsp_valid
    io.rd_rsp_ready := outputCore.io.rd_rsp_ready
    io.out_valid := outputCore.io.out_valid
    io.out_tag := outputCore.io.out_tag
    io.out_data := outputCore.io.out_data
    io.out_empty := outputCore.io.out_empty
    io.out_last := outputCore.io.out_last
    when (outputCore.io.r_valid && outputCore.io.r_tag === tag_r) {
      outState := 0.U
    }
  }

}