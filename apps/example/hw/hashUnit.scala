import chisel3._
import chisel3.util._

class hashUnit(key_width: Int, data_width: Int) extends Module {
  val io = IO(new Bundle{
    val data_in       = Input(UInt(key_width.W))
    val data_in_valid = Input(Bool())
    val stall         = Input(Bool())
    val hashed        = Output(UInt(data_width.W))
    val hashed_valid  = Output(Bool())
  })

  val valid = RegInit(false.B)
  val key = Wire(UInt((key_width+data_width).W))
  val multiply_res = Wire(Vec(data_width, UInt(key_width.W)))
  val reduced_res = Wire(Vec(data_width, Bool()))
  val hashed_res = Reg(UInt(data_width.W))

  key := "hdeadbefbcafe".U

  Range(0, data_width, 1).map(i => (multiply_res(i) := key(i+data_width-1, i) & io.data_in))
  Range(0, data_width, 1).map(i => (reduced_res(i) := multiply_res(i).xorR))

  when (!io.stall) {
    valid := io.data_in_valid
    hashed_res := reduced_res.asUInt
  }

  io.hashed_valid := valid
  io.hashed := hashed_res

}