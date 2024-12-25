import chisel3._
import chisel3.util._

import scala.collection.mutable.HashMap
import scala.collection.mutable.ArrayBuffer
import scala.collection.immutable.ListMap
import scala.util._

class DynamicBundle extends Bundle {
  private var _data = ArrayBuffer[(String, Data)]()

  private def modifyField(obj: AnyRef, name: String, value: Any) {
    def impl(clazz: Class[_] ) {
      Try(clazz.getDeclaredField(name)).toOption match {
        case Some(field) =>
          field.setAccessible(true)
          clazz.getMethod(name).invoke(obj) // force init
          field.set(obj, value)
        case None =>
          if (clazz.getSuperclass != null) {
            impl(clazz.getSuperclass)
          }
      }
    }
    impl(obj.getClass)
  }

}

object DynamicBundle {
  def apply(data: ArrayBuffer[(String, Data)] = ArrayBuffer()): DynamicBundle = {
    val dynamicBundle = new DynamicBundle
    dynamicBundle._data = data
    val new_elements = dynamicBundle.elements ++ data.foldLeft(ListMap[String, Data]())((a, b) => a + (b._1 -> b._2))
    dynamicBundle.modifyField(dynamicBundle, "elements", new_elements)
    dynamicBundle
  }
}

object gArbiterCtrl {
  def apply(request: Seq[Bool]): Seq[Bool] = request.length match {
    case 0 => Seq()
    case 1 => Seq(true.B)
    case _ => true.B +: request.tail.init.scanLeft(request.head)(_ || _).map(!_)
  }
}

class gioArbiter[T <: Data](n: Int, data: => T) extends Bundle {
  val out = new gFIFOIO(data)
  val in = Flipped(Vec(n, new gFIFOIO(data)))
  val chosen = Output(UInt((log2Up(n)).W))
}

class gioDistributor[T <: Data](n: Int, data: => T) extends Bundle {
  val out = Vec(n, new gFIFOIO(data))
  val in = Flipped(new gFIFOIO(data))
  val chosen = Output(UInt((log2Up(n)).W))
}

class RREncode(n: Int) extends Module {
  val io = IO(new Bundle {
    val valid = Input(Vec(n, Bool()))
    val chosen = Output(UInt((log2Up(n+1)).W))
    val ready = Input(Bool())
  })

  val last_grant = RegInit((0).U((log2Up(n)).W))
  val g = gArbiterCtrl((0 until n).map(i => io.valid(i) && (i).U > last_grant) ++ io.valid)
  val grant = (0 until n).map(i => g(i) && (i).U > last_grant || g(i+n))

  var choose = (n).U
  for (i <- n-1 to 0 by -1)
    choose = Mux(io.valid(i), (i).U, choose)
  for (i <- n-1 to 1 by -1)
    choose = Mux(io.valid(i) && (i).U > last_grant, (i).U, choose)
  val outValid = io.valid.foldLeft(false.B)( _ || _)
  when (outValid && io.ready) {
    last_grant := choose
  }
  io.chosen := choose
}

class gRRArbiter[T <: Data](n: Int, data: => T) extends Module with TagTrait {
  val io = IO(new gioArbiter(n, data))

  val last_grant = RegInit((0).U((log2Up(n)).W))
  val g = gArbiterCtrl((0 until n).map(i => io.in(i).valid && (i).U > last_grant) ++ io.in.map(_.valid))
  val grant = (0 until n).map(i => g(i) && (i).U > last_grant || g(i+n))
  (0 until n).map(i => io.in(i).ready := grant(i) && io.out.ready)

  var choose = (n-1).U
  for (i <- n-2 to 0 by -1)
    choose = Mux(io.in(i).valid, (i).U, choose)
  for (i <- n-1 to 1 by -1)
    choose = Mux(io.in(i).valid && (i).U > last_grant, (i).U, choose)
  when (io.out.valid && io.out.ready) {
    last_grant := choose
  }

  val dvec = Vec(n, data)
  val tvec = Vec(n, UInt((TAGWIDTH).W))
  (0 until n).map(i => dvec(i) := io.in(i).bits )
  (0 until n).map(i => tvec(i) := io.in(i).tag )

  io.out.valid := io.in.map(_.valid).foldLeft(false.B)( _ || _)
  io.out.bits := dvec(choose)
  io.out.tag := tvec(choose)
  io.chosen := choose
}

class gRRDistributor[T <: Data](n: Int, data: => T) extends Module {
  val io = IO(new gioDistributor(n, data))

  val last_grant = RegInit((0).U((log2Up(n)).W))
  val g = gArbiterCtrl((0 until n).map(i => io.out(i).ready && (i).U > last_grant) ++ io.out.map(_.ready))
  val grant = (0 until n).map(i => g(i) && (i).U > last_grant || g(i+n))
  (0 until n).map(i => io.out(i).valid := grant(i) && io.in.valid)
  //name_it()
  var choose = (n-1).U
  for (i <- n-2 to 0 by -1)
    choose = Mux(io.out(i).ready, (i).U, choose)
  for (i <- n-1 to 1 by -1)
    choose = Mux(io.out(i).ready && (i).U > last_grant, (i).U, choose)
  when (io.in.valid && io.in.ready) {
    last_grant := choose
  }

  (0 until n).map(i => io.out(i).bits := io.in.bits)
  (0 until n).map(i => io.out(i).tag := io.in.tag)
  io.in.ready := io.out.map(_.ready).foldLeft(false.B)( _ || _)
  io.chosen := choose
}

class gTaggedRRArbiter[T <: Data](n: Int, data: => T) extends Module with TagTrait {
  val io = IO(new gioArbiter(n, data))

  val last_grant = RegInit((0).U((log2Up(n)).W))
  val g = gArbiterCtrl((0 until n).map(i => io.in(i).valid && (i).U > last_grant) ++ io.in.map(_.valid))
  val grant = (0 until n).map(i => g(i) && (i).U > last_grant || g(i+n))
  (0 until n).map(i => io.in(i).ready := grant(i) && io.out.ready)

  var choose = (n-1).U
  for (i <- n-2 to 0 by -1)
    choose = Mux(io.in(i).valid, (i).U, choose)
  for (i <- n-1 to 1 by -1)
    choose = Mux(io.in(i).valid && (i).U > last_grant, (i).U, choose)
  when (io.out.valid && io.out.ready) {
    last_grant := choose
  }

  val dvec = Vec(n, data)
  val tvec = Vec(n, UInt((TAGWIDTH).W))
  (0 until n).map(i => dvec(i) := io.in(i).bits )
  (0 until n).map(i => tvec(i) := io.in(i).tag )

  io.out.valid := io.in.map(_.valid).foldLeft(false.B)( _ || _)
  io.out.bits := dvec(choose)
  io.out.tag := (choose << (TAGWIDTH).U) | tagLower(tvec(choose))
  io.chosen := choose
}

class gTaggedDistributor[T <: Data](n: Int, data: => T) extends Module with TagTrait {
  val io = IO(new gioDistributor(n, data))

