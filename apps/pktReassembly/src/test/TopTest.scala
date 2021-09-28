import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import flatspec._
import matchers.should._


class TopTests(c: Top) extends gTester[Top](c) {
  val inputData = List(0, 10, 20, 30)
  val iDelay = 1

  //Spin for a while without any test input
  for (time <- 0 until 5) {
    poke(c.io.in.valid, false.B)
    poke(c.io.in.bits.pkt.seq, 0.U)
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

  //Actual tests
  var sourced = 0
  var sourcedIndex = 0
  var sinked = 0
  var sinkedIndex = 0
  var allPassed = true
  var cycles = 0
  val numOfInputs = 64
  val numThreads = 16

  while(sourced < numOfInputs || sinked < numOfInputs) {
    if (sourced < numThreads) {
      poke(c.io.in.bits.res, 0xff.U)
      poke(c.io.in.bits.head_ptr, 0xffff.U)
      poke(c.io.in.bits.pkt.flags, 0.U)
      poke(c.io.in.bits.pkt.pktID, sourcedIndex.U)
      poke(c.io.in.bits.pkt.seq, (inputData(sourcedIndex)).U)
      poke(c.io.in.bits.pkt.length, 10.U)
      
      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else if ((sourced < numOfInputs) && (cycles % iDelay == 0)) {
      poke(c.io.in.bits.res, 0xff.U)
      poke(c.io.in.bits.head_ptr, (sourced % numThreads).U)
      poke(c.io.in.bits.pkt.flags, 0.U)
      poke(c.io.in.bits.pkt.pktID, sourcedIndex.U)
      poke(c.io.in.bits.pkt.seq, (inputData(sourcedIndex)).U)
      poke(c.io.in.bits.pkt.length, 10.U)
      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else {
      poke(c.io.in.bits.res, 0xff.U)
      poke(c.io.in.bits.head_ptr, 0xffff.U)
      poke(c.io.in.bits.pkt.flags, 0.U)
      poke(c.io.in.bits.pkt.pktID, 0.U)
      poke(c.io.in.bits.pkt.seq, 0.U)
      poke(c.io.in.bits.pkt.length, 10.U)
      poke(c.io.in.valid, false.B)
      poke(c.io.out.ready, true.B)
    }
    if (peek(c.io.in.ready) == 1 && (cycles % iDelay == 0) && (sourced < numOfInputs)) {
      sourced += 1
      sourcedIndex = sourced / numThreads
      println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex + " sinked is " + sinked)
    }
    if (peek(c.io.out.valid) == 1) {
      //When multi-threading or replication is used order of outputs are not preserved.
      //Otherwise, we can check the values
      //allPassed = allPassed && (peek(c.io.out.bits) == (inputData(sinkedIndex) + 2))
      // allPassed = allPassed && (peek(c.io.out.bits.a) == (inputData(sinkedIndex) + 2))

      if (allPassed == false) {
        // println("Test failed because output is " + peek(c.io.out.bits.a) +
        //         " expected " + (inputData(sinkedIndex) + 2))
        println("Sinked is " + sinked)
      }
        println("At " + cycles + " output " + peek(c.io.out.bits.res) +
                " sinked. sinked is " + sinked)
      sinked += 1
      sinkedIndex = sinked % inputData.length
    }
    step(1)
    cycles += 1
  }
  poke(c.io.in.valid, false.B)
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
}
