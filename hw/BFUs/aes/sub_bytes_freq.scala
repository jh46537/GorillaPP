import chisel3._
import chisel3.util._

// systemverilog black box
class sub_bytes_freq extends BlackBox {
  val io = IO(new Bundle {
    val clk = Input(Clock())
    val rst = Input(Bool())
    val en = Input(Bool())
    val bytes_in = Input(UInt(8.W))
    val bytes_out = Output(UInt(8.W))
  })
}


// BFU
class s_box (tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(tag_width.W))
    val in_opcode     = Input(UInt(opcode_width.W))
    val in_imm        = Input(UInt(12.W))
    val in_bits       = Input(UInt(reg_width.W))
    val in_ready      = Output(Bool())
    val out_valid     = Output(Bool())
    val out_tag       = Output(UInt(tag_width.W))
    val out_flag      = Output(UInt(ip_width.W))
    val out_bits      = Output(UInt(reg_width.W))
    val out_ready     = Input(Bool())
  })

  assert(reg_width % 8 == 0, s"Error ${this.getClass.getSimpleName}: reg_width ($reg_width) is not a multiple of 8")

  val sboxcount = reg_width / 8

  // instantiate an s-box for every byte of input/output
  val sub_gather = Wire(Vec(sboxcount, UInt(8.W)))
  for(i <- 0 until sboxcount) {
    val sub_bytes = Module(new sub_bytes_freq)

    // connect to implicit chisel clock, reset
    sub_bytes.io.clk := clock
    sub_bytes.io.rst := reset
    // flow control
    sub_bytes.io.en := io.out_ready

    // connect data
    sub_bytes.io.bytes_in := io.in_bits(i*8+7, i*8)
    sub_gather(i) := sub_bytes.io.bytes_out
  }
  io.out_bits := Cat(sub_gather.reverse)

  // synchronize tag with pipeline
  val tag_0 = RegInit(0.U(1.W))
  when (io.out_ready) { tag_0 := io.in_tag }
  io.out_tag := tag_0

  // flow control
  io.in_ready := io.out_ready

  val valid_flop = RegInit(0.U(1.W))
  when (io.out_ready) { valid_flop := io.in_valid }
  io.out_valid := valid_flop

  // tie to 0
  io.out_flag := 0.U
}

// TODO: should probably remove this
import _root_.circt.stage.ChiselStage
object s_boxDriver extends App {
  print(ChiselStage.emitSystemVerilog(new s_box(5, 16, 4, 1, 1)))
}