  (0 until n).map(i => io.out(i).bits := io.in.bits)
  (0 until n).map(i => io.out(i).tag := tagLower(io.in.tag))
  (0 until n).map(i => io.out(i).valid := io.in.valid && ((i).U((TAGWIDTH).W) === tagUpper(io.in.tag)))
  io.in.ready := io.in.valid && io.out(tagUpper(io.in.tag)).ready
  io.chosen := tagUpper(io.in.tag)
}

class gFIFOIO[T <: Data](data: => T) extends Bundle with TagTrait {
  val ready = Input(Bool())
  val valid = Output(Bool())
  val last = Output(Bool())
  val bits = Output(data)
  val tag = Output(UInt((TAGWIDTH*2).W))

  def fire(dummy: Int = 0) = ready && valid

}

class gFIFOIOND[T <: Data](data: => T) extends Bundle with TagTrait {
  val ready = Wire(Bool())
  val valid = Wire(Bool())
  val bits = Wire(data)
  val tag = Wire(UInt((TAGWIDTH*2).W))

  def fire(dummy: Int = 0) = ready && valid

}

class gInOutBundle[inT <: Data, outT <: Data](
  inData: => inT, outData: => outT
) extends Bundle {
  val in = Flipped(new gFIFOIO(inData))
  val out = new gFIFOIO(outData)
  val pcIn = Flipped(Valid(new PcBundle))
  val pcOut = Valid(new PcBundle)

}

class gRWInOutBundle[inReadT <: Data, inWriteT <: Data, outReadT <: Data, outWriteT <: Data](
  inReadData: => inReadT, inWriteData: => inWriteT, outReadData: => outReadT, outWriteData: => outWriteT
) extends Bundle {
  val read = new Bundle {
    val in = Flipped(new gFIFOIO(inReadData))
    val out = new gFIFOIO(outReadData)
  }
  val write = new Bundle {
    val in = Flipped(new gFIFOIO(inWriteData))
    val out = new gFIFOIO(outWriteData)
  }
  val pcIn = Flipped(Valid(new PcBundle))
  val pcOut = Valid(new PcBundle)

}

class gOffBundle[inT <: Data, outT <: Data](reqData: => inT, repData: => outT) extends Bundle {
  val req = new gFIFOIO(reqData)
  val rep = Flipped(new gFIFOIO(repData))

}

class gOffBundleND[inT <: Data, outT <: Data](reqData: => inT, repData: => outT) extends Bundle {
  val req = new gFIFOIOND(reqData)
  val rep = new gFIFOIOND(repData)

}

class gInOutOffBundle[inT <: Data, outT <: Data](
  inData: => inT, outData: => outT,
  offBundle: => DynamicBundle = DynamicBundle()
)
  extends gInOutBundle(inData, outData)
{
  val off = offBundle
  val mem = new gMemBundle

}

class gRWInOutOffBundle[inReadT <: Data, inWriteT <: Data, outReadT <: Data, outWriteT <: Data](
  inReadData: => inReadT, inWriteData: => inWriteT, outReadData: => outReadT, outWriteData: => outWriteT,
  offBundle: => DynamicBundle = DynamicBundle()
)
  extends gRWInOutBundle(inReadData, inWriteData, outReadData, outWriteData)
{
  val off = offBundle

}

class gMemBundle extends Bundle with MemTrait {
  val mem_addr      = Output(UInt(ADDR_WIDTH.W))
  val read          = Output(Bool())
  val write         = Output(Bool())
  val writedata     = Output(UInt(DATA_WIDTH.W))
  val byteenable    = Output(UInt((DATA_WIDTH/8).W))
  val waitrequest   = Input(Bool())
  val readdatavalid = Input(Bool())
  val readdata      = Input(UInt(DATA_WIDTH.W))
}

abstract class gComponentBase()
//abstract class gComponentBase[inT <: Data, outT <: Data](inData: => inT, outData: => outT)
  extends Module with include
{

}

class PcBundle extends Bundle {
  val request = Output(Bool())
  val moduleId = Output(UInt((16).W))
  val portId = Output(UInt((8).W))
  val pcValue = Output(UInt((Pcounters.PCWIDTH).W))
  val pcType = Output(UInt((4).W))
}

class gComponentLeaf[inT <: Data, outT <: Data](
  inData: => inT, outData: => outT,
  offloadData: ArrayBuffer[(String, Data, Data)], extCompName: String = ""
) extends gComponent(inData, outData, offloadData, extCompName)
{

  if (compilerControl.pcEnable) {
    val pcOutValid = RegInit(false.B)
    val pcOutRequest = RegInit(true.B)
    val pcOutModuleId = RegInit((0).U((16).W))
    val pcOutPortId = RegInit((0).U((8).W))
    val pcOutPcValue = RegInit((0).U((Pcounters.PCWIDTH).W))
    val pcOutPcType = RegInit((0).U((4).W))
    when (io.pcIn.valid && io.pcIn.bits.moduleId === (moduleId).U((16).W) && io.pcIn.bits.request) {
      pcOutValid := true.B
      pcOutPcValue := pcMuxed
      pcOutRequest := false.B
      pcOutPcType := io.pcIn.bits.pcType
      pcOutModuleId := io.pcIn.bits.moduleId
      pcOutPortId := io.pcIn.bits.portId
    }
    .otherwise {
      pcOutValid := io.pcIn.valid
      pcOutPcValue := io.pcIn.bits.pcValue
      pcOutRequest := io.pcIn.bits.request
      pcOutPcType := io.pcIn.bits.pcType
      pcOutModuleId := io.pcIn.bits.moduleId
      pcOutPortId := io.pcIn.bits.portId
    }
    io.pcOut.valid := pcOutValid
    io.pcOut.bits.request := pcOutRequest
    io.pcOut.bits.moduleId := pcOutModuleId
    io.pcOut.bits.portId := pcOutPortId
    io.pcOut.bits.pcValue := pcOutPcValue //mypcMuxed //inPCBackPressure //pcOutPcValue
    io.pcOut.bits.pcType := pcOutPcType
  }
}

class gRWComponentLeaf[inReadT <: Data, inWriteT <: Data, outReadT <: Data, outWriteT <: Data](
  inReadData: => inReadT, inWriteData: => inWriteT, outReadData: => outReadT, outWriteData: => outWriteT,
  offloadData: ArrayBuffer[(String, Data, Data)], extCompName: String = ""
) extends gRWComponent(inReadData, inWriteData, outReadData, outWriteData, offloadData, extCompName)
{

  if (compilerControl.pcEnable) {
    val pcOutValid = RegInit(false.B)
    val pcOutRequest = RegInit(true.B)
    val pcOutModuleId = RegInit((0).U((16).W))
    val pcOutPortId = RegInit((0).U((8).W))
    val pcOutPcValue = RegInit((0).U((Pcounters.PCWIDTH).W))
    val pcOutPcType = RegInit((0).U((4).W))
    when (io.pcIn.valid && io.pcIn.bits.moduleId === (moduleId).U((16).W) && io.pcIn.bits.request) {
      pcOutValid := true.B
      pcOutPcValue := pcMuxed
      pcOutRequest := false.B
      pcOutPcType := io.pcIn.bits.pcType
      pcOutModuleId := io.pcIn.bits.moduleId
      pcOutPortId := io.pcIn.bits.portId
    }
    .otherwise {
      pcOutValid := io.pcIn.valid
      pcOutPcValue := io.pcIn.bits.pcValue
      pcOutRequest := io.pcIn.bits.request
      pcOutPcType := io.pcIn.bits.pcType
      pcOutModuleId := io.pcIn.bits.moduleId
      pcOutPortId := io.pcIn.bits.portId
    }
    io.pcOut.valid := pcOutValid
    io.pcOut.bits.request := pcOutRequest
    io.pcOut.bits.moduleId := pcOutModuleId
    io.pcOut.bits.portId := pcOutPortId
    io.pcOut.bits.pcValue := pcOutPcValue
    io.pcOut.bits.pcType := pcOutPcType
  }
}

