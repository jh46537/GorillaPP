#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <map>
#include <vector>
#include <sstream>
#include <stdio.h>
#include <cmath>

#define OP_W 4
#define NUM_ALUOPS_LG 3
#define NUM_ALUS 2
#define NUM_FUS 5
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define NUM_SRC 2
#define NUM_DEST 2
#define NUM_REGS_LG 4
#define IP_W 8
#define IMM_W 16
#define INST_W (NUM_ALUS*(NUM_ALUOPS_LG+NUM_SRC*9+9)+NUM_FUS+(NUM_SRC+NUM_DEST)*NUM_REGS_LG+NUM_DEST*(1+NUM_FUS_LG)+IP_W+OP_W+IMM_W)
#define NUM_INT ((INST_W+31)/32)

using namespace std;

class instruction
{
	const map<string, int> preOp_dict {
		{"FT"     , 0},
		{"BR"     , 1},
		{"ALUA"   , 2},
		{"ALUB"   , 3},
		{"AND"    , 4},
		{"OR"     , 5},
		{"INPUT"  , 6},
		{"OUTPUT" , 7}
	};

	const map<string, int> aluOp_dict {
		{"FTA"    , 0},
		{"FTB"    , 1},
		{"ADD"    , 2},
		{"SUB"    , 3},
		{"EQ"     , 4},
		{"NEQ"    , 5},
		{"LT"     , 6},
		{"LTE"    , 7},
		{"GT"     , 8},
		{"GTE"    , 9}
	};

	const map<string, int> srcType_dict {
		{"uint32" , 0},
		{"uint16" , 1},
		{"uint8"  , 2},
		{"uint4"  , 3},
		{"int32"  , 4},
		{"int16"  , 5},
		{"int8"   , 6},
		{"int4"   , 7},
		{"uimm8"  , 8},
		{"imm8"   , 9}
	};

	const map<string, int> dstType_dict {
		{"uint128" , 0},
		{"uint32"  , 1},
		{"uint16"  , 2},
		{"uint8"   , 3}
	};

	int preOp;
	int aluOp[NUM_ALUS];
	int srcShiftR[NUM_ALUS][NUM_SRC];
	int srcMode[NUM_ALUS][NUM_SRC];
	int dstShiftL[NUM_ALUS];
	int dstMode[NUM_ALUS];
	int fuValids[NUM_FUS];
	int srcId[NUM_SRC];
	int destEn[NUM_DEST];
	int destId[NUM_DEST];
	int destLane[NUM_DEST];
	int brTarget;
	int imm;

public:
	instruction(string asm_line);
	void assemble(ofstream &bin_file);
	~instruction() {};
	
};

instruction::instruction(string asm_line) {
	preOp = 0;
	for (int i = 0; i < NUM_FUS; i++) fuValids[i] = 0;
	for (int i = 0; i < NUM_SRC; i++) srcId[i] = 0;
	for (int i = 0; i < NUM_DEST; i++) {
		destEn[i] = 0;
		destId[i] = 0;
		destLane[i] = 0;
	}
	for (int i = 0; i < NUM_ALUS; i++) {
		for (int j = 0; j < NUM_SRC; j++) {
			srcShiftR[i][j] = 0;
			srcMode[i][j] = 0;
		}
		aluOp[i] = 0;
		dstShiftL[i] = 0;
		dstMode[i] = 0;
	}
	brTarget = 0;
	imm = 0;
	
	//parse asm
	stringstream s_stream(asm_line);
	int i = 0;
	int ii = 0;
	int j = 0;
	int k = 0;
	int l = 0;
	int m = 0;
	int n = 0;
	while(s_stream.good()) {
		string operand;
		getline(s_stream, operand, ';');
		if (i == 0) {
			//pre-op
			if (preOp_dict.find(operand) != preOp_dict.end()) {
				preOp = preOp_dict.at(operand);
			} else {
				cout << "Undefined preOp\n";
			}
		} else if (i <= NUM_ALUS) {
			//alu-isnt
			stringstream alu_stream(operand);
			string alu_operand;
			getline(alu_stream, alu_operand, ',');
			if (aluOp_dict.find(alu_operand) != aluOp_dict.end()) {
				aluOp[ii] = aluOp_dict.at(alu_operand);
			} else {
				cout << "Undefined aluOp\n";
			}
			for (int ij = 0; ij < NUM_SRC; ij++) {
				// src type
				getline(alu_stream, alu_operand, ',');
				if (srcType_dict.find(alu_operand) != srcType_dict.end()) {
					srcMode[ii][ij] = srcType_dict.at(alu_operand);
				} else {
					cout << "Undefined src type\n";
				}
				// src shiftR
				getline(alu_stream, alu_operand, ',');
				srcShiftR[ii][ij] = stoi(alu_operand);
			}
			// dst type
			getline(alu_stream, alu_operand, ',');
			if (dstType_dict.find(alu_operand) != dstType_dict.end()) {
				dstMode[ii] = dstType_dict.at(alu_operand);
			} else {
				cout << "Undefined dst type\n";
			}
			// dst shiftL
			getline(alu_stream, alu_operand, ',');
			dstShiftL[ii] = stoi(alu_operand);
			ii++;
		} else if (i <= NUM_ALUS+NUM_FUS) {
			//FUs
			if (operand != " ") {
				fuValids[l] = 1;
				if (operand == "WEN") {
					if (j < NUM_DEST) {
						destLane[j] = l;
						j++;
					} else {
						cout << "Error: Out of RegFile write BW\n";
						return;
					}
				}
			}
			l++;
		} else if (i <= NUM_ALUS+NUM_FUS+NUM_SRC) {
			//src
			if (operand != " ") {
				srcId[k] = stoi(operand.substr(1));
				k++;
			}
		} else if (i <= NUM_ALUS+NUM_FUS+NUM_SRC+NUM_DEST) {
			//dstA
			if (operand != " ") {
				destId[m] = stoi(operand.substr(1));
				destEn[m] = 1;
				m++;
			}
		} else if (i == NUM_ALUS+NUM_FUS+NUM_SRC+NUM_DEST+1) {
			//brTarget
			if (operand != " ") {
				brTarget = stoi(operand);
			}
		} else if (i == NUM_ALUS+NUM_FUS+NUM_SRC+NUM_DEST+2) {
			//immediate
			if (operand != " ") {
				imm = stoi(operand, nullptr, 0);
			}
		}
		i++;
	}
}

