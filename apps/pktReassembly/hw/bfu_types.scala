import chisel3._
import chisel3.util._


class tuple_t extends Bundle { 
val dPort = UInt((16).W)
val sPort = UInt((16).W)
val dIP = UInt((32).W)
val sIP = UInt((32).W)
}
class metadata_t extends Bundle { 
val last_7_bytes = UInt((56).W)
val pdu_flag = UInt((2).W)
val pkt_flags = UInt((3).W)
val tcp_flags = UInt((9).W)
val hdr_len = UInt((9).W)
val flits = UInt((5).W)
val empty = UInt((6).W)
val pktID = UInt((10).W)
val len = UInt((16).W)
val seq = UInt((32).W)
val tuple = new tuple_t
val prot = UInt((8).W)
}
class fce_t extends Bundle { 
val pointer2 = UInt((9).W)
val addr3 = UInt((12).W)
val addr2 = UInt((12).W)
val addr1 = UInt((12).W)
val addr0 = UInt((12).W)
val last_7_bytes = UInt((56).W)
val slow_cnt = UInt((10).W)
val ll_valid = UInt((1).W)
val pointer = UInt((9).W)
val seq = UInt((32).W)
val tuple = new tuple_t
}
class ftCh0Input_t extends Bundle { 
val ch0_opcode = UInt((3).W)
val ch0_pkt = new metadata_t
}
class ftCh0Output_t extends Bundle { 
val flag = UInt((4).W)
val ch0_bit_map = UInt((5).W)
val ch0_q = new fce_t
}
class ftCh1Input_t extends Bundle { 
val ch1_opcode = UInt((3).W)
val ch1_bit_map = UInt((5).W)
val ch1_data = new fce_t
}
class llNode_t extends Bundle { 
val ptr1 = UInt((9).W)
val ptr0 = UInt((9).W)
val pkt = new metadata_t
}
class dyMemInput_t extends Bundle { 
val opcode = UInt((2).W)
val node = new llNode_t
}