class gComponent[inT <: Data, outT <: Data](
  inData: => inT, outData: => outT, offloadData: ArrayBuffer[(String, Data, Data)], extCompName: String = ""
) extends gComponentBase()
{

  val offBundle = DynamicBundle(offloadData.map((d) => (d._1, { val dBundle = new gOffBundle(d._2, d._3); dBundle.suggestName(d._1); dBundle})))
  //offBundle.suggestName("off")
  val io = IO(new gInOutOffBundle(inData, outData, offBundle))

  //name_it()
  if (extCompName != "") {
    suggestName(extCompName + "__class__" + this.getClass.getSimpleName)
  }
  println("In module " + toNamed + ", num of offload ports " + offloadData.size)

  //val nullOff = Wire(new Bundle{ val nullOff = new gOffBundle(UInt(32.W), UInt(32.W)) })
  //val nullOffOff = Wire(new gOffBundle(UInt(32.W), UInt(32.W)))
  //def ioOff = io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def ioOff = io.elements("off").asInstanceOf[Bundle]

  val moduleId = Pcounters.registerModule(toNamed.toString)
  var pcMuxed = (0).U((Pcounters.PCWIDTH).W)
  val offloadRateArray =
    if (offloadData.size == 0)
      RegInit(VecInit(Seq.fill(1)((0).U((Pcounters.PCWIDTH).W))))
    else
      RegInit(VecInit(Seq.fill(offloadData.size)((0).U((Pcounters.PCWIDTH).W))))
  val pcPaused = RegInit(false.B)
  val engineUtilization = RegInit(0.U((Pcounters.PCWIDTH).W))
  val inTokens = RegInit(0.U((Pcounters.PCWIDTH).W))
  val outTokens = RegInit(0.U((Pcounters.PCWIDTH).W))

  if (compilerControl.pcEnable) {
    //offloadData.foreach(x => println("Port name is " + x._1))
    val offPCBackPressure =
      if (offloadData.size == 0)
        RegInit(VecInit(Seq.fill(1)((0).U((Pcounters.PCWIDTH).W))))
      else
        RegInit(VecInit(Seq.fill(offloadData.size)((0).U((Pcounters.PCWIDTH).W))))

    //println("Module name is " + toNamed.toString)
    var portId = 1 //leave zero for broadcast
    val inPCBackPressure = RegInit((0).U((Pcounters.PCWIDTH).W))
    val outPCBackPressure = RegInit((0).U((Pcounters.PCWIDTH).W))

    val IsPcReset = io.pcIn.valid && io.pcIn.bits.request && io.pcIn.bits.pcType === Pcounters.pcReset
    when (IsPcReset) {
      pcPaused := false.B
    }
    when (io.pcIn.valid && io.pcIn.bits.request && io.pcIn.bits.pcType === Pcounters.pcPause) {
      pcPaused := !pcPaused
    }
    //Input back pressure pc
    Pcounters.registerPC("in", Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
    when (IsPcReset) {
      inPCBackPressure := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.in.valid && !io.in.ready && !pcPaused) {
      inPCBackPressure := inPCBackPressure + (1).U((Pcounters.PCWIDTH).W)
    }
    pcMuxed = Mux(io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) &&
    io.pcIn.bits.pcType === Pcounters.backPressure, inPCBackPressure, pcMuxed)

    //Output back pressure pc
    portId = portId + 1
    Pcounters.registerPC("out", Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
    when (IsPcReset) {
      engineUtilization := (0).U((Pcounters.PCWIDTH).W)
      outPCBackPressure := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.out.valid && !io.out.ready && !pcPaused) {
      outPCBackPressure := outPCBackPressure + (1).U((Pcounters.PCWIDTH).W)
    }
    when (IsPcReset) {
      inTokens := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.in.valid && io.in.ready && !pcPaused) {
      inTokens := inTokens + (1).U((Pcounters.PCWIDTH).W)
    }
    when (IsPcReset) {
      outTokens := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.out.valid && io.out.ready && !pcPaused) {
      outTokens := outTokens + (1).U((Pcounters.PCWIDTH).W)
    }
    pcMuxed = Mux(io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) &&
    io.pcIn.bits.pcType === Pcounters.backPressure, outPCBackPressure, pcMuxed)
    portId = portId + 1

    //Offload backpressure/rate pcs
    for ((n, i) <- ioOff.elements) {
      Pcounters.registerPC(n, Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
      when (IsPcReset) {
        offloadRateArray(portId-3) := (0).U((Pcounters.PCWIDTH).W)
        offPCBackPressure(portId-3) := (0).U((Pcounters.PCWIDTH).W)
      }
      .elsewhen (
        i.asInstanceOf[gOffBundle[Data, Data]].req.valid &&
        !i.asInstanceOf[gOffBundle[Data, Data]].req.ready && !pcPaused)
      {
        offPCBackPressure(portId-3) := offPCBackPressure(portId-3) + (1).U((Pcounters.PCWIDTH).W)
      }
      //Mux the pcounter based on the index
      pcMuxed = Mux(
        io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) && io.pcIn.bits.pcType === Pcounters.backPressure,
        offPCBackPressure(portId-3),
        pcMuxed
      )
      portId = portId + 1
    }
    Pcounters.registerPC("offloadRate", Pcounters.offloadRate, moduleId.asInstanceOf[Int], 0)
    val offloadRate = offloadRateArray.reduceLeft((x,y) => Mux(x>y, x, y))
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.offloadRate, offloadRate, pcMuxed)
    Pcounters.registerPC("engineUtilization", Pcounters.engineUtilization, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.engineUtilization, engineUtilization, pcMuxed)
    Pcounters.registerPC("inTokens", Pcounters.inTokens, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.inTokens, inTokens, pcMuxed)
    Pcounters.registerPC("outTokens", Pcounters.outTokens, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.outTokens, outTokens, pcMuxed)
  }
  else {
    for (i <- 0 until offloadData.size) {
      offloadRateArray(i) := (0).U((Pcounters.PCWIDTH).W)
    }
    pcPaused := false.B
    engineUtilization := (0).U((Pcounters.PCWIDTH).W)
    inTokens := (0).U((Pcounters.PCWIDTH).W)
    outTokens := (0).U((Pcounters.PCWIDTH).W)
  }
}

