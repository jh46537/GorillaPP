import chisel3._
import chisel3.util._

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

  io.ft2_out_valid := false.B
  io.ft2_out_tag := DontCare
  io.ft2_out_opcode := DontCare
  io.ft2_out_imm := DontCare
  io.ft2_out_bits := DontCare

  io.ft_out_valid := false.B
  io.ft_out_tag := io.ar_tag
  io.ft_out_opcode := io.ar_opcode
  io.ft_out_imm := io.ar_imm
  io.ft_out_bits := DontCare
  io.ar_ready := false.B
  io.in_ready := false.B
  when (io.ar_valid) {
    when (io.ar_opcode(0) === 0.U) {
      // Parse Done
      io.ft_out_valid := io.in_valid
      io.ft_out_bits(0) := io.in_data
      io.in_ready := io.ft_out_ready
      io.ar_ready := io.in_valid && io.ft_out_ready
    } .otherwise {
      // unlock
      io.ft_out_valid := true.B
      io.ft_out_bits(0) := io.ar_bits
      io.ar_ready := io.ft_out_ready
    }
  }


  io.ft_in_ready := false.B
  io.out_valid := false.B
  io.out_data := io.ft_in_bits(251, 0)
  io.out_tag := io.ft_in_tag
  io.out_empty := 0.U
  io.out_last := true.B
  io.w_valid := false.B
  io.w_early := false.B
  io.w_tag := io.ft_in_tag
  io.w_flag := io.ft_in_flag
  io.w_addr(0) := 1.U
  io.w_addr(1) := 2.U
  io.w_wen(0) := false.B
  io.w_wen(1) := false.B
  io.w_data(0) := io.ft_in_bits(251, 0)
  io.w_data(1) := io.ft_in_bits(517, 252)
  when (io.ft_in_valid) {
    when (io.ft_in_flag === 1.U) {
      // in order, output
      io.ft_in_ready := io.out_ready
      io.out_valid := true.B
      io.w_valid := io.out_ready
    } .elsewhen (io.ft_in_flag === 0.U) {
      // unlock
      io.w_early := true.B
      io.ft_in_ready := true.B
      io.w_valid := true.B
    } .otherwise {
      // out of order
      io.ft_in_ready := io.w_ready
      io.w_valid := true.B
      io.w_early := true.B
      io.w_wen(0) := true.B
      io.w_wen(1) := true.B
    }
  }


}