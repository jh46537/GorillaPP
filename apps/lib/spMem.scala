import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer


class memReq(addrSize: Int, dataSize: Int) extends Bundle {
  var rw    = UInt(1.W)
  var addr  = UInt(addrSize.W)
  var wData = UInt(dataSize.W)

  override def cloneType = (new memReq(addrSize, dataSize)).asInstanceOf[this.type]
}

class memReadOnlyReq(addrSize: Int, dataSize: Int) extends Bundle {
  var addr  = UInt(addrSize.W)

  override def cloneType = (new memReadOnlyReq(addrSize, dataSize)).asInstanceOf[this.type]
}

class memWriteOnlyReq(addrSize: Int, dataSize: Int) extends Bundle {
  var addr  = UInt(addrSize.W)
  var data  = UInt(dataSize.W)

  override def cloneType = (new memWriteOnlyReq(addrSize, dataSize)).asInstanceOf[this.type]
}

class memReqDualAddress(addrSize: Int, dataSize: Int) extends Bundle {
  var rw    = UInt(1.W)
  var rAddr = UInt(addrSize.W)
  var wAddr = UInt(addrSize.W)
  var wData = UInt(dataSize.W)

  override def cloneType = (new memReqDualAddress(addrSize, dataSize)).asInstanceOf[this.type]
}

class memRep(dataSize: Int) extends Bundle {
  var rData = UInt(dataSize.W)

  override def cloneType = (new memRep(dataSize)).asInstanceOf[this.type]
}

class memReadOnlyRep(dataSize: Int) extends Bundle {
  var data  = UInt(dataSize.W)

  override def cloneType = (new memReadOnlyRep(dataSize)).asInstanceOf[this.type]
}

class memWriteOnlyRep(dataSize: Int) extends Bundle {
  override def cloneType = (new memWriteOnlyRep(dataSize)).asInstanceOf[this.type]
}

class memReq32_t          extends memReq(32, 32)          { override def cloneType = (new memReq32_t).asInstanceOf[this.type] }
class memReq192_t         extends memReq(32, 192)         { override def cloneType = (new memReq192_t).asInstanceOf[this.type] }
class memReadOnlyReq32_t  extends memReadOnlyReq(32, 32)  { override def cloneType = (new memReadOnlyReq32_t).asInstanceOf[this.type] }
class memWriteOnlyReq32_t extends memWriteOnlyReq(32, 32) { override def cloneType = (new memWriteOnlyReq32_t).asInstanceOf[this.type] }

class memRep32_t          extends memRep(32)              { override def cloneType = (new memRep32_t).asInstanceOf[this.type] }
class memRep192_t         extends memRep(192)             { override def cloneType = (new memRep192_t).asInstanceOf[this.type] }
class memReadOnlyRep32_t  extends memReadOnlyRep(32)      { override def cloneType = (new memReadOnlyRep32_t).asInstanceOf[this.type] }
class memWriteOnlyRep32_t extends memWriteOnlyRep(32)     { override def cloneType = (new memWriteOnlyRep32_t).asInstanceOf[this.type] }


object spMem {
  def apply(height: Int, width: Int) =
    new gComponentGen(
      new spMemComponent(height, width),
      new memReq(log2Up(height), width),
      new memRep(width),
      ArrayBuffer()
    )
}

object rwSpMem {
  def apply(height: Int, width: Int) =
    new gRWComponentGen(
      new rwSpMemComponent(height, width),
      new memReadOnlyReq(log2Up(height), width),
      new memWriteOnlyReq(log2Up(height), width),
      new memReadOnlyRep(width),
      new memWriteOnlyRep(width),
      ArrayBuffer()
    )
}

class spMemComponent(height: Int, width: Int)
  extends gComponentLeaf(
    new memReq(log2Up(height), width),
    new memRep(width),
    ArrayBuffer(),
    extCompName="spMem"
  )
  with include
{
  override def cloneType = (new spMemComponent(height, width)).asInstanceOf[this.type]

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

class rwSpMemComponent(height: Int, width: Int)
  extends gRWComponentLeaf(
    new memReadOnlyReq(log2Up(height), width),
    new memWriteOnlyReq(log2Up(height), width),
    new memReadOnlyRep(width),
    new memWriteOnlyRep(width),
    ArrayBuffer(),
    extCompName="rwSpMem"
  )
  with include
{
  override def cloneType = (new rwSpMemComponent(height, width)).asInstanceOf[this.type]

  //val io = IO(new Bundle {
  //  val read = new gInOutBundle(
  //    new memReadOnlyReq(log2Up(height), width),
  //    new memReadOnlyRep(width)
  //  )
  //  val write = new gInOutBundle(
  //    new memWriteOnlyReq(log2Up(height), width),
  //    new memWriteOnlyRep(width)
  //  )
  //})

  val read::write::Nil = Enum(2)
  val readTagReg = Reg(UInt((TAGWIDTH*2).W))
  val writeTagReg = Reg(UInt((TAGWIDTH*2).W))
  val hasReadReqReg = RegInit(false.B)
  val hasWriteReqReg = RegInit(false.B)

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
