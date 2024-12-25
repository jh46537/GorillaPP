// This is an example file.
//input and output types are custom to the primate instance

import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class input_t extends Bundle { 
val data = UInt((512).W)
val empty = UInt(64.W)
}
class output_t extends Bundle { 
val data = UInt((512).W)
val empty = UInt(64.W)
}
