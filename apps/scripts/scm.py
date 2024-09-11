bfulist = open("bfu_list.txt", "r")
bfu_dict = {}

state = 0
for line in bfulist:
	if state == 0:
		# wait for bfu module name
		bfu_name = line.strip()
		bfu_dict[bfu_name] = []
		state = 1
	elif state == 1:
		# wait for {
		if (line[0] == '{'):
			state = 2
	elif state == 2:
		#ports
		if (line[0] == '}'):
			state = 0
		else:
			bfu_dict[bfu_name].append(line.strip())
bfu_dict["loadStoreUnit"] = ["io"]
bfulist.close()

primateCFG = open("primate.cfg", "r")
num_alu = 0
num_bfu = 0
for line in primateCFG:
	params = line.split("=")
	if params[0] == "NUM_ALUS":
		num_alu = int(params[1])
	elif params[0] == "NUM_BFUS":
		num_bfu = int(params[1])
primateCFG.close()

# print(bfu_dict)

with open("primate.template") as f_old, open("primate.scala", "w") as f_new:
	for line in f_old:
		if '#ALUBFU_INSTANTIATE#' in line:
			f_new.write("  val alu_bfuInst = Array(")
			for i in range(num_alu-1):
				f_new.write("Module(new alu_bfu{0}(NUM_THREADS_LG, REG_WIDTH, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH)),".format(i))
			f_new.write("Module(new alu_bfu{0}(NUM_THREADS_LG, REG_WIDTH, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH)))".format(num_alu-1))
		elif '#BFU_INSTANTIATE#' in line:
			if num_alu < num_bfu+1:
				bfu_id = 0
				for bfu_name in bfu_dict:
					if bfu_id >= num_alu:
						f_new.write("  val " + bfu_name + "Port = Module(new " + bfu_name + "(NUM_THREADS_LG, REG_WIDTH, NUM_FUOPS_LG, NUM_THREADS, IP_WIDTH))\n")
					bfu_id += len(bfu_dict[bfu_name])
		elif '#FIFO_INSTANTIATE#' in line:
			if num_alu < num_bfu+1:
				bfu_id = 0
				for bfu_name in bfu_dict:
					for port_name in bfu_dict[bfu_name]:
						if bfu_id >= num_alu:
							f_new.write("  val execBundle_" + str(bfu_id) + " = new Bundle {\n")
							f_new.write("    val tag = UInt(NUM_THREADS_LG.W)\n")
							f_new.write("    val opcode = UInt(NUM_FUOPS_LG.W)\n")
							f_new.write("    val imm = UInt(12.W)\n")
							f_new.write("    val bits = Vec(2, UInt(REG_WIDTH.W))\n")
							f_new.write("  }\n")
							f_new.write("  val fuFifos_" + str(bfu_id) + " = Module(new Queue(execBundle_" + str(bfu_id) + ", NUM_THREADS-1))\n")
							f_new.write("  fuFifos_" + str(bfu_id) + ".io.enq.valid := false.B\n")
							f_new.write("  fuFifos_" + str(bfu_id) + ".io.enq.bits := DontCare\n")
						bfu_id += 1
		elif '#FIFO_INPUT#' in line:
			if num_alu < num_bfu+1:
				i = 0
				for bfu_name in bfu_dict:
					for port_name in bfu_dict[bfu_name]:
						if i >= num_alu:
							f_new.write("    when ((gatherThread =/= NONE_SELECTED) && bfuValids_out(" + str(i) + ")) {\n")
							f_new.write("      fuFifos_" + str(i) + ".io.enq.valid := true.B\n")
							f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.tag := gatherThread\n")
							f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.opcode := bfuMicrocodes_out.opcode(" + str(i-num_alu) + ")\n")
							f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.imm := bfuMicrocodes_out.bimm(" + str(i-num_alu) + ")\n")
							f_new.write("    }\n")
						i += 1
		elif '#BFU_INPUT#' in line:
			if num_alu < num_bfu+1:
				i = 0
				for bfu_name in bfu_dict:
					for port_name in bfu_dict[bfu_name]:
						if i >= num_alu:
							f_new.write("  when (fuFifos_" + str(i) + ".io.deq.valid && " + bfu_name + "Port." + port_name + ".in_ready) {\n")
							f_new.write("    val deq = fuFifos_" + str(i) + ".io.deq\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_valid := true.B\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_tag := deq.bits.tag\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_opcode := deq.bits.opcode\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_imm := deq.bits.imm\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_bits := deq.bits.bits\n")
							f_new.write("    fuFifos_" + str(i) + ".io.deq.ready := true.B\n")
							f_new.write("  } .otherwise {\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_valid := false.B\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_tag := DontCare\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_opcode := DontCare\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_imm := DontCare\n")
							f_new.write("    " + bfu_name + "Port." + port_name + ".in_bits := DontCare\n")
							f_new.write("    fuFifos_" + str(i) + ".io.deq.ready := false.B\n")
							f_new.write("  }\n")
						i += 1
		elif '#BFU_OUTPUT#' in line:
			if num_alu < num_bfu+1:
				i = 0
				for bfu_name in bfu_dict:
					for port_name in bfu_dict[bfu_name]:
						if i >= num_alu:
							f_new.write("  " + bfu_name + "Port." + port_name + ".out_ready := true.B\n")
							f_new.write("  when (" + bfu_name + "Port." + port_name + ".out_valid) {\n")
							f_new.write("    val destMem_in = Wire(new DestMemT)\n")
							f_new.write("    destMem_in.dstPC := " + bfu_name + "Port." + port_name + ".out_flag\n")
							f_new.write("    destMem_in.dest := " + bfu_name + "Port." + port_name + ".out_bits\n")
							f_new.write("    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)\n")
							f_new.write("    destMems(" + str(i) + ").io.wren := true.B\n")
							f_new.write("    destMems(" + str(i) + ").io.wraddress := " + bfu_name + "Port." + port_name + ".out_tag\n")
							f_new.write("    destMems(" + str(i) + ").io.data := destMem_in.asUInt\n")
							f_new.write("    threadStates(" + bfu_name + "Port." + port_name + ".out_tag).execValids(" + str(i) + ") := true.B\n")
							f_new.write("  }\n")
						i += 1

		else:
			f_new.write(line)