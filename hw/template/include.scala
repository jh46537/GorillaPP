import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap
import scala.io.Source

// Parses config from primate.cfg and bundles all the knobs into a single object
// to be accepted by all configurable HW classes
class PrimateConfig(filename: String) {
    val fileSource = Source.fromFile(filename)
    val lines = fileSource.getLines().toList
    var knobs:Map[String, String] = Map()
    for (line <- lines) {
        val Array(key, value) = line.split("=")
        knobs += (key -> value)
    }
    val TAGWIDTH = 5
    val NUM_THREADS = knobs.apply("NUM_THREADS").toInt
    val REG_WIDTH = knobs.apply("REG_WIDTH").toInt
    val NUM_REGS = knobs.apply("NUM_REGS").toInt
    val NUM_BFUS = knobs.apply("NUM_BFUS").toInt + 2 // IO and LSU are hidden lol
    val NUM_ALUS = knobs.apply("NUM_ALUS").toInt
    val IMM_WIDTH = knobs.apply("IMM_WIDTH").toInt
    val NUM_REGBLOCKS = knobs.apply("NUM_REGBLOCKS").toInt
    val NUM_SRC_POS = knobs.apply("NUM_SRC_POS").toInt
    val NUM_SRC_MODES = knobs.apply("NUM_SRC_MODES").toInt
    val NUM_DST_POS = knobs.apply("NUM_DST_POS").toInt
    val NUM_WB_ENS = knobs.apply("NUM_WB_ENS").toInt
    val MAX_FIELD_WIDTH = knobs.apply("MAX_FIELD_WIDTH").toInt
    val IP_WIDTH = knobs.apply("IP_WIDTH").toInt
    val REG_BLOCK_WIDTH:Array[Int] = knobs.apply("REG_BLOCK_WIDTH").split(" ").map(_.toInt)
    val src_pos:Array[Int] = knobs.apply("SRC_POS").split(" ").map(_.toInt)
    val src_mode:Array[Int] = knobs.apply("SRC_MODE").split(" ").map(_.toInt)
    val dst_encode:Array[Long] = knobs.apply("DST_ENCODE").split(" ").map(_.toLong)
    val dst_pos:Array[Long] = knobs.apply("DST_POS").split(" ").map(_.toLong)
    val wbens:Array[Long] = knobs.apply("DST_EN").split(" ").map(_.toLong)
    val dst_en_encode:Array[(Int, Int)] = knobs.apply("DST_EN_ENCODE").split(";").map(_.split(" ") match {case Array(a1, a2) => (a1.toInt, a2.toInt)})

    val NUM_OPCODES  = 64 // number of unique opcodes
    val OPCODE_WIDTH = 6  // bits required to encode unique opcodes. Fixed to 6 for RISC-V rn
    val NUM_FUOPS_LG = OPCODE_WIDTH // TODO: Legacy code

    val NUM_THREADS_LG = log2Up(NUM_THREADS)
    val NUM_REGS_LG = log2Up(NUM_REGS)
    val NUM_FUS = (NUM_BFUS).max(NUM_ALUS)
    val NUM_FUS_LG = log2Up(NUM_FUS)
    val NUM_RD_BANKS = scala.math.pow(2, log2Up(NUM_FUS)).toInt
    val NUM_RF_RD_PORTS = NUM_FUS
    val NUM_WR = (NUM_BFUS).max(NUM_ALUS)
    val NUM_RF_WR_PORTS = (NUM_WR+1)/2
    val NUM_WR_BANKS = scala.math.pow(2, log2Up(NUM_RF_WR_PORTS)).toInt
    val NUM_SRC_POS_LG = log2Up(NUM_SRC_POS)
    val NUM_SRC_MODES_LG = log2Up(NUM_SRC_MODES)
    val NUM_DST_POS_LG = log2Up(NUM_DST_POS)
    val NUM_DST_MODES_LG = log2Up(NUM_SRC_MODES)
    val INST_RAM_SIZE = 4096
    // FIXME
    val ALU_SRC_WIDTH = NUM_REGS_LG
    val ALU_INST_WIDTH = Math.ceil((7 + ALU_SRC_WIDTH * 3 + 3 + 7)/8) * 8
    val INSTR_WIDTH = ALU_INST_WIDTH.toInt * (NUM_FUS + NUM_ALUS*3 + 1)

    val NONE_SELECTED = (NUM_THREADS).U((log2Up(NUM_THREADS+1)).W)

    // new signals
    val NUM_SLOTS = 2 + NUM_BFUS // TODO: idrfk but we need two slots for BRu and LS + number of BFUS
}


class BFU_IO(config: PrimateConfig) extends Bundle {
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(config.TAGWIDTH.W))
    val in_opcode     = Input(UInt(config.OPCODE_WIDTH.W))
    val in_imm        = Input(UInt(12.W))
    val in_bits       = Input(UInt(config.REG_WIDTH.W))
    val in_ready      = Output(Bool())
    val out_valid     = Output(Bool())
    val out_tag       = Output(UInt(config.TAGWIDTH.W))
    val out_flag      = Output(UInt(config.IP_WIDTH.W))
    val out_bits      = Output(UInt(config.REG_WIDTH.W))
    val out_ready     = Input(Bool())
}


object BFUOpCodes extends ChiselEnum {
  // TODO: how to define these?????
  val nop = Value
}
