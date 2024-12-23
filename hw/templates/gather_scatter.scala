import chisel3._
import chisel3.util._
import chisel3.util.Fill


// II = 1; Latency = 3;
// result is buffered internally to meet timing
class Gather(reg_width: Int, num_src_pos: Int, src_pos: Array[Int],
   max_out_width: Int, num_modes:Int, src_mode: Array[Int]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))
    val shift = Input(UInt(log2Up(num_src_pos).W))
    val mode = Input(UInt(log2Up(num_modes).W))
    val dout = Output(UInt(reg_width.W))
  })

  // populate the ROM with the values from parameterized array
  println("[GATHER] src_pos array: " + src_pos.mkString(" "))
  println("[GATHER] src_mode array: " + src_mode.mkString(" "))
  val src_pos_rom  = VecInit(src_pos.toSeq.map{s => s.U})
  val src_mode_rom = VecInit(src_mode.toSeq.map{s => s.U})

  // ports to the ROMs
  val field_start = Wire(UInt(32.W))
  val field_size  = Wire(UInt(32.W))

  field_start := src_pos_rom(io.shift)
  field_size  := src_mode_rom(io.mode)

  // required to match timing of original unit
  val dout_flop0 = Reg(UInt(reg_width.W))
  val dout_flop1 = Reg(UInt(reg_width.W))
  val dout_flop2 = Reg(UInt(reg_width.W))
  
  dout_flop0 := (io.din >> field_start)
  dout_flop1 := dout_flop0
  dout_flop2 := dout_flop1
  
  io.dout := dout_flop2

}

// II = 1; Latency = 1

class Scatter(reg_width: Int, lg_num_rdBlocks: Int, lg_num_modes: Int, num_wrBlocks: Int,
  num_dst_pos: Int, dst_encode: Array[Long], dst_pos: Array[Long],
  num_wbens: Int, dst_en_encode: Array[(Int, Int)], wbens: Array[Long]) extends Module {
  val io = IO(new Bundle {
    val din = Input(UInt(reg_width.W))           
    val shift = Input(UInt(lg_num_rdBlocks.W)) // encoded version of the field start bit
    val mode = Input(UInt(lg_num_modes.W))     // encoded version of the field size 
    val wren = Output(UInt(num_wrBlocks.W))    // block write enables for the register file
    val dout = Output(UInt(reg_width.W))       // shifted output. only defined for the blocks the regfile with write
  })

  // HW ROM that holds the destination field starting positions
  println("[SCATTER] dst_pos array: " + dst_pos.mkString(" "))	
  val dst_pos_rom  = VecInit(dst_pos.toSeq.map{s => s.U})

  // sugar over io.din
  val din_w = Wire(UInt(reg_width.W))

  // flop outputs for timing
  val dout_r = Reg(UInt(reg_width.W))
  val wben_r = Reg(UInt(num_wrBlocks.W))
  
  din_w := io.din
  dout_r := din_w << dst_pos_rom(io.shift)

  // mux to pick the correct wr enables.
  // dst_en_encode._1 is the start bit pos, dst_en_encode._2 is the field size. size == -1 means any size.
  val cases2 = (0 until num_wbens).map(i => ((io.shift === dst_en_encode(i)._1.U) && ((dst_en_encode(i)._2 == -1).B || (io.mode === dst_en_encode(i)._2.S.asUInt))) -> wbens(i).U)
  wben_r := MuxCase(0.U, cases2)

  io.dout := dout_r
  io.wren := wben_r
}

