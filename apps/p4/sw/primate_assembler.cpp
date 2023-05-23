#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <cmath>

#define NUM_ALUS 2
#define NUM_REGS_LG 5
#define NUM_SRC_POS 9
#define NUM_SRC_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_SRC_MODE 7
#define NUM_SRC_MODE_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_DST_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_DST_MODES_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_FUS 3
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define IP_W 32
#define ALU_SRC_W (NUM_REGS_LG + NUM_SRC_POS_LG + NUM_SRC_MODE_LG)
#define ALU_IMM_W (ALU_SRC_W > 12 ? ALU_SRC_W : 12)
// #define ALU_INST_W (7 + NUM_REGS_LG + NUM_DST_POS_LG + NUM_DST_MODES_LG + (3 + ALU_SRC_W + ALU_IMM_W))
#define ALU_INST_W 64
#define INST_W (32*(NUM_FUS + 1) + NUM_ALUS*ALU_INST_W)
#define NUM_INST (NUM_ALUS+NUM_FUS+1)
#define NUM_INT ((INST_W+31)/32)

using namespace std;

struct aluOp_t {
    unsigned long long opcode;
    unsigned long long rd, rd_pos, rd_mode;
    unsigned long long funct;
    unsigned long long rs1, rs1_pos, rs1_mode;
    unsigned long long rs2, rs2_pos, rs2_mode;

    unsigned long long imm;
    aluOp_t() : opcode(0), rd(0), rd_pos(0), rd_mode(0), funct(0), rs1(0), rs1_pos(0), rs1_mode(0),
     rs2(0), rs2_pos(0), rs2_mode(0), imm(0) {};
    unsigned long long assemble() {
        int RS1_START_POS = 10+NUM_REGS_LG+NUM_DST_POS_LG+NUM_DST_MODES_LG;
        int RS2_START_POS = RS1_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG+NUM_SRC_MODE_LG;
        int IMM_START_POS = RS2_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG+NUM_SRC_MODE_LG;
        unsigned long long res = opcode + (rd << 7) + (rd_pos << (7+NUM_REGS_LG)) + (rd_mode << (7+NUM_REGS_LG+NUM_DST_POS_LG))
         + (funct << (7+NUM_REGS_LG+NUM_DST_POS_LG+NUM_DST_MODES_LG)) + (rs1 << RS1_START_POS) + (rs1_pos << (RS1_START_POS+NUM_REGS_LG))
         + (rs1_mode << (RS1_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG)) + (rs2 << RS2_START_POS) + (rs2_pos << (RS2_START_POS+NUM_REGS_LG))
         + (rs2_mode << (RS2_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG)) + (imm << IMM_START_POS);
        return res;
    }
};

struct bfuOp_t {
    unsigned opcode;
    unsigned rd;
    unsigned funct;
    unsigned rs1;
    unsigned rs2;
    unsigned imm;
    bfuOp_t() : opcode(0), rd(0), funct(0), rs1(0), rs2(0), imm(0) {};
    unsigned assemble() {
        unsigned res = opcode + (rd << 7) + (funct << 12) + (rs1 << 15) + (rs2 << 20) + (imm << 25);
        return res;
    }
};

class instruction
{
    bool isComment;
    aluOp_t subInstALU[NUM_ALUS];
    bfuOp_t subInstBFU[NUM_FUS+1];

public:
    aluOp_t subInstructionALU(string asm_line);
    bfuOp_t subInstructionBFU(string asm_line);
    instruction(string asm_line);
    void assemble(ofstream &bin_file);
    ~instruction() {};
    
};

bfuOp_t instruction::subInstructionBFU(string asm_line) {
    bfuOp_t inst;
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
    } else if (opcode == "DEPARSE_DONE") {
        inst.opcode = 0x6b;
        inst.rd = 0;
        inst.funct = 2;
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
        } else {
            // 2 or more operands
            string op2;
            getline(alu_stream, op2, ',');
            int op1u = stoi(op1.substr(1));
            if (opcode == "JAL") {
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
                if (opcode == "BEQ" || opcode == "BNE" || opcode == "BLT" ||
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
                    cout << "invalid opcode" << endl;
                    exit(1);
                }
            }
        }
    }
    return inst;
}

