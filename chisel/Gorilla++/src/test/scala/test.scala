import org.scalatest._
import flatspec._
import matchers.should._


class TopSpec extends AnyFlatSpec with Matchers {
  behavior of "Top"

  it should "generate top hardware" in {
    chisel3.iotesters.Driver.execute(
      Array("--generate-vcd-output", "on"),
      () => new Top
    ) {
      c => new TopTests(c)
    } should be(true)
  }
}
