import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class porcIn_t extends Bundle { 
val newThread = Bool()
val word = UInt((128).W)
}
class porcOut_t extends Bundle { 
val data = UInt((64).W)
val threadID = UInt(4.W)
}
class mspmInWord_t extends Bundle {
val string = UInt(128.W)
val length = UInt(4.W)
val idx = UInt(3.W)
}
class mspmIn_t extends Bundle { 
val opcode = UInt((5).W)
val word = new mspmInWord_t
}
class mspmOut_t extends Bundle { 
val matched = UInt(8.W)
val match_pos0 = UInt((4).W)
val match_pos1 = UInt((4).W)
val match_pos2 = UInt((4).W)
val match_pos3 = UInt((4).W)
val match_pos4 = UInt((4).W)
val match_pos5 = UInt((4).W)
val match_pos6 = UInt((4).W)
val match_pos7 = UInt((4).W)
}
class asciiIn_t extends Bundle { 
val opcode = UInt((5).W)
val string = UInt((128).W)
}
class asciiOut_t extends Bundle { 
val integer = UInt((128).W)
}
