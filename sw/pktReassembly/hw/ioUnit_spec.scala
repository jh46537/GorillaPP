import chisel3._
import chisel3.util._

class pktReassembly extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val i_clk                      = Input(Clock())
    val i_rst                      = Input(Reset())

    val stream_in_t_val            = Input(Bool())
    val stream_in_t_rdy            = Output(Bool())
    val stream_in_t_msg            = Input(UInt(266.W))

    val stream_out_t_val           = Output(Bool())
    val stream_out_t_rdy           = Input(Bool())
    val stream_out_t_msg           = Output(UInt(266.W))

    val cmd_in_t_val               = Input(Bool())
    val cmd_in_t_rdy               = Output(Bool())
    val cmd_in_t_msg               = Input(UInt(313.W))

    val bfu_out_t_val              = Output(Bool())
    val bfu_out_t_rdy              = Input(Bool())
    val bfu_out_t_msg              = Output(UInt(557.W))

    val unlock_req_t_val           = Output(Bool())
    val unlock_req_t_rdy           = Input(Bool())
    val unlock_req_t_msg           = Output(UInt(288.W))

    val flow_table_read_req_t_val  = Output(Bool())
    val flow_table_read_req_t_rdy  = Input(Bool())
    val flow_table_read_req_t_msg  = Output(UInt(288.W))
    val flow_table_read_rsp_t_val  = Input(Bool())
    val flow_table_read_rsp_t_rdy  = Output(Bool())
    val flow_table_read_rsp_t_msg  = Input(UInt(529.W))

    val flow_table_write_req_t_val = Output(Bool())
    val flow_table_write_req_t_rdy = Input(Bool())
    val flow_table_write_req_t_msg = Output(UInt(288.W))

  })

  addResource("/pktReassembly.v")
}

