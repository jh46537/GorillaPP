#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <cmath>

#define NUM_ALUS 2
#define NUM_SRC_POS 9
#define NUM_SRC_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_SRC_MODE 7
#define NUM_SRC_MODE_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_FUS 3
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define IP_W 32
#define NUM_INT (NUM_ALUS*3+NUM_FUS+1)
#define INST_W (32*NUM_INT)

using namespace std;

struct aluOp_t {
    int opcode;
    int rd;
    int funct;
    int rs1;
    int rs2;
    unsigned imm;
    aluOp_t() : opcode(0), rd(0), funct(0), rs1(0), rs2(0), imm(0) {};
    int assemble() {
        int res = opcode + (rd << 7) + (funct << 12) + (rs1 << 15) + (rs2 << 20) + (imm << 25);
        return res;
    }
};

class instruction
{
    bool isComment;
    aluOp_t subInst[NUM_INT];

public:
    aluOp_t subInstruction(string asm_line);
    instruction(string asm_line);
    void assemble(ofstream &bin_file);
    ~instruction() {};
    
};

aluOp_t instruction::subInstruction(string asm_line) {
    aluOp_t inst;
    stringstream alu_stream(asm_line);
    string opcode;
    getline(alu_stream, opcode, ',');
    // No operand
    if (opcode == "NOP") {
        inst.opcode = 0x13;
        inst.rd = 0;
        inst.funct = 0;
        inst.rs1 = 0;
        inst.rs2 = 0;
        inst.imm = 0;
    } else if (opcode == "END") {
        inst.opcode = 0x6f;
        inst.rd = 0;
        inst.funct = 7;
        inst.rs1 = 0x1F;
        inst.rs2 = 0x1F;
        inst.imm = 0x7F;
    } else if (opcode == "PARSE_DONE") {
        inst.opcode = 0xb;
        inst.rd = 0;
        inst.funct = 4;
        inst.rs1 = 0;
        inst.rs2 = 0;
        inst.imm = 0;
    } else {
        // 1 or more operands
        string op1;
        getline(alu_stream, op1, ',');
        if (opcode == "J") {
            int op1u = stoi(op1);
            inst.opcode = 0x6f;
            inst.rd = 0;
            inst.funct = (op1u >> 12) & 7;
            inst.rs1 = (op1u >> 15) & 0x1f;
            inst.rs2 = (op1u & 0x1e) | ((op1u >> 11) & 1);
            inst.imm = ((op1u >> 5) & 0x3f) | ((op1u >> 20) << 6);
        } else if (opcode == "DEPARSE_DONE") {
            int op1u = stoi(op1.substr(1));
            inst.opcode = 0x6b;
            inst.rd = 0;
            inst.funct = 2;
            inst.rs1 = op1u;
            inst.rs2 = 0;
            inst.imm = 0;
        } else {
            // 2 or more operands
            string op2;
            getline(alu_stream, op2, ',');
            int op1u = stoi(op1.substr(1));
            if (opcode == "NOT") {
                int op2u = stoi(op2.substr(1));
                inst.opcode = 0x13;
                inst.rd = op1u;
                inst.funct = 4;
                inst.rs1 = op2u;
                inst.rs2 = 0x1f;
                inst.imm = 0x7f;
            } else if (opcode == "LUi") {
                int op2u = stoi(op2);
                inst.opcode = 0x37;
                inst.rd = op1u;
                inst.funct = (op2u >> 12) & 7;
                inst.rs1 = (op2u >> 15) & 0x1f;
                inst.rs2 = (op2u >> 20) & 0x1f;
                inst.imm = (op2u >> 25) & 0x7f;
            } else if (opcode == "SNEZ") {
                int op2u = stoi(op2.substr(1));
                inst.opcode = 0x33;
                inst.rd = op1u;
                inst.funct = 3;
                inst.rs1 = 0;
                inst.rs2 = op2u;
                inst.imm = 0;
            } else if (opcode == "JAL") {
                int op2u = stoi(op2);
                inst.opcode = 0x6f;
                inst.rd = op1u;
                inst.funct = (op2u >> 12) & 7;
                inst.rs1 = (op2u >> 15) & 0x1f;
                inst.rs2 = (op2u & 0x1e) | ((op2u >> 11) & 1);
                inst.imm = ((op2u >> 5) & 0x3f) | ((op2u >> 20) << 6);
            } else if (opcode == "JR") {
                int op2u = stoi(op2);
                inst.opcode = 0x67;
                inst.rd = 0;
                inst.funct = 0;
                inst.rs1 = op1u;
                inst.rs2 = op2u & 0x1f;
                inst.imm = (op2u >> 5) & 0x3f;
            } else {
                // 3 or more operands
                string op3;
                getline(alu_stream, op3, ',');
                int op2u = stoi(op2.substr(1));
                if (opcode == "ADDi" || opcode == "SLTi" || opcode == "SLTiu" || opcode == "ANDi" ||
                    opcode == "ORi" || opcode == "XORi") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x13;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    inst.imm = (op3u >> 5) & 0x7f;
                    if (opcode == "ADDi") {
                        inst.funct = 0;
                    } else if (opcode == "SLTi") {
                        inst.funct = 2;
                    } else if (opcode == "SLTiu") {
                        inst.funct = 3;
                    } else if (opcode == "ANDi") {
                        inst.funct = 7;
                    } else if (opcode == "ORi") {
                        inst.funct = 6;
                    } else if (opcode == "XORi") {
                        inst.funct = 4;
                    }
                } else if (opcode == "SLLi" || opcode == "SRLi" || opcode == "SRAi") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x13;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    if (opcode == "SLLi") {
                        inst.funct = 1;
                        inst.imm = 0;
                    } else if (opcode == "SRLi") {
                        inst.funct = 5;
                        inst.imm = 0;
                    } else if (opcode == "SRAi") {
                        inst.funct = 5;
                        inst.imm = 0x20;
                    }
                } else if (opcode == "ADD" || opcode == "SLT" || opcode == "SLTu" || opcode == "AND" ||
                    opcode == "OR" || opcode == "XOR" || opcode == "SLL" || opcode == "SRL") {
                    int op3u = stoi(op3.substr(1));
                    inst.opcode = 0x33;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u;
                    inst.imm = 0;
                    if (opcode == "ADD") {
                        inst.funct = 0;
                    } else if (opcode == "SLT") {
                        inst.funct = 2;
                    } else if (opcode == "SLTu") {
                        inst.funct = 3;
                    } else if (opcode == "AND") {
                        inst.funct = 7;
                    } else if (opcode == "OR") {
                        inst.funct = 6;
                    } else if (opcode == "XOR") {
                        inst.funct = 4;
                    } else if (opcode == "SLL") {
                        inst.funct = 1;
                    } else if (opcode == "SRL") {
                        inst.funct = 5;
                    }
                } else if (opcode == "SUB") {
                    int op3u = stoi(op3.substr(1));
                    inst.opcode = 0x33;
                    inst.funct = 0;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u;
                    inst.imm = 0x20;
                } else if (opcode == "SRA") {
                    int op3u = stoi(op3.substr(1));
                    inst.opcode = 0x33;
                    inst.funct = 5;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u;
                    inst.imm = 0x20;
                } else if (opcode == "LW") {
                    int op3u = stoi(op3);
                    inst.opcode = 3;
                    inst.rd = op1u;
                    inst.funct = 2;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    inst.imm = (op3u >> 5) & 0x7f;
                } else if (opcode == "SW") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x23;
                    inst.rd = op3u & 0x1f;
                    inst.funct = 2;
                    inst.rs1 = op2u;
                    inst.rs2 = op1u;
                    inst.imm = (op3u >> 5) & 0x7f;
                } else if (opcode == "BEQ" || opcode == "BNE" || opcode == "BLT" ||
                    opcode == "BLTu" || opcode == "BGE" || opcode == "BGEu") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x63;
                    inst.rd = ((op3u >> 11) & 1) | (op3u & 0x1e);
                    inst.rs1 = op1u;
                    inst.rs2 = op2u;
                    inst.imm = ((op3u >> 5) & 0x3f) | ((op3u & 0x1000) >> 6);
                    if (opcode == "BEQ") {
                        inst.funct = 0;
                    } else if (opcode == "BNE") {
                        inst.funct = 1;
                    } else if (opcode == "BLT") {
                        inst.funct = 4;
                    } else if (opcode == "BLTu") {
                        inst.funct = 6;
                    } else if (opcode == "BGE") {
                        inst.funct = 5;
                    } else if (opcode == "BGEu") {
                        inst.funct = 7;
                    }
                } else if (opcode == "MATCH" || opcode == "LOAD" || opcode == "RESET" || opcode == "PASS") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x5b;
                    inst.rd = op1u;
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    inst.imm = (op3u >> 5) & 0x7f;
                    if (opcode == "RESET") {
                        inst.funct = 0;
                    } else if (opcode == "LOAD") {
                        inst.funct = 1;
                    } else if (opcode == "MATCH") {
                        inst.funct = 2;
                    } else if (opcode == "PASS") {
                        inst.funct = 3;
                    }
                } else if (opcode == "EXTRACTi" || opcode == "EXTRACTi_DONE") {
                    int op3u = stoi(op3);
                    inst.opcode = 0xb;
                    inst.rd = op1u;
                    if (opcode == "EXTRACTi") {
                        inst.funct = 3;
                    } else if (opcode == "EXTRACTi_DONE") {
                        inst.funct = 7;
                    }
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    inst.imm = (op3u >> 5) & 0x3f;
                } else if (opcode == "EMIT" || opcode == "OUTPUT_META" || opcode == "EMIT_DONE") {
                    int op3u = stoi(op3);
                    inst.opcode = 0x6b;
                    inst.rd = op1u;
                    if (opcode == "EMIT") {
                        inst.funct = 1;
                    } else if (opcode == "EMIT_DONE") {
                        inst.funct = 3;
                    } else if (opcode == "OUTPUT_META") {
                        inst.funct = 0;
                    }
                    inst.rs1 = op2u;
                    inst.rs2 = op3u & 0x1f;
                    inst.imm = (op3u >> 5) & 0x3f;
                } else {
                    // 4 or more operands
                    int op3u = stoi(op3);
                    string op4;
                    getline(alu_stream, op4, ',');
                    int op4u = stoi(op4);
                    if (opcode == "GATHER" || opcode == "SCATTER") {
                        inst.opcode = 0x2b;
                        inst.rd = op1u;
                        inst.rs1 = op2u;
                        if (opcode == "GATHER") {
                            inst.funct = 0;
                        } else {
                            inst.funct = 1;
                        }
                        int imm_u = (op3u & ((1 << (NUM_SRC_POS_LG))-1)) + ((op4u & ((1 << (NUM_SRC_MODE_LG))-1)) << (NUM_SRC_POS_LG));
                        cout << imm_u << endl;
                        inst.rs2 = imm_u & 0x1f;
                        inst.imm = (imm_u >> 5) & 0x7f;
                    } else {
                        cout << "invalid opcode" << endl;
                        exit(1);
                    }
                }
            }
        }
    }
    return inst;
}

instruction::instruction(string asm_line) {
    isComment = false;
    
    //parse asm
    stringstream s_stream(asm_line);
    int i = 0;
    while(s_stream.good()) {
        string inst;
        getline(s_stream, inst, ';');
        if (inst[0] == '#') {
            if (i == 0) isComment = true;
            return;
        }

        if (i < NUM_INT) {
            subInst[i] = subInstruction(inst);
        } else {
            cout << "Found more than expected sub-instructions" << endl;
            exit(1);
        }
        i++;
    }
}

void instruction::assemble(ofstream &bin_file) {
    int inst[NUM_INT];
    int i = 0;
    int j = 0;
    if (isComment) return;

    for (i = 0; i < NUM_INT; i++) {
        inst[i] = subInst[i].assemble();
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

    // cout << "INST_W is " << INST_W << endl;

    string asm_line;
    while (getline(asm_file, asm_line)) {
        instruction inst(asm_line);
        inst.assemble(bin_file);
    }

    asm_file.close();
    bin_file.close();
    return 0;
}

