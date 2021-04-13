import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class dualInput[T <: Data](data: () => T) extends Bundle {
  val in1 = Input(data())
  val in2 = Input(data())
}

class fuBB[T <: Data](ioType: () => T) extends BlackBox {
  val io = new Bundle {
    val a = Input(ioType())
    val b = Input(ioType())
    val result = Output(ioType())
    val ce = Input(Bool())
    val rdy = Output(Bool())
  }
}

class FUSynWrapper[ioT <: Data](ioType: () => ioT)(fuGen: () => fuBB[ioT])(stages: Int)(extCompName: String)
  extends gComponentLeaf(() => new dualInput(ioType))(ioType)(ArrayBuffer())(extCompName=extCompName)
  with include
{
  val tagPipe = new gPipe(stages)
  val bb = fuGen()
  tagPipe.io.in.valid := io.in.valid
  tagPipe.io.in.tag := io.in.tag
  tagPipe.io.out.ready := io.out.ready
  io.out.tag := tagPipe.io.out.tag
  io.in.ready := tagPipe.io.in.ready
  io.out.valid := bb.io.rdy && tagPipe.io.out.valid // TODO: fifo is not required
  bb.io.a <> io.in.bits.in1
  bb.io.b <> io.in.bits.in2
  // this causes the output unconnected
  //bb.io.result <> io.out.bits
  io.out.bits := bb.io.result
  bb.io.ce := true.B // TODO: this should be attached to (valid || outstanding > 0)
}
