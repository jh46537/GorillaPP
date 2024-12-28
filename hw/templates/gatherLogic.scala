
  // /****************** Gather Stage 0-2 *************************/
  // val gatherThread = readThread_vec(ALU_DELAY)  // gatherThread as input
  // val aluMicrocodes_out = aluMicrocodes_vec(0)  // aluMicrocodes_out is the input because there is no write to it, aluMicrocodes_vec(0) not in the module (exluded) (the bitwidth can be tell by val bfuMicrocodes_vec = Reg(Vec(REG_DELAY, new BFUMicrocodes(NUM_FUS-NUM_ALUS, ALU_SRC_WIDTH))))
  // val bfuMicrocodes_out = bfuMicrocodes_vec(0)  // aluMicrocodes_out is the input, 
  // val bfuValids_out = bfuValids_vec(0)          // bfuValids_out is the input, bfuValids_vec(0) is input  (val bfuValids_vec = RegInit(VecInit(Seq.fill(REG_DELAY)(VecInit(Seq.fill(NUM_BFUS)(false.B))))))

  // ///// exclude start
  // val gather_srcA = Seq.fill(NUM_ALUS)(Module(new Gather(REG_WIDTH, NUM_SRC_POS, src_pos, MAX_FIELD_WIDTH, NUM_SRC_MODES, src_mode)))
  // val gather_srcB = Seq.fill(NUM_ALUS)(Module(new Gather(REG_WIDTH, NUM_SRC_POS, src_pos, MAX_FIELD_WIDTH, NUM_SRC_MODES, src_mode)))  
  // for (i <- 0 until NUM_ALUS) {
  //   gather_srcA(i).io.din   := srcA(i)    // srcA(i) is the input (val srcA = Wire(Vec(NUM_FUS, UInt(REG_WIDTH.W))))
  //   gather_srcA(i).io.shift := aluMicrocodes_out.rs1_pos(i)
  //   gather_srcA(i).io.mode  := aluMicrocodes_out.rs1_mode(i)
  //   gather_srcB(i).io.din   := srcB(i)
  //   gather_srcB(i).io.shift := aluMicrocodes_out.rs2_pos(i)
  //   gather_srcB(i).io.mode  := aluMicrocodes_out.rs2_mode(i)
  // }
  // ///// exclude end

  // // BFU FIFOs
  // val execBundle_io = new Bundle {
  //   val tag = UInt(NUM_THREADS_LG.W)
  //   val opcode = UInt(NUM_FUOPS_LG.W)
  //   val rd = UInt(NUM_REGS_LG.W)
  //   val imm = UInt(12.W)
  //   val bits = UInt(REG_WIDTH.W)
  // }

  // // exclude start
  // val fuFifos_iou = Module(new Queue(execBundle_io, NUM_THREADS))
  // // exclude end
  // fuFifos_iou.io.enq.valid := false.B
  // fuFifos_iou.io.enq.bits := DontCare
  

  // if (NUM_BFUS > NUM_ALUS) {
  //   when (gatherThread =/= NONE_SELECTED) {
  //     when (bfuValids_out(NUM_BFUS-1) === true.B) {
  //       fuFifos_iou.io.enq.valid := true.B  // make an output boundle name as fuFifos_enq.valid
  //       fuFifos_iou.io.enq.bits.tag := gatherThread  // output fuFifos_enq.bit_tag
  //       fuFifos_iou.io.enq.bits.opcode := bfuMicrocodes_out.opcode(NUM_BFUS-1-NUM_ALUS) // output
  //       fuFifos_iou.io.enq.bits.rd := bfuMicrocodes_out.rd(NUM_BFUS-1-NUM_ALUS) // output
  //       fuFifos_iou.io.enq.bits.imm := bfuMicrocodes_out.bimm(NUM_BFUS-1-NUM_ALUS) // output
  //       fuFifos_iou.io.enq.bits.bits := srcA(NUM_BFUS-1) // output
  //     }
  //   }
  // } else {
  //   when (gatherThread =/= NONE_SELECTED) {
  //     when (aluMicrocodes_out.bfu_valid(NUM_BFUS-1) === true.B) {
  //       fuFifos_iou.io.enq.valid := true.B
  //       fuFifos_iou.io.enq.bits.tag := gatherThread
  //       fuFifos_iou.io.enq.bits.opcode := aluMicrocodes_out.opcode(NUM_BFUS-1)
  //       fuFifos_iou.io.enq.bits.rd := aluMicrocodes_out.rd(NUM_BFUS-1)
  //       fuFifos_iou.io.enq.bits.imm := aluMicrocodes_out.imm(NUM_BFUS-1).asUInt
  //       fuFifos_iou.io.enq.bits.bits := srcA(NUM_BFUS-1)
  //     }
  //   }
  // }

