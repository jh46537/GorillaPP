import chisel3._
import chisel3.util._

class BranchUnit extends Module {
  val io = IO(new Bundle {
    val rs1       = Input(SInt(32.W))
    val rs2       = Input(SInt(32.W))
    val pc        = Input(SInt(32.W))
    val brValid   = Input(Bool())
    val brMode    = Input(UInt(4.W))
    val pcOffset  = Input(SInt(21.W))

    val pcOut     = Output(SInt(32.W))
    // val dout      = Output(SInt(32.W))
    val finish    = Output(Bool())
  })

  val pcInc = Wire(SInt(32.W))
  val pcOff = Wire(SInt(32.W))
  val pcPlain = Wire(SInt(32.W))
  val pcOut_r = Reg(SInt(32.W))
  val finish_r = RegInit(false.B)
  pcInc := io.pc + 4.S
  pcOff := io.pc + io.pcOffset
  pcPlain := io.pcOffset
  io.pcOut := pcOut_r
  // io.dout := pcInc
  io.finish := finish_r

  pcOut_r := pcInc
  finish_r := false.B
  when (io.brValid) {
    switch (io.brMode) {
      is (0.U) {
        when (io.rs1 === io.rs2) {
          pcOut_r := pcOff
        }
      }
      is (1.U) {
        when (io.rs1 =/= io.rs2) {
          pcOut_r := pcOff
        }
      }
      is (2.U) {
        pcOut_r := pcOff
      }
      is (3.U) {
        pcOut_r := pcOff
        when (pcPlain === -2.S) {
          finish_r := true.B
        }
      }
      is (4.U) {
        when (io.rs1 < io.rs2) {
          pcOut_r := pcOff
        }
      }
      is (5.U) {
        when (io.rs1 >= io.rs2) {
          pcOut_r := pcOff
        }
      }
      is (6.U) {
        val rs1_u = io.rs1.asUInt
        val rs2_u = io.rs2.asUInt
        when (rs1_u < rs2_u) {
          pcOut_r := pcOff
        }
      }
      is (7.U) {
        val rs1_u = io.rs1.asUInt
        val rs2_u = io.rs2.asUInt
        when (rs1_u >= rs2_u) {
          pcOut_r := pcOff
        }
      }
      is (8.U) {
        pcOut_r := io.rs1 + io.pcOffset
      }
    }
  }
}