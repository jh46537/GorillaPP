import chisel3._
import chisel3.util._

class cache_t(tag_width: Int, value_width: Int) extends Bundle {
  val valid = Bool()
  val tag   = UInt(tag_width.W)
  val value = UInt(value_width.W)

  override def cloneType = (new cache_t(tag_width, value_width).asInstanceOf[this.type])
}

class cache(num_entries: Int, tag_width: Int, value_width: Int, associativity: Int) extends Module {
  val io = IO(new Bundle {
    val index_rd   = Input(UInt(log2Up(num_entries).W))
    val tag_rd     = Input(UInt(tag_width.W))
    val read       = Input(Bool())
    val write      = Input(Bool())
    val index_wr   = Input(UInt(log2Up(num_entries).W))
    val tag_wr     = Input(UInt(tag_width.W))
    val writedata  = Input(UInt(value_width.W))
    val readdata   = Output(UInt(value_width.W))
    val hit        = Output(Bool())
  })

  val resetState = RegInit(true.B)
  val resetPtr = RegInit(0.U((log2Up(num_entries)+1).W))
  val mems = for (i <- 0 until associativity) yield {
    val mem = SyncReadMem(num_entries, new cache_t(tag_width, value_width))
    mem
  }

  // Read logic
  val match_vec = Wire(Vec(associativity, Bool()))
  val matched_val = Wire(UInt(value_width.W))
  val hit_r = RegInit(false.B)
  val readdata_r = Reg(UInt(value_width.W))
  val read_r = RegNext(io.read)
  val tag_rd_r = RegNext(io.tag_rd)
  val readdata = Wire(Vec(associativity, new cache_t(tag_width, value_width)))
  Range(0, associativity, 1).map(i => (readdata(i) := mems(i)(io.index_rd)))
  Range(0, associativity, 1).map(i => (match_vec(i) := (tag_rd_r === readdata(i).tag) && readdata(i).valid))
  val cases = (0 until associativity).map(i => match_vec(i) -> readdata(i).value)
  matched_val := MuxCase(DontCare, cases)

  hit_r := false.B
  when (read_r) {
    hit_r := match_vec.asUInt.orR
    readdata_r := matched_val
  }

  // Write logic
  val write_r = RegNext(io.write)
  val index_wr_r = RegNext(io.index_wr)
  val tag_wr_r = RegNext(io.tag_wr)
  val writedata_r = RegNext(io.writedata)
  val write_ptrs = RegInit(VecInit(Seq.fill(num_entries)(0.U((log2Up(associativity).W)))))
  val write_ptr = Reg(UInt(log2Up(associativity).W))

  when (io.write) {
    write_ptr := write_ptrs(io.index_wr)
    write_ptrs(io.index_wr) := write_ptrs(io.index_wr) + 1.U
  }

  when (resetState) {
    for (i <- 0 until associativity) {
      mems(i)(resetPtr) := 0.U.asTypeOf(new cache_t(tag_width, value_width))
    }
    when (resetPtr < num_entries.U) {
      resetPtr := resetPtr + 1.U
    } .otherwise {
      resetState := false.B
    }
  } .otherwise {
    when (write_r) {
      val mem_wrdata = Wire(new cache_t(tag_width, value_width))
      mem_wrdata.valid := true.B
      mem_wrdata.tag := tag_wr_r
      mem_wrdata.value := writedata_r
      for (i <- 0 until associativity) {
        when (write_ptr === i.U) {
          mems(i)(index_wr_r) := mem_wrdata
        }
      }
    }
  }

  io.readdata := readdata_r
  io.hit := hit_r

}