aluOp_t instruction::subInstructionALU(string asm_line) {
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
    } else {
        // 1 or more operands
        string op1, op2, op3;
        getline(alu_stream, op1, ',');
        getline(alu_stream, op2, ',');
        getline(alu_stream, op3, ',');
        int op1u = stoi(op1.substr(1));
        int op2u = stoi(op2);
        int op3u = stoi(op3);
        // 2 or more operands
        string op4;
        getline(alu_stream, op4, ',');
        if (opcode == "LUi") {
            int op4u = stoi(op4);
            inst.opcode = 0x37;
            inst.rd = op1u;
            inst.rd_pos = op2u;
            inst.rd_mode = op3u;
            inst.funct = (op4u >> 12) & 7;
            int RS1_START_POS = 15;
            inst.rs1 = (op4u >> RS1_START_POS) & ((1 << NUM_REGS_LG) - 1);
            inst.rs1_pos = (op4u >> (RS1_START_POS+NUM_REGS_LG)) & ((1 << NUM_SRC_POS_LG) - 1);
            inst.rs1_mode = (op4u >> (RS1_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG)) & ((1 << NUM_SRC_MODE_LG) - 1);
            int RS2_START_POS = RS1_START_POS + NUM_REGS_LG + NUM_SRC_POS_LG + NUM_SRC_MODE_LG;
            inst.rs2 = (op4u >> RS2_START_POS) & ((1 << NUM_REGS_LG) - 1);
            inst.rs2_pos = (op4u >> (RS2_START_POS+NUM_REGS_LG)) & ((1 << NUM_SRC_POS_LG) - 1);
            inst.rs2_mode = (op4u >> (RS2_START_POS+NUM_REGS_LG+NUM_SRC_POS_LG)) & ((1 << NUM_SRC_MODE_LG) - 1);
            int IMM_START_POS = RS2_START_POS + NUM_REGS_LG + NUM_SRC_POS_LG + NUM_SRC_MODE_LG;
            if (IMM_START_POS <= 32) {
                inst.imm = op4u >> IMM_START_POS;
            }
        } else {
            // 6 or more operands
            string op5, op6;
            getline(alu_stream, op5, ',');
            getline(alu_stream, op6, ',');
            int op4u = stoi(op4.substr(1));
            int op5u = stoi(op5);
            int op6u = stoi(op6);
            if (opcode == "NOT") {
                inst.opcode = 0x13;
                inst.rd = op1u;
                inst.rd_pos = op2u;
                inst.rd_mode = op3u;
                inst.funct = 4;
                inst.rs1 = op4u;
                inst.rs1_pos = op5u;
                inst.rs1_mode = op6u;
                inst.rs2 = (1 << NUM_REGS_LG) - 1;
                inst.rs2_pos = (1 << NUM_SRC_POS_LG) - 1;
                inst.rs2_mode = (1 << NUM_SRC_MODE_LG) - 1;
                inst.imm = (1 << ALU_IMM_W) - 1;
            } else if (opcode == "SNEZ") {
                inst.opcode = 0x33;
                inst.rd = op1u;
                inst.rd_pos = op2u;
                inst.rd_mode = op3u;
                inst.funct = 3;
                inst.rs1 = 0;
                inst.rs1_pos = 0;
                inst.rs1_mode = 0;
                inst.rs2 = op4u;
                inst.rs2_pos = op5u;
                inst.rs2_mode = op6u;
                inst.imm = 0;
            } else {
                // 7 or more operands
                string op7;
                getline(alu_stream, op7, ',');
                if (opcode == "ADDi" || opcode == "SLTi" || opcode == "SLTiu" || opcode == "ANDi" ||
                    opcode == "ORi" || opcode == "XORi") {
                    int op7u = stoi(op7);
                    inst.opcode = 0x13;
                    inst.rd = op1u;
                    inst.rd_pos = op2u;
                    inst.rd_mode = op3u;
                    inst.rs1 = op4u;
                    inst.rs1_pos = op5u;
                    inst.rs1_mode = op6u;
                    inst.rs2 = op7u & ((1 << NUM_REGS_LG) - 1);
                    inst.rs2_pos = (op7u >> NUM_REGS_LG) & ((1 << NUM_SRC_POS_LG) - 1);
                    inst.rs2_mode = (op7u >> (NUM_REGS_LG + NUM_SRC_POS_LG)) & ((1 << NUM_SRC_MODE_LG) - 1);
                    int IMM_START_POS = NUM_REGS_LG + NUM_DST_POS_LG + NUM_DST_MODES_LG;
                    inst.imm = op7u >> IMM_START_POS;
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
                } else {
                    // 9 or more operands
                    string op8, op9;
                    getline(alu_stream, op8, ',');
                    getline(alu_stream, op9, ',');
                    if (opcode == "SLLi" || opcode == "SRLi" || opcode == "SRAi") {
                        int op7u = stoi(op7);
                        inst.opcode = 0x13;
                        inst.rd = op1u;
                        inst.rd_pos = op2u;
                        inst.rd_mode = op3u;
                        inst.rs1 = op4u;
                        inst.rs1_pos = op5u;
                        inst.rs1_mode = op6u;
                        inst.rs2 = op7u & ((1 << NUM_REGS_LG) - 1);
                        inst.rs2_pos = (op7u >> NUM_REGS_LG) & ((1 << NUM_SRC_POS_LG) - 1);
                        inst.rs2_mode = (op7u >> (NUM_REGS_LG + NUM_SRC_POS_LG)) & ((1 << NUM_SRC_MODE_LG) - 1);
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
                        int op7u = stoi(op7.substr(1));
                        int op8u = stoi(op8);
                        int op9u = stoi(op9);
                        inst.opcode = 0x33;
                        inst.rd = op1u;
                        inst.rd_pos = op2u;
                        inst.rd_mode = op3u;
                        inst.rs1 = op4u;
                        inst.rs1_pos = op5u;
                        inst.rs1_mode = op6u;
                        inst.rs2 = op7u;
                        inst.rs2_pos = op8u;
                        inst.rs2_mode = op9u;
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
                        int op7u = stoi(op7.substr(1));
                        int op8u = stoi(op8);
                        int op9u = stoi(op9);
                        inst.opcode = 0x33;
                        inst.rd = op1u;
                        inst.rd_pos = op2u;
                        inst.rd_mode = op3u;
                        inst.rs1 = op4u;
                        inst.rs1_pos = op5u;
                        inst.rs1_mode = op6u;
                        inst.rs2 = op7u;
                        inst.rs2_pos = op8u;
                        inst.rs2_mode = op9u;
                        inst.funct = 0;
                        inst.imm = 0x20;
                    } else if (opcode == "SRA") {
                        int op7u = stoi(op7.substr(1));
                        int op8u = stoi(op8);
                        int op9u = stoi(op9);
                        inst.opcode = 0x33;
                        inst.rd = op1u;
                        inst.rd_pos = op2u;
                        inst.rd_mode = op3u;
                        inst.rs1 = op4u;
                        inst.rs1_pos = op5u;
                        inst.rs1_mode = op6u;
                        inst.rs2 = op7u;
                        inst.rs2_pos = op8u;
                        inst.rs2_mode = op9u;
                        inst.funct = 5;
                        inst.imm = 0x20;
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
            cout << "\n";
            return;
        }
        cout << inst << "; ";
        if (i < NUM_ALUS) {
            subInstALU[i] = subInstructionALU(inst);
        } else if (i < NUM_INST) {
            subInstBFU[i - NUM_ALUS] = subInstructionBFU(inst);
        } else {
            cout << "Found more than expected sub-instructions" << endl;
            exit(1);
        }
        i++;
    }
    cout << "\n";
}

void instruction::assemble(ofstream &bin_file) {
    unsigned inst[NUM_INT];
    int i = 0;
    int j = 0;
    if (isComment) return;

    for (i = 0; i < NUM_ALUS; i++) {
        unsigned long long res = subInstALU[i].assemble();
        inst[2*i] = res & 0xffffffff;
        inst[2*i+1] = (res >> 32);
    }
    for (i = 2*NUM_ALUS; i < NUM_INT; i++, j++) {
        inst[i] = subInstBFU[j].assemble();
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

