import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


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

class dynamicMem(extCompName: String) extends gComponentLeaf(new dyMemInput_t, new llNode_t, ArrayBuffer(), extCompName + "__type__engine__MT__1__") {
  /*******************Decode, allocate new ptr*****************/
  val inputTag = Reg(UInt((TAGWIDTH*2).W))
  val opcode = Reg(UInt(2.W))
  val inputReg = Reg(new llNode_t)
  val valid_d = Reg(Bool())

  /*******************Initialize empty list*********************/
  val empty_list = Module(new Queue(UInt(9.W), 512))
  val state = RegInit(0.U(1.W))
  val init_id = RegInit(0.U(9.W))
  val ptr = RegInit(0.U(10.W))
  val new_ptr = RegInit(0.U(10.W))

  io.in.ready := io.out.ready
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
    when (io.in.valid && io.out.ready) {
      opcode := io.in.bits.opcode
      inputReg := io.in.bits.node
      inputTag := io.in.tag
      when (io.in.bits.opcode === 0.U) {
        when (empty_list.io.count > 0.U) {
          new_ptr := empty_list.io.deq.bits
          empty_list.io.deq.ready := true.B
        } .otherwise {
          println("Empty list empty")
        }
      } .elsewhen (io.in.bits.opcode === 3.U) {
        empty_list.io.enq.valid := true.B
        val node_u = io.in.bits.node.asUInt
        empty_list.io.enq.bits := node_u(8, 0)
      }
    }
    valid_d := io.in.valid && io.out.ready
  }


  /*******************Access RAM 0*****************************/
  val tag_a0 = Reg(UInt((TAGWIDTH*2).W))
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
  val valid_a0 = Reg(Bool())
  val opcode_a0 = Reg(UInt(2.W))

  valid_a0 := DontCare
  wren := false.B
  rden := false.B
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
      wrData := Cat(0.U(9.W), input_u(17, 9), 0.U(252.W))
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
  val tag_a1 = Reg(UInt((TAGWIDTH*2).W))
  val valid_a1 = Reg(Bool())
  val rdData = Wire(UInt(270.W))
  val opcode_a1 = Reg(UInt(2.W))
  val ptr_o = Reg(UInt(9.W))

  when (io.out.ready) {
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
  val tag_a2 = Reg(UInt((TAGWIDTH*2).W))
  val valid_a2 = Reg(Bool())
  val opcode_a2 = Reg(UInt(2.W))
  val ptr_o_r = Reg(UInt(9.W))
  when (io.out.ready) {
    opcode_a2 := opcode_a1
    valid_a2 := valid_a1
    tag_a2 := tag_a1
    ptr_o_r := ptr_o
  }
  rdData := Cat(mem2.io.q, mem1.io.q, mem0.io.q)

  io.out.tag := DontCare
  io.out.valid := false.B
  io.out.bits := DontCare
  when (valid_a2) {
    io.out.tag := tag_a2
    io.out.valid := true.B
    when (opcode_a2 === 0.U) {
      io.out.bits := ptr_o_r.asTypeOf(new llNode_t)
    } .otherwise {
      io.out.bits := rdData.asTypeOf(new llNode_t)
    }
  }
  
}