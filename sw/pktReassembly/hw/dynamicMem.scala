import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap

class dynamicMem(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle{
    val in_valid  = Input(Bool())
    val in_tag    = Input(UInt(tag_width.W))
    val in_opcode = Input(UInt(opcode_width.W))
    val in_imm    = Input(UInt(12.W))
    val in_bits   = Input(Vec(2, UInt(reg_width.W)))
    val in_ready  = Output(Bool())
    val out_valid = Output(Bool())
    val out_tag   = Output(UInt(tag_width.W))
    val out_flag  = Output(UInt(ip_width.W))
    val out_bits  = Output(UInt(reg_width.W))
    val out_ready = Input(Bool())
  })
  val in_bits = Wire(new dyMemInput_t)
  val out_bits = Wire(new llNode_t)
  in_bits := io.in_bits(0).asTypeOf(new dyMemInput_t)
  io.out_bits := out_bits.asUInt
  io.out_flag := 0.U
  /*******************Decode, allocate new ptr*****************/
  val inputTag = Reg(UInt(tag_width.W))
  val opcode = Reg(UInt(3.W))
  val inputReg = Reg(new llNode_t)
  val inputReg2 = Reg(UInt(32.W))
  val valid_d = RegInit(false.B)

  /*******************Initialize empty list*********************/
  val empty_list = Module(new Queue(UInt(9.W), 512))
  val state = RegInit(0.U(1.W))
  val init_id = RegInit(0.U(9.W))
  val ptr = RegInit(0.U(10.W))
  val new_ptr = RegInit(0.U(10.W))

  io.in_ready := io.out_ready
  when (state === 0.U) {
    when (init_id === 511.U) {
      println("Empty list initialization done")
      state := 1.U
    }
    empty_list.io.enq.valid := true.B
    empty_list.io.enq.bits := init_id
    empty_list.io.deq.ready := false.B
    valid_d := false.B
    init_id := init_id + 1.U
  } .otherwise {
    empty_list.io.deq.ready := false.B
    empty_list.io.enq.valid := false.B
    empty_list.io.enq.bits := DontCare
    when (io.in_valid && io.out_ready) {
      opcode := io.in_opcode
      inputReg := in_bits.node
      inputReg2 := io.in_bits(1)
      inputTag := io.in_tag
      when (io.in_opcode(2, 0) === 0.U) {
        when (empty_list.io.count > 0.U) {
          new_ptr := empty_list.io.deq.bits
          empty_list.io.deq.ready := true.B
        } .otherwise {
          println("Empty list empty")
        }
      } .elsewhen (io.in_opcode(2, 0) === 3.U) {
        empty_list.io.enq.valid := true.B
        val node_u = in_bits.node.asUInt
        empty_list.io.enq.bits := node_u(8, 0)
      }
    }
    when (io.out_ready) {
      valid_d := io.in_valid
    }
  }


  /*******************Access RAM 0*****************************/
  val tag_a0 = Reg(UInt(tag_width.W))
  val mem0 = Module(new ram_simple2port(512, 252))
  val mem1 = Module(new ram_simple2port(512, 9))
  val mem2 = Module(new ram_simple2port(512, 9))
  // val mem0 = Reg(Vec(512, UInt(252.W)))
  // val mem1 = Reg(Vec(512, Vec(2, UInt(9.W))))
  val wren = Reg(Bool())
  val rden = Reg(Bool())
  val wben = Reg(UInt(3.W))
  val wrAddr = Reg(UInt(9.W))
  val wrData = Reg(UInt(270.W))
  val rdAddr = Reg(UInt(9.W))

  val ptr_a = Reg(UInt(10.W))
  val valid_a0 = RegInit(false.B)
  val opcode_a0 = Reg(UInt(2.W))

  wren := false.B
  rden := false.B
  wben := 0.U
  wrAddr := DontCare
  wrData := DontCare
  ptr_a := DontCare
  rdAddr := DontCare
  when (io.out_ready) {
    valid_a0 := valid_d
  }
  when (valid_d && io.out_ready) {
    opcode_a0 := opcode
    tag_a0 := inputTag
    val input_u = Wire(UInt(270.W))
    input_u := inputReg.asUInt
    when (opcode === 0.U) {
      wren := true.B
      val ptr0 = Wire(UInt(9.W))
      val ptr1 = Wire(UInt(9.W))
      ptr0 := 0.U
      ptr1 := 0.U
      wrData := Cat(ptr1, ptr0, input_u(251, 0))
      wrAddr := new_ptr
      wben := 0x7.U
      ptr_a := new_ptr
    } .elsewhen (opcode === 1.U) {
      wren := false.B
      rden := true.B
      rdAddr := input_u(8, 0)
    } .elsewhen (opcode === 2.U) {
      wrData := Cat(0.U(9.W), inputReg2(8, 0), 0.U(252.W))
      wrAddr := input_u(8, 0)
      wren := true.B
      wben := 0x2.U
    }
    // .elsewhen (opcode === 3.U) {
    //   wrData := Cat(input_u(17, 9), 0.U(9.W), 0.U(252.W))
    //   wrAddr := input_u(8, 0)
    //   wren := true.B
    //   wben := 0x4.U
    // }
  }

  /*******************Access RAM 1*****************************/
  val tag_a1 = Reg(UInt(tag_width.W))
  val valid_a1 = RegInit(false.B)
  val rdData = Wire(UInt(270.W))
  val opcode_a1 = Reg(UInt(2.W))
  val ptr_o = Reg(UInt(9.W))

  when (io.out_ready) {
    tag_a1 := tag_a0
    valid_a1 := valid_a0
    opcode_a1 := opcode_a0
    ptr_o := ptr_a
  }

  mem0.io.clock := clock
  mem1.io.clock := clock
  mem2.io.clock := clock
  mem0.io.data := wrData(251, 0)
  mem1.io.data := wrData(260, 252)
  mem2.io.data := wrData(269, 261)
  mem0.io.rdaddress := rdAddr
  mem1.io.rdaddress := rdAddr
  mem2.io.rdaddress := rdAddr
  mem0.io.rden := rden
  mem1.io.rden := rden
  mem2.io.rden := rden
  mem0.io.wraddress := wrAddr
  mem1.io.wraddress := wrAddr
  mem2.io.wraddress := wrAddr
  mem0.io.wren := wren && (wben(0) === 1.U)
  mem1.io.wren := wren && (wben(1) === 1.U)
  mem2.io.wren := wren && (wben(2) === 1.U)


  // when (wren) {
  //   when (wben(0) === 1.U) {
  //     mem0(wrAddr) := wrData(251, 0)
  //   }
  //   when (wben(1) === 1.U) {
  //     mem1(wrAddr)(0) := wrData(260, 252)
  //   }
  //   when (wben(2) === 1.U) {
  //     mem1(wrAddr)(1) := wrData(269, 261)
  //   }
  // }
  // rdData := Cat(mem1(rdAddr).asUInt, mem0(rdAddr))

  /*******************Output**********************************/
  val tag_a2 = Reg(UInt(tag_width.W))
  val valid_a2 = RegInit(false.B)
  val opcode_a2 = Reg(UInt(2.W))
  val ptr_o_r = Reg(UInt(9.W))
  when (io.out_ready) {
    opcode_a2 := opcode_a1
    valid_a2 := valid_a1
    tag_a2 := tag_a1
    ptr_o_r := ptr_o
  }
  rdData := Cat(mem2.io.q, mem1.io.q, mem0.io.q)

  io.out_tag := DontCare
  io.out_valid := false.B
  out_bits := DontCare
  when (valid_a2) {
    io.out_tag := tag_a2
    io.out_valid := true.B
    when (opcode_a2 === 0.U) {
      out_bits := ptr_o_r.asTypeOf(new llNode_t)
    } .otherwise {
      out_bits := rdData.asTypeOf(new llNode_t)
    }
  }
  
}