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

  val outputCore = Module(new outputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  outputCore.io.out_ready     := io.out_ready
  io.out_valid                   := outputCore.io.out_valid
  io.out_tag                     := outputCore.io.out_tag
  io.out_data                    := outputCore.io.out_data
  io.out_empty                   := outputCore.io.out_empty
  io.out_last                    := outputCore.io.out_last
  outputCore.io.ar_valid      := io.ar_valid
  outputCore.io.ar_tag        := io.ar_tag
  outputCore.io.ar_opcode     := io.ar_opcode
  outputCore.io.ar_rs         := io.ar_rs
  outputCore.io.ar_bits       := io.ar_bits
  outputCore.io.ar_imm        := io.ar_imm
  io.ar_ready                    := outputCore.io.ar_ready
  io.r_valid                     := outputCore.io.r_valid
  io.r_flag                      := outputCore.io.r_flag
  io.r_tag                       := outputCore.io.r_tag
  outputCore.io.pkt_buf_data  := io.pkt_buf_data
  outputCore.io.pkt_buf_valid := io.pkt_buf_valid
  io.pkt_buf_ready               := outputCore.io.pkt_buf_ready
  io.rd_req_valid                := outputCore.io.rd_req_valid
  outputCore.io.rd_req_ready  := io.rd_req_ready
  io.rd_req                      := outputCore.io.rd_req
  outputCore.io.rd_rsp_valid  := io.rd_rsp_valid
  io.rd_rsp_ready                := outputCore.io.rd_rsp_ready
  outputCore.io.rd_rsp        := io.rd_rsp

}