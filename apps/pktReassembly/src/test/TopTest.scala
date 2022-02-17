import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import flatspec._
import matchers.should._


class TopTests(c: Top) extends gTester[Top](c) {
  val inputData = List(0, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101, 111, 121, 131, 141, 1)
  val iDelay = 1

  // val filename = "/home/marui/input.txt"
  // val fileSource = Source.fromFile(filename)
  // val lines = fileSource.getLines.toList

  //Spin for a while without any test input
  for (time <- 0 until 5) {
    poke(c.io.in.valid, false.B)
    poke(c.io.in.bits.seq, 0.U)
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
  val numOfInputs = 128
  val numThreads = 8

  while(cycles < 10000 && (sourced < numOfInputs || sinked < numOfInputs)) {
    // Read packets from file
    // val Array(prot, sIP, dIP, sPort, dPort, seq, len, pktID, tcp_flags) = lines(sourced).split(" ").map(_.toLong)
    // if (sourced < numOfInputs) {
    //   poke(c.io.in.bits.prot, prot.U)
    //   poke(c.io.in.bits.tuple.sIP, sIP.U)
    //   poke(c.io.in.bits.tuple.dIP, dIP.U)
    //   poke(c.io.in.bits.tuple.sPort, sPort.U)
    //   poke(c.io.in.bits.tuple.dPort, dPort.U)
    //   poke(c.io.in.bits.seq, seq.U)
    //   poke(c.io.in.bits.len, len.U)
    //   poke(c.io.in.bits.pktID, pktID.U)
    //   poke(c.io.in.bits.tcp_flags, tcp_flags.U)
      
    //   poke(c.io.in.valid, true.B)
    //   poke(c.io.out.ready, true.B)
    // } else {
    //   poke(c.io.in.valid, false.B)
    //   poke(c.io.out.ready, true.B)
    // }

    // Generate packets
    if (sourced < numThreads) {
      poke(c.io.in.bits.prot, 0x6.U)
      poke(c.io.in.bits.tuple.sIP, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.dIP, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.sPort, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.dPort, (sourced % numThreads).U)
      poke(c.io.in.bits.seq, (inputData(sourcedIndex)).U)
      poke(c.io.in.bits.len, 10.U)
      poke(c.io.in.bits.pktID, sourced.U)
      poke(c.io.in.bits.tcp_flags, 2.U)
      
      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else if ((sourced < numOfInputs) && (cycles % iDelay == 0)) {
      poke(c.io.in.bits.prot, 0x6.U)
      poke(c.io.in.bits.tuple.sIP, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.dIP, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.sPort, (sourced % numThreads).U)
      poke(c.io.in.bits.tuple.dPort, (sourced % numThreads).U)
      poke(c.io.in.bits.seq, (inputData(sourcedIndex)).U)
      poke(c.io.in.bits.len, 10.U)
      poke(c.io.in.bits.pktID, sourced.U)
      poke(c.io.in.bits.tcp_flags, 0.U)

      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else {
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
        println("At " + cycles + " output " + peek(c.io.out.bits.pkt_flags) +
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

  fileSource.close
  
}