class ioUnit_spec(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val in_valid     = Input(Bool())
    val in_tag       = Input(UInt(log2Up(num_threads).W))
    val in_data      = Input(UInt(256.W))
    val in_empty     = Input(UInt(5.W))
    val in_last      = Input(Bool())
    val in_ready     = Output(Bool())

    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_data     = Output(UInt(256.W))
    val out_empty    = Output(UInt(5.W))
    val out_last     = Output(Bool())

    val w_ready      = Input(Bool())
    val w_valid      = Output(Bool())
    val w_early      = Output(Bool())
    val w_tag        = Output(UInt(log2Up(num_threads).W))
    val w_flag       = Output(UInt(ip_width.W))
    val w_wen        = Output(Vec(2, Bool()))
    val w_addr       = Output(Vec(2, UInt(num_regs_lg.W)))
    val w_data       = Output(Vec(2, UInt(reg_width.W)))

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rd        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(reg_width.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())

    // to flow_table ch0
    val ft_out_valid  = Output(Bool())
    val ft_out_tag    = Output(UInt(log2Up(num_threads).W))
    val ft_out_opcode = Output(UInt(opcode_width.W))
    val ft_out_imm    = Output(UInt(12.W))
    val ft_out_bits   = Output(Vec(1, UInt(reg_width.W)))
    val ft_out_ready  = Input(Bool())
    val ft_in_valid   = Input(Bool())
    val ft_in_tag     = Input(UInt(log2Up(num_threads).W))
    val ft_in_flag    = Input(UInt(ip_width.W))
    val ft_in_bits    = Input(UInt(518.W))
    val ft_in_ready   = Output(Bool())

    // to flow_table ch2
    val ft2_out_valid  = Output(Bool())
    val ft2_out_tag    = Output(UInt(log2Up(num_threads).W))
    val ft2_out_opcode = Output(UInt(opcode_width.W))
    val ft2_out_imm    = Output(UInt(12.W))
    val ft2_out_bits   = Output(Vec(1, UInt(reg_width.W)))
    val ft2_out_ready  = Input(Bool())
  })

  val ioU_inst = Module(new pktReassembly)
  val tag_width = log2Up(num_threads)

  ioU_inst.io.i_clk := clock
  ioU_inst.io.i_rst := reset

  ioU_inst.io.stream_in_t_val := io.in_valid
  ioU_inst.io.stream_in_t_msg := Cat(io.in_last, io.in_empty, io.in_data, io.in_tag)
  io.in_ready := ioU_inst.io.stream_in_t_rdy

  io.out_valid := ioU_inst.io.stream_out_t_val
  io.out_tag := ioU_inst.io.stream_out_t_msg(tag_width-1, 0)
  io.out_data := ioU_inst.io.stream_out_t_msg(tag_width+255, tag_width)
  io.out_empty := ioU_inst.io.stream_out_t_msg(tag_width+260, tag_width+256)
  io.out_last := ioU_inst.io.stream_out_t_msg(tag_width+261)
  ioU_inst.io.stream_out_t_rdy := io.out_ready

  val unlock_r = RegInit(false.B)
  val tag_r = Reg(UInt(tag_width.W))
  ioU_inst.io.cmd_in_t_val := false.B
  unlock_r := false.B
  when (io.ar_opcode(0) =/= 1.U) {
    ioU_inst.io.cmd_in_t_val := io.ar_valid
    io.ar_ready := ioU_inst.io.cmd_in_t_rdy
  } .otherwise {
    io.ar_ready := io.ft_out_ready
    tag_r := io.ar_tag
    when (io.ar_valid && io.ft_out_ready) {
      unlock_r := true.B
    }
  }
  ioU_inst.io.cmd_in_t_msg := Cat(io.ar_imm, io.ar_bits, io.ar_rd, io.ar_opcode, io.ar_tag)

  val bfu_out_done = ioU_inst.io.bfu_out_t_msg(tag_width+ip_width)
  io.w_addr(0) := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+2, tag_width+ip_width+3)
  io.w_data(0) := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+reg_width+2, tag_width+ip_width+num_regs_lg+3)
  io.w_addr(1) := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg*2+reg_width+3, tag_width+ip_width+num_regs_lg+reg_width+4)
  io.w_data(1) := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg*2+reg_width*2+3, tag_width+ip_width+num_regs_lg*2+reg_width+4)
  ioU_inst.io.bfu_out_t_rdy := false.B
  when (unlock_r) {
    io.w_valid := true.B
    io.w_tag := tag_r
    io.w_flag := 0.U
    io.w_early := true.B
    io.w_wen(0) := false.B
    io.w_wen(1) := false.B
  } .otherwise {
    io.w_valid := ioU_inst.io.bfu_out_t_val && bfu_out_done
    io.w_tag := ioU_inst.io.bfu_out_t_msg(tag_width-1, 0)
    io.w_flag := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width-1, tag_width)
    io.w_early := ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+1)
    io.w_wen(0) := ioU_inst.io.bfu_out_t_val && ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+2)
    io.w_wen(1) := ioU_inst.io.bfu_out_t_val && ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+reg_width+3)
    when (ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+2) === 0.U && 
      ioU_inst.io.bfu_out_t_msg(tag_width+ip_width+num_regs_lg+reg_width+3) === 0.U) {
      ioU_inst.io.bfu_out_t_rdy := true.B
    } .otherwise {
      ioU_inst.io.bfu_out_t_rdy := io.w_ready
    }
  }

  ioU_inst.io.flow_table_read_req_t_rdy := false.B
  ioU_inst.io.unlock_req_t_rdy := false.B
  io.ft_out_valid := ioU_inst.io.unlock_req_t_val | ioU_inst.io.flow_table_read_req_t_val
  ioU_inst.io.unlock_req_t_rdy := io.ft_out_ready && (!(io.ar_valid && (io.ar_opcode(0) === 1.U)))
  ioU_inst.io.flow_table_read_req_t_rdy := io.ft_out_ready && (!(io.ar_valid && (io.ar_opcode(0) === 1.U))) && (!ioU_inst.io.unlock_req_t_val)
  when (io.ar_valid && (io.ar_opcode(0) === 1.U)) {
    io.ft_out_valid := true.B
    io.ft_out_tag := io.ar_tag
    io.ft_out_opcode := io.ar_opcode
    io.ft_out_imm := DontCare
    io.ft_out_bits(0) := io.ar_bits
  }.elsewhen (ioU_inst.io.unlock_req_t_val) {
    io.ft_out_tag := ioU_inst.io.unlock_req_t_msg(tag_width-1, 0)
    io.ft_out_opcode := ioU_inst.io.unlock_req_t_msg(tag_width+opcode_width-1, tag_width)
    io.ft_out_imm := ioU_inst.io.unlock_req_t_msg(tag_width+opcode_width+11, tag_width+opcode_width)
    io.ft_out_bits(0) := ioU_inst.io.unlock_req_t_msg(tag_width+opcode_width+reg_width+11, tag_width+opcode_width+12)
  } .otherwise {
    io.ft_out_valid := ioU_inst.io.flow_table_read_req_t_val
    io.ft_out_tag := ioU_inst.io.flow_table_read_req_t_msg(tag_width-1, 0)
    io.ft_out_opcode := ioU_inst.io.flow_table_read_req_t_msg(tag_width+opcode_width-1, tag_width)
    io.ft_out_imm := ioU_inst.io.flow_table_read_req_t_msg(tag_width+opcode_width+11, tag_width+opcode_width)
    io.ft_out_bits(0) := ioU_inst.io.flow_table_read_req_t_msg(tag_width+opcode_width+reg_width+11, tag_width+opcode_width+12)
  }

  when (io.ft_in_flag =/= 0.U) {
    ioU_inst.io.flow_table_read_rsp_t_val := io.ft_in_valid
    io.ft_in_ready := ioU_inst.io.flow_table_read_rsp_t_rdy
  } .otherwise {
    ioU_inst.io.flow_table_read_rsp_t_val := false.B
    io.ft_in_ready := true.B
  }
  ioU_inst.io.flow_table_read_rsp_t_msg := Cat(io.ft_in_bits, io.ft_in_flag, io.ft_in_tag)

  io.ft2_out_valid := ioU_inst.io.flow_table_write_req_t_val
  io.ft2_out_tag := ioU_inst.io.flow_table_write_req_t_msg(tag_width-1, 0)
  io.ft2_out_opcode := ioU_inst.io.flow_table_write_req_t_msg(tag_width+opcode_width-1, tag_width)
  io.ft2_out_imm := ioU_inst.io.flow_table_write_req_t_msg(tag_width+opcode_width+11, tag_width+opcode_width)
  io.ft2_out_bits(0) := ioU_inst.io.flow_table_write_req_t_msg(tag_width+opcode_width+reg_width+11, tag_width+opcode_width+12)
  ioU_inst.io.flow_table_write_req_t_rdy := io.ft2_out_ready

}