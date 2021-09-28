import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class dynamicMem(extCompName: String) extends gComponentLeaf(UInt((128).W), UInt((128).W), ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  /*******************Decode, allocate new ptr*****************/
  val inputTag = Reg(UInt((TAGWIDTH*2).W))
  val opcode = Reg(UInt(2.W))
  val inputReg = Reg(UInt(126.W))
  val valid_d = Reg(Bool())

  val ptr = RegInit(0.U(16.W))
  val new_ptr = RegInit(0.U(16.W))

  io.in.ready := io.out.ready
  valid_d := io.in.valid && io.out.ready

  when (io.in.valid && io.out.ready) {
    opcode := io.in.bits(127, 126)
    inputReg := io.in.bits(125, 0)
    inputTag := io.in.tag
    when (io.in.bits(127, 126) === 0.U) {
      when (ptr < 512.U) {
        new_ptr := ptr
        ptr := ptr + 1.U
      } .otherwise {
        new_ptr := 0xffff.U
      }
    }
  }

  /*******************Access RAM 0*****************************/
  val tag_a0 = Reg(UInt((TAGWIDTH*2).W))
  val mem = Reg(Vec(512, Vec(8, UInt(16.W))))
  val wren = Reg(Bool())
  val wben = Reg(UInt(8.W))
  val wrAddr = Reg(UInt(9.W))
  val wrData = Reg(UInt(128.W))
  val rdAddr = Reg(UInt(9.W))

  val ptr_a = Reg(UInt(16.W))
  val valid_a0 = Reg(Bool())
  val opcode_a0 = Reg(UInt(2.W))

  valid_a0 := DontCare
  wren := false.B
  wben := 0.U
  wrAddr := DontCare
  wrData := DontCare
  ptr_a := DontCare
  rdAddr := DontCare
  when (io.out.ready) {
    valid_a0 := valid_d
  }
  when (valid_d && io.out.ready) {
    opcode_a0 := opcode
    tag_a0 := inputTag
    when (opcode === 0.U && new_ptr =/= 0xffff.U) {
      wren := true.B
      val ptr0 = Wire(UInt(16.W))
      val ptr1 = Wire(UInt(16.W))
      ptr0 := 0xffff.U
      ptr1 := 0xffff.U
      wrData := Cat(inputReg(83, 16), ptr1, ptr0)
      wrAddr := new_ptr
      wben := 0xff.U
      ptr_a := new_ptr
    } .elsewhen (opcode === 1.U) {
      wren := false.B
      rdAddr := inputReg(15, 0)
    } .elsewhen (opcode === 2.U) {
      wrData := inputReg(31, 16)
      wrAddr := inputReg(15, 0)
      wren := true.B
      wben := 0x1.U
    } .elsewhen (opcode === 3.U) {
      wrData := Cat(inputReg(31, 16), 0.U(16.W))
      wrAddr := inputReg(15, 0)
      wren := true.B
      wben := 0x2.U
    }
  }

  /*******************Access RAM 1*****************************/
  val tag_a1 = Reg(UInt((TAGWIDTH*2).W))
  val valid_a1 = Reg(Bool())
  val rdData = Reg(UInt(128.W))
  val opcode_a1 = Reg(UInt(2.W))
  val ptr_o = Reg(UInt(16.W))

  when (io.out.ready) {
    tag_a1 := tag_a0
    valid_a1 := valid_a0
    opcode_a1 := opcode_a0
    ptr_o := ptr_a
  }
  when (wren) {
    var i = 0
    for (i <- 0 until 8) {
      when (wben(i) === 1.U) {
        mem(wrAddr)(i) := wrData(i*16+15, i*16)
      }
    }
  }
  rdData := mem(rdAddr).asUInt

  /*******************Output**********************************/
  io.out.tag := DontCare
  io.out.valid := false.B
  io.out.bits := DontCare
  when (valid_a1) {
    io.out.tag := tag_a1
    io.out.valid := true.B
    when (opcode_a1 === 0.U) {
      io.out.bits := ptr_o
    } .otherwise {
      io.out.bits := rdData
    }
  }
  
}