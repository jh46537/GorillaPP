//> using scala "2.13.12"
//> using dep "org.chipsalliance::chisel:6.5.0"
//> using plugin "org.chipsalliance:::chisel-plugin:6.5.0"
//> using options "-unchecked", "-deprecation", "-language:reflectiveCalls", "-feature", "-Xcheckinit", "-Xfatal-warnings", "-Ywarn-dead-code", "-Ywarn-unused", "-Ymacro-annotations"


import chisel3._
import chisel3.util._
//import chisel3.util.HasBlackBoxResource // is this necessary?


class sub_bytes extends BlackBox {
  val io = IO(new Bundle {
    val bytes_in  = Input(Vec(4, UInt(8.W)))
    val bytes_out = Output(Vec(4, UInt(8.W)))
  })
  //addResource("sub_bytes.sv") // is this necessary?
}


class shift_rows extends BlackBox {
  val io = IO(new Bundle {
    val input_matrix  = Input(VecInit.fill(4, 4)(8.U))
    val output_matrix = Output(VecInit.fill(4, 4)(8.U))
  })
  //addResource("shift_rows.sv") // is this necessary?
}


class mix_columns extends BlackBox {
  val io = IO(new Bundle {
    val input_matrix  = Input(VecInit.fill(4, 4)(8.U))
    val output_matrix = Output(VecInit.fill(4, 4)(8.U))
  })
  //addResource("mix_columns.sv") // is this necessary?
}


class aes128(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
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

    //val mem           = new gMemBundle
  })

  // sub_bytes.io.bytes_in
  // sub_bytes.io.bytes_out := <something>

  val sub_bytes0 = Module(new sub_bytes)
  val sub_bytes1 = Module(new sub_bytes)
  val sub_bytes2 = Module(new sub_bytes)
  val sub_bytes3 = Module(new sub_bytes)

  val shift_rows = Module(new shift_rows)
  val mix_columns = Module(new mix_columns)

  shift_rows.io.input_matrix(0) := sub_bytes0.io.bytes_out
  shift_rows.io.input_matrix(1) := sub_bytes1.io.bytes_out
  shift_rows.io.input_matrix(2) := sub_bytes2.io.bytes_out
  shift_rows.io.input_matrix(3) := sub_bytes3.io.bytes_out

  mix_columns.io.input_matrix := shift_rows.io.output_matrix

}