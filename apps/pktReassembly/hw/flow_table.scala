import chisel3._
import chisel3.util._
import chisel3.util.Fill

class flow_table_wrap(tag_width: Int) extends 
  BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val ch0_req_valid                       = Input(Bool())
    val ch0_req_tag                         = Input(UInt(tag_width.W))
    val ch0_req_data_ch0_opcode             = Input(UInt(3.W))
    val ch0_req_data_ch0_pkt_prot           = Input(UInt(8.W))
    val ch0_req_data_ch0_pkt_tuple_sIP      = Input(UInt(32.W))
    val ch0_req_data_ch0_pkt_tuple_dIP      = Input(UInt(32.W))
    val ch0_req_data_ch0_pkt_tuple_sPort    = Input(UInt(16.W))
    val ch0_req_data_ch0_pkt_tuple_dPort    = Input(UInt(16.W))
    val ch0_req_data_ch0_pkt_seq            = Input(UInt(32.W))
    val ch0_req_data_ch0_pkt_len            = Input(UInt(16.W))
    val ch0_req_data_ch0_pkt_pktID          = Input(UInt(10.W))
    val ch0_req_data_ch0_pkt_empty          = Input(UInt(6.W))
    val ch0_req_data_ch0_pkt_flits          = Input(UInt(5.W))
    val ch0_req_data_ch0_pkt_hdr_len        = Input(UInt(9.W))
    val ch0_req_data_ch0_pkt_tcp_flags      = Input(UInt(9.W))
    val ch0_req_data_ch0_pkt_pkt_flags      = Input(UInt(3.W))
    val ch0_req_data_ch0_pkt_pdu_flag       = Input(UInt(2.W))
    val ch0_req_data_ch0_pkt_last_7_bytes   = Input(UInt(56.W))
    val ch0_req_ready                       = Output(Bool())

    val ch0_rep_valid                       = Output(Bool())
    val ch0_rep_tag                         = Output(UInt(tag_width.W))
    val ch0_rep_data_flag                   = Output(UInt(2.W))
    val ch0_rep_data_ch0_bit_map            = Output(UInt(5.W))
    val ch0_rep_data_ch0_q_tuple_sIP        = Output(UInt(32.W))
    val ch0_rep_data_ch0_q_tuple_dIP        = Output(UInt(32.W))
    val ch0_rep_data_ch0_q_tuple_sPort      = Output(UInt(16.W))
    val ch0_rep_data_ch0_q_tuple_dPort      = Output(UInt(16.W))
    val ch0_rep_data_ch0_q_seq              = Output(UInt(32.W))
    val ch0_rep_data_ch0_q_pointer          = Output(UInt(9.W))
    val ch0_rep_data_ch0_q_ll_valid         = Output(Bool())
    val ch0_rep_data_ch0_q_slow_cnt         = Output(UInt(10.W))
    val ch0_rep_data_ch0_q_last_7_bytes     = Output(UInt(56.W))
    val ch0_rep_data_ch0_q_addr0            = Output(UInt(12.W))
    val ch0_rep_data_ch0_q_addr1            = Output(UInt(12.W))
    val ch0_rep_data_ch0_q_addr2            = Output(UInt(12.W))
    val ch0_rep_data_ch0_q_addr3            = Output(UInt(12.W))
    val ch0_rep_data_ch0_q_pointer2         = Output(UInt(9.W))
    val ch0_rep_ready                       = Input(Bool())

    val ch1_req_valid                       = Input(Bool())
    val ch1_req_tag                         = Input(UInt(tag_width.W))
    val ch1_req_data_ch1_opcode             = Input(UInt(3.W))
    val ch1_req_data_ch1_bit_map            = Input(UInt(5.W))
    val ch1_req_data_ch1_data_tuple_sIP     = Input(UInt(32.W))
    val ch1_req_data_ch1_data_tuple_dIP     = Input(UInt(32.W))
    val ch1_req_data_ch1_data_tuple_sPort   = Input(UInt(16.W))
    val ch1_req_data_ch1_data_tuple_dPort   = Input(UInt(16.W))
    val ch1_req_data_ch1_data_seq           = Input(UInt(32.W))
    val ch1_req_data_ch1_data_pointer       = Input(UInt(9.W))
    val ch1_req_data_ch1_data_ll_valid      = Input(Bool())
    val ch1_req_data_ch1_data_slow_cnt      = Input(UInt(12.W))
    val ch1_req_data_ch1_data_last_7_bytes  = Input(UInt(56.W))
    val ch1_req_data_ch1_data_addr0         = Input(UInt(12.W))
    val ch1_req_data_ch1_data_addr1         = Input(UInt(12.W))
    val ch1_req_data_ch1_data_addr2         = Input(UInt(12.W))
    val ch1_req_data_ch1_data_addr3         = Input(UInt(12.W))
    val ch1_req_data_ch1_data_pointer2      = Input(UInt(9.W))
    val ch1_req_ready                       = Output(Bool())

    val ch1_rep_valid                       = Output(Bool())
    val ch1_rep_tag                         = Output(UInt(tag_width.W))
    val ch1_rep_data                        = Output(UInt(8.W))
    val ch1_rep_ready                       = Input(Bool())

    val rst                                 = Input(Reset())
    val clk                                 = Input(Clock())
  })

  addResource("/bram_true2port_sim.v")
  addResource("/flow_table_wrap.sv")
}