class gRWComponent[inReadT <: Data, inWriteT <: Data, outReadT <: Data, outWriteT <: Data](
  inReadData: => inReadT, inWriteData: => inWriteT, outReadData: => outReadT, outWriteData: => outWriteT,
  offloadData: ArrayBuffer[(String, Data, Data)], extCompName: String = ""
) extends gComponentBase()
{

  val offBundle = DynamicBundle(offloadData.map((d) => (d._1, { val dBundle = new gOffBundle(d._2, d._3); dBundle.suggestName(d._1); dBundle})))
  val io = IO(new gRWInOutOffBundle(inReadData, inWriteData, outReadData, outWriteData, offBundle))

  if (extCompName != "") {
    suggestName(extCompName + "__class__" + this.getClass.getSimpleName)
  }
  println("In module " + toNamed + ", num of offload ports " + offloadData.size)

  def ioOff = io.elements("off").asInstanceOf[Bundle]

  val moduleId = Pcounters.registerModule(toNamed.toString)
  var pcMuxed = (0).U((Pcounters.PCWIDTH).W)
  val offloadRateArray =
    if (offloadData.size == 0)
      RegInit(VecInit(Seq.fill(1)((0).U((Pcounters.PCWIDTH).W))))
    else
      RegInit(VecInit(Seq.fill(offloadData.size)((0).U((Pcounters.PCWIDTH).W))))
  val pcPaused = RegInit(false.B)
  val engineUtilization = RegInit(0.U((Pcounters.PCWIDTH).W))
  val inTokens = RegInit(0.U((Pcounters.PCWIDTH).W))
  val outTokens = RegInit(0.U((Pcounters.PCWIDTH).W))

  if (compilerControl.pcEnable) {
    val offPCBackPressure =
      if (offloadData.size == 0)
        RegInit(VecInit(Seq.fill(1)((0).U((Pcounters.PCWIDTH).W))))
      else
        RegInit(VecInit(Seq.fill(offloadData.size)((0).U((Pcounters.PCWIDTH).W))))

    var portId = 1 //leave zero for broadcast
    val inPCBackPressure = RegInit((0).U((Pcounters.PCWIDTH).W))
    val outPCBackPressure = RegInit((0).U((Pcounters.PCWIDTH).W))

    val IsPcReset = io.pcIn.valid && io.pcIn.bits.request && io.pcIn.bits.pcType === Pcounters.pcReset
    when (IsPcReset) {
      pcPaused := false.B
    }
    when (io.pcIn.valid && io.pcIn.bits.request && io.pcIn.bits.pcType === Pcounters.pcPause) {
      pcPaused := !pcPaused
    }
    //Input back pressure pc
    Pcounters.registerPC("in", Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
    when (IsPcReset) {
      inPCBackPressure := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.read.in.valid && !io.read.in.ready && io.write.in.valid && !io.write.in.ready && !pcPaused) {
      inPCBackPressure := inPCBackPressure + (1).U((Pcounters.PCWIDTH).W)
    }
    pcMuxed = Mux(io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) &&
    io.pcIn.bits.pcType === Pcounters.backPressure, inPCBackPressure, pcMuxed)

    //Output back pressure pc
    portId = portId + 1
    Pcounters.registerPC("out", Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
    when (IsPcReset) {
      engineUtilization := (0).U((Pcounters.PCWIDTH).W)
      outPCBackPressure := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.read.out.valid && !io.read.out.ready && io.write.out.valid && !io.write.out.ready && !pcPaused) {
      outPCBackPressure := outPCBackPressure + (1).U((Pcounters.PCWIDTH).W)
    }
    when (IsPcReset) {
      inTokens := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.read.in.valid && io.read.in.ready && io.write.in.valid && io.write.in.ready && !pcPaused) {
      inTokens := inTokens + (1).U((Pcounters.PCWIDTH).W)
    }
    when (IsPcReset) {
      outTokens := (0).U((Pcounters.PCWIDTH).W)
    }
    .elsewhen (io.read.out.valid && io.read.out.ready && io.write.out.valid && io.write.out.ready && !pcPaused) {
      outTokens := outTokens + (1).U((Pcounters.PCWIDTH).W)
    }
    pcMuxed = Mux(io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) &&
    io.pcIn.bits.pcType === Pcounters.backPressure, outPCBackPressure, pcMuxed)
    portId = portId + 1

    //Offload backpressure/rate pcs
    for ((n, i) <- ioOff.elements) {
      Pcounters.registerPC(n, Pcounters.backPressure, moduleId.asInstanceOf[Int], portId)
      when (IsPcReset) {
        offloadRateArray(portId-3) := (0).U((Pcounters.PCWIDTH).W)
        offPCBackPressure(portId-3) := (0).U((Pcounters.PCWIDTH).W)
      }
      .elsewhen (
        i.asInstanceOf[gOffBundle[Data, Data]].req.valid &&
        !i.asInstanceOf[gOffBundle[Data, Data]].req.ready && !pcPaused)
      {
        offPCBackPressure(portId-3) := offPCBackPressure(portId-3) + (1).U((Pcounters.PCWIDTH).W)
      }
      //Mux the pcounter based on the index
      pcMuxed = Mux(
        io.pcIn.bits.portId === (portId).U((Pcounters.PCWIDTH).W) && io.pcIn.bits.pcType === Pcounters.backPressure,
        offPCBackPressure(portId-3),
        pcMuxed
      )
      portId = portId + 1
    }
    Pcounters.registerPC("offloadRate", Pcounters.offloadRate, moduleId.asInstanceOf[Int], 0)
    val offloadRate = offloadRateArray.reduceLeft((x,y) => Mux(x>y, x, y))
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.offloadRate, offloadRate, pcMuxed)
    Pcounters.registerPC("engineUtilization", Pcounters.engineUtilization, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.engineUtilization, engineUtilization, pcMuxed)
    Pcounters.registerPC("inTokens", Pcounters.inTokens, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.inTokens, inTokens, pcMuxed)
    Pcounters.registerPC("outTokens", Pcounters.outTokens, moduleId.asInstanceOf[Int], 0)
    pcMuxed = Mux(io.pcIn.bits.pcType === Pcounters.outTokens, outTokens, pcMuxed)
  }
  else {
    for (i <- 0 until offloadData.size) {
      offloadRateArray(i) := (0).U((Pcounters.PCWIDTH).W)
    }
    pcPaused := false.B
    engineUtilization := (0).U((Pcounters.PCWIDTH).W)
    inTokens := (0).U((Pcounters.PCWIDTH).W)
    outTokens := (0).U((Pcounters.PCWIDTH).W)
  }
}

abstract class gComponentGenBase(
  _offloadData: ArrayBuffer[(String, Data, Data)], _extCompName: String = ""
)
{
  val offloadData = _offloadData
  val extCompName = _extCompName
}

class gComponentGen[inT <: Data, outT <: Data](
  comp: => gComponent[inT, outT],
  _inData: => inT, _outData: => outT,
  _offloadData: ArrayBuffer[(String, Data, Data)], _extCompName: String = ""
)
  extends gComponentGenBase(_offloadData, _extCompName)
{
  val inData = _inData
  val outData = _outData

  def apply(): gComponent[inT, outT] = comp
}

