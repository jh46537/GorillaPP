import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


trait include extends GorillaUtil {
  val dummy = 0
}

object ALUOpCodes extends ChiselEnum {
  val add, sub, xor, or, and, sll, srl, sra, slt, sltu, lui, cat = Value
}