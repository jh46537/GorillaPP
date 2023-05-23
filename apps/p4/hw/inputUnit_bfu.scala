import chisel3._
import chisel3.util._

class inputUnit(reg_width: Int, num_regs_lg: Int, opcode_width: Int, num_threads: Int, ip_width: Int) extends MultiIOModule {
  val io = IO(new Bundle {
    val in_valid     = Input(Bool())
    val in_tag       = Input(UInt(log2Up(num_threads).W))
    val in_data      = Input(UInt(512.W))
    val in_last      = Input(Bool())
    val in_ready     = Output(Bool())

    val out_ready    = Input(Bool())
    val out_valid    = Output(Bool())
    val out_flag     = Output(UInt(ip_width.W))
    val out_tag      = Output(UInt(log2Up(num_threads).W))
    val out_wen      = Output(Vec(2, Bool()))
    val out_addr     = Output(Vec(2, UInt(num_regs_lg.W)))
    val out_data     = Output(Vec(2, UInt(reg_width.W)))

    val idle_threads = Input(Vec(num_threads, Bool()))
    val new_thread   = Output(Bool())
    val new_tag      = Output(UInt(log2Up(num_threads).W))

    val ar_valid     = Input(Bool())
    val ar_tag       = Input(UInt(log2Up(num_threads).W))
    val ar_opcode    = Input(UInt(opcode_width.W))
    val ar_rd        = Input(UInt(num_regs_lg.W))
    val ar_bits      = Input(UInt(32.W))
    val ar_imm       = Input(UInt(32.W))
    val ar_ready     = Output(Bool())
  })
  // opcode(0) = 0: not write back, 1: write back
  // opcode(1) = 0: not shift, 1: shift
  // opcode(2) = 0: parse not done, 1: parse done
  // opcode(3) = 0: select imm, 1: select reg

  class outFifo_t extends Bundle {
    val out_valid = Bool()
    val out_tag   = UInt(log2Up(num_threads).W)
    val out_wen   = Bool()
    val out_addr  = UInt(num_regs_lg.W)
    val out_data  = UInt(reg_width.W)
    val out_flag  = UInt(2.W)
  }

  val state = RegInit(0.U(4.W))
  val ar_valid_core  = Wire(Bool())
  val ar_tag_core    = Wire(UInt(log2Up(num_threads).W))
  val ar_opcode_core = Wire(UInt(opcode_width.W))
  val ar_rd_core     = Wire(UInt(num_regs_lg.W))
  val ar_bits_core   = Wire(UInt(32.W))
  val ar_imm_core    = Wire(UInt(32.W))
  val ar_ready_core  = Wire(Bool())
  val tag = Reg(UInt(log2Up(num_threads).W))
  val inputCore = Module(new inputUnit_core(reg_width, num_regs_lg, opcode_width, num_threads))
  val outFifo_in = Reg(new outFifo_t)
  val outFifo_enq = RegInit(false.B)
  val matched = RegInit(false.B)
  val outFifo = Module(new Queue(new outFifo_t, 4))

  inputCore.io.in_valid := io.in_valid
  inputCore.io.in_tag := io.in_tag
  inputCore.io.in_data := io.in_data
  inputCore.io.in_last := io.in_last
  io.in_ready := inputCore.io.in_ready
  inputCore.io.idle_threads := io.idle_threads
  io.new_thread := inputCore.io.new_thread
  io.new_tag := inputCore.io.new_tag
  inputCore.io.ar_valid := ar_valid_core
  inputCore.io.ar_tag := ar_tag_core
  inputCore.io.ar_opcode := ar_opcode_core
  inputCore.io.ar_rd := ar_rd_core
  inputCore.io.ar_bits := ar_bits_core
  inputCore.io.ar_imm := ar_imm_core
  ar_ready_core := inputCore.io.ar_ready

  io.ar_ready := false.B
  ar_valid_core := false.B
  ar_tag_core := DontCare
  ar_opcode_core := DontCare
  ar_rd_core := DontCare
  ar_bits_core := io.ar_bits
  ar_imm_core := DontCare
  io.out_valid := false.B
  io.out_wen := false.B
  io.out_flag := DontCare

  outFifo.io.enq.bits := outFifo_in
  outFifo.io.enq.valid := outFifo_enq
  outFifo.io.deq.ready := false.B
  io.out_valid := false.B
  io.out_tag := outFifo.io.deq.bits.out_tag
  io.out_wen := false.B
  io.out_addr := outFifo.io.deq.bits.out_addr
  io.out_data := outFifo.io.deq.bits.out_data
  io.out_flag := outFifo.io.deq.bits.out_flag
  when (outFifo.io.deq.valid && io.out_ready) {
    outFifo.io.deq.ready := true.B
    io.out_valid := outFifo.io.deq.bits.out_valid
    io.out_wen := outFifo.io.deq.bits.out_wen
  }

