#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <map>
#include <vector>
#include <sstream>
#include <stdio.h>
#include <cmath>

#define OP_W 3
#define NUM_FUS 5
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define NUM_SRC 2
#define NUM_DEST 2
#define NUM_REGS_LG 3
#define IP_W 8
#define IMM_W 8
#define INST_W NUM_FUS+(NUM_SRC+NUM_DEST)*NUM_REGS_LG+NUM_DEST*(1+NUM_FUS_LG)+IP_W+OP_W+IMM_W
#define NUM_INT (INST_W+31)/32

using namespace std;

class instruction
{
	const map<string, int> preOp_dict {
		{"ETHERNET"    , 0},
		{"IPV4"        , 1},
		{"LOOKUP"      , 2},
		{"LOOKUP_POST" , 3},
		{"UPDATE"      , 4},
		{"UPDATE_POST" , 5},
		{"EXCEPTION"   , 6},
		{"INPUT"       , 7},
		{"OUTPUT"      , 8}
	};

	int preOp;
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
	brTarget = 0;
	imm = 0;
	
	//parse asm
	stringstream s_stream(asm_line);
	int i = 0;
	int j = 0;
	int k = 0;
	int m = 0;
	int n = 0;
	while(s_stream.good()) {
		string operand;
		getline(s_stream, operand, ',');
		if (i == 0) {
			//pre-op
			if (preOp_dict.find(operand) != preOp_dict.end()) {
				preOp = preOp_dict.at(operand);
			} else {
				cout << "Undefined preOp\n";
			}
		} else if (i <= NUM_FUS) {
			//FUs
			if (operand != " ") {
				fuValids[i-1] = 1;
				if (operand == "WEN") {
					if (j < NUM_DEST) {
						destLane[j] = i-1;
						j++;
					} else {
						cout << "Error: Out of RegFile write BW\n";
						return;
					}
				}
			}
		} else if (i <= NUM_FUS+NUM_SRC) {
			//src
			if (operand != " ") {
				srcId[k] = stoi(operand.substr(1));
				k++;
			}
		} else if (i <= NUM_FUS+NUM_SRC+NUM_DEST) {
			//dstA
			if (operand != " ") {
				destId[m] = stoi(operand.substr(1));
				destEn[m] = 1;
				m++;
			}
		} else if (i == NUM_FUS+NUM_SRC+NUM_DEST+1) {
			//brTarget
			if (operand != " ") {
				brTarget = stoi(operand);
			}
		} else if (i == NUM_FUS+NUM_SRC+NUM_DEST+2) {
			//immediate
			if (operand != " ") {
				imm = stoi(operand);
			}
		}
		i++;
	}
}

void instruction::assemble(ofstream &bin_file) {
	unsigned inst[NUM_INT] = {0};
	unsigned brTarget_u = unsigned(brTarget) & ((1 << IP_W) - 1);
	int i = 0;
	int j = 0;
	// brTarget
	inst[j] += brTarget_u;
	int shift_w = IP_W;
	// fuValids
	for (i = 0; i < NUM_FUS; i++) {
		unsigned tmp = unsigned(fuValids[i]) & 1;
		inst[j] += (tmp << shift_w);
		if (shift_w == 32) {
			shift_w = 0;
			j++;
		} else {
			shift_w++;
		}
	}
	// preOps
	unsigned preOp_u = unsigned(preOp) & ((1 << OP_W) - 1);
	inst[j] += (preOp_u << shift_w);
	if (shift_w+OP_W > 32) {
		inst[j+1] += (preOp_u >> (32-shift_w));
		shift_w = shift_w+OP_W-32;
		j++;
	} else if (shift_w+OP_W == 32) {
		shift_w = 0;
		j++;		
	} else {
		shift_w += OP_W;
	}
	// destLane
	for (i = 0; i < NUM_DEST; i++) {
		unsigned destLane_u = unsigned(destLane[i]) & ((1 << NUM_FUS_LG) - 1);
		inst[j] += (destLane_u << shift_w);
		if (shift_w+NUM_FUS_LG > 32) {
			inst[j+1] += (destLane_u >> (32-shift_w));
			shift_w = shift_w+NUM_FUS_LG-32;
			j++;
		} else if (shift_w+NUM_FUS_LG == 32) {
			shift_w = 0;
			j++;
		} else {
			shift_w += NUM_FUS_LG;
		}
	}
	// destId
	for (i = 0; i < NUM_DEST; i++) {
		unsigned destId_u = unsigned(destId[i]) & ((1 << NUM_REGS_LG) - 1);
		inst[j] += (destId_u << shift_w);
		if (shift_w+NUM_REGS_LG > 32) {
			inst[j+1] += (destId_u >> (32-shift_w));
			shift_w = shift_w+NUM_REGS_LG-32;
			j++;
		} else if (shift_w+NUM_REGS_LG == 32) {
			shift_w = 0;
			j++;
		} else {
			shift_w += NUM_REGS_LG;
		}
	}
	// destEn
	for (i = 0; i < NUM_DEST; i++) {
		unsigned tmp = unsigned(destEn[i]) & 1;
		inst[j] += (tmp << shift_w);
		if (shift_w == 32) {
			shift_w = 0;
			j++;
		} else {
			shift_w++;
		}
	}
	// srcId
	for (i = 0; i < NUM_SRC; i++) {
		unsigned srcId_u = unsigned(srcId[i]) & ((1 << NUM_REGS_LG) - 1);
		inst[j] += (srcId_u << shift_w);
		// cout << "shift_w is" << shift_w << ", srcId is " << srcId_u << endl;
		if (shift_w+NUM_REGS_LG > 32) {
			inst[j+1] += (srcId_u >> (32-shift_w));
			shift_w = shift_w+NUM_REGS_LG-32;
			j++;
		} else if (shift_w+NUM_REGS_LG == 32) {
			shift_w = 0;
			j++;
		} else {
			shift_w += NUM_REGS_LG;
		}
	}
	// immediate
	unsigned imm_u = unsigned(imm) & ((1 << IMM_W) - 1);
	inst[j] += (imm_u << shift_w);
	// cout << "shift_w is" << shift_w << ", imm is " << imm_u << endl;
	if (shift_w+IMM_W > 32) {
		inst[j+1] += (imm_u >> (32-shift_w));
		shift_w = shift_w+IMM_W-32;
		j++;
	} else if (shift_w+IMM_W == 32) {
		shift_w = 0;
		j++;
	} else {
		shift_w += IMM_W;
	}

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