class GatherScatterUnit(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int,
  num_src_pos: Int, src_pos: Array[Int], max_out_width: Int, num_modes:Int, src_mode: Array[Int], 
  num_regblocks: Int, num_dst_pos: Int, dst_encode: Array[Long], dst_pos: Array[Long],
  num_wbens: Int, dst_en_encode: Array[(Int, Int)], wbens: Array[Long]) extends Module {
  val io = IO(new Bundle{
    val in_valid      = Input(Bool())
    val in_tag        = Input(UInt(tag_width.W))
    val in_opcode     = Input(UInt(opcode_width.W))
    val in_imm        = Input(UInt(12.W))
    val in_bits       = Input(Vec(1, UInt(reg_width.W)))
    val in_ready      = Output(Bool())
    val out_valid     = Output(Bool())
    val out_tag       = Output(UInt(tag_width.W))
    val out_flag      = Output(UInt(ip_width.W))
    val out_bits      = Output(UInt(reg_width.W))
    val out_wben      = Output(UInt(num_regblocks.W))
    val out_ready     = Input(Bool())
  })

  val num_src_pos_lg = log2Up(num_src_pos)
  val num_dst_pos_lg = log2Up(num_dst_pos)
  val num_modes_lg = log2Up(num_modes)

  val GATHER_DELAY = 3
  val SCATTER_DELAY = 1
  val DELAY = GATHER_DELAY.max(SCATTER_DELAY)
  val DELAY_MIN = GATHER_DELAY.min(SCATTER_DELAY)

  // opcode(0), 0: extract(gather); 1: insert(scatter)
  // in_imm(num_src_pos_lg-1, 0): src_pos
  // in_imm(num_src_pos_lg+num_modes_lg-1, num_src_pos_lg): src_mode

  val shift_gather = io.in_imm(num_src_pos_lg-1, 0)
  val mode_gather = io.in_imm(num_src_pos_lg+num_modes_lg-1, num_src_pos_lg)
  val shift_scatter = io.in_imm(num_dst_pos_lg-1, 0)
  val mode_scatter = io.in_imm(num_dst_pos_lg+num_modes_lg-1, num_dst_pos_lg)
  val gather = Module(new Gather(reg_width, num_src_pos, src_pos, max_out_width, num_modes, src_mode))
  val scatter = Module(new Scatter(reg_width, num_src_pos_lg, num_modes_lg, num_regblocks, num_dst_pos, dst_encode, dst_pos, num_wbens, dst_en_encode, wbens))
  
  val valid_vec = RegInit(VecInit(Seq.fill(DELAY)(false.B)))
  val tag_vec = Reg(Vec(DELAY, UInt(tag_width.W)))
  val opcode_vec = Reg(Vec(DELAY, UInt(1.W)))
  val res_vec = Reg(Vec(DELAY-DELAY_MIN, UInt(reg_width.W)))
  val wren_vec = RegInit(VecInit(Seq.fill(DELAY-DELAY_MIN)(0.U(num_regblocks.W))))

  gather.io.din := io.in_bits(0)
  gather.io.shift := shift_gather
  gather.io.mode := mode_gather

  scatter.io.din := io.in_bits(0)
  scatter.io.shift := shift_scatter
  scatter.io.mode := mode_scatter

  valid_vec(0) := false.B
  when (io.in_valid) {
    valid_vec(0) := true.B
    tag_vec(0) := io.in_tag
    opcode_vec(0) := io.in_opcode(0)
  }

  for (i <- 1 until DELAY-1) {
    valid_vec(i) := valid_vec(i-1)
    tag_vec(i) := tag_vec(i-1)
    opcode_vec(i) := opcode_vec(i-1)
  }

  res_vec(0) := scatter.io.dout
  wren_vec(0) := scatter.io.wren
  for (i <- 1 until DELAY-DELAY_MIN-1) {
    res_vec(i) := res_vec(i-1)
    wren_vec(i) := wren_vec(i-1)
  }

  when (opcode_vec(DELAY-1) === 0.U) {
    io.out_bits := gather.io.dout
    io.out_wben := Fill(num_regblocks, 1.U)
  } .otherwise {
    io.out_bits := scatter.io.dout
    io.out_wben := scatter.io.wren
  }
  io.out_valid := valid_vec(DELAY-1)
  io.out_tag := tag_vec(DELAY-1)
  io.out_flag := 0.U

}
