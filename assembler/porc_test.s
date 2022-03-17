# uint8      prot           0 [  7,   0]
# uint96     tuple          0 [103,   8]
# uint32     seq            0 [135, 104]
# uint16     len            0 [151, 136]
# uint10     pktID          0 [161, 152]
# uint6      empty          0 [167, 162]
# uint5      flits          0 [172, 168]
# uint9      hdr_len        0 [181, 173]
# uint9      tcp_flags      0 [190, 182]
# uint3      pkt_flags      0 [193, 191]
# uint2      pdu_flag       0 [195, 194]
# uint56     last_7_bytes   0 [251, 196]
# uint9      ptr0           0 [260, 252]
# uint9      ptr1           0 [269, 261]
#
# uint96     tuple          2 [ 95,   0]
# uint32     seq            2 [127,  96]
# uint9      pointer        2 [136, 128]
# uint1      ll_valid       2 [137, 137]
# uint10     slow_cnt       2 [147, 138]
# uint56     last_7_bytes   2 [203, 148]
# uint12     addr0          2 [215, 204]
# uint12     addr1          2 [227, 216]
# uint12     addr2          2 [239, 228]
# uint12     addr3          2 [251, 240]
# uint9      pointer2       2 [260, 252]
# uint5      ch0_bit_map    2 [265, 261]
#
# metadata_t pkt            3 [251,   0]
# uint9      ptr0           3 [260, 252]
# uint9      ptr1           3 [269, 261]
#
# uint9      new_node_ptr   4 [  8,   0]
#
# uint9      node_ptr       5 [  8,   0]
#
# uint10     slow_cnt       6 [  9,   0]
#
# 0, 1,  2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25
# 0, 8, 96, 104, 108, 120, 128, 132, 136, 137, 138, 148, 152, 162, 168, 173, 182, 191, 194, 196, 204, 216, 228, 240, 252, 261
#
INPUT;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0;FTLOOKUP; ;WEN; ;R2;R0;1;6;11;0;0;
INPUTSEEK;FTA,R0,uimm8,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;4;0;
INPUTSEEK;FTA,R0,uimm8,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;8;0;
INPUTSEEK;FTA,R0,uimm8,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;12;0;
INPUTSEEK;FTA,R0,uimm8,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;16;0;
INPUTSEEK;FTA,R0,uimm8,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;8;0;
OUTPUTRET;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0;UNLOCK; ; ; ; ; ;0;0;0;0;0;