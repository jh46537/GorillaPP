#!/usr/bin/env python3

import sys

NUM_ALU = 2
NUM_INSTS = 6

def gen_alu_inst(ops, alu_pos):
	program = ""
	if ops[0] == "NOP":
		program += "NOP;NOP;NOP;NOP;"
	elif ops[0] == 'LUi':
		program += ("NOP;NOP;LUi,R0,{3};SCATTER,{0},X{4},{1},{2};".format(ops[1], ops[2], ops[3], ops[4], (alu_pos*4+2)))
	elif ops[0][-1] == 'i':
		program += ("GATHER,R0,{0},{1},{2};NOP;".format(ops[4], ops[5], ops[6]))
		program += ("{0},R0,X{2},{1};".format(ops[0], ops[7], (alu_pos*4)))
		program += ("SCATTER,{0},X{3},{1},{2};".format(ops[1], ops[2], ops[3], (alu_pos*4+2)))
	else:
		print("alu not supported\n")

	return program


def translate_idx(idx):
	new_idx = 0
	if idx < NUM_ALU:
		new_idx = idx*4+2
	elif idx < 2*NUM_ALU:
		new_idx = (idx - NUM_ALU)*4+2
	else:
		new_idx = NUM_ALU*4+idx-2*NUM_ALU

	return new_idx


def main():

	filename_src = sys.argv[1]
	filename_dst = sys.argv[2]

	f_src = open(filename_src, "r")
	f_dst = open(filename_dst, "w")

	lines = f_src.readlines()

	line_num = 1
	for line in lines:
		# print(line_num)
		if line[0] == '#':
			f_dst.write(line)
		else:
			insts = line.split(";")
			ops = []
			for i in range(NUM_INSTS):
				ops.append(insts[i].split(","))

			# ALU 0
			if ops[2][0] == "NOP":
				program = gen_alu_inst(ops[0], 0)
				f_dst.write(program)
			else:
				program = ""
				program += ("GATHER,R0,{0},{1},{2};NOP;".format(ops[0][4], ops[0][5], ops[0][6]))
				program += ("{0},R0,X0,{1};".format(ops[2][0], ops[2][3]))
				program += ("SCATTER,{0},X2,0,6;".format(ops[2][1]))
				f_dst.write(program)

			# ALU 1
			if ops[4][0] != "OUTPUT_META":
				program = gen_alu_inst(ops[1], 1)
				f_dst.write(program)
			else:
				f_dst.write("NOP;NOP;NOP;NOP;")

			# INPUT/OUTPUT
			if ops[4][0] == "NOP":
				f_dst.write("NOP;")
			elif ops[4][0] == "EXTRACTi" or ops[4][0] == "EMIT" or ops[4][0] == "EXTRACTi_DONE" or ops[4][0] == "EMIT_DONE":
				f_dst.write("{0},{1},{2},{3};".format(ops[4][0], ops[4][1], ops[4][2], ops[4][3]))
			elif ops[4][0] == "PARSE_DONE" or ops[4][0] == "DEPARSE_DONE":
				f_dst.write("{0};".format(ops[4][0]))
			elif ops[4][0] == "OUTPUT_META":
				f_dst.write("OUTPUT_META,{0},{1},{2};".format(ops[4][1],ops[1][4],ops[1][7]))
			else:
				print("io not supported\n")

			# BRANCH
			if ops[5][0] == "NOP" or ops[5][0] == "END":
				f_dst.write("{0};".format(ops[5][0]))
			elif ops[5][0][0] == 'B':
				idx0 = translate_idx(int(ops[5][1][1:]))
				idx1 = translate_idx(int(ops[5][2][1:]))
				f_dst.write("{0},X{1},X{2},{3};".format(ops[5][0], idx0, idx1, ops[5][3]))
			elif ops[5][0] == "JR":
				idx = translate_idx(int(ops[5][1][1:]))
				f_dst.write("JR,X{0},{1};".format(idx, ops[5][2]))
			elif ops[5][0] == "J":
				f_dst.write("J,{0};".format(ops[5][1]))
			else:
				print("branch not supported\n")

			f_dst.write("#\n")
		line_num += 1
		
	f_src.close()
	f_dst.close()			


if __name__ == "__main__":
	main()