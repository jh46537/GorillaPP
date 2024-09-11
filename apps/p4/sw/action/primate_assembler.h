#include <iostream>
#include <map>
#include <string>

static std::map<std::string, int> srcType_dict {
    {"uint8", 0},
    {"uint16", 1},
    {"uint40", 2},
    {"uint48", 3},
    {"uint112", 4},
    {"uint192", 5},
    {"uint", 6},
    {"uimm", 7}
};
#define NUM_SRC_POS 11
#define NUM_SRC_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_SRC_MODE 7
#define NUM_SRC_MODE_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_REGS 16
#define NUM_REGS_LG int(ceil(log2(NUM_REGS)))
#define NUM_ALUS 4
#define NUM_FUS 4
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define IP_W 3
#define IMM_W 15
