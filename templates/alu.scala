import chisel3._
import chisel3.util._

class ALU(num_aluops_lg: Int, reg_width: Int) extends Module {
  val io = IO(new Bundle {
    val signA = Input(UInt(1.W))
    val srcA = Input(UInt(reg_width.W))
    val signB = Input(UInt(1.W))
    val srcB = Input(UInt(reg_width.W))
    val aluOp = Input(UInt(num_aluops_lg.W))
    val dout = Output(UInt(reg_width.W))
  })
  val opA = Wire(SInt(33.W))
  val opB = Wire(SInt(33.W))
  val res = Wire(UInt(32.W))
  opA := Cat(io.signA, io.srcA(31, 0)).asSInt
  opB := Cat(io.signB, io.srcB(31, 0)).asSInt
  io.dout := 0.U
  res := 0.U
  switch (io.aluOp) {
    is (0.U) {
      // fall through srcA
      io.dout := io.srcA
    }
    is (1.U) {
      // fall through srcB
      io.dout := io.srcB
    }
    is (2.U) {
      // add
      res := (opA + opB).asUInt
      io.dout := Cat(0.U, res)
    }
    is (3.U) {
      // subtract
      res := (opA - opB).asUInt
      io.dout := Cat(0.U, res)
    }
    is (4.U) {
      // equal
      when (opA === opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (5.U) {
      // not equal
      when (opA =/= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (6.U) {
      // less than
      when (opA < opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (7.U) {
      // less than or equal
      when (opA <= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (8.U) {
      // greater than
      when (opA > opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (9.U) {
      // greater than or equal
      when (opA >= opB) {
        io.dout := 1.U
      } .otherwise {
        io.dout := 0.U
      }
    }
    is (10.U) {
      // and
      io.dout := (opA & opB).asUInt
    }
    is (11.U) {
      // or
      io.dout := (opA | opB).asUInt
    }
    is (12.U) {
      // concatenate
      io.dout := Cat(0.U(252.W), io.srcB(8, 0), io.srcA(8, 0))
    }
  }
}