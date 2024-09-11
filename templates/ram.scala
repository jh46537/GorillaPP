import chisel3._
import chisel3.util._
import chisel3.util.Fill

class ram_simple2port(num: Int, width: Int) extends
  BlackBox(Map("AWIDTH" -> log2Up(num),
               "DWIDTH" -> width,
               "DEPTH"  -> num)) with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock     = Input(Clock())
    val data      = Input(UInt(width.W))
    val rdaddress = Input(UInt(log2Up(num).W))
    val rden      = Input(Bool())
    val wraddress = Input(UInt(log2Up(num).W))
    val wren      = Input(Bool())
    val q         = Output(UInt(width.W))
  })

  addResource("/ram_simple2port_sim.v")

}

class ram_qp(num: Int, width: Int) extends 
  BlackBox(Map("AWIDTH" -> log2Up(num),
               "DWIDTH" -> width,
               "DEPTH"  -> num)) with HasBlackBoxResource {
  val io = IO(new Bundle {
    val read_address_a  = Input(UInt(log2Up(num).W))
    val read_address_b  = Input(UInt(log2Up(num).W))
    val q_a             = Output(UInt(width.W))
    val q_b             = Output(UInt(width.W))

    val wren_a          = Input(Bool())
    val wren_b          = Input(Bool())
    val write_address_a = Input(UInt(log2Up(num).W))
    val write_address_b = Input(UInt(log2Up(num).W))
    val data_a          = Input(UInt(width.W))
    val data_b          = Input(UInt(width.W))

    val clock           = Input(Clock())
  })

  addResource("/ram_qp_sim.v")

}