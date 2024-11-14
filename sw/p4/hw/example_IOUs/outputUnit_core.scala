import chisel3._
import chisel3.util._

class outputUnit_core(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends Module {
  val io = IO(new Bundle {
    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_data     = Output(UInt(512.W))
    val out_empty    = Output(UInt(6.W))
    val out_last     = Output(Bool())

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rs        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(32.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())

    val r_valid      = Output(Bool())
    val r_flag     = Output(UInt(ip_width.W))
    val r_tag        = Output(UInt(log2Up(num_threads).W))

    // from input unit
    val pkt_buf_data  = Input(new pkt_buf_t(num_threads))
    val pkt_buf_valid = Input(Bool())
    val pkt_buf_ready = Output(Bool())

    // dump regfile interface
    val rd_req_valid  = Output(Bool())
    val rd_req_ready  = Input(Bool())
    val rd_req        = Output(new BFU_regfile_req_t(log2Up(num_threads), num_regs_lg))
    val rd_rsp_valid  = Input(Bool())
    val rd_rsp_ready  = Output(Bool())
    val rd_rsp        = Input(new BFU_regfile_rsp_t(reg_width))
  })
  // opcode(0) = 0: set meta, 1: emit hdr
  // opcode(1) = 0: deparse not done, 1: deparse done
  // imm(5, 0): length

  val hdrMem_t = new Bundle {
    val regIdx = UInt(num_regs_lg.W)
    val length = UInt(6.W)
    val en = Bool()
    val last = Bool()
  }

  val lengthFifo_t = new Bundle {
    val length = UInt(6.W)
    val last = Bool()
  }

  val port = RegInit(0.U(9.W))
  val mcast_grp = RegInit(0.U(16.W))
  val threadDone = RegInit(VecInit(Seq.fill(num_threads)(false.B)))
  val hdrMem = SyncReadMem(32*num_threads, hdrMem_t)
  val hdrMemWrPtr = RegInit(VecInit(Seq.fill(num_threads)(0.U(5.W))))
  val hdrMemRdPtr = RegInit(0.U(5.W))

  val outReqState = RegInit(0.U(2.W))
  
  // Write hdrMem
  val wrAddr = Wire(UInt((log2Up(num_threads)+5).W))
  val wrData = Wire(hdrMem_t)
  val r_valid_r = RegInit(false.B)
  val tag_r = Reg(UInt(log2Up(num_threads).W))

  io.ar_ready := true.B
  io.r_flag := 0.U
  wrData := DontCare
  r_valid_r := false.B
  tag_r := io.ar_tag
  wrAddr := Cat(io.ar_tag, hdrMemWrPtr(io.ar_tag))
  when (io.ar_valid) {
    when (io.ar_opcode(0)) {
      wrData.regIdx := io.ar_rs
      wrData.length := io.ar_imm(5, 0)
      wrData.en := true.B
      when (io.ar_opcode(1)) {
        wrData.last := 1.U
        hdrMemWrPtr(io.ar_tag) := 0.U
        threadDone(io.ar_tag) := true.B
      } .otherwise {
        r_valid_r := true.B
        wrData.last := 0.U
        hdrMemWrPtr(io.ar_tag) := hdrMemWrPtr(io.ar_tag) + 1.U
      }
      hdrMem.write(wrAddr, wrData)
    } .otherwise {
      wrData.en := false.B
      wrData.last := 1.U
      when (io.ar_opcode(1)) {
        hdrMemWrPtr(io.ar_tag) := 0.U
        threadDone(io.ar_tag) := true.B
        hdrMem.write(wrAddr, wrData)
      } .otherwise {
        port := io.ar_bits(8, 0)
        mcast_grp := io.ar_bits(31, 16)
        r_valid_r := true.B
      }
    }
  }

  // Send Regfile read requests
  val rdAddr = Wire(UInt((log2Up(num_threads)+5).W))
  val rdAddr_r = Reg(UInt((log2Up(num_threads)+5).W))
  val lengthFifo = Module(new Queue(lengthFifo_t, 8))
  val rdData = hdrMem(rdAddr)

  io.rd_req_valid := false.B
  io.rd_req := DontCare
  lengthFifo.io.enq.valid := false.B
  lengthFifo.io.enq.bits := DontCare
  rdAddr := rdAddr_r
  when (outReqState === 0.U) {
    // IDLE
    when (io.pkt_buf_valid) {
      when (threadDone(io.pkt_buf_data.tag)) {
        rdAddr := Cat(io.pkt_buf_data.tag, hdrMemRdPtr)
        rdAddr_r := rdAddr
        hdrMemRdPtr := hdrMemRdPtr + 1.U
        outReqState := 1.U
      }
    }
  } .elsewhen (outReqState === 1.U) {
    // Dump out regfile
    when (rdData.en) {
      when (lengthFifo.io.enq.ready) {
        io.rd_req_valid := true.B
        io.rd_req.tag := io.pkt_buf_data.tag
        io.rd_req.rdAddr1 := rdData.regIdx
        io.rd_req.rdAddr2 := 0.U
        lengthFifo.io.enq.bits.length := rdData.length
        lengthFifo.io.enq.bits.last := rdData.last
        when (io.rd_req_ready) {
          lengthFifo.io.enq.valid := true.B
          rdAddr := Cat(io.pkt_buf_data.tag, hdrMemRdPtr)
          rdAddr_r := rdAddr
          when (rdData.last) {
            outReqState := 2.U
          } .otherwise {
            hdrMemRdPtr := hdrMemRdPtr + 1.U
          }
        } .otherwise {
          rdAddr := rdAddr_r
        }
      }
    } .otherwise {
      when (lengthFifo.io.enq.ready) {
        lengthFifo.io.enq.bits.length := 0.U
        lengthFifo.io.enq.bits.last := true.B
        lengthFifo.io.enq.valid := true.B
        outReqState := 2.U
      }
    }
  } .elsewhen (outReqState === 2.U) {
    // Wait Done
    hdrMemRdPtr := 0.U
    threadDone(io.pkt_buf_data.tag) := false.B
    outReqState := 0.U
  }

  // Receive regfile read responses
  val outRspState = RegInit(0.U(2.W))

  lengthFifo.io.deq.ready := false.B
  io.rd_rsp_ready := false.B
  io.r_valid := r_valid_r
  io.r_tag := tag_r
  io.pkt_buf_ready := false.B
  io.out_valid := false.B
  io.out_last := true.B
  io.out_data := DontCare
  io.out_empty := DontCare
  io.out_tag := DontCare
  when (outRspState === 0.U) {
    // Wait for regfile response
    when (io.rd_rsp_valid) {
      io.out_tag := io.pkt_buf_data.tag
      io.out_data := io.rd_rsp.rdData1
      when (io.pkt_buf_data.empty === 64.U) {
        io.out_last := true.B
      } .otherwise {
        io.out_last := false.B
      }
      io.out_empty := 64.U - lengthFifo.io.deq.bits.length
      io.out_valid := true.B
      when (io.out_ready) {
        io.rd_rsp_ready := true.B
        lengthFifo.io.deq.ready := true.B
        when (lengthFifo.io.deq.bits.last) {
          outRspState := 1.U
        }
      }
    } .elsewhen (lengthFifo.io.deq.valid && (lengthFifo.io.deq.bits.length === 0.U) && lengthFifo.io.deq.bits.last) {
      lengthFifo.io.deq.ready := true.B
      outRspState := 1.U
    }
  } .elsewhen (outRspState === 1.U) {
    // Dump packet buf
    when (io.pkt_buf_data.empty === 64.U) {
      when (!r_valid_r) {
        io.r_valid := true.B
        io.r_tag := io.pkt_buf_data.tag
        io.pkt_buf_ready := true.B
        outRspState := 0.U
      }
    } .elsewhen (io.pkt_buf_valid) {
      io.out_tag := io.pkt_buf_data.tag
      io.out_data := io.pkt_buf_data.data
      io.out_last := io.pkt_buf_data.last
      io.out_empty := io.pkt_buf_data.empty
      io.out_valid := true.B
      when (io.out_ready) {
        when (io.pkt_buf_data.last) {
          when (!r_valid_r) {
            io.r_valid := true.B
            io.r_tag := io.pkt_buf_data.tag
            io.pkt_buf_ready := true.B
            outRspState := 0.U
          } .otherwise {
            outRspState := 2.U
          }
        } .otherwise {
          io.pkt_buf_ready := true.B
        }
      }
    }
  } .elsewhen (outRspState === 2.U) {
    when (!r_valid_r) {
      io.r_valid := true.B
      io.r_tag := io.pkt_buf_data.tag
      io.pkt_buf_ready := true.B
      outRspState := 0.U
    }
  }

}