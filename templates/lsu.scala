import chisel3._
import chisel3.util._
import chisel3.util.Fill
import scala.math._

class loadStoreUnit(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle{
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(tag_width.W))
    val in_opcode     = Input(UInt(opcode_width.W))
    val in_imm        = Input(UInt(12.W))
    val in_bits       = Input(Vec(2, UInt(reg_width.W)))
    val in_ready      = Output(Bool())
    val out_valid     = Output(Bool())
    val out_tag       = Output(UInt(tag_width.W))
    val out_flag      = Output(UInt(ip_width.W))
    val out_bits      = Output(UInt(reg_width.W))
    val out_ready     = Input(Bool())

    val mem           = new gMemBundle

  })

  val MEM_WIDTH = 256
  val NUM_BLOCKS = MEM_WIDTH >> 5
  val RATIO = (Math.floor(reg_width / MEM_WIDTH)).toInt
  assert(RATIO * MEM_WIDTH == reg_width, "Register file width must be multiple of MEM_WIDTH")
 
  val MEM_SIZE = 512
  val ADDR_WIDTH_B = log2Up(MEM_SIZE) + log2Up(MEM_WIDTH) - 3
  val ADDR_WIDTH_W = ADDR_WIDTH_B + 2

  val mem = Seq.fill(NUM_BLOCKS)(SyncReadMem(MEM_SIZE, UInt(MEM_WIDTH.W)))
  val mem_addr = RegInit(0.U(ADDR_WIDTH_B.W))
  val mem_index = Wire(UInt(log2Up(MEM_SIZE).W))
  val mem_offset = Wire(UInt(log2Up(MEM_WIDTH).W))
  val mem_wr = RegInit(false.B)
  val valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(tag_width.W))
  val base_addr = Wire(SInt(32.W))
  val disp = Wire(SInt(32.W))
  val wr_data_obj = Reg(Vec(RATIO, UInt(MEM_WIDTH.W)))
  val wr_data = Reg(Vec(NUM_BLOCKS, UInt(32.W)))
  val readmeta = RegInit(false.B)
  val isObj = RegInit(false.B)

  io.mem.mem_addr   := DontCare
  io.mem.read       := false.B
  io.mem.write      := false.B
  io.mem.writedata  := DontCare
  io.mem.byteenable := DontCare

  io.out_flag := 0.U
  base_addr := io.in_bits(0)(31, 0).asSInt
  disp := io.in_imm.asSInt

  // Calculate address
  val mem_state = RegInit(0.U(1.W))
  val counter = RegInit(0.U(log2Up(RATIO).W))
  io.in_ready := false.B
  when (mem_state === 0.U) {
    io.in_ready := io.out_ready
    when (io.out_ready) {
      valid_r := io.in_valid
    }
    when (io.in_valid && io.out_ready) {
      when (io.in_opcode(2, 0) === 1.U) {
        (0 until NUM_BLOCKS).map(i => wr_data(i) := io.in_bits(1)(i*32+31, i*32))
        isObj := true.B
        when (counter < (RATIO-1).U) {
          counter := counter + 1.U
          mem_state := 1.U
        }
      } .otherwise {
        (0 until NUM_BLOCKS).map(i => wr_data(i) := io.in_bits(1)(31, 0))
        isObj := false.B
      }
      tag_r := io.in_tag
      mem_wr := io.in_opcode(4)
      (0 until RATIO).map(i => wr_data_obj(i) := io.in_bits(1)(i*MEM_WIDTH+MEM_WIDTH-1, i*MEM_WIDTH))
      val addr = base_addr + disp
      mem_addr := addr.asUInt
      when (addr === -1.S) {
        readmeta := true.B
      } .otherwise {
        readmeta := false.B
      }
    }
  } .otherwise {
    // multicycle load/store object
    when (io.out_ready) {
      mem_addr := mem_addr + (MEM_WIDTH >> 3).U
      for (i <- 0 until NUM_BLOCKS) {
        val cases = (0 until RATIO).map(x => (x.U === counter) -> wr_data_obj(x)(i*32+31, i*32))
        wr_data(i) := MuxCase(DontCare, cases)
      }
      //(0 until NUM_BLOCKS).map(i => wr_data(i) := wr_data_obj(counter*MEM_WIDTH+i*32+31, counter*MEM_WIDTH+i*32))
      when (counter < (RATIO-1).U) {
        counter := counter + 1.U
      } .otherwise {
        counter := 0.U
        mem_state := 0.U
      }
    }

  }
  mem_offset := mem_addr(log2Up(MEM_WIDTH)-4, 2)
  mem_index := mem_addr(ADDR_WIDTH_B-1, log2Up(MEM_WIDTH)-3)

  // Mem read/write
  val rd_data = Wire(Vec(NUM_BLOCKS, UInt(32.W)))
  val counter_r = Reg(UInt(log2Up(RATIO).W))
  val valid_r2 = RegInit(false.B)
  val isObj_r = RegInit(false.B)
  val tag_r2 = Reg(UInt(tag_width.W))
  val readmeta_r = RegInit(false.B)
  val mem_offset_r = Reg(UInt(log2Up(MEM_WIDTH).W))
  rd_data := DontCare
  io.out_bits := DontCare
  when (io.out_ready) {
    valid_r2 := false.B
    counter_r := counter
    isObj_r := isObj
    mem_offset_r := mem_offset
    tag_r2 := tag_r
    readmeta_r := readmeta
    when (valid_r) {
      for (i <- 0 until NUM_BLOCKS) {
        val rdwrPort = mem(i)(mem_index)
        when (mem_wr) {
          when (mem_offset === i.U) {
            rdwrPort := wr_data(i)
          }
        } .otherwise {
          when (io.out_ready) {
            rd_data(i) := rdwrPort
          }
        }
      }
      valid_r2 := true.B
    }
  }

  // Extract word
  val valid_out = RegInit(false.B)
  val rd_data_obj = Reg(Vec(RATIO, UInt(MEM_WIDTH.W)))
  val tag_out = Reg(UInt(tag_width.W))
  val readmeta_out = RegInit(false.B)
  when (io.out_ready) {
    valid_out := false.B
    readmeta_out := readmeta_r
    when (valid_r2) {
      tag_out := tag_r
      when (isObj_r) {
        rd_data_obj(counter_r) := rd_data.asUInt
        when (counter_r === (RATIO-1).U) {
          valid_out := true.B
        }
      } .otherwise {
        rd_data_obj(0) := rd_data(mem_offset_r)
        valid_out := true.B
      }
    }
  }

  when (readmeta_out) {
    io.out_bits := tag_out
  } .otherwise {
    io.out_bits := rd_data_obj.asUInt
  }

  io.out_valid := valid_out
  io.out_tag := tag_out

}