class gRWComponentGen[inReadT <: Data, inWriteT <: Data, outReadT <: Data, outWriteT <: Data](
  comp: => gRWComponent[inReadT, inWriteT, outReadT, outWriteT],
  _inReadData: => inReadT, _inWriteData: => inWriteT, _outReadData: => outReadT, _outWriteData: => outWriteT,
  _offloadData: ArrayBuffer[(String, Data, Data)], _extCompName: String = ""
)
  extends gComponentGenBase(_offloadData, _extCompName)
{
  val inReadData = _inReadData
  val inWriteData = _inWriteData
  val outReadData = _outReadData
  val outWriteData = _outWriteData

  def apply(): gRWComponent[inReadT, inWriteT, outReadT, outWriteT] = comp
}

//class gComponentMD[inT <: Data, outT <: Data](inData: => inT, outData: => outT, offloadData: ArrayBuffer[(String, Data, Data)]) {
//  val inDataGen = inData
//  val outDataGen = outData
//  val offloadDataGen = offloadData
//
//  override def clone = { new gComponentMD(inData, outData, offloadData).asInstanceOf[this.type] }
//}

class gChainedComponent[inT <: Data, connT <: Data, outT <: Data](
  inDataSrc: => inT, outDataSrc: => connT, inDataSink: => connT, outDataSink: => outT,
  offloadData: ArrayBuffer[(String, Data, Data)],
  srcCompGen: gComponentGen[inT, connT], sinkCompGen: gComponentGen[connT, outT],
  extCompName: String
) extends gComponent(inDataSrc, outDataSink, offloadData, extCompName) with include
{
  val srcComp = Module(srcCompGen())
  val sinkComp = Module(sinkCompGen())

  //if (srcComp.parent != this) {
  //  srcComp.parent.children -= srcComp
  //  srcComp.parent = this
  //}
  //if (!this.children.contains(srcComp))
  //  this.children += srcComp
  //if (sinkComp.parent != this) {
  //  sinkComp.parent.children -= sinkComp
  //  sinkComp.parent = this
  //}
  //if (!this.children.contains(sinkComp))
  //  this.children += sinkComp

  //println("In gChained")
  //printChildren(this)

  io.in <> srcComp.io.in
  io.out <> sinkComp.io.out
  srcComp.io.out <> sinkComp.io.in
  //Connect the offload interfaces of offloaded component to the enclosing
  //component's offload interfaces
  //def sourceOff = srcComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def sourceOff = srcComp.io.elements("off").asInstanceOf[Bundle]
  //def sinkOff = sinkComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def sinkOff = sinkComp.io.elements("off").asInstanceOf[Bundle]
  val cOffElements = sinkOff.elements.filter((t) => {
    sourceOff.elements.exists((t1) => {t._1 == t1._1})
  })
  val cOffData = offloadData.filter((t) => {
    sinkOff.elements.exists((t1) => {t._1 == t1._1}) &&
    sourceOff.elements.exists((t2) => {t._1 == t2._1})
  })
  for ((n, i) <- ioOff.elements) {
    for ((n1, i1) <- sinkOff.elements) {
      if (n == n1 && !sourceOff.elements.exists((t) => {t._1 == n1})) {
        i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
        i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
      }
    }
  }
  for ((n, i) <- ioOff.elements) {
    for ((n1, i1) <- sourceOff.elements) {
      if (n == n1 && !sinkOff.elements.exists((t) => {t._1 == n1})) {
        i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
        i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
      }
    }
  }

  val reqArbs = cOffData.map(i => new gTaggedRRArbiter(2, i._2))
  val repDists = cOffData.map(i => new gTaggedDistributor(2, i._3))
  var i = 0

  for ((name1, reqInterface, replyInterface) <- cOffData) {
    for ((name, interface) <- ioOff.elements) {
      if (name1 == name) {
        interface.asInstanceOf[gOffBundle[Data, Data]].req <> reqArbs(i).io.out
        interface.asInstanceOf[gOffBundle[Data, Data]].rep <> repDists(i).io.in
      }
    }
    for ((name, interface) <- sourceOff.elements) {
      if (name1 == name) {
        interface.asInstanceOf[gOffBundle[Data, Data]].req <> reqArbs(i).io.in(0)
        interface.asInstanceOf[gOffBundle[Data, Data]].rep <> repDists(i).io.out(0)
      }
    }
    for ((name, interface) <- sinkOff.elements) {
      if (name1 == name) {
        interface.asInstanceOf[gOffBundle[Data, Data]].req <> reqArbs(i).io.in(1)
        interface.asInstanceOf[gOffBundle[Data, Data]].rep <> repDists(i).io.out(1)
      }
    }
    i = i + 1
  }

  //attach the performance counter interfaces
  io.pcIn <> srcComp.io.pcIn
  io.pcOut <> sinkComp.io.pcOut
  srcComp.io.pcOut <> sinkComp.io.pcIn
}

class gOffloadedComponent[
  inT <: Data, outT <: Data,
  inOffT <: Data, outOffT <: Data
](
  inData: => inT, outData: => outT,
  inOffData: => inOffT, outOffData: => outOffT,
  offloadData: ArrayBuffer[(String, Data, Data)],
  mainCompGen: gComponentGen[inT, outT], offCompGen: gComponentGen[inOffT, outOffT],
  offPort: String, extCompName: String
) extends gComponent(inData, outData, offloadData, extCompName) with include
{
  //println("This is gOffloadedComponent, offPort is " , offPort)

  val mainComp = Module(mainCompGen())
  val offComp = Module(offCompGen())

  //if (mainComp.parent != this) {
  //  mainComp.parent.children -= mainComp
  //  mainComp.parent = this
  //}
  //if (!this.children.contains(mainComp))
  //  this.children += mainComp
  //if (offComp.parent != this) {
  //  offComp.parent.children -= offComp
  //  offComp.parent = this
  //}
  //if (!this.children.contains(offComp))
  //  this.children += offComp

  //println("In gOffloaded")
  //printChildren(this)

  //val (left, right) = offloadDataMain.span( _._1 == offPort)
  //if (left.isEmpty) println("Gorilla++ Error: no offloaded port " + offPort + " in module")
  //val restOfOffloadedDataMain = { if (left.isEmpty) right else left.init ++ right}
  //val offoff = Bundle((mergeOffloads(restOfOffloadedDataMain, offloadDataOff).map((t) => (t._1, t._2()))))
  //offoff.name = "off"
  //io += offoff

  io.in <> mainComp.io.in
  io.out <> mainComp.io.out

  //def mainOff = mainComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def mainOff = mainComp.io.elements("off").asInstanceOf[Bundle]
  //def offOff = offComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def offOff = offComp.io.elements("off").asInstanceOf[Bundle]
  //Connect main component offload interface with argument port name to in/out of the offload component
  //Connect the rest of main component offload interfaces to the enclosing component's offload interfaces
  for ((n, i) <- mainOff.elements) {
    //println("offload name is " + n)
    if (n == offPort && i.isInstanceOf[gOffBundle[inOffT, outOffT]]) {
      i.asInstanceOf[gOffBundle[inOffT, outOffT]].req <> offComp.io.in
      i.asInstanceOf[gOffBundle[inOffT, outOffT]].rep <> offComp.io.out
    }
    else {
      for ((n1, i1) <- ioOff.elements) {
        if (n == n1) {
          i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
          i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
        }
      }
    }
  }
  //Connect the offload interfaces of offloaded compoenent to the enclosing component's offload interfaces
  for ((n, i) <- offOff.elements) {
    for ((n1, i1) <- ioOff.elements) {
      if (n == n1) {
        i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
        i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
      }
    }
  }
  //attache the performance counter interfaces
  io.pcIn <> mainComp.io.pcIn
  io.pcOut <> offComp.io.pcOut
  mainComp.io.pcOut <> offComp.io.pcIn
}

