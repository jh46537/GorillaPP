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
#define NUM_ALUOPS_LG 4
#define NUM_ALUS 2
#define NUM_SRC_POS 26
#define NUM_SRC_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_SRC_MODE 14
#define NUM_SRC_MODE_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_FUOPS_LG 2
#define NUM_FUS 4
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define NUM_DEST 2
#define NUM_REGS_LG 4
#define NUM_BT 3
#define IP_W 8
#define IMM_W 8
#define INST_W (NUM_ALUS*(NUM_ALUOPS_LG+3*(NUM_SRC_POS_LG+NUM_SRC_MODE_LG)+2*NUM_REGS_LG)+NUM_FUS*(1+NUM_FUOPS_LG)+NUM_DEST*NUM_REGS_LG+NUM_DEST*(1+NUM_FUS_LG)+IP_W*NUM_BT+OP_W+IMM_W*NUM_ALUS)
#define NUM_INT ((INST_W+31)/32)

using namespace std;

struct fuOp_t {
    int opcode;
    int wren;
};

class instruction
{
    const map<string, int> preOp_dict {
        {"FT"        , 0},
        {"BR"        , 1},
        {"ALUA"      , 2},
        {"ALUB"      , 3},
        {"AND"       , 4},
        {"OR"        , 5},
        {"GT"        , 6},
        {"GE"        , 7},
        {"EQ"        , 8},
        {"NEQ"       , 9},
        {"INPUT"     , 10},
        {"OUTPUT"    , 11},
        {"OUTPUTRET" , 12},
        {"RET"       , 13},
        {"INPUTSEEK" , 14}
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
        {"GTE"    , 9},
        {"AND"    ,10},
        {"OR"     ,11},
        {"CAT"    ,12}
    };

    const map<string, int> srcType_dict {
        {"uint1"  , 0},
        {"uint2"  , 1},
        {"uint3"  , 2},
        {"uint5"  , 3},
        {"uint6"  , 4},
        {"uint8"  , 5},
        {"uint9"  , 6},
        {"uint10" , 7},
        {"uint12" , 8},
        {"uint16" , 9},
        {"uint32" , 10},
        {"uint56" , 11},
        {"uint96" , 12},
        {"uint"   , 13},
        {"uimm8"  , 14},
        {"uimm16" , 15}
    };

    const map<string, int> dstType_dict {
        {"uint1"  , 0},
        {"uint2"  , 1},
        {"uint3"  , 2},
        {"uint5"  , 3},
        {"uint6"  , 4},
        {"uint8"  , 5},
        {"uint9"  , 6},
        {"uint10" , 7},
        {"uint12" , 8},
        {"uint16" , 9},
        {"uint32" , 10},
        {"uint56" , 11},
        {"uint96" , 12},
        {"uint"   , 13}
    };

    const map<string, fuOp_t> fuOp_dict {
        {"FTLOOKUP", {0, 1}},
        {"UNLOCK"  , {1, 0}},
        {"INSERT"  , {1, 0}},
        {"UPDATE"  , {2, 0}},
        {"DELETE"  , {3, 0}},
        {"MALLOC"  , {0, 1}},
        {"LOOKUP"  , {1, 1}},
        {"UPDATE0" , {2, 0}},
        // {"UPDATE1" , {3, 0}},
        {"RELEASE" , {3, 0}},
        {"EN"      , {0, 0}},
        {"WEN"     , {1, 1}}
    };

    bool comment;
    int preOp;
    int aluOp[NUM_ALUS];
    int srcId[NUM_ALUS][2];
    int srcShiftR[NUM_ALUS][2];
    int srcMode[NUM_ALUS][2];
    int dstShiftL[NUM_ALUS];
    int dstMode[NUM_ALUS];
    int fuOp[NUM_FUS];
    int fuValids[NUM_FUS];
    int destEn[NUM_DEST];
    int destId[NUM_DEST];
    int destLane[NUM_DEST];
    int brTarget[NUM_BT];
    int imm[NUM_ALUS];

public:
    instruction(string asm_line);
    void assemble(ofstream &bin_file);
    ~instruction() {};
    
};

