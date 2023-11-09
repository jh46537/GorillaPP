import chisel3._
import chisel3.util._

class inOutUnit(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends MultiIOModule {
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
    val out_data     = Output(new metadata_t)
    val out_empty    = Output(UInt(5.W))
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
    val w_finish     = Output(Bool())
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

  /****************** Start Thread *********************************/
  // select idle thread
  val sThreadEncoder = Module(new RREncode(num_threads))
  val sThread = sThreadEncoder.io.chosen
  val input_fifo = Module(new Queue(UInt(256.W), num_threads))
  Range(0, num_threads, 1).map(i =>
    sThreadEncoder.io.valid(i) := io.idle_threads(i))
  sThreadEncoder.io.ready := sThread =/= num_threads.U

  io.in_ready := false.B
  io.new_thread := false.B
  io.new_tag := DontCare
  input_fifo.io.enq.valid := false.B
  input_fifo.io.enq.bits := io.in_data
  when (io.in_valid && (sThread =/= num_threads.U)) {
    io.new_thread := true.B
    io.new_tag := sThread
    io.in_ready := true.B
    input_fifo.io.enq.valid := true.B
  }

  val ioSpec = Module(new ioUnit_spec(reg_width, num_regs_lg, opcode_width, num_threads, ip_width))

  class out_t extends Bundle {
    val tag   = UInt(log2Up(num_threads).W)
    val data  = UInt(256.W)
  }
  val out_fifo = Module(new Queue(new out_t, 2))

  ioSpec.io.in_valid := input_fifo.io.deq.valid
  ioSpec.io.in_tag := 0.U
  ioSpec.io.in_data := input_fifo.io.deq.bits
  ioSpec.io.in_empty := 0.U
  ioSpec.io.in_last := 1.U
  input_fifo.io.deq.ready := ioSpec.io.in_ready

  ioSpec.io.w_ready := io.w_ready
  io.w_valid := ioSpec.io.w_valid
  io.w_tag   := ioSpec.io.w_tag
  io.w_finish := !ioSpec.io.w_early
  io.w_flag  := (ioSpec.io.w_flag << 2)
  io.w_wen   := ioSpec.io.w_wen
  io.w_addr  := ioSpec.io.w_addr
  io.w_data  := ioSpec.io.w_data

  ioSpec.io.ar_valid  := false.B
  ioSpec.io.ar_tag    := io.ar_tag
  ioSpec.io.ar_opcode := io.ar_opcode
  ioSpec.io.ar_rd     := io.ar_rd
  ioSpec.io.ar_bits   := io.ar_bits
  ioSpec.io.ar_imm    := io.ar_imm

  io.ft_out_valid  := ioSpec.io.ft_out_valid
  io.ft_out_tag    := ioSpec.io.ft_out_tag
  io.ft_out_opcode := ioSpec.io.ft_out_opcode
  io.ft_out_imm    := ioSpec.io.ft_out_imm
  io.ft_out_bits   := ioSpec.io.ft_out_bits
  ioSpec.io.ft_out_ready := io.ft_out_ready
  ioSpec.io.ft_in_valid  := io.ft_in_valid
  ioSpec.io.ft_in_tag    := io.ft_in_tag
  ioSpec.io.ft_in_flag   := io.ft_in_flag
  ioSpec.io.ft_in_bits   := io.ft_in_bits
  io.ft_in_ready  := ioSpec.io.ft_in_ready

  io.ft2_out_valid  := ioSpec.io.ft2_out_valid
  io.ft2_out_tag    := ioSpec.io.ft2_out_tag
  io.ft2_out_opcode := ioSpec.io.ft2_out_opcode
  io.ft2_out_imm    := ioSpec.io.ft2_out_imm
  io.ft2_out_bits   := ioSpec.io.ft2_out_bits
  ioSpec.io.ft2_out_ready := io.ft2_out_ready

  io.ar_ready := false.B
  out_fifo.io.enq.valid := false.B
  out_fifo.io.enq.bits := DontCare
  io.r_valid := false.B
  io.r_tag := io.ar_tag
  io.r_flag := 0.U
  when (io.ar_valid) {
    when (io.ar_opcode(opcode_width-1) === 0.U) {
      io.ar_ready := ioSpec.io.ar_ready
      ioSpec.io.ar_valid := true.B
    } .otherwise {
      io.ar_ready := out_fifo.io.enq.ready
      out_fifo.io.enq.valid := true.B
      out_fifo.io.enq.bits.tag := io.ar_tag
      out_fifo.io.enq.bits.data := io.ar_bits
      io.r_valid := true.B
    }
  }

  io.out_valid := false.B
  io.out_empty := 0.U
  io.out_last  := true.B
  io.out_tag := DontCare
  io.out_data := DontCare
  ioSpec.io.out_ready := io.out_ready
  out_fifo.io.deq.ready := false.B
  when (ioSpec.io.out_valid) {
    io.out_valid := ioSpec.io.out_valid
    io.out_tag   := ioSpec.io.out_tag
    io.out_data  := ioSpec.io.out_data.asTypeOf(new metadata_t)
  } .elsewhen (io.out_ready) {
    io.out_valid := out_fifo.io.deq.valid
    io.out_tag := out_fifo.io.deq.bits.tag
    io.out_data := out_fifo.io.deq.bits.data.asTypeOf(new metadata_t)
    out_fifo.io.deq.ready := true.B
  }

  io.rd_req_valid := false.B
  io.rd_req := DontCare
  io.rd_rsp_ready := true.B

}