class gOffloadedRWComponent[
  inT <: Data, outT <: Data,
  inReadOffT <: Data, inWriteOffT <: Data, outReadOffT <: Data, outWriteOffT <: Data
](
  inData: => inT, outData: => outT,
  inReadOffData: => inReadOffT, inWriteOffData: => inWriteOffT, outReadOffData: => outReadOffT, outWriteOffData: => outWriteOffT,
  offloadData: ArrayBuffer[(String, Data, Data)],
  mainCompGen: gComponentGen[inT, outT], offCompGen: gRWComponentGen[inReadOffT, inWriteOffT, outReadOffT, outWriteOffT],
  offPort: String, extCompName: String
) extends gComponent(inData, outData, offloadData, extCompName) with include
{
  val mainComp = Module(mainCompGen())
  val offComp = Module(offCompGen())

  //if (mainComp.parent != this) {
  //  mainComp.parent.children -= mainComp
  //  mainComp.parent = this
  //}
  //if (!this.children.contains(mainComp))
  //  this.children += mainComp
  //if (offComp.parent != this) {
  //  offComp.parent.children -= offComp
  //  offComp.parent = this
  //}
  //if (!this.children.contains(offComp))
  //  this.children += offComp

  io.in <> mainComp.io.in
  io.out <> mainComp.io.out

  //def mainOff = mainComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def mainOff = mainComp.io.elements("off").asInstanceOf[Bundle]
  //def offOff = offComp.io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def offOff = offComp.io.elements("off").asInstanceOf[Bundle]
  //Connect main component offload interface with argument port name to in/out of the offload component
  //Connect the rest of main component offload interfaces to the enclosing component's offload interfaces
  for ((n, i) <- mainOff.elements) {
    //println("offload name is " + n)
    if (n == (offPort + "Read") && i.isInstanceOf[gOffBundle[inReadOffT, outReadOffT]]) {
      i.asInstanceOf[gOffBundle[inReadOffT, outReadOffT]].req <> offComp.io.read.in
      i.asInstanceOf[gOffBundle[inReadOffT, outReadOffT]].rep <> offComp.io.read.out
    }
    else if (n == (offPort + "Write") && i.isInstanceOf[gOffBundle[inWriteOffT, outWriteOffT]]) {
      i.asInstanceOf[gOffBundle[inWriteOffT, outWriteOffT]].req <> offComp.io.write.in
      i.asInstanceOf[gOffBundle[inWriteOffT, outWriteOffT]].rep <> offComp.io.write.out
    }
    else {
      for ((n1, i1) <- ioOff.elements) {
        if (n == n1) {
          i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
          i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
        }
      }
    }
  }
  //We dont Connect the offload interfaces of offloaded compoenent to the enclosing
  //component's offload interfaces
  //rwSpMem does not have offload ports.
  //for ((n, i) <- offOff.elements) {
  //  for ((n1, i1) <- ioOff.elements) {
  //    if (n == n1) {
  //      i1.asInstanceOf[gOffBundle[Data, Data]].req <> i.asInstanceOf[gOffBundle[Data, Data]].req
  //      i1.asInstanceOf[gOffBundle[Data, Data]].rep <> i.asInstanceOf[gOffBundle[Data, Data]].rep
  //    }
  //  }
  //}
  //attach the performance counter interfaces. We keep the spMems out of rings
  //Cause they are gComponnet and do not have PCs. TODO: change this
  io.pcIn <> mainComp.io.pcIn
  mainComp.io.pcOut <> offComp.io.pcIn
  io.pcOut <> mainComp.io.pcOut
}

class distributorComponent[T <: Data](n: Int, data: => T) extends Module {
  val io = IO(new gioDistributor(n, data))
}

class RRDistributorComponent[T <: Data](n: Int, data: => T) extends distributorComponent(n, data) {
  val rrDist = new gRRDistributor(n, data)
  //name_it()
  io <> rrDist.io
}

class distributorEngine[T <: Data](n: Int, data: => T) extends Module {
  val io = IO(new Bundle {
    val out = new gFIFOIO(data)
    val in = Flipped(new gFIFOIO(data))
    val outIndex = Output(UInt((log2Up(n)).W))
  })
}

class aggregatorComponent[T <: Data](n: Int, data: => T) extends Module {
  val io = IO(new gioArbiter(n, data))
}

class RRAggregatorComponent[T <: Data](n: Int, data: => T) extends aggregatorComponent(n, data) {
  val rrArb = new gRRArbiter(n, data)
  //rrArb.name_it()
  //name_it()
  io <> rrArb.io
}

class aggregatorEngine[T <: Data](n: Int, data: => T) extends Module {
  val io = IO(new Bundle {
    val out = Flipped(new gFIFOIO(data))
    val in = new gFIFOIO(data)
    val inIndex = Output(UInt((log2Up(n)).W))
  })
}

class pDistributor[T <: Data](n: Int, data: => T,
  distributorEngineGen: (Int, => T) => distributorEngine[T]
) extends distributorComponent[T](n, data) with include
{
  val distEngine = distributorEngineGen(n, data)
  val readies = Vec(n, Bool())

  io.in <> distEngine.io.in
  val broadcast =
    distEngine.io.outIndex === broadcastDistribute && io.out.map(x => x.ready).reduce(_&&_) && distEngine.io.out.valid

  for (i <- 0 to n) {
    io.out(i).valid := Mux(broadcast, true.B, (i).U === distEngine.io.outIndex && distEngine.io.out.valid)
    io.out(i).bits <> io.in.bits
    readies(i) := io.out(i).ready && (i).U === distEngine.io.outIndex
  }
  distEngine.io.out.ready := broadcast || readies.reduce(_&&_)
  io.in.ready := distEngine.io.in.ready
}

//class pAggregrator[T <: Data](n: Int, data: => T,
//  aggregatorEngineGen: (Int, => T) => aggregatorEngine[T]
//) extends aggregatorComponent(n, data) with include
//{
//  val aggEngine = aggregatorEngineGen(n, data)
//  val rrArb = new gRRArbiter(n, data) //TODO: if aggregator wants an specific input RR should be off
//  io.in <> rrArb.io.in
//  rrArb.io.out <> aggEngine.io.in
//  io.out <> aggEngine.io.out
//}