instruction::instruction(string asm_line) {
    comment = false;
    preOp = 0;
    for (int i = 0; i < NUM_FUS; i++) {
        fuValids[i] = 0;
        fuOp[i] = 0;
    }
    for (int i = 0; i < NUM_DEST; i++) {
        destEn[i] = 0;
        destId[i] = 0;
        destLane[i] = 0;
    }
    for (int i = 0; i < NUM_ALUS; i++) {
        for (int j = 0; j < 2; j++) {
            srcId[i][j] = 0;
            srcShiftR[i][j] = 0;
            srcMode[i][j] = 0;
        }
        aluOp[i] = 0;
        dstShiftL[i] = 0;
        dstMode[i] = 0;
        imm[i] = 0;
    }
    for (int i = 0; i < NUM_BT; i++) {
        brTarget[i] = 0;
    }
    
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
        if (operand[0] == '#') {
            if (i == 0) comment = true;
            return;
        }
        if (i == 0) {
            //pre-op
            if (preOp_dict.find(operand) != preOp_dict.end()) {
                preOp = preOp_dict.at(operand);
            } else {
                cout << preOp << ", Undefined preOp\n";
            }
        } else if (i <= NUM_ALUS) {
            //alu-isnt
            stringstream alu_stream(operand);
            string alu_operand;
            getline(alu_stream, alu_operand, ',');
            if (aluOp_dict.find(alu_operand) != aluOp_dict.end()) {
                aluOp[ii] = aluOp_dict.at(alu_operand);
            } else {
                cout << alu_operand << ", Undefined aluOp\n";
            }
            for (int ij = 0; ij < 2; ij++) {
                // src select
                getline(alu_stream, alu_operand, ',');
                srcId[ii][ij] = stoi(alu_operand.substr(1));
                // src type
                getline(alu_stream, alu_operand, ',');
                if (srcType_dict.find(alu_operand) != srcType_dict.end()) {
                    srcMode[ii][ij] = srcType_dict.at(alu_operand);
                } else {
                    cout << alu_operand << ", Undefined src type\n";
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
                cout << alu_operand << ", Undefined dst type\n";
            }
            // dst shiftL
            getline(alu_stream, alu_operand, ',');
            dstShiftL[ii] = stoi(alu_operand);
            ii++;
        } else if (i <= NUM_ALUS+NUM_FUS) {
            //FUs
            if (operand != " ") {
                fuValids[l] = 1;
                if (fuOp_dict.find(operand) != fuOp_dict.end()) {
                    fuOp[l] = fuOp_dict.at(operand).opcode;
                    if (fuOp_dict.at(operand).wren) {
                        if (j < NUM_DEST) {
                            destLane[j] = l;
                            j++;
                        } else {
                            cout << "Error: Out of RegFile write BW\n";
                            return;
                        }
                    }
                } else {
                    cout << operand << ", Undefined FUOp\n";
                }
            }
            l++;
        } else if (i <= NUM_ALUS+NUM_FUS+NUM_DEST) {
            //dstA
            if (operand != " ") {
                destId[m] = stoi(operand.substr(1));
                destEn[m] = 1;
                m++;
            }
        } else if (i <= NUM_ALUS+NUM_FUS+NUM_DEST+NUM_BT) {
            //brTarget
            if (operand != " ") {
                brTarget[n] = stoi(operand);
                n++;
            }
        } else if (i <= NUM_ALUS+NUM_FUS+NUM_DEST+NUM_BT+NUM_ALUS) {
            //immediate
            if (operand != " ") {
                imm[k] = stoi(operand, nullptr, 0);
                k++;
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
    const int size = NUM_INT;
    unsigned inst[size] = {0};
    int shift_w = 0;
    int i = 0;
    int j = 0;
    if (comment) return;
    // preOps
    unsigned preOp_u = unsigned(preOp) & ((1 << OP_W) - 1);
    insert(inst, j, shift_w, preOp_u, OP_W);
    // aluInsts
    for (i = 0; i < NUM_ALUS; i++) {
        unsigned aluOp_u = unsigned(aluOp[i]) & ((1 << NUM_ALUOPS_LG) - 1);
        insert(inst, j, shift_w, aluOp_u, NUM_ALUOPS_LG);
        for (int k = 0; k < 2; k++) {
            unsigned srcId_u = unsigned(srcId[i][k]) & ((1 << NUM_REGS_LG) - 1);
            insert(inst, j, shift_w, srcId_u, NUM_REGS_LG);
        }
        for (int k = 0; k < 2; k++) {
            unsigned srcShiftR_u = unsigned(srcShiftR[i][k]) & ((1 << NUM_SRC_POS_LG) - 1);
            insert(inst, j, shift_w, srcShiftR_u, NUM_SRC_POS_LG);
        }
        for (int k = 0; k < 2; k++) {
            unsigned srcMode_u = unsigned(srcMode[i][k]) & ((1 << NUM_SRC_MODE_LG) - 1);
            insert(inst, j, shift_w, srcMode_u, NUM_SRC_MODE_LG);
        }
        unsigned dstShiftL_u = unsigned(dstShiftL[i]) & ((1 << NUM_SRC_POS_LG) - 1);
        insert(inst, j, shift_w, dstShiftL_u, NUM_SRC_POS_LG);
        unsigned dstMode_u = unsigned(dstMode[i]) & ((1 << NUM_SRC_MODE_LG) - 1);
        insert(inst, j, shift_w, dstMode_u, NUM_SRC_MODE_LG);
    }
    // fuValids
    for (i = 0; i < NUM_FUS; i++) {
        unsigned tmp = unsigned(fuValids[i]) & 1;
        insert(inst, j, shift_w, tmp, 1);
    }
    // fuOps
    for (i = 0; i < NUM_FUS; i++) {
        unsigned tmp = unsigned(fuOp[i]) & ((1 << NUM_FUOPS_LG) - 1);
        insert(inst, j, shift_w, tmp, NUM_FUOPS_LG);
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
    for (i = 0; i < NUM_BT; i++) {
        unsigned brTarget_u = unsigned(brTarget[i]) & ((1 << IP_W) - 1);
        insert(inst, j, shift_w, brTarget_u, IP_W);
    }
    // immediate
    for (i = 0; i < NUM_ALUS; i++) {
        unsigned imm_u = unsigned(imm[i]) & ((1 << IMM_W) - 1);
        insert(inst, j, shift_w, imm_u, IMM_W);
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