  inputCore.io.out_ready := false.B
  when (state === 0.U) {
    io.ar_ready := ar_ready_core
    when (io.ar_valid) {
      when (io.ar_opcode(4) === 1.U) {
        // Fused parsing operation
        // Parse Eth
        ar_valid_core := true.B
        ar_tag_core := io.ar_tag
        ar_opcode_core := 3.U
        ar_rd_core := 1.U
        ar_imm_core := 14.U
        tag := io.ar_tag
        when (ar_ready_core) {
          state := 1.U
        }
      } .otherwise {
        ar_valid_core := io.ar_valid
        ar_tag_core := io.ar_tag
        ar_opcode_core := io.ar_opcode
        ar_rd_core := io.ar_rd
        ar_imm_core := io.ar_imm
      }
    }
    when (outFifo.io.enq.ready) {
      inputCore.io.out_ready := true.B
      when (inputCore.io.out_valid) {
        outFifo_in.out_wen := inputCore.io.out_wen
        outFifo_in.out_valid := inputCore.io.out_valid
        outFifo_in.out_tag := inputCore.io.out_tag
        outFifo_in.out_addr := inputCore.io.out_addr
        outFifo_in.out_data := inputCore.io.out_data
        outFifo_in.out_flag := inputCore.io.out_flag
        outFifo_enq := true.B
      } .otherwise {
        outFifo_enq := false.B
      }
    }
  } .elsewhen (state === 1.U) {
    // Get Eth
    inputCore.io.out_ready := true.B
    when (inputCore.io.out_valid) {
      outFifo_in.out_wen := true.B
      outFifo_in.out_tag := inputCore.io.out_tag
      outFifo_in.out_addr := inputCore.io.out_addr
      outFifo_in.out_data := inputCore.io.out_data
      when (inputCore.io.out_data(111, 96) === 0x88f7.U) {
        outFifo_in.out_valid := false.B
      } .otherwise {
        outFifo_in.out_valid := true.B
        outFifo_in.flag := 1.U
      }
      outFifo_enq := true.B
      state := 2.U
    }
  } .elsewhen (state === 2.U) {
    when (outFifo.io.enq.ready) {
      outFifo_enq := false.B
      when (!outFifo_in.out_valid) {
        // Parse Ptp_l
        ar_valid_core := true.B
        ar_tag_core := tag
        ar_opcode_core := 3.U
        ar_rd_core := 2.U
        ar_imm_core := 20.U
        when (ar_ready_core) {
          state := 3.U
        }
      } .otherwise {
        // Stop, accept
        state := 0.U
      }
    }
  } .elsewhen (state === 3.U) {
    // Get Ptp_l
    inputCore.io.out_ready := true.B
    when (inputCore.io.out_valid) {
      outFifo_in.out_wen := true.B
      outFifo_in.out_tag := inputCore.io.out_tag
      outFifo_in.out_addr := inputCore.io.out_addr
      outFifo_in.out_data := inputCore.io.out_data
      outFifo_in.out_valid := false.B
      when (inputCore.io.out_data(47, 40) === 1.U) {
        matched := true.B
      } .otherwise {
        matched := false.B
      }
      outFifo_enq := true.B
      state := 4.U
    }
  } .elsewhen (state === 4.U) {
    when (outFifo.io.enq.ready) {
      // Parse Ptp_h
      outFifo_enq := false.B
      ar_valid_core := true.B
      ar_tag_core := tag
      ar_opcode_core := 3.U
      ar_rd_core := 3.U
      ar_imm_core := 24.U
      when (ar_ready_core) {
        state := 5.U
      }
    }
  } .elsewhen (state === 5.U) {
    // Get Ptp_h
    inputCore.io.out_ready := true.B
    when (inputCore.io.out_valid) {
      outFifo_in.out_wen := true.B
      outFifo_in.out_tag := inputCore.io.out_tag
      outFifo_in.out_addr := inputCore.io.out_addr
      outFifo_in.out_data := inputCore.io.out_data
      when (matched) {
        outFifo_in.out_valid := false.B
      } .otherwise {
        outFifo_in.out_valid := true.B
        outFifo_in.out_flag := 1.U
      }
      outFifo_enq := true.B
      state := 6.U
    }
  } .elsewhen (state === 6.U) {
    when (outFifo.io.enq.ready) {
      outFifo_enq := false.B
      when (!outFifo_in.out_valid) {
        // Parse Header_0
        ar_valid_core := true.B
        ar_tag_core := tag
        ar_opcode_core := 3.U
        ar_rd_core := 4.U
        ar_imm_core := 8.U
        when (ar_ready_core) {
          state := 7.U
        }
      } .otherwise {
        // Stop, accept
        state := 0.U
      }
    }
  } .elsewhen (state === 7.U) {
    // Get Header_0
    inputCore.io.out_ready := true.B
    when (inputCore.io.out_valid) {
      outFifo_in.out_wen := true.B
      outFifo_in.out_tag := inputCore.io.out_tag
      outFifo_in.out_addr := inputCore.io.out_addr
      outFifo_in.out_data := inputCore.io.out_data
      outFifo_in.out_valid := false.B
      when (inputCore.io.out_data(16, 0) =/= 0.U) {
        outFifo_in.out_valid := false.B
      } .otherwise {
        outFifo_in.out_valid := true.B
        outFifo_in.out_flag := 1.U
      }
      outFifo_enq := true.B
      state := 8.U
    }
  } .elsewhen (state === 8.U) {
    when (outFifo.io.enq.ready) {
      outFifo_enq := false.B
      when (!outFifo_in.out_valid) {
        // Parse Header_1
        ar_valid_core := true.B
        ar_tag_core := tag
        ar_opcode_core := 3.U
        ar_rd_core := 5.U
        ar_imm_core := 8.U
        when (ar_ready_core) {
          state := 9.U
        }
      } .otherwise {
        // Stop, accept
        state := 0.U
      }
    }
  } .elsewhen (state === 9.U) {
    // Get Header_1
    inputCore.io.out_ready := true.B
    when (inputCore.io.out_valid) {
      outFifo_in.out_wen := true.B
      outFifo_in.out_tag := inputCore.io.out_tag
      outFifo_in.out_addr := inputCore.io.out_addr
      outFifo_in.out_data := inputCore.io.out_data
      outFifo_in.out_valid := true.B
      outFifo_in.out_flag := 0.U
      outFifo_enq := true.B
      state := 10.U
    }
  } .elsewhen (state === 10.U) {
    when (outFifo.io.enq.ready) {
      outFifo_enq := false.B
      state := 0.U
    }
  }

}