import chisel3._
import chisel3.util._
import chisel3.util.Fill


class gatherLogic(
    NUM_THREADS: Int,
    NUM_BFUS: Int,
    NUM_ALUS: Int,
    NUM_FUS: Int,
    REG_WIDTH: Int,
    NUM_THREADS_LG: Int,
    NUM_REGS_LG: Int,
    NUM_FUOPS_LG: Int,
    ALU_SRC_WIDTH: Int,
    NUM_SRC_POS_LG: Int, 
    NUM_SRC_MODES_LG: Int, 
    NONE_SELECTED: UInt  // !type check please!
   
) extends Module {
  val io = IO(new Bundle {
    // Inputs
    val gatherThread = Input(UInt(log2Up(NUM_THREADS + 1).W)) // Input gather thread
    val aluMicrocodes_out = Input(new ALUMicrocodes(NUM_ALUS, ALU_SRC_WIDTH, NUM_SRC_POS_LG, NUM_SRC_MODES_LG)) 
    val bfuMicrocodes_out = Input(new BFUMicrocodes(NUM_FUS-NUM_ALUS, ALU_SRC_WIDTH))
    val bfuValids_out = Input(Vec(NUM_BFUS, Bool())) // Validity vector for BFU
    val srcA = Input(Vec(NUM_FUS, UInt(REG_WIDTH.W)))
    // Outputs
    val fuFifos_enq_valid = Output(Bool()) // FIFO enqueue valid signal
    val fuFifos_enq_bits_tag = Output(UInt(log2Up(NUM_THREADS + 1).W)) // Enqueue tag
    val fuFifos_enq_bits_opcode = Output(UInt(NUM_FUOPS_LG.W)) // Enqueue opcode              
    val fuFifos_enq_bits_rd = Output(UInt(NUM_REGS_LG.W)) // Enqueue destination register    
    val fuFifos_enq_bits_imm = Output(UInt(12.W)) // Enqueue immediate value              
    val fuFifos_enq_bits_bits = Output(UInt(REG_WIDTH.W)) // Enqueue bits
  })

  // Default values for outputs
  io.fuFifos_enq_valid := false.B
  io.fuFifos_enq_bits_tag := DontCare
  io.fuFifos_enq_bits_opcode := DontCare
  io.fuFifos_enq_bits_rd := DontCare
  io.fuFifos_enq_bits_imm := DontCare
  io.fuFifos_enq_bits_bits := DontCare

  if (NUM_BFUS > NUM_ALUS) {
    when (io.gatherThread =/= NONE_SELECTED) {
      when (io.bfuValids_out(NUM_BFUS - 1) === true.B) {
        io.fuFifos_enq_valid := true.B  
        io.fuFifos_enq_bits_tag := io.gatherThread  
        io.fuFifos_enq_bits_opcode := io.bfuMicrocodes_out.opcode(NUM_BFUS - 1 - NUM_ALUS)
        io.fuFifos_enq_bits_rd := io.bfuMicrocodes_out.rd(NUM_BFUS - 1 - NUM_ALUS)
        io.fuFifos_enq_bits_imm := io.bfuMicrocodes_out.bimm(NUM_BFUS - 1 - NUM_ALUS)
        io.fuFifos_enq_bits_bits := io.srcA(NUM_BFUS - 1)
      }
    }
  } else {
    when (io.gatherThread =/= NONE_SELECTED) {
      when (io.aluMicrocodes_out.bfu_valid(NUM_BFUS - 1) === true.B) {
        io.fuFifos_enq_valid := true.B
        io.fuFifos_enq_bits_tag := io.gatherThread
        io.fuFifos_enq_bits_opcode := io.aluMicrocodes_out.opcode(NUM_BFUS - 1)
        io.fuFifos_enq_bits_rd := io.aluMicrocodes_out.rd(NUM_BFUS - 1)
        io.fuFifos_enq_bits_imm := io.aluMicrocodes_out.imm(NUM_BFUS - 1).asUInt
        io.fuFifos_enq_bits_bits := io.srcA(NUM_BFUS - 1)
      }
    }
  }
    
}