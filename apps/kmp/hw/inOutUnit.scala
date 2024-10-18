import chisel3._
import chisel3.util._

class pkt_buf_t(num_threads: Int) extends Bundle {
  val data = UInt(512.W)
  val tag = UInt(log2Up(num_threads).W)
  val empty = UInt(7.W)
  val last = Bool()

  override def cloneType = (new pkt_buf_t(num_threads).asInstanceOf[this.type])
}

class inOutUnit(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends MultiIOModule {
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
    val out_data     = Output(UInt(512.W))
    val out_empty    = Output(UInt(6.W))
    val out_last     = Output(Bool())

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rd        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(reg_width.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())

    val w_ready      = Input(Bool())
    val w_valid      = Output(Bool())
    val w_tag        = Output(UInt(log2Up(num_threads).W))
    val w_flag       = Output(UInt(ip_width.W))
    val w_wen        = Output(Vec(2, Bool()))
    val w_addr       = Output(Vec(2, UInt(num_regs_lg.W)))
    val w_data       = Output(Vec(2, UInt(reg_width.W)))

    val idle_threads = Input(Vec(num_threads, Bool()))
    val new_thread   = Output(Bool())
    val new_tag      = Output(UInt(log2Up(num_threads).W))

    val r_valid      = Output(Bool())
    val r_flag       = Output(UInt(ip_width.W))
    val r_tag        = Output(UInt(log2Up(num_threads).W))

    val rd_req_valid = Output(Bool())
    val rd_req_ready = Input(Bool())
    val rd_req       = Output(new BFU_regfile_req_t(log2Up(num_threads), num_regs_lg))
    val rd_rsp_valid = Input(Bool())
    val rd_rsp_ready = Output(Bool())
    val rd_rsp       = Input(new BFU_regfile_rsp_t(reg_width))

  })

  val ar_ready_in = Wire(Bool())
  val ar_ready_out = Wire(Bool())
  val ar_valid_in = Wire(Bool())
  val ar_valid_out = Wire(Bool())

  io.ar_ready := Mux((io.ar_opcode(opcode_width-1) === 1.U), ar_ready_out, ar_ready_in)
  ar_valid_in := Mux((io.ar_opcode(opcode_width-1) === 1.U), false.B, io.ar_valid)
  ar_valid_out := Mux((io.ar_opcode(opcode_width-1) === 1.U), io.ar_valid, false.B)

  //***************************************************************//
  //***************    Input Unit     *****************************//
  //***************************************************************//
  val inputU = Module(new inputUnit(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  inputU.io.in_valid     := io.in_valid
  inputU.io.in_tag       := io.in_tag
  inputU.io.in_data      := io.in_data
  inputU.io.in_empty     := io.in_empty
  inputU.io.in_last      := io.in_last
  io.in_ready            := inputU.io.in_ready
  inputU.io.out_ready    := io.w_ready
  io.w_valid             := inputU.io.out_valid
  io.w_tag               := inputU.io.out_tag
  io.w_flag              := inputU.io.out_flag
  io.w_wen               := inputU.io.out_wen
  io.w_addr              := inputU.io.out_addr
  io.w_data              := inputU.io.out_data
  inputU.io.idle_threads := io.idle_threads
  io.new_thread          := inputU.io.new_thread
  io.new_tag             := inputU.io.new_tag
  inputU.io.ar_valid     := ar_valid_in
  inputU.io.ar_tag       := io.ar_tag
  inputU.io.ar_opcode    := io.ar_opcode
  inputU.io.ar_rd        := io.ar_rd
  inputU.io.ar_bits      := io.ar_bits
  inputU.io.ar_imm       := io.ar_imm
  ar_ready_in            := inputU.io.ar_ready

  //***************************************************************//
  //***************    Output Unit     ****************************//
  //***************************************************************//

  val outputU = Module(new outputUnit(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  outputU.io.out_ready    := io.out_ready
  io.out_valid            := outputU.io.out_valid
  io.out_tag              := outputU.io.out_tag
  io.out_data             := outputU.io.out_data
  io.out_empty            := outputU.io.out_empty
  io.out_last             := outputU.io.out_last
  outputU.io.ar_valid     := ar_valid_out
  outputU.io.ar_tag       := io.ar_tag
  outputU.io.ar_opcode    := io.ar_opcode
  outputU.io.ar_rs        := io.ar_rd
  outputU.io.ar_bits      := io.ar_bits
  outputU.io.ar_imm       := io.ar_imm
  ar_ready_out            := outputU.io.ar_ready
  io.r_valid              := outputU.io.r_valid
  io.r_flag               := outputU.io.r_flag
  io.r_tag                := outputU.io.r_tag
  io.rd_req_valid         := outputU.io.rd_req_valid
  outputU.io.rd_req_ready := io.rd_req_ready
  io.rd_req               := outputU.io.rd_req
  outputU.io.rd_rsp_valid := io.rd_rsp_valid
  io.rd_rsp_ready         := outputU.io.rd_rsp_ready
  outputU.io.rd_rsp       := io.rd_rsp

  //***************************************************************//
  //*************  Input Unit <->  Output Unit ********************//
  //***************************************************************//

  outputU.io.pkt_buf_data := inputU.io.pkt_buf_data
  outputU.io.pkt_buf_valid := inputU.io.pkt_buf_valid
  inputU.io.pkt_buf_ready := outputU.io.pkt_buf_ready
}