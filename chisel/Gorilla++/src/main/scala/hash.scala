import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap

class hashV extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val sIP    = Input(UInt(32.W))
    val dIP    = Input(UInt(32.W))
    val sPort  = Input(UInt(16.W))
    val dPort  = Input(UInt(16.W))
    val tuple_in_valid = Input(Bool())
    val h0_hashed = Output(UInt(12.W))
    val h1_hashed = Output(UInt(12.W))
    val h2_hashed = Output(UInt(12.W))
    val h3_hashed = Output(UInt(12.W))
    val sIP_out = Output(UInt(32.W))
    val dIP_out = Output(UInt(32.W))
    val sPort_out = Output(UInt(16.W))
    val dPort_out = Output(UInt(16.W))
    val hashed_valid = Output(Bool())

    val rst                   = Input(Reset())
    val clk                   = Input(Clock())
  })

  addResource("/hash_wrap.sv")

}

class hash(extCompName: String) extends gComponentLeaf(new tuple_t, new fce_meta_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  val tag_vec = Reg(Vec(8, UInt((TAGWIDTH*2).W)))
  val valid_vec = Reg(Vec(8, Bool()))

  tag_vec(7) := io.in.tag
  valid_vec(7) := io.in.valid
  var i = 0
  for (i <- 0 until 7) {
    tag_vec(i) := tag_vec(i+1)
    valid_vec(i) := valid_vec(i+1)
  }
  io.in.ready := true.B

  val hash_inst = Module(new hashV)

  hash_inst.io.clk := clock
  hash_inst.io.rst := reset
  hash_inst.io.sIP := io.in.bits.sIP
  hash_inst.io.dIP := io.in.bits.dIP
  hash_inst.io.sPort := io.in.bits.sPort
  hash_inst.io.dPort := io.in.bits.dPort
  hash_inst.io.tuple_in_valid := io.in.valid
  io.out.tag := tag_vec(0)
  io.out.valid := valid_vec(0)
  io.out.bits.tuple.sIP := hash_inst.io.sIP_out
  io.out.bits.tuple.dIP := hash_inst.io.dIP_out
  io.out.bits.tuple.sPort := hash_inst.io.sPort_out
  io.out.bits.tuple.dPort := hash_inst.io.dPort_out
  io.out.bits.addr0 := hash_inst.io.h0_hashed
  io.out.bits.addr1 := hash_inst.io.h1_hashed
  io.out.bits.addr2 := hash_inst.io.h2_hashed
  io.out.bits.addr3 := hash_inst.io.h3_hashed

}

