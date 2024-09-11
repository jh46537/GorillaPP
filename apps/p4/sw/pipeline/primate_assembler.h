#include <iostream>
#include <map>
#include <string>

static std::map<std::string, int> srcType_dict {
    {"uint8", 0},
    {"uint16", 1},
    {"uint48", 2},
    {"uint64", 3},
    {"uint72", 4},
    {"uint80", 5},
    {"uint160", 6},
    {"uint", 7},
    {"uimm", 8}
};
#define NUM_SRC_POS 9
#define NUM_SRC_POS_LG int(ceil(log2(NUM_SRC_POS)))
#define NUM_SRC_MODE 8
#define NUM_SRC_MODE_LG int(ceil(log2(NUM_SRC_MODE)))
#define NUM_REGS 16
#define NUM_REGS_LG int(ceil(log2(NUM_REGS)))
#define NUM_ALUS 2
#define NUM_FUS 2
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define IP_W 6
#define IMM_W 11
