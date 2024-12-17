import chisel3._
import chisel3.util._

class ALU(reg_width: Int) extends Module {
  val io = IO(new Bundle {
    val rs1       = Input(UInt(reg_width.W))
    val rs2       = Input(UInt(32.W))
    val addEn     = Input(Bool())
    val subEn     = Input(Bool())
    val sltEn     = Input(Bool())
    val sltuEn    = Input(Bool())
    val andEn     = Input(Bool())
    val orEn      = Input(Bool())
    val xorEn     = Input(Bool())
    val sllEn     = Input(Bool())
    val srEn      = Input(Bool())
    val srMode    = Input(Bool())
    val luiEn     = Input(Bool())
    val catEn     = Input(Bool())
    val immSel    = Input(Bool())
    val imm       = Input(SInt(32.W))
    val dout      = Output(UInt(reg_width.W))
  })

  val opA = Reg(SInt(32.W))
  val opB = Reg(SInt(32.W))
  val res = Wire(SInt(32.W))
  val rs1_r = Reg(UInt(reg_width.W))
  val addEn_r   = RegInit(false.B)
  val subEn_r   = RegInit(false.B)
  val sltEn_r   = RegInit(false.B)
  val sltuEn_r  = RegInit(false.B)
  val andEn_r   = RegInit(false.B)
  val orEn_r    = RegInit(false.B)
  val xorEn_r   = RegInit(false.B)
  val sllEn_r   = RegInit(false.B)
  val srEn_r    = RegInit(false.B)
  val srMode_r  = RegInit(false.B)
  val luiEn_r   = RegInit(false.B)
  val catEn_r   = RegInit(false.B)

  opA := io.rs1(31, 0).asSInt
  opB := Mux(io.immSel, io.imm, io.rs2(31, 0).asSInt)
  rs1_r := io.rs1
  addEn_r  := io.addEn
  subEn_r  := io.subEn
  sltEn_r  := io.sltEn
  sltuEn_r := io.sltuEn
  andEn_r  := io.andEn
  orEn_r   := io.orEn
  xorEn_r  := io.xorEn
  sllEn_r  := io.sllEn
  srEn_r   := io.srEn
  srMode_r := io.srMode
  luiEn_r  := io.luiEn
  res := DontCare

  when (addEn_r) {
    res := opA + opB
  } .elsewhen (subEn_r) {
    res := opA - opB
  } .elsewhen (sltEn_r) {
    when (opA < opB) {
      res := 1.S
    } .otherwise {
      res := 0.S
    }
  } .elsewhen(sltuEn_r) {
    val opA_u = opA.asUInt
    val opB_u = opB.asUInt
    when (opA_u < opB_u) {
      res := 1.S
    } .otherwise {
      res := 0.S
    }
  } .elsewhen (andEn_r) {
    res := opA & opB
  } .elsewhen (orEn_r) {
    res := opA | opB
  } .elsewhen (xorEn_r) {
    res := opA ^ opB
  } .elsewhen (sllEn_r) {
    val shamt = opB(4, 0).asUInt
    res := opA << shamt
  } .elsewhen (sllEn_r) {
    val shamt = opB(4, 0).asUInt
    when (srMode_r) {
      res := opA >> shamt
    } .otherwise {
      val opA_u = opA.asUInt
      res := (opA_u >> shamt).asSInt
    }
  } .elsewhen (luiEn_r) {
    res := opB
  } .elsewhen (catEn_r) {
    val opA_u = opA(8, 0).asUInt
    val opB_u = opB(8, 0).asUInt
    res := Cat(0.U(14.W), opB_u, opA_u).asSInt
  }

  io.dout := Cat(rs1_r(reg_width-1, 32), res.asUInt)

}