void insert(unsigned* inst, int &idx, int &shift_w, unsigned operand, int width) {
	inst[idx] += (operand << shift_w);
	if (shift_w+width > 32) {
		inst[idx+1] += (operand >> (32 - shift_w));
		shift_w = shift_w + width - 32;
		idx++;
	} else if (shift_w + width == 32) {
		shift_w = 0;
		idx++;
	} else {
		shift_w += width;
	}
}

void instruction::assemble(ofstream &bin_file) {
	unsigned inst[NUM_INT] = {0};
	int shift_w = 0;
	int i = 0;
	int j = 0;
	// preOps
	unsigned preOp_u = unsigned(preOp) & ((1 << OP_W) - 1);
	insert(inst, j, shift_w, preOp_u, OP_W);
	// aluInsts
	for (i = 0; i < NUM_ALUS; i++) {
		unsigned aluOp_u = unsigned(aluOp[i]) & ((1 << NUM_ALUOPS_LG) - 1);
		insert(inst, j, shift_w, aluOp_u, NUM_ALUOPS_LG);
		for (int k = 0; k < NUM_SRC; k++) {
			unsigned srcShiftR_u = unsigned(srcShiftR[i][k]) & ((1 << 5) - 1);
			insert(inst, j, shift_w, srcShiftR_u, 5);
		}
		for (int k = 0; k < NUM_SRC; k++) {
			unsigned srcMode_u = unsigned(srcMode[i][k]) & ((1 << 4) - 1);
			insert(inst, j, shift_w, srcMode_u, 4);
		}
		unsigned dstShiftL_u = unsigned(dstShiftL[i]) & ((1 << 5) - 1);
		insert(inst, j, shift_w, dstShiftL_u, 5);
		unsigned dstMode_u = unsigned(dstMode[i]) & ((1 << 4) - 1);
		insert(inst, j, shift_w, dstMode_u, 4);
	}
	// fuValids
	for (i = 0; i < NUM_FUS; i++) {
		unsigned tmp = unsigned(fuValids[i]) & 1;
		insert(inst, j, shift_w, tmp, 1);
	}
	// srcId
	for (i = 0; i < NUM_SRC; i++) {
		unsigned srcId_u = unsigned(srcId[i]) & ((1 << NUM_REGS_LG) - 1);
		insert(inst, j, shift_w, srcId_u, NUM_REGS_LG);
	}
	// destId
	for (i = 0; i < NUM_DEST; i++) {
		unsigned destId_u = unsigned(destId[i]) & ((1 << NUM_REGS_LG) - 1);
		insert(inst, j, shift_w, destId_u, NUM_REGS_LG);
	}
	// destEn
	for (i = 0; i < NUM_DEST; i++) {
		unsigned tmp = unsigned(destEn[i]) & 1;
		insert(inst, j, shift_w, tmp, 1);
	}
	// destLane
	for (i = 0; i < NUM_DEST; i++) {
		unsigned destLane_u = unsigned(destLane[i]) & ((1 << NUM_FUS_LG) - 1);
		insert(inst, j, shift_w, destLane_u, NUM_FUS_LG);
	}
	// brTarget
	unsigned brTarget_u = unsigned(brTarget) & ((1 << IP_W) - 1);
	insert(inst, j, shift_w, brTarget_u, IP_W);
	// immediate
	unsigned imm_u = unsigned(imm) & ((1 << IMM_W) - 1);
	insert(inst, j, shift_w, imm_u, IMM_W);

	// Output
	for (i = NUM_INT-1; i >= 0; i--) {
		bin_file << hex << setfill('0') << setw(8) << inst[i];
	}
	bin_file << endl;
}

int main(int argc, char const *argv[])
{
	ifstream asm_file;
	ofstream bin_file;
	if (argc > 2) {
		asm_file.open(argv[1], ios::in);
		bin_file.open(argv[2], ios::out);
	} else {
		cout << "./assemble <asm file> <bin file>" << endl;
		return 0;
	}

	// cout << "NUM_FUS_LG is " << NUM_FUS_LG << endl;

	string asm_line;
	while (getline(asm_file, asm_line)) {
		instruction inst(asm_line);
		inst.assemble(bin_file);
	}

	asm_file.close();
	bin_file.close();
	return 0;
}
