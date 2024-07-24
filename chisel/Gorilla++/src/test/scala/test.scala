import org.scalatest._
import flatspec._
import matchers.should._

import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec
import circt.stage.ChiselStage

object TopMain extends App {
  new TopTests(new Top)
}

object VerilogMain extends App {
  ChiselStage.emitSystemVerilog(new Top)
}

class runMain extends AnyFlatSpec with Matchers {
  behavior of "Top"

  it should "pass" in {
    simulate(new Top) {
      c => new TopTests(c)
    }
  }
}
