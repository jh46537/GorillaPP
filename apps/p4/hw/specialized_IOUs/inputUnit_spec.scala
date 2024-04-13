import chisel3._
import chisel3.util._
import chisel3.util.Fill

class inputUnit_wrap extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val i_clk             = Input(Clock())
    val i_rst             = Input(Reset())

    val stream_in_t_val   = Input(Bool())
    val stream_in_t_rdy   = Output(Bool())
    val stream_in_t_msg   = Input(UInt(523.W))

    val cmd_in_t_val      = Input(Bool())
    val cmd_in_t_rdy      = Output(Bool())
    val cmd_in_t_msg      = Input(UInt(79.W))

    val bfu_out_t_val     = Output(Bool())
    val bfu_out_t_rdy     = Input(Bool())
    val bfu_out_t_msg     = Output(UInt(434.W))

    // To output unit
    val pkt_buf_out_t_val = Output(Bool())
    val pkt_buf_out_t_rdy = Input(Bool())
    val pkt_buf_out_t_msg = Output(UInt(523.W))
  })

  addResource("/inputUnit_wrap.v")
}

class inputUnit_spec(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(log2Up(num_threads).W))
    val in_data       = Input(UInt(512.W))
    val in_empty      = Input(UInt(6.W))
    val in_last       = Input(Bool())
    val in_ready      = Output(Bool())

    val out_ready     = Input(Bool())
    val out_valid     = Output(Bool())
    val out_early     = Output(Bool())
    val out_tag       = Output(UInt(log2Up(num_threads).W))
    val out_flag      = Output(UInt(ip_width.W))
    val out_wen       = Output(Vec(2, Bool()))
    val out_addr      = Output(Vec(2, UInt(num_regs_lg.W)))
    val out_data      = Output(Vec(2, UInt(reg_width.W)))

    val ar_valid      = Input(Bool())
    val ar_tag        = Input(UInt(log2Up(num_threads).W))
    val ar_opcode     = Input(UInt(opcode_width.W))
    val ar_rd         = Input(UInt(num_regs_lg.W))
    val ar_bits       = Input(UInt(32.W))
    val ar_imm        = Input(UInt(32.W))
    val ar_ready      = Output(Bool())

    // To output unit
    val pkt_buf_data  = Output(new pkt_buf_t(num_threads))
    val pkt_buf_valid = Output(Bool())
    val pkt_buf_ready = Input(Bool())
  })

  val inputU_inst = Module(new inputUnit_wrap)
  val tag_width = log2Up(num_threads)

  inputU_inst.io.i_clk := clock
  inputU_inst.io.i_rst := reset

  inputU_inst.io.stream_in_t_val := io.in_valid
  inputU_inst.io.stream_in_t_msg := Cat(io.in_last, io.in_empty, io.in_data, io.in_tag)
  io.in_ready := inputU_inst.io.stream_in_t_rdy

  inputU_inst.io.cmd_in_t_val := io.ar_valid
  inputU_inst.io.cmd_in_t_msg := Cat(io.ar_imm, io.ar_bits, io.ar_rd, io.ar_opcode, io.ar_tag)
  io.ar_ready := inputU_inst.io.cmd_in_t_rdy

  val bfu_out_done = inputU_inst.io.bfu_out_t_msg(tag_width+ip_width)
  io.out_valid := inputU_inst.io.bfu_out_t_val && bfu_out_done
  inputU_inst.io.bfu_out_t_rdy := io.out_ready
  io.out_tag := inputU_inst.io.bfu_out_t_msg(tag_width-1, 0)
  io.out_flag := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width-1, tag_width)
  io.out_early := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+1)
  io.out_wen(0) := inputU_inst.io.bfu_out_t_val && inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+2)
  io.out_addr(0) := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+2, tag_width+ip_width+3)
  io.out_data(0) := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+reg_width+2, tag_width+ip_width+num_regs_lg+3)
  io.out_wen(1) := inputU_inst.io.bfu_out_t_val && inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+reg_width+3)
  io.out_addr(1) := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg*2+reg_width+3, tag_width+ip_width+num_regs_lg+reg_width+4)
  io.out_data(1) := inputU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg*2+reg_width*2+3, tag_width+ip_width+num_regs_lg*2+reg_width+4)

  io.pkt_buf_valid := inputU_inst.io.pkt_buf_out_t_val
  inputU_inst.io.pkt_buf_out_t_rdy := io.pkt_buf_ready
  io.pkt_buf_data.tag := inputU_inst.io.pkt_buf_out_t_msg(tag_width-1, 0)
  io.pkt_buf_data.data := inputU_inst.io.pkt_buf_out_t_msg(tag_width+512-1, tag_width)
  io.pkt_buf_data.empty := inputU_inst.io.pkt_buf_out_t_msg(tag_width+6+512-1, tag_width+512)
  io.pkt_buf_data.last := inputU_inst.io.pkt_buf_out_t_msg(tag_width+6+512)
}