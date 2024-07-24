import chisel3._
import chisel3.util._


class alu_bfu2(tag_width0: Int, reg_width0: Int, opcode_width0: Int, num_threads0: Int, ip_width0: Int) extends {
   val ip_width: Int = ip_width0
   val num_threads: Int = num_threads0
   val opcode_width: Int = opcode_width0
   val reg_width: Int = reg_width0
   val tag_width: Int = tag_width0
  } with Module with HasALUBFUInterface {

  val aluInst = Module(new ALU(reg_width))
  val alu_valid_d0 = RegInit(false.B)
  val tag_r = RegNext(io.in_tag)
  
  // in_alu_bfu: 0: select alu; 1: select bfu
  alu_valid_d0      := io.in_valid && (!io.in_alu_bfu)
  aluInst.io.rs1    := io.in_rs1   
  aluInst.io.rs2    := io.in_rs2   
  aluInst.io.addEn  := io.in_addEn 
  aluInst.io.subEn  := io.in_subEn 
  aluInst.io.sltEn  := io.in_sltEn 
  aluInst.io.sltuEn := io.in_sltuEn
  aluInst.io.andEn  := io.in_andEn 
  aluInst.io.orEn   := io.in_orEn  
  aluInst.io.xorEn  := io.in_xorEn 
  aluInst.io.sllEn  := io.in_sllEn 
  aluInst.io.srEn   := io.in_srEn  
  aluInst.io.srMode := io.in_srMode
  aluInst.io.luiEn  := io.in_luiEn 
  aluInst.io.catEn  := io.in_catEn 
  aluInst.io.immSel := io.in_immSel
  aluInst.io.imm    := io.in_imm   

  io.mem.mem_addr   := DontCare
  io.mem.read       := false.B
  io.mem.write      := false.B
  io.mem.writedata  := DontCare
  io.mem.byteenable := 0.U

  io.in_ready := true.B

  io.out_valid := alu_valid_d0
  io.out_tag := tag_r
  io.out_flag := aluInst.io.dout
  io.out_bits := aluInst.io.dout

}
