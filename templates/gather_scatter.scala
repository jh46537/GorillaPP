import chisel3._
import chisel3.util._
import chisel3.util.Fill

class Gather(imm_width: Int, reg_width: Int, num_blocks: Int, src_pos: Array[Int],
   max_out_width: Int, num_modes:Int, src_mode: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))
    val shift = Input(UInt(log2Up(num_blocks).W))
    val mode = Input(UInt(log2Up(num_modes).W))
    val imm = Input(UInt(imm_width.W))
    val sign_out = Output(UInt(1.W))
    val dout = Output(UInt(reg_width.W))
  })

  val din_d0 = Reg(UInt(reg_width.W))
  val shift_d0 = Reg(UInt(log2Up(num_blocks).W))
  val mode_d0 = Reg(UInt(log2Up(num_modes).W))
  val imm_d0 = Reg(UInt(imm_width.W))

  val num_muxes : Int = (num_blocks+7)/8
  val reg0 = Reg(Vec(num_muxes, UInt(max_out_width.W)))
  val src_pos_i = src_pos ++ Array(0, 0, 0, 0, 0, 0, 0)
  for (i <- 0 until num_muxes) {
    switch(io.shift(2, 0)) {
      is (0.U) {
        reg0(i) := io.din((src_pos_i(i*8)+max_out_width-1).min(reg_width-1), src_pos_i(i*8))
      }
      is (1.U) {
        reg0(i) := io.din((src_pos_i(i*8+1)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+1))
      }
      is (2.U) {
        reg0(i) := io.din((src_pos_i(i*8+2)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+2))
      }
      is (3.U) {
        reg0(i) := io.din((src_pos_i(i*8+3)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+3))
      }
      is (4.U) {
        reg0(i) := io.din((src_pos_i(i*8+4)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+4))
      }
      is (5.U) {
        reg0(i) := io.din((src_pos_i(i*8+5)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+5))
      }
      is (6.U) {
        reg0(i) := io.din((src_pos_i(i*8+6)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+6))
      }
      is (7.U) {
        reg0(i) := io.din((src_pos_i(i*8+7)+max_out_width-1).min(reg_width-1), src_pos_i(i*8+7))
      }
    }
  }

  din_d0 := io.din
  shift_d0 := (io.shift >> 3)
  mode_d0 := io.mode
  imm_d0 := io.imm

  val reg1 = Reg(UInt(max_out_width.W))
  val din_d1 = Reg(UInt(reg_width.W))
  val mode_d1 = Reg(UInt(log2Up(num_modes).W))
  val imm_d1 = Reg(UInt(imm_width.W))

  din_d1 := din_d0
  mode_d1 := mode_d0
  imm_d1 := imm_d0
  val cases = (0 until num_muxes).map( x => x.U -> reg0(x))
  reg1 := MuxLookup(shift_d0, DontCare, cases)

  val reg2 = Reg(UInt(max_out_width.W))
  val din_d2 = Reg(UInt(reg_width.W))
  val mode_d2 = Reg(UInt(log2Up(num_modes).W))
  val imm_d2 = Reg(UInt(imm_width.W))
  din_d2 := din_d1
  mode_d2 := mode_d1
  imm_d2 := imm_d1

  val cases2 = (0 until num_modes).map( x => x.U -> reg1(src_mode(x)-1, 0))
  reg2 := MuxLookup(mode_d1, DontCare, cases2)
  when (mode_d2 === num_modes.U) {
    io.dout := Cat(0.U, imm_d2)
  } .otherwise {
    io.dout := Cat(din_d2(reg_width-1, max_out_width), reg2)
  }
  io.sign_out := 0.U
}

class Scatter(reg_width: Int, lg_num_rdBlocks: Int, lg_num_modes: Int, num_wrBlocks: Int,
  num_dst_pos: Int, dst_encode: Array[Int], dst_pos: Array[Int],
  num_wbens: Int, dst_en_encode: Array[(Int, Int)], wbens: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))
    val shift = Input(UInt(lg_num_rdBlocks.W))
    val mode = Input(UInt(lg_num_modes.W))
    val wren = Output(UInt(num_wrBlocks.W))
    val dout = Output(UInt(reg_width.W))
  })
  val din_w = Wire(UInt(reg_width.W))
  val dout_r = Reg(UInt(reg_width.W))
  val wben_r = Reg(UInt(num_wrBlocks.W))
  din_w := io.din

  val cases = (0 until num_dst_pos).map(i => (io.shift === dst_encode(i).U) -> (din_w << dst_pos(i)))
  dout_r := MuxCase(DontCare, cases)
  val cases2 = (0 until num_wbens).map(i => ((io.shift === dst_en_encode(i)._1.U) && ((dst_en_encode(i)._2 == -1).B || (io.mode === dst_en_encode(i)._2.S.asUInt))) -> wbens(i).U)
  wben_r := MuxCase(0.U, cases2)

  io.dout := dout_r
  io.wren := wben_r
}