class flowTable(tag_width: Int, reg_width: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends MultiIOModule {
  val ch0 = IO(new Bundle {
    val in_valid  = Input(Bool())
    val in_tag    = Input(UInt(tag_width.W))
    val in_opcode = Input(UInt(opcode_width.W))
    val in_imm    = Input(UInt(12.W))
    val in_bits   = Input(Vec(1, UInt(reg_width.W)))
    val in_ready  = Output(Bool())
    val out_valid = Output(Bool())
    val out_tag   = Output(UInt(tag_width.W))
    val out_flag  = Output(UInt(ip_width.W))
    val out_bits  = Output(UInt(reg_width.W))
    val out_ready = Input(Bool())
  })

  val ch1 = IO(new Bundle {
    val in_valid  = Input(Bool())
    val in_tag    = Input(UInt(tag_width.W))
    val in_opcode = Input(UInt(opcode_width.W))
    val in_imm    = Input(UInt(12.W))
    val in_bits   = Input(Vec(1, UInt(reg_width.W)))
    val in_ready  = Output(Bool())
    val out_valid = Output(Bool())
    val out_tag   = Output(UInt(tag_width.W))
    val out_flag  = Output(UInt(ip_width.W))
    val out_bits  = Output(UInt(reg_width.W))
    val out_ready = Input(Bool())
  })

  val io = IO(new Bundle {
    val mem           = new gMemBundle
  })

  io.mem.mem_addr := DontCare
  io.mem.read := false.B
  io.mem.write := false.B
  io.mem.writedata := DontCare
  io.mem.byteenable := DontCare

  val ch0_req_valid  = Wire(Bool())
  val ch0_req_tag    = Wire(UInt(tag_width.W))
  val ch0_req_data   = Wire(new ftCh0Input_t)
  val ch0_req_ready  = Wire(Bool())

  val ch0_rep_valid  = Wire(Bool())
  val ch0_rep_tag    = Wire(UInt(tag_width.W))
  val ch0_rep_data   = Wire(new ftCh0Output_t)
  val ch0_rep_ready  = Wire(Bool())

  val ch1_req_valid  = Wire(Bool())
  val ch1_req_tag    = Wire(UInt(tag_width.W))
  val ch1_req_data   = Wire(new ftCh1Input_t)
  val ch1_req_ready  = Wire(Bool())

  val ch1_rep_valid  = Wire(Bool())
  val ch1_rep_tag    = Wire(UInt(tag_width.W))
  val ch1_rep_data   = Wire(UInt(8.W))
  val ch1_rep_ready  = Wire(Bool())

  ch0_req_valid := ch0.in_valid
  ch0_req_tag := ch0.in_tag
  ch0_req_data.ch0_opcode := ch0.in_opcode
  ch0_req_data.ch0_pkt := ch0.in_bits(0).asTypeOf(new metadata_t)
  ch0.in_ready := ch0_req_ready

  ch0.out_valid := ch0_rep_valid
  ch0.out_tag := ch0_rep_tag
  ch0.out_flag := ch0_rep_data.flag
  ch0.out_bits := Cat(ch0_rep_data.ch0_bit_map, ch0_rep_data.ch0_q.asUInt)
  ch0_rep_ready := ch0.out_ready

  ch1_req_valid := ch1.in_valid
  ch1_req_tag := ch1.in_tag
  ch1_req_data.ch1_opcode := ch1.in_opcode
  ch1_req_data.ch1_bit_map := ch1.in_bits(0)(265, 261)
  ch1_req_data.ch1_data := ch1.in_bits(0)(260, 0).asTypeOf(new fce_t)
  ch1.in_ready := ch1_req_ready

  ch1.out_valid := ch1_rep_valid
  ch1.out_tag := ch1_rep_tag
  ch1.out_flag := 0.U
  ch1.out_bits := ch1_rep_data
  ch1_rep_ready := ch1.out_ready

  val ft_inst = Module(new flow_table_wrap(tag_width))
  ft_inst.io.clk := clock
  ft_inst.io.rst := reset
  ft_inst.io.ch0_req_valid                      := ch0_req_valid
  ft_inst.io.ch0_req_tag                        := ch0_req_tag
  ft_inst.io.ch0_req_data_ch0_opcode            := ch0_req_data.ch0_opcode
  ft_inst.io.ch0_req_data_ch0_pkt_prot          := ch0_req_data.ch0_pkt.prot
  ft_inst.io.ch0_req_data_ch0_pkt_tuple_sIP     := ch0_req_data.ch0_pkt.tuple.sIP
  ft_inst.io.ch0_req_data_ch0_pkt_tuple_dIP     := ch0_req_data.ch0_pkt.tuple.dIP
  ft_inst.io.ch0_req_data_ch0_pkt_tuple_sPort   := ch0_req_data.ch0_pkt.tuple.sPort
  ft_inst.io.ch0_req_data_ch0_pkt_tuple_dPort   := ch0_req_data.ch0_pkt.tuple.dPort
  ft_inst.io.ch0_req_data_ch0_pkt_seq           := ch0_req_data.ch0_pkt.seq
  ft_inst.io.ch0_req_data_ch0_pkt_len           := ch0_req_data.ch0_pkt.len
  ft_inst.io.ch0_req_data_ch0_pkt_pktID         := ch0_req_data.ch0_pkt.pktID
  ft_inst.io.ch0_req_data_ch0_pkt_empty         := ch0_req_data.ch0_pkt.empty
  ft_inst.io.ch0_req_data_ch0_pkt_flits         := ch0_req_data.ch0_pkt.flits
  ft_inst.io.ch0_req_data_ch0_pkt_hdr_len       := ch0_req_data.ch0_pkt.hdr_len
  ft_inst.io.ch0_req_data_ch0_pkt_tcp_flags     := ch0_req_data.ch0_pkt.tcp_flags
  ft_inst.io.ch0_req_data_ch0_pkt_pkt_flags     := ch0_req_data.ch0_pkt.pkt_flags
  ft_inst.io.ch0_req_data_ch0_pkt_pdu_flag      := ch0_req_data.ch0_pkt.pdu_flag
  ft_inst.io.ch0_req_data_ch0_pkt_last_7_bytes  := ch0_req_data.ch0_pkt.last_7_bytes
  ch0_req_ready                                 := ft_inst.io.ch0_req_ready
  ch0_rep_valid                                 := ft_inst.io.ch0_rep_valid
  ch0_rep_tag                                   := ft_inst.io.ch0_rep_tag
  ch0_rep_data.flag                             := ft_inst.io.ch0_rep_data_flag
  ch0_rep_data.ch0_bit_map                      := ft_inst.io.ch0_rep_data_ch0_bit_map
  ch0_rep_data.ch0_q.tuple.sIP                  := ft_inst.io.ch0_rep_data_ch0_q_tuple_sIP
  ch0_rep_data.ch0_q.tuple.dIP                  := ft_inst.io.ch0_rep_data_ch0_q_tuple_dIP
  ch0_rep_data.ch0_q.tuple.sPort                := ft_inst.io.ch0_rep_data_ch0_q_tuple_sPort
  ch0_rep_data.ch0_q.tuple.dPort                := ft_inst.io.ch0_rep_data_ch0_q_tuple_dPort
  ch0_rep_data.ch0_q.seq                        := ft_inst.io.ch0_rep_data_ch0_q_seq
  ch0_rep_data.ch0_q.pointer                    := ft_inst.io.ch0_rep_data_ch0_q_pointer
  ch0_rep_data.ch0_q.ll_valid                   := ft_inst.io.ch0_rep_data_ch0_q_ll_valid
  ch0_rep_data.ch0_q.slow_cnt                   := ft_inst.io.ch0_rep_data_ch0_q_slow_cnt
  ch0_rep_data.ch0_q.last_7_bytes               := ft_inst.io.ch0_rep_data_ch0_q_last_7_bytes
  ch0_rep_data.ch0_q.addr0                      := ft_inst.io.ch0_rep_data_ch0_q_addr0
  ch0_rep_data.ch0_q.addr1                      := ft_inst.io.ch0_rep_data_ch0_q_addr1
  ch0_rep_data.ch0_q.addr2                      := ft_inst.io.ch0_rep_data_ch0_q_addr2
  ch0_rep_data.ch0_q.addr3                      := ft_inst.io.ch0_rep_data_ch0_q_addr3
  ch0_rep_data.ch0_q.pointer2                   := ft_inst.io.ch0_rep_data_ch0_q_pointer2
  ft_inst.io.ch0_rep_ready                      := ch0_rep_ready
  ft_inst.io.ch1_req_valid                      := ch1_req_valid
  ft_inst.io.ch1_req_tag                        := ch1_req_tag
  ft_inst.io.ch1_req_data_ch1_opcode            := ch1_req_data.ch1_opcode
  ft_inst.io.ch1_req_data_ch1_bit_map           := ch1_req_data.ch1_bit_map
  ft_inst.io.ch1_req_data_ch1_data_tuple_sIP    := ch1_req_data.ch1_data.tuple.sIP
  ft_inst.io.ch1_req_data_ch1_data_tuple_dIP    := ch1_req_data.ch1_data.tuple.dIP
  ft_inst.io.ch1_req_data_ch1_data_tuple_sPort  := ch1_req_data.ch1_data.tuple.sPort
  ft_inst.io.ch1_req_data_ch1_data_tuple_dPort  := ch1_req_data.ch1_data.tuple.dPort
  ft_inst.io.ch1_req_data_ch1_data_seq          := ch1_req_data.ch1_data.seq
  ft_inst.io.ch1_req_data_ch1_data_pointer      := ch1_req_data.ch1_data.pointer
  ft_inst.io.ch1_req_data_ch1_data_ll_valid     := ch1_req_data.ch1_data.ll_valid
  ft_inst.io.ch1_req_data_ch1_data_slow_cnt     := ch1_req_data.ch1_data.slow_cnt
  ft_inst.io.ch1_req_data_ch1_data_last_7_bytes := ch1_req_data.ch1_data.last_7_bytes
  ft_inst.io.ch1_req_data_ch1_data_addr0        := ch1_req_data.ch1_data.addr0
  ft_inst.io.ch1_req_data_ch1_data_addr1        := ch1_req_data.ch1_data.addr1
  ft_inst.io.ch1_req_data_ch1_data_addr2        := ch1_req_data.ch1_data.addr2
  ft_inst.io.ch1_req_data_ch1_data_addr3        := ch1_req_data.ch1_data.addr3
  ft_inst.io.ch1_req_data_ch1_data_pointer2     := ch1_req_data.ch1_data.pointer2
  ch1_req_ready                                 := ft_inst.io.ch1_req_ready
  ch1_rep_valid                                 := ft_inst.io.ch1_rep_valid
  ch1_rep_tag                                   := ft_inst.io.ch1_rep_tag
  ch1_rep_data                                  := ft_inst.io.ch1_rep_data
  ft_inst.io.ch1_rep_ready                      := ch1_rep_ready
}