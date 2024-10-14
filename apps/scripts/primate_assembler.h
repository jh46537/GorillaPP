#include <iostream>
#include <map>
#include <string>

#define NUM_REGS 128
#define NUM_REGS_LG int(ceil(log2(NUM_REGS)))
#define NUM_ALUS 2
#define NUM_FUS 2
#define NUM_FUS_LG int(ceil(log2(NUM_FUS)))
#define IP_W -2147483648
#define IMM_W 5
