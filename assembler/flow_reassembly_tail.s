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
# uint96     tuple          1 [ 95,   0]
# uint12     addr0          1 [107,  96]
# uint12     addr1          1 [119, 108]
# uint12     addr2          1 [131, 120]
# uint12     addr3          1 [143, 132]
# uint56     last_7_bytes   1 [203, 148]
# uint32     seq            1 [235, 204]
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
INPUT;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0;HASH; ; ; ; ;WEN; ; ;R1;R0;0;0;#                  #INPUT unit also sets pkt_flags
ALUA;NEQ,s0,uint8,0,s1,uimm8,0,uint32,0;FTB,s0,uint32,0,s1,uint,0,uint,0; ; ; ; ; ; ;R0; ; ; ;2;0x11;
BR;FTA,s0,uimm8,0,s1,uint,0,uint3,17;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ; ; ;R0; ;34;2;#                       #goto output
OR;NEQ,s0,uint9,16,s1,uimm8,0,uint32,0;NEQ,s0,uint16,8,s1,uimm8,0,uint32,0; ; ; ; ; ; ;R0; ; ; ;2;0x1000;
BR;FTA,s0,uimm8,0,s1,uint,0,uint3,17;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ; ; ;R0; ;32;0;#                       #goto output
FT;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ;FTLOOKUP; ; ; ; ;R0;R1;R2; ;0;0;#                  #lock, lookup ft
ALUA;EQ,s0,uint5,25,s1,uimm8,0,uint32,0;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ;R2; ; ; ;32;0;#                    #goto insert new ft
ALUA;NEQ,s0,uint32,3,s1,uint32,2,uint32,0;FTB,s0,uint32,0,s1,uint32,0,uint32,0; ; ; ; ; ; ;R0;R2; ; ;11;0;#           #goto insert new pkt or drop
ALUA;NEQ,s0,uint10,10,s1,uimm8,0,uint32,0;FTA,s0,uint9,6,s1,uint32,0,uint9,24; ; ; ; ; ;WEN;R2; ;R0; ;5;0;#           #goto release pkt
OR;AND,s0,uint9,16,s1,uimm8,0,uint32,0;AND,s0,uint9,16,s1,uimm8,0,uint32,0; ; ; ; ; ; ;R0; ; ; ;3;0x401;
FT;ADD,s0,uint32,3,s0,uint16,8,uint32,2;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ;WEN; ;R0; ;R2; ;0;0;#                  #prepare to update
OUTPUTRET;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ;UNLOCK;UPDATE; ; ; ;R0;R2; ; ;0;0;#         #output, update, return
OUTPUTRET;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ;UNLOCK;DELETE; ; ; ;R0;R2; ; ;0;0;#         #output, delete, return
FT;ADD,s0,uint32,3,s0,uint16,8,uint32,0;FTA,s0,uint9,24,s1,uint32,0,uint32,0; ; ; ;LOOKUP;WEN; ;R0; ;R3;R4;0;0;
ALUA;NEQ,s0,uint32,0,s1,uint32,3,uint32,0;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ;R4;R3; ; ;-4;0;#                 #match ll head seq
OUTPUT;FTA,s0,uint,0,s1,uint,0,uint,0;FTA,s1,uint,0,s1,uint,0,uint,0; ; ; ; ; ;WEN;R0;R3;R0; ;1;0;
ALUA;SUB,s0,uint10,10,s1,uimm8,0,uint10,10;FTB,s0,uint,0,s1,uint9,24,uint9,6; ; ; ; ;WEN;WEN;R2;R3;R2;R2;-3;1;
BR;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ; ; ; ; ;-8;0;
ALUA;GT,s0,uint32,3,s1,uint32,2,uint32,0;FTB,s0,uint32,0,s1,uint32,0,uint32,0; ; ; ; ; ; ;R0;R2; ; ;2;0;#             #goto insert if true
BR;FTA,s0,uimm8,0,s1,uint,0,uint3,17;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ;WEN; ; ; ;R0; ;18;1;#                     #drop, goto output
FT;FTB,s0,uint,0,s1,uint10,10,uint10,0;FTA,s0,uint,0,s1,uint,0,uint,0; ; ; ;MALLOC;WEN; ;R0;R2;R4;R6;0;0;#            #insert new pkt
ALUA;NEQ,s0,uint10,10,s1,uimm8,0,uint,0;FTA,s0,uint9,24,s1,uint,0,uint9,0; ; ; ;LOOKUP; ;WEN;R2; ;R3;R5;2;0;#         #check empty, look up tail
BR;FTA,s0,uint9,0,s1,uint,0,uint9,6;FTA,s0,uint9,0,s1,uint,0,uint9,24; ; ; ; ;WEN;WEN;R4; ;R2;R2;12;0;#               #goto update ft
GE;FTA,s0,uint32,3,s1,uint,0,uint32,0;ADD,s1,uint32,3,s1,uint16,8,uint32,0; ; ; ; ; ; ;R0;R3; ; ;6;0;#                #if true, go to insert tail
FT;FTA,s0,uint,0,s1,uint,0,uint,0;FTA,s0,uint9,6,s1,uint,0,uint9,0; ; ; ;LOOKUP; ; ;R2; ;R3; ;0;0;
GT;ADD,s0,uint32,3,s0,uint16,8,uint32,0;FTB,s0,uint,0,s1,uint32,3,uint32,0; ; ; ; ; ; ;R0;R3; ; ;2;0;#                #check head seq
BR;FTA,s0,uint9,0,s1,uint,0,uint9,6;CAT,s0,uint9,0,s1,uint9,0,uint,0; ; ; ;UPDATE0;WEN; ;R4;R5;R2; ;8;0;#             #goto update ft
GT;ADD,s0,uint32,3,s0,uint16,8,uint32,0;FTB,s0,uint,0,s1,uint32,3,uint32,0; ; ; ; ; ; ;R3;R0; ; ;-8;0;#               #goto drop if true
ALUA;SUB,s0,uint10,0,s1,uimm8,0,uint10,0;FTB,s0,uint,0,s1,uint9,24,uint,0; ; ; ;LOOKUP;WEN; ;R6;R3;R7;R6;2;1;
BR;FTB,s0,uint,0,s1,uint,0,uint9,24;CAT,s0,uint9,0,s1,uint9,0,uint,0; ; ; ;UPDATE0;WEN; ;R5;R4;R2; ;5;0;#             #insert to tail
GT;ADD,s0,uint32,3,s0,uint16,8,uint32,0;FTB,s0,uint,0,s1,uint32,3,uint32,0; ; ; ; ; ; ;R0;R7; ; ;3;0;#                #compare next seq
FT;FTA,s0,uint,0,s1,uint,0,uint,0;CAT,s0,uint9,0,s1,uint9,24,uint,0; ; ; ;UPDATE0; ; ;R4;R3; ; ;0;0;#                 #insert
BR;FTA,s0,uint,0,s1,uint,0,uint,0;CAT,s0,uint9,0,s1,uint9,0,uint,0; ; ; ;UPDATE0; ; ;R5;R4; ; ;2;0;#                  #goto update ft
BR;FTA,s0,uint9,24,s1,uint,0,uint9,24;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ;WEN;WEN;R3;R7;R5;R3;-6;0;
FT;ADD,s0,uint10,10,s1,uimm8,0,uint10,10;FTA,s0,uint,0,s1,uint,0,uint,0; ; ; ; ;WEN; ;R2; ;R2; ;0;1;#                 #increment slow_cnt
RET;FTA,s0,uint,0,s1,uint,0,uint,0;FTA,s0,uint,0,s1,uint,0,uint,0; ;UNLOCK;UPDATE; ; ; ;R2; ; ; ;0;0;#                #update ft and return
OUTPUTRET;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ; ; ; ; ; ;R0; ; ; ;1;0;#                    #output, ret
OUTPUTRET;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ;UNLOCK; ; ; ; ;R0; ; ; ;1;0;#               #output, ret, unlock
OR;AND,s0,uint9,16,s1,uimm8,0,uint32,0;AND,s0,uint9,16,s1,uimm8,0,uint32,0; ; ; ; ; ; ;R0; ; ; ;-1;0x401;
ALUA;AND,s0,uint9,16,s1,uimm8,0,uint32,0;ADD,s0,uint32,3,s1,uimm8,0,uint32,20; ; ; ; ; ;WEN;R0; ;R1; ;2;0x102;#       #goto insert and output if true
FT;FTA,s0,uint56,19,s1,uint,0,uint56,11;ADD,s0,uint32,3,s0,uint16,8,uint32,20; ; ; ; ;WEN;WEN;R0; ;R1;R1;0;0;
OUTPUTRET;FTA,s0,uint,0,s1,uint,0,uint,0;FTB,s0,uint,0,s1,uint,0,uint,0; ;UNLOCK;INSERT; ; ; ;R0;R1; ; ;0;0;#         #insert, output, return