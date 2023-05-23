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
    val ar_bits      = Input(UInt(32.W))
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

  /****************** Start Thread *********************************/
  // select idle thread
  val sThreadEncoder = Module(new RREncode(num_threads))
  val sThread = sThreadEncoder.io.chosen
  Range(0, num_threads, 1).map(i =>
    sThreadEncoder.io.valid(i) := io.idle_threads(i))
  sThreadEncoder.io.ready := sThread =/= num_threads.U

  io.w_wen(0) := false.B
  io.w_wen(1) := false.B
  io.w_valid := false.B
  io.w_tag := DontCare
  io.w_flag := 0.U
  io.w_addr(0) := 1.U
  io.w_addr(1) := DontCare
  io.w_data(0) := io.in_data(0)
  io.w_data(1) := DontCare
  io.ar_ready := true.B
  io.in_ready := false.B
  io.new_thread := false.B
  io.new_tag := DontCare
  io.w_tag := sThread
  when (io.in_valid && (sThread =/= num_threads.U) && (io.w_ready)) {
    io.w_wen(0) := true.B
    io.in_ready := true.B
    io.new_thread := true.B
    io.new_tag := sThread
  }

  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(log2Up(num_threads).W))

  io.out_valid := false.B
  io.out_tag := io.ar_tag
  io.out_data := DontCare
  io.out_empty := 0.U
  io.out_last := true.B
  io.ar_ready := true.B
  io.r_valid := valid_r
  io.r_tag := tag_r
  io.r_flag := 0.U
  valid_r := false.B
  when (io.ar_valid && (io.ar_opcode(opcode_width-1) === 1.U)) {
    io.out_valid := true.B
    io.out_data := io.ar_bits
    valid_r := true.B
    tag_r := io.ar_tag
  }

  io.rd_req_valid := false.B
  io.rd_req := DontCare
  io.rd_rsp_ready := true.B

}