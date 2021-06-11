import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer


class memReq(addrSize: Int, dataSize: Int) extends Bundle {
  var rw    = UInt(1.W)
  var addr  = UInt(addrSize.W)
  var wData = UInt(dataSize.W)
}

class memReadOnlyReq(addrSize: Int, dataSize: Int) extends Bundle {
  var addr  = UInt(addrSize.W)
}

class memWriteOnlyReq(addrSize: Int, dataSize: Int) extends Bundle {
  var addr  = UInt(addrSize.W)
  var data  = UInt(dataSize.W)
}

class memReqDualAddress(addrSize: Int, dataSize: Int) extends Bundle {
  var rw    = UInt(1.W)
  var rAddr = UInt(addrSize.W)
  var wAddr = UInt(addrSize.W)
  var wData = UInt(dataSize.W)
}

class memRep(dataSize: Int) extends Bundle {
  var rData = UInt(dataSize.W)
}

class memReadOnlyRep(dataSize: Int) extends Bundle {
  var data  = UInt(dataSize.W)
}

class memWriteOnlyRep(dataSize: Int) extends Bundle {
}

class memReq32_t          extends memReq(32, 32)
class memReq192_t         extends memReq(32, 192)
class memReadOnlyReq32_t  extends memReadOnlyReq(32, 32)
class memWriteOnlyReq32_t extends memWriteOnlyReq(32, 32)

class memRep32_t          extends memRep(32)
class memRep192_t         extends memRep(192)
class memReadOnlyRep32_t  extends memReadOnlyRep(32)
class memWriteOnlyRep32_t extends memWriteOnlyRep(32)


object spMem {
  def apply(height: Int, width: Int) =
    new gComponentGen(
      new spMemComponent(height, width),
      new memReq(log2Up(height), width),
      new memRep(width),
      ArrayBuffer()
    )
}

//object rwSpMem {
//  def apply(height: Int, width: Int) = {
//    val mdRead = new gComponentMD(
//      new memReadOnlyReq(log2Up(height), width),
//      new memReadOnlyRep(width), ArrayBuffer())
//    val mdWrite = new gComponentMD(
//      new memWriteOnlyReq(log2Up(height), width),
//      new memWriteOnlyRep(width), ArrayBuffer())
//
//    val h = (new rwSpMemComponent(height, width))
//
//    (mdRead, mdWrite, h).asInstanceOf[(
//      gComponentMD[Data,Data],
//      gComponentMD[Data,Data],
//      rwSpMemComponent
//    )]
//  }
//}

class spMemComponent(height: Int, width: Int)
  extends gComponentLeaf(
    new memReq(log2Up(height), width),
    new memRep(width),
    ArrayBuffer(),
    extCompName="spMem"
  )
  with include
{
  val read::write::Nil = Enum(2)
  val tagReg = Reg(UInt((TAGWIDTH*2).W))
  val hasReqReg = RegInit(false.B)

  io.in.ready := io.out.ready
  tagReg := io.in.tag
  io.out.tag := tagReg
  val ram = SyncReadMem(height, UInt(width.W))
  val rAddrReg = Reg(UInt(width.W))
  when(io.in.valid && (io.in.bits.rw === write)) {
    ram(io.in.bits.addr) := io.in.bits.wData
  }
  when(io.in.valid && (io.in.bits.rw === read)) {
    rAddrReg := io.in.bits.addr
  }
  io.out.bits.rData := ram(io.in.bits.addr)
  io.out.valid := hasReqReg
}

class rwSpMemComponent(height: Int, width: Int) extends Module with include {
  val io = IO(new Bundle {
    val read = new gInOutBundle(new memReadOnlyReq(addrSize=log2Up(height), dataSize=width),
     new memReadOnlyRep(dataSize=width))
    val write = new gInOutBundle(new memWriteOnlyReq(addrSize=log2Up(height), dataSize=width),
     new memWriteOnlyRep(dataSize=width))
  })

  val read::write::Nil = Enum(2)
  val readTagReg = Reg(UInt((TAGWIDTH*2).W))
  val writeTagReg = Reg(UInt((TAGWIDTH*2).W))
  val hasReadReqReg = Reg(false.B)
  val hasWriteReqReg = Reg(false.B)
  io.read.in.ready := io.read.out.ready
  io.write.in.ready := io.write.out.ready
  readTagReg := io.read.in.tag
  writeTagReg := io.write.in.tag
  io.read.out.tag := readTagReg
  io.write.out.tag := writeTagReg

  val ram1r1w = SyncReadMem(height, UInt(width.W))
  val reg_raddr = Reg(UInt(width.W))
  when(io.write.in.valid) {
    ram1r1w(io.write.in.bits.addr) := io.write.in.bits.data
  }
  when(io.read.in.valid) {
    reg_raddr := io.read.in.bits.addr
  }
  io.read.out.bits.data := ram1r1w(reg_raddr)
  io.read.out.valid := hasReadReqReg
  io.read.in.ready := io.read.out.ready
  io.write.out.valid := hasWriteReqReg
  io.write.in.ready := io.write.out.ready
}

class spMemDualAddress(height: Int, width: Int)
  extends gComponentLeaf(
    new memReqDualAddress(log2Up(height), width),
    new memRep(width),
    ArrayBuffer(),
    extCompName="spMemDualAddress"
  )
{
  val readCmd::writeCmd::Nil = Enum(2)
  val ram = SyncReadMem(height, UInt(width.W))

  when(io.in.valid && (io.in.bits.rw === writeCmd)) {
    ram(io.in.bits.wAddr) := io.in.bits.wData
  }
  io.out.bits.rData := ram(io.in.bits.rAddr)
  io.out.valid := true.B
  io.in.ready := true.B
}

class spMem32 extends spMemComponent(1024, 1024)

//class spMemTests(c: spMemComponent) extends Tester(c, Array(c.io)) {
//  defTests {
//    var allGood = true
//    val svars = new HashMap[Node, Node]()
//    val ovars = new HashMap[Node, Node]()
//
//    step(svars, ovars, false)
//    allGood
//  }
//}
