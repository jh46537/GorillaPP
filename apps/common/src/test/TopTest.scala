import chisel3.simulator.EphemeralSimulator._
import org.scalatest._
import flatspec._
import matchers.should._
import scala.io.Source


class TopTests(c: Top) extends gTester[Top](c) {
  val iDelay = 1
  val memDelay = 40  

  val filename = "input.txt"
  val fileSource = Source.fromFile(filename)
  val lines = fileSource.getLines.toList

  val memFile = "memInit.txt"
  val memSource = Source.fromFile(memFile)
  val mem = memSource.getLines.toList

  //Spin for a while without any test input
  for (time <- 0 until 5) {
    c.io.in.valid.poke(false.B)
    c.io.in.last.poke(true.B)
    c.io.pcIn.valid.poke(false.B)
    c.io.pcIn.bits.pcType.poke(Pcounters.pcReset)
    c.io.pcIn.bits.moduleId.poke((0).U)
    c.io.pcIn.bits.portId.poke((0).U)
    c.clock.step(1)
  }

  //Reset the PC Ring
  c.io.pcIn.valid.poke(true.B)
  c.io.pcIn.bits.request.poke(true.B)
  c.io.pcIn.bits.pcType.poke(Pcounters.pcReset)
  c.clock.step(1)
  c.io.pcIn.valid.poke(false.B)
  while(c.io.pcOut.valid.peek() == 0) {
    c.clock.step(1)
  }
  println("PCREPORT: Performance counter reset received")
  for (time <- 0 until 512) {
    c.clock.step(1)
  }
  //Actual tests
  var sourced = 0
  var sourcedIndex = 0
  var sinked = 0
  var sinkedIndex = 0
  var allPassed = true
  var cycles = 0
  // val numOfInputs = lines.length
  val numOfInputs = 512
  val numOfOutputs = 512
  val numThreads = 16
  var memReqBuf_time = new Array[Int](1024)
  var memReqBuf_addr = new Array[Int](1024)
  var memReqPtr = 0
  var memRspPtr = 0

  while(cycles < 250000 && (sourced < numOfInputs || sinked < numOfOutputs)) {
    // Read packets from file
    val line = lines(sourcedIndex).split(" ")
    val data = BigInt(line(2), 16)
    val empty = BigInt(line(1), 16)
    val last = BigInt(line(0))
    if (sourced < numOfInputs) {
      c.io.in.bits.data.poke(data.U)
//      c.io.in.bits.empty.poke(empty.U)
      c.io.in.last.poke(last.U.asBool)
      c.io.in.valid.poke(true.B)
      c.io.out.ready.poke(true.B)
    } else {
      c.io.in.valid.poke(false.B)
      c.io.in.last.poke(true.B)
      c.io.out.ready.poke(true.B)
    }

    // Memory
    c.io.mem.waitrequest.poke(false.B)
    if (c.io.mem.read.peek() == 1) {
      memReqBuf_time(memReqPtr) = cycles + memDelay
      memReqBuf_addr(memReqPtr) = c.io.mem.mem_addr.peek().litValue.toInt
      if (memReqPtr == 1023) {
        memReqPtr = 0
      } else {
        memReqPtr = memReqPtr + 1
      }
    }
    if (cycles == memReqBuf_time(memRspPtr) && (cycles != 0)) {
      println("mem response: cycles: " + cycles + ", time: " + memReqBuf_time(memRspPtr) + ", ptr: " + memRspPtr)
      val memReqAddr = memReqBuf_addr(memRspPtr) >> 6
      val mem_res = BigInt(mem(memReqAddr), 16)
      c.io.mem.readdatavalid.poke(true.B)
      c.io.mem.readdata.poke(mem_res.U)
      if (memRspPtr == 1023) {
        memRspPtr = 0
      } else {
        memRspPtr = memRspPtr + 1
      }
    } else {
      c.io.mem.readdatavalid.poke(false.B)
    }

    // Generate packets

    if (c.io.in.ready.peek() == 1 && (sourced < numOfInputs)) {
      sourcedIndex += 1
    //   println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex + " sinked is " + sinked)
    }
    if (c.io.in.ready.peek() == 1 && c.io.in.last.peek() == 1 && (sourced < numOfInputs)) {
      sourced += 1
    //   println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex + " sinked is " + sinked)
    }
    if (c.io.out.valid.peek() == 1 && c.io.out.last.peek() == 1) {
    //   //When multi-threading or replication is used order of outputs are not preserved.
    //   //Otherwise, we can check the values
    //   //allPassed = allPassed && (peek(c.io.out.bits) == (inputData(sinkedIndex) + 2))
    //   // allPassed = allPassed && (peek(c.io.out.bits.a) == (inputData(sinkedIndex) + 2))

    //   if (allPassed == false) {
    //     // println("Test failed because output is " + peek(c.io.out.bits.a) +
    //     //         " expected " + (inputData(sinkedIndex) + 2))
    //     println("Sinked is " + sinked)
    //   }
    //     println("At " + cycles + " output " + peek(c.io.out.bits.pkt_flags) +
    //             " sinked. sinked is " + sinked)
      sinked += 1
    //   sinkedIndex = sinked % inputData.length
    }
    c.clock.step(1)
    cycles += 1
  }
  c.io.in.valid.poke(false.B)
  c.io.in.last.poke(true.B)
  c.clock.step(1)

  val UsePCReport = true
  if (!UsePCReport) {
    // Inquire the back pressure through the PC ring
    c.io.pcIn.valid.poke(true.B)
    c.io.pcIn.bits.request.poke(true.B)
    c.io.pcIn.bits.pcType.poke(Pcounters.backPressure)
    c.io.pcIn.bits.moduleId.poke((3).U) //incthrough module Replicated
    c.io.pcIn.bits.portId.poke((1).U) //Input port
    c.clock.step(1)
    c.io.pcIn.valid.poke(false.B)
    while(c.io.pcOut.valid.peek() == 0) {
      c.clock.step(1)
    }
    println("PCREPORT: back pressure received " + c.io.pcOut.bits.pcValue.peek())
    println("cycles: " + cycles)
  } else {
    PCReport(cycles, numOfInputs)
  }
  c.clock.step(1)

  assert(allPassed.B)

  // fileSource.close
  
}
