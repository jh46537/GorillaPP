import chisel3._
import chisel3.util._
import chisel3.util.Fill
import scala.math._

class loadStoreUnit(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle{
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(tag_width.W))
    val in_opcode     = Input(UInt(opcode_width.W))
    val in_imm        = Input(UInt(12.W))
    val in_bits       = Input(Vec(2, UInt(reg_width.W)))
    val in_ready      = Output(Bool())
    val out_valid     = Output(Bool())
    val out_tag       = Output(UInt(tag_width.W))
    val out_flag      = Output(UInt(ip_width.W))
    val out_bits      = Output(UInt(reg_width.W))
    val out_ready     = Input(Bool())
  })

  val MEM_SIZE = 512
  val ADDR_WIDTH = log2Up(MEM_SIZE)

  val mem = SyncReadMem(MEM_SIZE, UInt(reg_width.W))
  val mem_addr = RegInit(0.U(ADDR_WIDTH.W))
  val mem_wr = RegInit(false.B)
  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(tag_width.W))
  val base_addr = Wire(SInt(32.W))
  val disp = Wire(SInt(32.W))
  val wr_data = Reg(UInt(reg_width.W))
  val valid_out = RegInit(false.B)
  val readmeta = RegInit(false.B)

  io.in_ready := true.B
  io.out_flag := 0.U
  valid_r := io.in_valid
  tag_r := io.in_tag
  base_addr := io.in_bits(0)(31, 0).asSInt
  disp := io.in_imm.asSInt
  when (io.in_valid) {
    mem_wr := io.in_opcode(4)
    wr_data := io.in_bits(1)
    val addr = base_addr + disp
    mem_addr := addr.asUInt
    when (addr === -1.S) {
      readmeta := true.B
    } .otherwise {
      readmeta := false.B
    }
  }

  val tag_out = RegNext(tag_r)
  val rd_data = Wire(UInt(reg_width.W))
  valid_out := false.B
  rd_data := DontCare
  io.out_bits := DontCare
  when (valid_r) {
    val rdwrPort = mem(mem_addr)
    when (mem_wr) {
      rdwrPort := wr_data
    } .otherwise {
      rd_data := rdwrPort
    }
    when (readmeta) {
      io.out_bits := tag_out
    } .otherwise {
      io.out_bits := rd_data
    }
    valid_out := true.B
  }

  io.out_valid := valid_out
  io.out_tag := tag_out

}