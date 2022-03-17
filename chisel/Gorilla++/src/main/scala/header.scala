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
class mspmIn_t extends Bundle { 
val opcode = UInt((5).W)
val word = UInt((128).W)
}
class mspmOut_t extends Bundle { 
val match_idx_vec = UInt((16).W)
val match_pos0 = UInt((4).W)
val match_pos1 = UInt((4).W)
val match_pos2 = UInt((4).W)
val match_pos3 = UInt((4).W)
val match_pos4 = UInt((4).W)
val match_pos5 = UInt((4).W)
val match_pos6 = UInt((4).W)
val match_pos7 = UInt((4).W)
val match_pos8 = UInt((4).W)
val match_pos9 = UInt((4).W)
val match_pos10 = UInt((4).W)
val match_pos11 = UInt((4).W)
val match_pos12 = UInt((4).W)
val match_pos13 = UInt((4).W)
val match_pos14 = UInt((4).W)
val match_pos15 = UInt((4).W)
}
class asciiIn_t extends Bundle { 
val opcode = UInt((5).W)
val string = UInt((128).W)
}
class asciiOut_t extends Bundle { 
val integer = UInt((128).W)
}
