import org.scalatest._
import flatspec._
import matchers.should._

import chisel3._
import tywaves.simulator._
import tywaves.simulator.simulatorSettings._
import tywaves.simulator.ParametricSimulator._
import org.scalatest.flatspec.AnyFlatSpec
import circt.stage.ChiselStage

object VerilogMain extends App {
  Console.println("Gen Verilog...")
  ChiselStage.emitSystemVerilogFile(new Top,
  //args
  Array("--target-dir", "sv_output/")
  )
}

object TopSimMain extends App {
  new TopSimTester
}

class TopSimTester extends AnyFlatSpec with Matchers {
  behavior of "Top"

  it should "pass" in {
    import TywavesSimulator._
    simulate(new Top, Seq(VcdTrace, SaveWorkdirFile("Primate-sim")), simName="Primate_Sim") {
      c => new TopTests(c)
    }
  }

  // it should "Pass" in {
  //   import TywavesSimulator._
  //   simulate(new FakeMem, Seq(VcdTrace, SaveWorkdirFile("FakeMemTest")), simName="memInitTest") {
  //     c => {
  //       // c.io.reset.poke(true.B)
  // 	// c.io.enable.poke(false.B)
  // 	// c.clock.step(20)
  // 	// c.io.reset.poke(false.B)
  // 	// c.io.enable.poke(true.B)
  //       c.io.addr.poke(0.U)
  // 	c.clock.step(20)
  // 	c.io.addr.poke(1.U)
  // 	c.clock.step(20)
  // 	c.io.addr.poke(2.U)
  // 	c.clock.step(20)
  // 	println(cf"last value of memory is ${c.io.dataOut.peek()}")
  //     }
  //   }
  // }
}