//class gReplicatedComponentDistAgg[inT <: Data, outT <: Data](
//  inData: => inT, outData: => outT, offloadData: ArrayBuffer[(String, Data, Data)],
//  compGen: gComponentGen[inT, outT], n: Int,
//  distributorGen: (Int, => inT) => distributorComponent[inT],
//  aggregatorGen: (Int, => outT) => aggregatorComponent[outT]
//) extends gComponent(inData, outData, offloadData) with include
//{}

class gReplicatedComponent[inT <: Data, outT <: Data](
  inData: => inT, outData: => outT, offloadData: ArrayBuffer[(String, Data, Data)],
  compGen: gComponentGen[inT, outT], n: Int, extCompName: String
) extends gComponent(inData, outData, offloadData, extCompName) with include
{
  val components = Range(0, n).map(i => Module(compGen()))
  //components.foreach(i => {
  //  if (i.parent != this) {
  //    i.parent.children -= i
  //    i.parent = this
  //  }
  //  if (!this.children.contains(i))
  //    this.children += i
  //})

  //val inputDist = distributorGen(n, inData)
  val inputDist = (new RRDistributorComponent(n, inData))
  val outputArb = (new RRAggregatorComponent(n, outData))
  //outputArb.name_it()
  //val outputArb = aggregatorGen(n, outData)
  val reqArbs = offloadData.map(i => new gTaggedRRArbiter(n, i._2))
  //val reqArbs = offloadData.map(i => new gRRArbiter(n, i._2))
  val repDists = offloadData.map(i => new gTaggedDistributor(n, i._3))
  //val repDists = offloadData.map(i => new gRRDistributor(n, i._3))
  //val repDists = offloadData.map(i => (new gRRDistributor(n)) {i._3()})
  //reqArbs.foreach(i => i.name_it())

  //println("In gReplicated")
  //printChildren(this)

  //offloadData.map(i => Range(0, n-1).map(reqArbs(i).in(j) := components(j)
  io.in <> inputDist.io.in
  Range(0, n).foreach(i => inputDist.io.out(i) <> components(i).io.in)
  io.out <> outputArb.io.out
  Range(0, n).foreach(i => outputArb.io.in(i) <> components(i).io.out)

  var i = 0
  //def cOff = io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
  def cOff = io.elements("off").asInstanceOf[Bundle]

  for ((name, interface) <- cOff.elements) {
    interface.asInstanceOf[gOffBundle[Data, Data]].req <> reqArbs(i).io.out
    interface.asInstanceOf[gOffBundle[Data, Data]].rep <> repDists(i).io.in
    i = i + 1
  }

  for (j <- 0 until n) {
    i = 0
    //def cOff = components(j).io.elements.getOrElse("off", nullOff).asInstanceOf[Bundle]
    def cOff = components(j).io.elements("off").asInstanceOf[Bundle]
    //Chain the performance counter interfaces
    if (j > 0) {
      //def pcIn = components(j).io.elements.getOrElse("pcIn", nullOff).asInstanceOf[Bundle]
      def pcIn = components(j).io.elements("pcIn").asInstanceOf[Bundle]
      //def pcOutPrevious = components(j-1).io.elements.getOrElse("pcOut", nullOff).asInstanceOf[Bundle]
      def pcOutPrevious = components(j-1).io.elements("pcOut").asInstanceOf[Bundle]
      pcIn <> pcOutPrevious
    }
    for ((name, interface) <- cOff.elements) {
      //if (interface.isInstanceOf[gOffBundle[Data, Data]]) {
        interface.asInstanceOf[gOffBundle[Data, Data]].req <> reqArbs(i).io.in(j)
        interface.asInstanceOf[gOffBundle[Data, Data]].rep <> repDists(i).io.out(j)
      //}
      i = i + 1
    }
  }

  //Attached the first component pc input to the main pc input
  //def pcIn0 = components(0).io.elements.getOrElse("pcIn", nullOff).asInstanceOf[Bundle]
  def pcIn0 = components(0).io.elements("pcIn").asInstanceOf[Bundle]
  io.pcIn <> pcIn0
  //Attached the last component pc out to the main pc output
  //def pcOutN = components(n-1).io.elements.getOrElse("pcOut", nullOff).asInstanceOf[Bundle]
  def pcOutN = components(n-1).io.elements("pcOut").asInstanceOf[Bundle]
  io.pcOut <> pcOutN
}

class PcElement(myName: String, myPCType: UInt, myModuleId: Int, myPortId: Int) {
  val name = myName
  val pcType = myPCType
  val moduleId = myModuleId
  val portId = myPortId
  var pcValue = 0
}

object Pcounters {
  val PCWIDTH = 20
  val nopc::backPressure::offloadRate::engineUtilization::pcReset::pcPause::inTokens::outTokens::Nil = Enum(8)
  var moduleId = 1 //leave zero for broadcast
  var elements = new ArrayBuffer[PcElement]()
  var moduleIDs = new HashMap[String, Int]()
  def numOfOffloadPorts(moduleName: String) = {
    elements.count(e => e.moduleId == moduleIDs.getOrElse(moduleName, 0) && e.pcType == backPressure)-2
  }
  def registerPC(name: String, pcType: UInt, moduleId: Int, portId: Int) {
    elements += new PcElement(name, pcType, moduleId, portId)
    //println("PCREPORT: PC is registered name: " + name + " type " + pcType.litValue().intValue() + " moduleId " + moduleId + " portId " + portId)
  }
  def registerModule(name: String) = {
    //println("PCREPORT: module " + name + " registered for pc moduleId is " + moduleId)
    moduleIDs += (name -> moduleId)
    moduleId = moduleId + 1
    moduleId - 1
  }
}

trait TagTrait {
  val TAGWIDTH = 5
  def tagUpper(x: UInt) = ((x >> (TAGWIDTH).U) & (((1).U << (TAGWIDTH).U) - (1).U))
  def tagLower(x: UInt) = (x & (((1).U << (TAGWIDTH).U) - (1).U))
}

trait MemTrait {
  val ADDR_WIDTH = 32
  val DATA_WIDTH = 512
}

trait GorillaUtil extends TagTrait {
  //def updateElementsCache(bundle: Bundle, field: Data, fieldName: String): Unit = {
  //  if (bundle.elementsCache != null) {
  //  var i = bundle.elementsCache.findIndexOf(x => x._1 == fieldName)
  //    if (i == -1) {
  //      println("Gorilla++Error: bundle does not have field " + fieldName)
  //    }
  //    bundle.elementsCache.update(i, (fieldName, field))
  //  }
  //}

  def mergeOffloads(offloadData1: ArrayBuffer[(String, Data, Data)], offloadData2: ArrayBuffer[(String, Data, Data)]) = {
    val offNames1 = offloadData1.map((t) => t._1).toSet
    val offNames2 = offloadData2.map((t) => t._1).toSet
    val offloadData1Minus2 = offloadData1.filter((t) => {
      !offNames2.contains(t._1)
    })
    offloadData1Minus2 ++ offloadData2
  }

