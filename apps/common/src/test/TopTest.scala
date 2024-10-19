import chisel3.iotesters.PeekPokeTester
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
    poke(c.io.in.valid, false.B)
    poke(c.io.in.last, true.B)
    poke(c.io.pcIn.valid, false.B)
    poke(c.io.pcIn.bits.pcType, Pcounters.pcReset)
    poke(c.io.pcIn.bits.moduleId, (0).U)
    poke(c.io.pcIn.bits.portId, (0).U)
    step(1)
  }

  //Reset the PC Ring
  poke(c.io.pcIn.valid, true.B)
  poke(c.io.pcIn.bits.request, true.B)
  poke(c.io.pcIn.bits.pcType, Pcounters.pcReset)
  step(1)
  poke(c.io.pcIn.valid, false.B)
  while(peek(c.io.pcOut.valid) == 0) {
    step(1)
  }
  println("PCREPORT: Performance counter reset received")
  for (time <- 0 until 512) {
    step(1)
  }
  //Actual tests
  var sourced = 0
  var sourcedIndex = 0
  var sinked = 0
  var sinkedIndex = 0
  var allPassed = true
  var cycles = 0
  val numOfInputs = lines.length
  val numOfOutputs = lines.length
  // val numOfInputs = 512
  // val numOfOutputs = 512
  val numThreads = 16
  var memReqBuf_time = new Array[Int](1024)
  var memReqBuf_addr = new Array[Int](1024)
  var memReqPtr = 0
  var memRspPtr = 0

  while(cycles < 250000 && (sourced < numOfInputs || sinked < numOfOutputs)) {
    // Read packets from file
    if (sourced < numOfInputs) {
      val line = lines(sourcedIndex).split(" ")
      val data = BigInt(line(2), 16)
      val empty = BigInt(line(1), 16)
      val last = BigInt(line(0))
      poke(c.io.in.bits.data, data.U)
      poke(c.io.in.last, last.U.asBool)
      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else {
      poke(c.io.in.valid, false.B)
      poke(c.io.in.last, true.B)
      poke(c.io.out.ready, true.B)
    }

    // Memory
    poke(c.io.mem.waitrequest, false.B)
    if (peek(c.io.mem.read) == 1) {
      memReqBuf_time(memReqPtr) = cycles + memDelay
      memReqBuf_addr(memReqPtr) = peek(c.io.mem.mem_addr).toInt
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
      poke(c.io.mem.readdatavalid, true.B)
      poke(c.io.mem.readdata, mem_res.U)
      if (memRspPtr == 1023) {
        memRspPtr = 0
      } else {
        memRspPtr = memRspPtr + 1
      }
    } else {
      poke(c.io.mem.readdatavalid, false.B)
    }

    // Generate packets

    if (peek(c.io.in.ready) == 1 && (sourced < numOfInputs)) {
      sourcedIndex += 1
    //   println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex + " sinked is " + sinked)
    }
    if (peek(c.io.in.ready) == 1 && peek(c.io.in.last) == 1 && (sourced < numOfInputs)) {
      sourced += 1
    //   println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex + " sinked is " + sinked)
    }
    if (peek(c.io.out.valid) == 1 && peek(c.io.out.last) == 1) {
    //   //When multi-threading or replication is used order of outputs are not preserved.
    //   //Otherwise, we can check the values
    //   //allPassed = allPassed && (peek(c.io.out.bits) == (inputData(sinkedIndex) + 2))
    //   // allPassed = allPassed && (peek(c.io.out.bits.a) == (inputData(sinkedIndex) + 2))

    //   if (allPassed == false) {
    //     // println("Test failed because output is " + peek(c.io.out.bits.a) +
    //     //         " expected " + (inputData(sinkedIndex) + 2))
    //     println("Sinked is " + sinked)
    //   }
        println("At " + cycles + " output " + peek(c.io.out.bits.pkt_flags) +
                " sinked. sinked is " + sinked)
      sinked += 1
    //   sinkedIndex = sinked % inputData.length
    }
    step(1)
    cycles += 1
  }
  poke(c.io.in.valid, false.B)
  poke(c.io.in.last, true.B)
  step(1)

  val UsePCReport = true
  if (!UsePCReport) {
    // Inquire the back pressure through the PC ring
    poke(c.io.pcIn.valid, true.B)
    poke(c.io.pcIn.bits.request, true.B)
    poke(c.io.pcIn.bits.pcType, Pcounters.backPressure)
    poke(c.io.pcIn.bits.moduleId, (3).U) //incthrough module Replicated
    poke(c.io.pcIn.bits.portId, (1).U) //Input port
    step(1)
    poke(c.io.pcIn.valid, false.B)
    while(peek(c.io.pcOut.valid) == 0) {
      step(1)
    }
    println("PCREPORT: back pressure received " + peek(c.io.pcOut.bits.pcValue))
    println("cycles: " + cycles)
  } else {
    PCReport(cycles, numOfInputs)
  }
  step(1)

  expect(allPassed.B, true.B)

  // fileSource.close
  
}
