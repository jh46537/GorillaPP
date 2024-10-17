import chisel3._
import chisel3.util._

class input_t extends Bundle {
    val empty = UInt(96.W)
    val data = UInt(768.W)
}
class output_t extends Bundle {
    val empty = UInt(16.W)
    val data = UInt(128.W)
}