  def Chain(
    extCompName: String,
    aGen: gComponentGen[Data, Data],
    bGen: gComponentGen[Data, Data]
  ): gComponentGen[Data, Data] =
  {
    val newExtCompName = extCompName + "__type__chained__"
    val inData = aGen.inData
    val outData = bGen.outData
    val offloadData = mergeOffloads(aGen.offloadData, bGen.offloadData)

    new gComponentGen(
      new gChainedComponent(aGen.inData, aGen.outData, bGen.inData, bGen.outData, offloadData, aGen, bGen, newExtCompName),
      inData, outData, offloadData, newExtCompName
    )
  }
  def Chain(
    extCompName: String,
    aGen: gComponentGen[Data, Data],
    bGen: gComponentGen[Data, Data],
    cGen: gComponentGen[Data, Data]
  ): gComponentGen[Data, Data] =
  {
    Chain(extCompName + "__" + "Chained__2", Chain(extCompName + "__" + "Chained_1", aGen, bGen), cGen)
  }
  def Chain(
    extCompName: String, compGens: gComponentGen[Data, Data]*
  ): gComponentGen[Data, Data] =
  {
    var i = 0
    compGens.reduceLeft {(a, b) => { i += 1; Chain(extCompName + "__" + "Chained__" + i, a, b)} }
  }

  def Offload[
    inT <: Data, outT <: Data,
    inOffT<: Data, outOffT<: Data
  ](
    extCompName: String,
    mainGen: gComponentGen[inT, outT],
    offGen: gComponentGen[inOffT, outOffT],
    offPort: String
  ): gComponentGen[inT, outT] =
  {
    val (left, right) = mainGen.offloadData.partition(_._1 != offPort)

    //println("Offload called for port " + offPort)
    //println("main offlaod ports are")
    //mainGen.offloadData.foreach(x => println(x._1))
    //println("left offlaod ports are")
    //left.foreach(x => println(x._1))
    //println("right offlaod ports are")
    //right.foreach(x => println(x._1))

    val restOfOffloadedDataMain = {if (right.isEmpty) left else left ++ right.tail}

    //println("in Offload main offPorts is ")
    //mainGen.offloadData.foreach(x => println(x._1))
    //println("in Offload offload offPorts is ")
    //offGen.offloadData.foreach(x => println(x._1))

    val offOff = mergeOffloads(restOfOffloadedDataMain, offGen.offloadData)
    //println("merged offlaod ports are")
    //offOff.foreach(x => println(x._1))

    val newExtCompName = extCompName + "__type__offloaded__" + offPort

    new gComponentGen(
      new gOffloadedComponent(
        mainGen.inData, mainGen.outData,
        offGen.inData, offGen.outData,
        offOff,
        mainGen, offGen,
        offPort, newExtCompName
      ),
      mainGen.inData, mainGen.outData, offOff, newExtCompName
    )
  }
  def Offload[
    inT <: Data, outT <: Data,
    inReadOffT <: Data, inWriteOffT <: Data, outReadOffT <: Data, outWriteOffT <: Data
  ](
    extCompName: String,
    mainGen: gComponentGen[inT, outT],
    offGen: gRWComponentGen[inReadOffT, inWriteOffT, outReadOffT, outWriteOffT],
    offPort: String
  ): gComponentGen[inT, outT] =
  {
    val (leftRead, rightRead) = mainGen.offloadData.partition(_._1 == offPort + "Read")
    val (leftWrite, rightWrite) = rightRead.partition(_._1 == offPort + "Write")
    val offOff = rightWrite

    val newExtCompName = extCompName + "__type__offloaded__" + offPort

    new gComponentGen(
      new gOffloadedRWComponent(
        mainGen.inData, mainGen.outData,
        offGen.inReadData, offGen.inWriteData, offGen.outReadData, offGen.outWriteData,
        offOff,
        mainGen, offGen,
        offPort, newExtCompName
      ),
      mainGen.inData, mainGen.outData, offOff, newExtCompName
    )
  }
  //def Offload[
  //  inT <: Data, outT <: Data,
  //  inOffT <: Data, outOffT <: Data
  //](
  //  extCompName: String,
  //  mainGen: gComponentGen[inT, outT],
  //  offGens: (gComponentGen[inOffT, outOffT], String)*
  //): gComponentGen[inT, outT] =
  //{
  //  offGens.foldLeft(mainGen) { (x, y) => Offload(extCompName + "__type__offloaded__" + y._2, x, y._1, y._2) }
  //}
  //def Offload[inT <: Data, outT <: Data, offCompGenT <: gComponentGenBase](
  //  extCompName: String,
  //  mainGen: gComponentGen[inT, outT],
  //  offGens: ArrayBuffer[(offCompGenT, String)]
  //): off[inT, outT] =
  //{
  //  offGens.foldLeft(mainGen) { (x, y) => Offload(extCompName + "__type__offloaded__" + y._2, x, y._1, y._2) }
  //}
  def Offload[
    inT <: Data, outT <: Data,
    inOffT <: Data, outOffT <: Data
  ](
    extCompName: String,
    mainGen: gComponentGen[inT, outT],
    offGens: ArrayBuffer[(gComponentGen[inOffT, outOffT], String)]
  ): gComponentGen[inT, outT] =
  {
    offGens.foldLeft(mainGen) { (x, y) => Offload(extCompName + "__type__offloaded__" + y._2, x, y._1, y._2) }
  }
  def Offload[
    inT <: Data, outT <: Data,
    inReadOffT <: Data, inWriteOffT <: Data, outReadOffT <: Data, outWriteOffT <: Data
  ](
    extCompName: String,
    mainGen: gComponentGen[inT, outT],
    offGens: ArrayBuffer[(gRWComponentGen[inReadOffT, inWriteOffT, outReadOffT, outWriteOffT], String)],
    dummy: String = "rw"  // FIXME: hack so function signature is different from the other Offload array buffer after type erasure
  ): gComponentGen[inT, outT] =
  {
    //offGens.foldLeft(mainGen) { (x, y) => Offload(extCompName + "__type__offloaded__" + y._2, x, y._1, y._2) }
    val test = offGens.foldLeft(mainGen) { (x, y) => Offload(extCompName + "__type__offloaded__" + y._2, x, y._1, y._2) }
    println(test)
    return test
  }

  def Replicate[inT <: Data, outT <: Data, OffT <: Data](
    extCompName: String,
    compGen: gComponentGen[inT, outT],
    n: Int
  ): gComponentGen[inT, outT] =
  {
    val newExtCompName = extCompName + "__type__replicated__"

    new gComponentGen(
      new gReplicatedComponent(
        compGen.inData, compGen.outData, compGen.offloadData, compGen, n, newExtCompName
      ),
      compGen.inData, compGen.outData, compGen.offloadData, newExtCompName
    )
  }

  val broadcastDistribute = (255).U

  //def printChildren(p: Module) {
  //  p.children.foreach(c => {
  //    println("Design hierarchy --- parent " + p.name + " child " + c.name)
  //    printChildren(c)
  //  })
  //}

  //def printPC(p: Module) {
  //  if (compilerControl.pcEnable) {
  //    p.children.foreach(c => {
  //      if (p.isInstanceOf[gComponent[Data, Data]]) {
  //        println("Backpressure in module " + p.name + " is " + p.asInstanceOf[gComponent[Data, Data]].inPCBackPressure.litValue().intValue())
  //      }
  //      printPC(c)
  //    })
  //  }
  //}
}
