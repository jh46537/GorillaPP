import chisel3._
import chisel3.util._
import chisel3.simulator.EphemeralSimulator._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class gPipe[T <: Data](latency: Int = 1)
  extends gComponentLeaf(UInt(32.W), UInt(32.W), ArrayBuffer())
{
  val tags = Reg(Vec(latency, UInt(5.W)))
  val valids = RegInit(VecInit(Seq.fill(latency)(false.B)))
  when (io.out.ready) {
    tags(0) := io.in.tag
    valids(0) := io.in.valid
  }
  for (i <- latency-1 to 1 by -1) {
    when (io.out.ready) {
      valids(i) := valids(i-1)
      tags(i) := tags(i-1)
    }
  }
  io.out.tag := tags(latency-1)
  io.out.valid := valids(latency-1)
  io.in.ready := io.out.ready
}

class gTester[T <: Module](c: T) {
  def PCReport(cycles: Int, dataElements: Int) = {
    println("PCREPORT: throughput " +
     "%.4f".format(dataElements.intValue.toDouble/
      cycles.toDouble))
    println("PCREPORT: cycles " + cycles)
    pausePC()
    getBackPressures(cycles)
    getOffloadRates(cycles)
    getEngineUtilizationis(cycles)
    getInOutTokens(dataElements)
  }

  def resetPC() = {
    val io = c.asInstanceOf[Top].io
    io.in.valid.poke(false.B)
    io.pcIn.valid.poke(true.B)
    io.pcIn.bits.request.poke(true.B)
    io.pcIn.bits.pcType.poke(Pcounters.pcReset)
    c.clock.step(1)
    poke(io.pcIn.valid, false.B)
    while(io.pcOut.valid.peek() == 0) {
      c.clock.step(1)
    }
    println("PCREPORT: Performance counter reset received")
  }

  def pausePC() = {
    val io = c.asInstanceOf[Top].io
    io.pcIn.valid.poke(true.B)
    io.pcIn.bits.request.poke(true.B)
    io.pcIn.bits.pcType.poke(Pcounters.pcPause)
    io.pcIn.bits.moduleId.poke(0.U)
    io.pcIn.bits.portId.poke(0.U)
    c.clock.step(1)
    io.pcIn.valid.poke(false.B)
    while(io.pcOut.valid.peek() == 0) {
      c.clock.step(1)
    }
    println("PCREPORT: Performance counter pause ack received")
  }

  def getBackPressure(moduleId: Int, portId: Int): Int = {
      val io = c.asInstanceOf[Top].io
      c.clock.step(1)
      io.pcIn.valid.poke(true.B)
      io.pcIn.bits.request.poke(true.B)
      io.pcIn.bits.pcType.poke(Pcounters.backPressure)
      io.pcIn.bits.moduleId.poke(moduleId.U)
      io.pcIn.bits.portId.poke(portId.U)
      c.clock.step(1)
      io.pcIn.valid.poke(false.B)
      while(io.pcOut.valid.peek() == 0) {
        c.clock.step(1)
      }
    io.pcOut.bits.pcValue.peek().litValue.toInt
  }

  def getBackPressures(cycles: Int) = {
    val io = c.asInstanceOf[Top].io
    for ((name, id) <- Pcounters.moduleIDs) {
      //Input backPressure
      println("PCREPORT: input back pressure " +  name + " received " + "%.4f".format(
        getBackPressure(id, 1).toDouble/cycles.toDouble)
      )
      step(1)
      //Output backPressure
      println("PCREPORT: output back pressure " +  name + " received " + "%.4f".format(
        getBackPressure(id, 2).toDouble/cycles.toDouble)
      )
      //Offload backpressure
      for (i <- 3 to Pcounters.numOfOffloadPorts(name)+2) {
        println("PCREPORT: offload back pressure " +  i + " " + name + " received " + "%.4f".format(
          getBackPressure(id, i).toDouble/cycles.toDouble)
        )
      }
    }
  }

  def getGenericRatioPc(cycles: Int, pcName: String,
   pcType: UInt) {
    val io = c.asInstanceOf[Top].io
    for ((name, id) <- Pcounters.moduleIDs) {
      c.clock.step(1)
      io.pcIn.valid.poke(true.B)
      io.pcIn.bits.request.poke(true.B)
      io.pcIn.bits.pcType.poke(pcType)
      io.pcIn.bits.moduleId.poke(id.U)
      io.pcIn.bits.portId.poke(0.U) // doesn't matter
      c.clock.step(1)
      io.pcIn.valid.poke(false.B)
      while(io.pcOut.valid.peek() == 0) {
        c.clock.step(1)
      }
      println("PCREPORT: " + pcName + " " +  name + " received " +
       "%.4f".format(io.pcOut.bits.pcValue.peek().litValue.toInt.toDouble / cycles.toDouble))
      c.clock.step(1)
    }
  }

  def getEngineUtilizationis(cycles: Int) = {
    getGenericRatioPc(cycles, "engine utilization",
     Pcounters.engineUtilization)
  }

  def getInOutTokens(inputs: Int) = {
    getGenericRatioPc(inputs, "in tokens", Pcounters.inTokens)
    getGenericRatioPc(inputs, "out tokens", Pcounters.outTokens)
  }

  def getOffloadRates(cycles: Int) = {
    getGenericRatioPc(cycles, "offload rate",
     Pcounters.offloadRate)
  }

  def round(value: Either[Double, Float], places: Int) = {
    if (places < 0) 0
    else {
      val factor = Math.pow(10, places)
      value match {
        case Left(d) => (Math.round(d * factor) / factor)
        case Right(f) => (Math.round(f * factor) / factor)
      }
    }
  }

  def round(value: Double): Double =
   round(Left(value), 0)
  def round(value: Double, places: Int): Double =
   round(Left(value), places)
  def round(value: Float): Double =
   round(Right(value), 0)
  def round(value: Float, places: Int): Double =
   round(Right(value), places)
}
