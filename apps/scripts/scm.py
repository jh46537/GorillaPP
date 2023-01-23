bfulist = open("bfu_list.txt", "r")
bfu_dict = {}
ic_dict = {}

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

bfulist.close()

cfgfile = open("interconnect.cfg", "r")
for line in cfgfile:
	tmp = line.split()
	bfu_name = tmp[0].strip(':')
	ic_dict[bfu_name] = []
	for i in range(1, len(tmp)):
		ic_dict[bfu_name].append(int(tmp[i]))
cfgfile.close()

# print(bfu_dict)

with open("primate.template") as f_old, open("primate.scala", "w") as f_new:
	for line in f_old:
		if '#BFU_INSTANTIATE#' in line:
			for bfu_name in bfu_dict:
				f_new.write("  val " + bfu_name + "Port = Module(new " + bfu_name + "(NUM_THREADS_LG, REG_WIDTH, NUM_FUOPS_LG, NUM_THREADS))\n")
		elif '#FIFO_INSTANTIATE#' in line:
			i = 0
			for bfu_name in bfu_dict:
				for port_name in bfu_dict[bfu_name]:
					ic_list = ic_dict.get(bfu_name + '_' + port_name)
					if ic_list == None:
						print("Warning! BFU not found!")
					else:
						f_new.write("  val execBundle_" + str(i) + " = new Bundle {\n")
						f_new.write("    val tag = UInt(NUM_THREADS_LG.W)\n")
						f_new.write("    val opcode = UInt(NUM_FUOPS_LG.W)\n")
						f_new.write("    val bits = UInt((" + str(sum(ic_list)) + "*REG_WIDTH).W)\n")
						f_new.write("  }\n")
						f_new.write("  val fuFifos_" + str(i) + " = Module(new Queue(execBundle_" + str(i) + ", NUM_THREADS-1))\n")
						f_new.write("  fuFifos_" + str(i) + ".io.enq.valid := false.B\n")
						f_new.write("  fuFifos_" + str(i) + ".io.enq.bits := DontCare\n")
						i += 1
		elif '#BFU_INTERCONNECT#' in line:
			i = 0
			for bfu_name in bfu_dict:
				for port_name in bfu_dict[bfu_name]:
					ic_list = ic_dict.get(bfu_name + '_' + port_name)
					if ic_list == None:
						print("Warning! BFU not found!")
					else:
						f_new.write("    when (fuValids_vec(0)(" + str(i) + ") === true.B) {\n")
						f_new.write("      fuFifos_" + str(i) + ".io.enq.valid := true.B\n")
						f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.tag := preOpThread\n")
						f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.opcode := fuOps_vec(0)(" + str(i) + ")\n")
						f_new.write("      fuFifos_" + str(i) + ".io.enq.bits.bits := Cat(")
						isFirst = True
						for j in reversed(range(len(ic_list))):
							if (ic_list[j] == 1):
								if isFirst:
									isFirst = False
								else:
									f_new.write(", ")
								f_new.write("preOpRes(" + str(j) + ")")
						f_new.write(")\n")
						f_new.write("    }\n")
						i += 1
		elif '#BFU_INPUT#' in line:
			i = 0
			for bfu_name in bfu_dict:
				for port_name in bfu_dict[bfu_name]:
					f_new.write("  when (fuFifos_" + str(i) + ".io.deq.valid && " + bfu_name + "Port." + port_name + ".in_ready) {\n")
					f_new.write("    val deq = fuFifos_" + str(i) + ".io.deq\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_valid := true.B\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_tag := deq.bits.tag\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_opcode := deq.bits.opcode\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_bits := deq.bits.bits\n")
					f_new.write("    fuFifos_" + str(i) + ".io.deq.ready := true.B\n")
					f_new.write("  } .otherwise {\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_valid := false.B\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_tag := DontCare\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_opcode := DontCare\n")
					f_new.write("    " + bfu_name + "Port." + port_name + ".in_bits := DontCare\n")
					f_new.write("    fuFifos_" + str(i) + ".io.deq.ready := false.B\n")
					f_new.write("  }\n")
					i += 1
		elif '#BFU_OUTPUT#' in line:
			i = 0
			for bfu_name in bfu_dict:
				for port_name in bfu_dict[bfu_name]:
					f_new.write("  " + bfu_name + "Port." + port_name + ".out_ready := true.B\n")
					f_new.write("  when (" + bfu_name + "Port." + port_name + ".out_valid) {\n")
					f_new.write("    val destMem_in = Wire(new DestMemT)\n")
					f_new.write("    destMem_in.slctFU := " + bfu_name + "Port." + port_name + ".out_flag\n")
					f_new.write("    destMem_in.dest := " + bfu_name + "Port." + port_name + ".out_bits\n")
					f_new.write("    destMem_in.wben := Fill(NUM_REGBLOCKS, 1.U)\n")
					f_new.write("    destMems(" + str(i) + ").io.wren := true.B\n")
					f_new.write("    destMems(" + str(i) + ").io.wraddress := " + bfu_name + "Port." + port_name + ".out_tag\n")
					f_new.write("    destMems(" + str(i) + ").io.data := destMem_in.asUInt\n")
					f_new.write("    threadStates(" + bfu_name + "Port." + port_name + ".out_tag).execValids(" + str(i) + ") := true.B\n")
					f_new.write("  }\n")

		else:
			f_new.write(line)