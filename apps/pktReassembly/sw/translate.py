#!/usr/bin/env python3

import sys

NUM_ALU = 3
NUM_INSTS = 5

BFU_2REG = ["UPDATE", "DELETE", "LOOKUP", "RELEASE", "MALLOC"]
BFU_3REG = ["UPDATE0"]

def gen_alu_inst(ops, alu_pos):
	program = ""
	if ops[0] == "NOP":
		program += "NOP;NOP;NOP;NOP;"
	elif ops[0] == 'LUi':
		program += ("NOP;NOP;LUi,R0,{3};SCATTER,{0},X{4},{1},{2};".format(ops[1], ops[2], ops[3], ops[4], (alu_pos*4+2)))
	elif ops[0][-1] == 'i' or (ops[0] in BFU_2REG):
		program += ("GATHER,R0,{0},{1},{2};NOP;".format(ops[4], ops[5], ops[6]))
		program += ("{0},R0,X{2},{1};".format(ops[0], ops[7], (alu_pos*4)))
		program += ("SCATTER,{0},X{3},{1},{2};".format(ops[1], ops[2], ops[3], (alu_pos*4+2)))
	else:
		# print(ops[0] + " alu not supported\n")
		program += ("GATHER,R0,{0},{1},{2};".format(ops[4], ops[5], ops[6]))
		program += ("GATHER,R0,{0},{1},{2};".format(ops[7], ops[8], ops[9]))
		program += ("{0},R0,X{1},X{2};".format(ops[0], (alu_pos*4), (alu_pos*4+1)))
		program += ("SCATTER,{0},X{3},{1},{2};".format(ops[1], ops[2], ops[3], (alu_pos*4+2)))

	return program


def translate_idx(idx):
	new_idx = 0
	if idx < NUM_ALU:
		new_idx = idx*4+2
	else:
		new_idx = NUM_ALU*4+idx-NUM_ALU

	return new_idx


def main():

	filename_src = sys.argv[1]
	filename_dst = sys.argv[2]

	f_src = open(filename_src, "r")
	f_dst = open(filename_dst, "w")

	lines = f_src.readlines()

	line_num = 1
	for line in lines:
		print(line_num)
		if line[0] == '#':
			f_dst.write(line)
		else:
			insts = line.split(";")
			ops = []
			for i in range(NUM_INSTS):
				ops.append(insts[i].split(","))

			# ALU 0
			for i in range(NUM_ALU):
				program = gen_alu_inst(ops[i], i)
				f_dst.write(program)

			# INPUT/OUTPUT
			if ops[NUM_ALU][0] == "NOP":
				f_dst.write("NOP;")
			elif ops[NUM_ALU][0] == "EXTRACTi" or ops[NUM_ALU][0] == "EMIT" or ops[NUM_ALU][0] == "EXTRACTi_DONE" or ops[NUM_ALU][0] == "EMIT_DONE" or ops[NUM_ALU][0] == "UNLOCK":
				f_dst.write("{0},{1},{2},{3};".format(ops[NUM_ALU][0], ops[NUM_ALU][1], ops[NUM_ALU][2], ops[NUM_ALU][3]))
			elif ops[NUM_ALU][0] == "PARSE_DONE" or ops[NUM_ALU][0] == "DEPARSE_DONE":
				f_dst.write("{0};".format(ops[NUM_ALU][0]))
			elif ops[NUM_ALU][0] == "OUTPUT_META":
				f_dst.write("OUTPUT_META,{0},{1},{2};".format(ops[NUM_ALU][1],ops[1][NUM_ALU],ops[1][7]))
			else:
				print(ops[NUM_ALU][0] + " io not supported\n")

			# BRANCH
			if ops[NUM_ALU+1][0] == "NOP" or ops[NUM_ALU+1][0] == "END":
				f_dst.write("{0};".format(ops[NUM_ALU+1][0]))
			elif ops[NUM_ALU+1][0][0] == 'B':
				idx0 = translate_idx(int(ops[NUM_ALU+1][1][1:]))
				idx1 = translate_idx(int(ops[NUM_ALU+1][2][1:]))
				f_dst.write("{0},X{1},X{2},{3};".format(ops[NUM_ALU+1][0], idx0, idx1, ops[NUM_ALU+1][3]))
			elif ops[NUM_ALU+1][0] == "JR":
				idx = translate_idx(int(ops[NUM_ALU+1][1][1:]))
				f_dst.write("JR,X{0},{1};".format(idx, ops[NUM_ALU+1][2]))
			elif ops[NUM_ALU+1][0] == "J":
				f_dst.write("J,{0};".format(ops[NUM_ALU+1][1]))
			else:
				print(ops[NUM_ALU+1][0] + " branch not supported\n")

			f_dst.write("#\n")
		line_num += 1
		
	f_src.close()
	f_dst.close()			


if __name__ == "__main__":
	main()