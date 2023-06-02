import chisel3._
import chisel3.util._
import scala.math._

class matchTable(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
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

  val NUM_TABLES = 8
  val NUM_TABLES_LG = log2Up(NUM_TABLES)
  val KEY_WIDTH = 48
  val VALUE_WIDTH = 15
  val ADDR_WIDTH = 8+NUM_TABLES_LG
  val DEFAULT_RULE_VAL = 1023
  val PC0 = 1
  val PC1 = 2

  val tag = Reg(UInt(tag_width.W))

  // val mem = Module(new mem(ADDR_WIDTH))
  val cache = Module(new cache(512, KEY_WIDTH, VALUE_WIDTH, 1))
  val hashU = Module(new hashUnit(KEY_WIDTH, ADDR_WIDTH-NUM_TABLES_LG-6))

  // Stage 0: hash
  val stall = Wire(Bool())
  val valid_s0 = RegInit(false.B)
  val tag_s0 = Reg(UInt(tag_width.W))
  val key_s0 = Reg(UInt(KEY_WIDTH.W))
  val tableID_s0 = Reg(UInt(NUM_TABLES_LG.W))

  io.in_ready := !stall
  hashU.io.data_in_valid := false.B
  hashU.io.stall := stall
  hashU.io.data_in := io.in_bits(0)(47, 0)
  when (!stall) {
    valid_s0 := io.in_valid
    tag_s0 := io.in_tag
    key_s0 := io.in_bits(0)(47, 0)
    tableID_s0 := io.in_imm(NUM_TABLES_LG-1, 0)
  }

  // Stage 1: access cache
  val valid_s1 = RegInit(false.B)
  val valid_s2 = RegInit(false.B)
  val tag_s1 = Reg(UInt(tag_width.W))
  val tag_s2 = Reg(UInt(tag_width.W))
  val key_s1 = Reg(UInt(KEY_WIDTH.W))
  val key_s2 = Reg(UInt(KEY_WIDTH.W))
  val hasehd_s1 = Reg(UInt((ADDR_WIDTH-6).W))
  val hasehd_s2 = Reg(UInt((ADDR_WIDTH-6).W))
  cache.io.read := false.B
  cache.io.index_rd := DontCare
  cache.io.tag_rd := DontCare

  when (!stall) {
    valid_s1 := valid_s0
    valid_s2 := valid_s1
    tag_s1 := tag_s0
    tag_s2 := tag_s1
    key_s1 := key_s0
    key_s2 := key_s1
    hasehd_s1 := Cat(tableID_s0, hashU.io.hashed)
    hasehd_s2 := hasehd_s1
  }

  when (valid_s0) {
    cache.io.read := true.B
    cache.io.index_rd := Cat(tableID_s0, hashU.io.hashed)
    cache.io.tag_rd := key_s0
  }

  // Stage 2: access cache
  // Stage 3: Cache return
  val metaFifo_t = new Bundle{
    val tag = UInt(tag_width.W)
    val key = UInt(KEY_WIDTH.W)
  }

  val memRspFifo_t = new Bundle{
    val tag = UInt(tag_width.W)
    val data = new cache_t(KEY_WIDTH, VALUE_WIDTH)
    val addr = UInt((ADDR_WIDTH-6).W)
  }

  val memRetryFifo_t = new Bundle{
    val tag = UInt(tag_width.W)
    val key = UInt(KEY_WIDTH.W)
    val addr = UInt((ADDR_WIDTH-6).W)
  }

  val memReqFifo = Module(new Queue(UInt((ADDR_WIDTH-6).W), num_threads))
  val memRspFifo = Module(new Queue(memRspFifo_t, num_threads))
  val metaFifo = Module(new Queue(metaFifo_t, num_threads))
  val hit_r = RegInit(false.B)

  io.out_valid := false.B
  io.out_tag := DontCare
  io.out_flag := DontCare
  io.out_bits := DontCare
  memReqFifo.io.enq.valid := false.B
  memReqFifo.io.enq.bits := DontCare
  metaFifo.io.enq.valid := false.B
  metaFifo.io.enq.bits := DontCare
  stall := false.B
  when (valid_s2) {
    when (cache.io.hit || hit_r) {
      stall := !io.out_ready
      when (io.out_ready) {
        io.out_valid := true.B
        io.out_flag := Mux((cache.io.readdata(9) === 0.U), PC0.U, PC1.U)
        io.out_bits := cache.io.readdata(8, 0)
        io.out_tag := tag_s2
        hit_r := false.B
      } .otherwise {
        hit_r := true.B
      }
    } .otherwise {
      stall := false.B
      memReqFifo.io.enq.bits := hasehd_s2
      memReqFifo.io.enq.valid := true.B
      metaFifo.io.enq.bits.tag := tag_s2
      metaFifo.io.enq.bits.key := key_s2
      metaFifo.io.enq.valid := true.B
    }
  }

  // Stage 4: Access memory
  val metaInFlightFifo = Module(new Queue(memRetryFifo_t, num_threads))
  val memRetryFifo = Module(new Queue(memRetryFifo_t, num_threads))
  memReqFifo.io.deq.ready := false.B
  metaFifo.io.deq.ready := false.B
  io.mem.mem_addr := DontCare
  io.mem.read := false.B
  io.mem.write := false.B
  io.mem.writedata := DontCare
  io.mem.byteenable := 0.U
  metaInFlightFifo.io.enq.valid := false.B
  metaInFlightFifo.io.enq.bits := DontCare
  memRetryFifo.io.deq.ready := false.B
  when (memRetryFifo.io.deq.valid) {
    io.mem.read := true.B
    io.mem.mem_addr := Cat(memRetryFifo.io.deq.bits.addr, 0.U(6.W))
    metaInFlightFifo.io.enq.bits:= memRetryFifo.io.deq.bits
    when (!io.mem.waitrequest) {
      memRetryFifo.io.deq.ready := true.B
      metaInFlightFifo.io.enq.valid := true.B
    }
  }.elsewhen (memReqFifo.io.deq.valid) {
    io.mem.read := true.B
    io.mem.mem_addr := Cat(memReqFifo.io.deq.bits, 0.U(6.W))
    metaInFlightFifo.io.enq.bits.key := metaFifo.io.deq.bits.key
    metaInFlightFifo.io.enq.bits.tag := metaFifo.io.deq.bits.tag
    metaInFlightFifo.io.enq.bits.addr := memReqFifo.io.deq.bits
    when (!io.mem.waitrequest) {
      memReqFifo.io.deq.ready := true.B
      metaFifo.io.deq.ready := true.B
      metaInFlightFifo.io.enq.valid := true.B
    }
  }

  // Stage 5: Memory return, linear search
  val ENTRY_WIDTH = KEY_WIDTH+VALUE_WIDTH+1
  val META_WIDTH = ADDR_WIDTH-6+1
  val NUM_ENTRIES = (512-META_WIDTH)/ENTRY_WIDTH
  val entries = Wire(Vec(NUM_ENTRIES, new cache_t(KEY_WIDTH, VALUE_WIDTH)))
  val match_vec = Wire(Vec(NUM_ENTRIES, Bool()))
  val matched_val = Wire(UInt(VALUE_WIDTH.W))
  val matched_r = RegInit(false.B)
  val matched_val_r = Reg(UInt(VALUE_WIDTH.W))
  val readdatavalid_s6 = RegInit(false.B)
  val hasLinkedList = RegInit(false.B)
  val linkedListAddr = Reg(UInt((ADDR_WIDTH-6).W))
  val key_s6 = Reg(UInt(KEY_WIDTH.W))
  val tag_s6 = Reg(UInt(tag_width.W))
  val addr_s6 = Reg(UInt((ADDR_WIDTH-6).W))

  Range(0, NUM_ENTRIES, 1).map(i => (entries(i) := 
    io.mem.readdata((i+1)*ENTRY_WIDTH-1, i*ENTRY_WIDTH).asTypeOf(new cache_t(KEY_WIDTH, VALUE_WIDTH))))
  Range(0, NUM_ENTRIES, 1).map(i => (match_vec(i) := 
    (entries(i).tag === metaInFlightFifo.io.deq.bits.key) && entries(i).valid))

  val cases = (0 until NUM_ENTRIES).map(i => match_vec(i) -> entries(i).value)
  matched_val := MuxCase(DEFAULT_RULE_VAL.U, cases)

  hasLinkedList := io.mem.readdata(511)
  linkedListAddr := io.mem.readdata(510, 512-META_WIDTH)
  metaInFlightFifo.io.deq.ready := false.B
  readdatavalid_s6 := io.mem.readdatavalid
  when (io.mem.readdatavalid) {
    key_s6 := metaInFlightFifo.io.deq.bits.key
    tag_s6 := metaInFlightFifo.io.deq.bits.tag
    addr_s6 := metaInFlightFifo.io.deq.bits.addr
    matched_r := match_vec.asUInt.orR
    metaInFlightFifo.io.deq.ready := true.B
    matched_val_r := matched_val
  }

  // Stage 6: Enq RspFifo
  memRetryFifo.io.enq.valid := false.B
  memRetryFifo.io.enq.bits := DontCare
  memRspFifo.io.enq.valid := false.B
  memRspFifo.io.enq.bits := DontCare
  when (matched_r || !hasLinkedList) {
    memRspFifo.io.enq.valid := readdatavalid_s6
    memRspFifo.io.enq.bits.tag := tag_s6
    memRspFifo.io.enq.bits.addr := addr_s6
    memRspFifo.io.enq.bits.data.valid := true.B
    memRspFifo.io.enq.bits.data.tag := key_s6
    memRspFifo.io.enq.bits.data.value := matched_val_r
  } .otherwise {
    // second access to memory
    memRetryFifo.io.enq.valid := true.B
    memRetryFifo.io.enq.bits.tag := tag_s6
    memRetryFifo.io.enq.bits.key := key_s6
    memRetryFifo.io.enq.bits.addr := linkedListAddr
  }

  // Install cache, return
  memRspFifo.io.deq.ready := false.B
  cache.io.write := false.B
  cache.io.writedata := memRspFifo.io.deq.bits.data.value
  cache.io.index_wr := memRspFifo.io.deq.bits.addr
  cache.io.tag_wr := memRspFifo.io.deq.bits.data.tag
  when (!(valid_s2 && cache.io.hit) && memRspFifo.io.deq.valid && io.out_ready) {
    cache.io.write := true.B
    memRspFifo.io.deq.ready := true.B
    io.out_valid := true.B
    io.out_tag := memRspFifo.io.deq.bits.tag
    io.out_bits := memRspFifo.io.deq.bits.data.value(8, 0)
    io.out_flag := Mux((memRspFifo.io.deq.bits.data.value(9) === 0.U), PC0.U, PC1.U)
  }

}