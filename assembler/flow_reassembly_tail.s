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
INPUT;FTA,R0,uint,0,R0,uint,0,uint,0;FTB,R0,uint,0,R0,uint,0,uint,0;HASH; ; ; ; ;WEN;R1;R0;0;0;0;0;0;#                  #INPUT unit also sets pkt_flags
FU;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;FTLOOKUP; ; ; ; ;R2; ;1;6;11;0;0;#                   #fast path, lock if slow path, lookup ft
OUTPUTRET;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ; ; ;0;0;0;0;0;
OR;AND,R0,uint9,16,R1,uimm8,0,uint32,0;AND,R0,uint9,16,R1,uimm8,0,uint32,0; ; ; ; ; ; ; ; ;3;0;0;1;4;
FT;ADD,R0,uint32,3,R0,uint16,8,uint32,2;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ;WEN; ;R2; ;0;0;0;0;0;#                   #prepare to update
OUTPUTRET;FTA,R0,uint,0,R2,uint,0,uint,0;FTB,R0,uint,0,R2,uint,0,uint,0; ;UNLOCK;UPDATE; ; ; ; ; ;0;0;0;0;0;#           #output, update, return
OUTPUTRET;FTA,R0,uint,0,R2,uint,0,uint,0;FTB,R0,uint,0,R2,uint,0,uint,0; ;UNLOCK;DELETE; ; ; ; ; ;0;0;0;0;0;#           #output, delete, return
FT;ADD,R0,uint32,3,R0,uint16,8,uint32,0;FTB,R0,uint,0,R2,uint9,6,uint32,0; ; ; ;LOOKUP;WEN; ;R3;R4;0;0;0;0;0;#          #start releasing pkt
ALUA;NEQ,R4,uint32,0,R3,uint32,3,uint32,0;FTB,R4,uint,0,R3,uint,0,uint,0; ; ; ; ; ; ; ; ;-4;0;0;0;0;#                   #match ll head seq
OUTPUT;FTA,R0,uint,0,R3,uint,0,uint,0;FTA,R3,uint,0,R3,uint,0,uint,0; ; ; ; ; ;WEN;R0; ;1;0;0;0;0;
ALUA;SUB,R2,uint10,10,R3,uimm8,0,uint10,10;FTB,R2,uint,0,R3,uint9,24,uint9,6; ; ; ; ;WEN;WEN;R2;R2;-3;0;0;1;0;
BR;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ; ; ;-8;0;0;0;0;
ALUA;GT,R0,uint32,3,R2,uint32,2,uint32,0;FTB,R0,uint32,0,R2,uint32,0,uint32,0; ; ; ; ; ; ; ; ;2;0;0;0;0;#               #start inserting pkt, goto insert if true
BR;FTA,R0,uimm8,0,R1,uint,0,uint3,17;FTB,R0,uint,0,R1,uint,0,uint,0; ; ; ; ;WEN; ;R0; ;18;0;0;1;0;#                     #drop, goto output
FT;FTB,R0,uint,0,R2,uint10,10,uint10,0;FTA,R0,uint,0,R2,uint,0,uint,0; ; ; ;MALLOC;WEN; ;R4;R6;0;0;0;0;0;#              #insert new pkt
ALUA;NEQ,R2,uint10,10,R0,uimm8,0,uint,0;FTA,R2,uint9,24,R0,uint,0,uint9,0; ; ; ;LOOKUP; ;WEN;R3;R5;2;0;0;0;0;#          #check empty, look up tail
BR;FTA,R4,uint9,0,R0,uint,0,uint9,6;FTA,R4,uint9,0,R0,uint,0,uint9,24; ; ; ; ;WEN;WEN;R2;R2;12;0;0;0;0;#                #goto update ft
GE;FTA,R0,uint32,3,R3,uint,0,uint32,0;ADD,R3,uint32,3,R3,uint16,8,uint32,0; ; ; ; ; ; ; ; ;6;0;0;0;0;#                  #if true, go to insert tail
FT;FTA,R2,uint,0,R0,uint,0,uint,0;FTA,R2,uint9,6,R0,uint,0,uint9,0; ; ; ;LOOKUP; ;WEN;R3;R5;0;0;0;0;0;
GT;ADD,R0,uint32,3,R0,uint16,8,uint32,0;FTB,R0,uint,0,R3,uint32,3,uint32,0; ; ; ; ; ; ; ; ;2;0;0;0;0;#                  #check head seq
BR;FTA,R4,uint9,0,R5,uint,0,uint9,6;CAT,R4,uint9,0,R5,uint9,0,uint,0; ; ; ;UPDATE0;WEN; ;R2; ;8;0;0;0;0;#               #goto update ft
GT;ADD,R3,uint32,3,R3,uint16,8,uint32,0;FTB,R3,uint,0,R0,uint32,3,uint32,0; ; ; ; ; ; ; ; ;-8;0;0;0;0;#                 #goto drop if true
ALUA;SUB,R6,uint10,0,R3,uimm8,0,uint10,0;FTB,R6,uint,0,R3,uint9,24,uint,0; ; ; ;LOOKUP;WEN; ;R7;R6;2;0;0;1;0;
BR;FTB,R5,uint,0,R4,uint,0,uint9,24;CAT,R5,uint9,0,R4,uint9,0,uint,0; ; ; ;UPDATE0;WEN; ;R2; ;5;0;0;0;0;#               #insert to tail
GT;ADD,R0,uint32,3,R0,uint16,8,uint32,0;FTB,R0,uint,0,R7,uint32,3,uint32,0; ; ; ; ; ; ; ; ;3;0;0;0;0;#                  #compare next seq
FT;FTA,R4,uint,0,R3,uint,0,uint,0;CAT,R4,uint9,0,R3,uint9,24,uint,0; ; ; ;UPDATE0; ; ; ; ;0;0;0;0;0;#                   #insert
BR;FTA,R5,uint,0,R4,uint,0,uint,0;CAT,R5,uint9,0,R4,uint9,0,uint,0; ; ; ;UPDATE0; ; ; ; ;2;0;0;0;0;#                    #goto update ft
BR;FTA,R3,uint9,24,R7,uint,0,uint9,0;FTB,R3,uint,0,R7,uint,0,uint,0; ; ; ; ;WEN;WEN;R5;R3;-6;0;0;0;0;
FT;ADD,R2,uint10,10,R0,uimm8,0,uint10,10;FTA,R2,uint,0,R0,uint,0,uint,0; ; ; ; ;WEN; ;R2; ;0;0;0;1;0;#                  #increment slow_cnt
RET;FTA,R2,uint,0,R0,uint,0,uint,0;FTA,R2,uint,0,R0,uint,0,uint,0; ;UNLOCK;UPDATE; ; ; ; ; ;0;0;0;0;0;#                 #update ft and return
OUTPUTRET;FTA,R0,uint,0,R0,uint,0,uint,0;FTB,R0,uint,0,R0,uint,0,uint,0; ; ; ; ; ; ; ; ;1;0;0;0;0;#                     #output, ret
OUTPUTRET;FTA,R0,uint,0,R0,uint,0,uint,0;FTB,R0,uint,0,R0,uint,0,uint,0; ;UNLOCK; ; ; ; ; ; ;1;0;0;0;0;#                #output, ret, unlock
OR;AND,R0,uint9,16,R0,uimm8,0,uint32,0;AND,R0,uint9,16,R0,uimm8,0,uint32,0; ; ; ; ; ; ; ; ;-1;0;0;1;4;
ALUA;AND,R0,uint9,16,R0,uimm8,0,uint32,0;ADD,R0,uint32,3,R0,uimm8,0,uint32,20; ; ; ; ; ;WEN;R1; ;2;0;0;2;1;#            #goto insert and output if true
FT;FTA,R0,uint56,19,R0,uint,0,uint56,11;ADD,R0,uint32,3,R0,uint16,8,uint32,20; ; ; ; ;WEN;WEN;R1;R1;0;0;0;0;0;
OUTPUTRET;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;UNLOCK;INSERT; ; ; ; ; ;0;0;0;0;0;#           #insert, output, return