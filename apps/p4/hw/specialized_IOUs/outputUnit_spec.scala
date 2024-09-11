import chisel3._
import chisel3.util._

class outputUnit_wrap extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val i_clk             = Input(Clock())
    val i_rst             = Input(Reset())

    val stream_out_t_val  = Output(Bool())
    val stream_out_t_rdy  = Input(Bool())
    val stream_out_t_msg  = Output(UInt(523.W))

    val cmd_in_t_val      = Input(Bool())
    val cmd_in_t_rdy      = Output(Bool())
    val cmd_in_t_msg      = Input(UInt(79.W))

    val bfu_out_t_val     = Output(Bool())
    val bfu_out_t_rdy     = Input(Bool())
    val bfu_out_t_msg     = Output(UInt(37.W))

    val bfu_rdreq_t_val   = Output(Bool())
    val bfu_rdreq_t_rdy   = Input(Bool())
    val bfu_rdreq_t_msg   = Output(UInt(14.W))

    val bfu_rdrsp_t_val   = Input(Bool())
    val bfu_rdrsp_t_rdy   = Output(Bool())
    val bfu_rdrsp_t_msg   = Input(UInt(384.W))
  })

  addResource("/outputUnit_wrap.v")
}

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

  val outputU_inst = Module(new outputUnit_wrap)
  val tag_width = log2Up(num_threads)

  val threadDone = RegInit(VecInit(Seq.fill(num_threads)(false.B)))
  val hdrModeMem = Reg(Vec(num_threads, UInt(8.W)))
  val tag_r = Reg(UInt(tag_width.W))
  val outState = RegInit(0.U(1.W))

  io.pkt_buf_ready := false.B
  io.ar_ready := true.B
  when (io.ar_valid) {
    threadDone(io.ar_tag) := true.B
    hdrModeMem(io.ar_tag) := io.ar_bits(7, 0)
  }

  outputU_inst.io.cmd_in_t_val := false.B
  outputU_inst.io.cmd_in_t_msg := DontCare
  when (outState === 0.U) {
    when (io.pkt_buf_valid) {
      when (threadDone(io.pkt_buf_data.tag)) {
        outputU_inst.io.cmd_in_t_val := true.B
        val bits_in = Wire(UInt(32.W))
        val tag_in = Wire(UInt(tag_width.W))
        tag_in := io.pkt_buf_data.tag
        bits_in := hdrModeMem(io.pkt_buf_data.tag)
        tag_r := io.pkt_buf_data.tag
        outputU_inst.io.cmd_in_t_msg := Cat(bits_in, tag_in)
        when (outputU_inst.io.cmd_in_t_rdy) {
          outState := 1.U
        }
      }
    }
  } .otherwise {
    threadDone(tag_r) := false.B
    outState := 0.U
  }

  outputU_inst.io.i_clk := clock
  outputU_inst.io.i_rst := reset

  io.out_valid := outputU_inst.io.stream_out_t_val
  outputU_inst.io.stream_out_t_rdy := io.out_ready
  io.out_tag := outputU_inst.io.stream_out_t_msg(tag_width-1, 0)
  io.out_data := outputU_inst.io.stream_out_t_msg(tag_width+512-1, tag_width)
  io.out_empty := outputU_inst.io.stream_out_t_msg(tag_width+6+512-1, tag_width+512)
  io.out_last := outputU_inst.io.stream_out_t_msg(tag_width+6+512)

  io.r_valid := outputU_inst.io.bfu_out_t_val
  outputU_inst.io.bfu_out_t_rdy := true.B
  io.r_tag := outputU_inst.io.bfu_out_t_msg(tag_width-1, 0)
  io.r_flag := outputU_inst.io.bfu_out_t_msg(tag_width+ip_width-1, tag_width)
  io.r_early := outputU_inst.io.bfu_out_t_msg(tag_width+ip_width)

  io.rd_req_valid := outputU_inst.io.bfu_rdreq_t_val
  outputU_inst.io.bfu_rdreq_t_rdy := io.rd_req_ready
  io.rd_req.tag := outputU_inst.io.bfu_rdreq_t_msg(tag_width-1, 0)
  io.rd_req.rdAddr1 := outputU_inst.io.bfu_rdreq_t_msg(tag_width+num_regs_lg-1, tag_width)
  io.rd_req.rdAddr2 := outputU_inst.io.bfu_rdreq_t_msg(tag_width+num_regs_lg*2-1, tag_width+num_regs_lg)
  outputU_inst.io.bfu_rdrsp_t_val := io.rd_rsp_valid
  io.rd_rsp_ready := outputU_inst.io.bfu_rdrsp_t_rdy
  outputU_inst.io.bfu_rdrsp_t_msg := Cat(io.rd_rsp.rdData2, io.rd_rsp.rdData1)

}