import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import flatspec._
import matchers.should._


class TopTests(c: Top) extends gTester(c) {
  val inputs_data = List(1, 2, 4, 8)
  val iDelay = 1

  for (time <- 0 until 5) {
    poke(c.io.in.valid, false.B)
    step(1)
  }

  if (compilerControl.pcEnable) {
    resetPC()
  }

  var sourced = 0
  var sourcedIndex = 0
  var sinked = 0
  var sinkedIndex = 0
  var time = 0
  var allPassed = true
  var cycles = 0
  //val numOfPackets = 5000
  val numOfPackets = 2500
  val version = (4).U((4).W)
  val hLength = (14).U((4).W)
  val tos = (0).U((8).W)
  val length = (21).U((16).W)
  val identification = (10).U((16).W)
  val flagsOffset = (10).U((16).W)
  val ttl = (5).U((8).W)
  val protocol = (4).U((8).W)
  val checksum = (21).U((16).W)
  val srcAddr = (0).U((32).W)
  val dstAddr = (0).U((32).W)
  //val ipv4Header = Cat(version, hLength, tos, length,
  //  identification, flagsOffset, ttl, protocol, checksum,
  //  srcAddr, dstAddr)
  //val ipv4Header_1 = BigInt("0x_4_E_00_0015_000A_000A_05_04_0015_00000000", 16)
  val ipv4Header_1 = BigInt("4E000015000A000A0504001500000000", 16)
  //val ipv4Header_2 = BigInt("0x_00000000_000000000000000000000000", 16)
  val ipv4Header_2 = BigInt("00000000000000000000000000000000", 16)

  while(sourced < numOfPackets || sinked < numOfPackets-100) {
    if ((sourced < numOfPackets) && (cycles % iDelay == 0)) {
      poke(c.io.in.bits.l3.h1, ipv4Header_1)
      poke(c.io.in.bits.l3.h2, ipv4Header_2)
      poke(c.io.in.bits.l3.h2, 0.U(128.W))
      poke(c.io.in.bits.l3.h3, 0.U(128.W))
      poke(c.io.in.bits.l3.h4, 0.U(128.W))
      poke(c.io.in.bits.l3.h5, 0.U(128.W))
      poke(c.io.in.bits.l3.h6, 0.U(128.W))
      poke(c.io.in.bits.l3.h7, 0.U(128.W))
      poke(c.io.in.bits.l3.h8, 0.U(128.W))
      poke(c.io.in.bits.l2Protocol, (128).U)
      poke(c.io.in.bits.eth.l3Type, (64).U)
      poke(c.io.in.valid, true.B)
      poke(c.io.out.ready, true.B)
    } else {
      //poke(c.io.in.bits, (0).U)
      poke(c.io.in.valid, false.B)
      poke(c.io.out.ready, true.B)
    }
    // bump counters and check outputs after advancing clock
    if (peek(c.io.in.ready) == 1 && (cycles % iDelay == 0) && (sourced < numOfPackets)) {
      sourced += 1
      sourcedIndex = sourced % 4
      println("sourced and sourcedIndex are " + sourced + " " + sourcedIndex)
    }
    cycles += 1
    if (peek(c.io.out.valid) == 1) {
      if (allPassed == false) {
        println("Test failed ") //+ peek(c.io.out.bits) +
        //" expected " + (inputs_data(sinkedIndex) +2))
        println("Sinked is " + sinked)
      }
      println("At " + time + " outpout " + " sinked. Sinked is " +
        sinked + " sourced is " + sourced );
      sinked += 1
      sinkedIndex = sinked % 4
    }
    step(1)
    time += 1
  }

  if (compilerControl.pcEnable) {
    PCReport(cycles, numOfPackets)
  }

  step(1)
  allPassed
}
