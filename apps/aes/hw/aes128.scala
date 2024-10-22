import chisel3._
import chisel3.util._
import _root_.circt.stage.ChiselStage

class aes_block_encrypt extends BlackBox {
  val io = IO(new Bundle {
    val clk = Input(Clock())
    val rst = Input(Bool())
    val valid_in = Input(Bool())
    val valid_out = Output(Bool())
    val ready_out = Input(Bool())
    val ready_in  = Output(Bool())
    val expanded_key = Input(UInt(1408.W))
    val plaintext = Input(UInt(128.W))
    val ciphertext = Output(UInt(128.W))
  })
}


//class aes128(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
class aes128(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
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
 
  val block_cipher = Module(new aes_block_encrypt)

  // connect to implicit chisel clock, reset
  block_cipher.io.clk := clock
  block_cipher.io.rst := reset

  // hopefully this works since only one thread. if not, send it thru pipeline
  io.out_tag := io.in_tag

  // flow control
  io.in_ready := block_cipher.io.ready_in
  block_cipher.io.ready_out := io.out_ready
  block_cipher.io.valid_in := io.in_valid
  io.out_valid := block_cipher.io.valid_out

  // payload
  block_cipher.io.expanded_key := io.in_bits(44*32-1, 0)
  block_cipher.io.plaintext := io.in_bits(44*32+4*32-1, 44*32)

  io.out_bits := block_cipher.io.ciphertext.asUInt

  // tie to 0
  io.out_flag := 0.U
}

object aes128Driver extends App {
  ChiselStage.emitSystemVerilogFile(new aes128(5, 1536, 4, 1, 1))
}

object Main extends App {
  println(
    ChiselStage.emitSystemVerilog(gen = new aes128(5, 1536, 4, 1, 1))
  )
}