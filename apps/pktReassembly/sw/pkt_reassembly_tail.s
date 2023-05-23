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
# uint10     pointer        2 [137, 128]
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
# 0, 1,  2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13
# 0, 8, 96, 104, 128, 136, 138, 148, 152, 182, 191, 194, 252, 261
#          0 1 2 3  4  5  6  7  8  9  10  11
# SRC_MODE=3 5 8 9 10 16 30 32 58 96 104 104
#ALU0;ALU1;ALU2;FT0;FT1;DYMEM;IOUNIT;BRANCH;
ADDi,R0,0,11,R1,0,11,0;NOP;NOP;FTLOOKUP,R2,X0,0;NOP;NOP;NOP;JR,X3,0;#
NOP;ADDi,R0,0,11,R1,0,11,0;NOP;NOP;NOP;NOP;OUTPUT,R0,X1,0;END;#
ANDi,R0,0,11,R1,9,3,1;ANDi,R0,0,11,R1,9,3,4;NOP;NOP;NOP;NOP;BNE,X0,X1,3;#
ADD,R2,2,7,R1,3,7,R1,5,5;NOP;NOP;NOP;NOP;NOP;NOP;NOP;#
ADDi,R0,0,11,R1,0,11,0;ADDi,R0,0,11,R2,0,11,0;NOP;UNLOCK;UPDATE;NOP;NOP;END;#
ADDi,R0,0,11,R1,0,11,0;ADDi,R0,0,11,R2,0,11,0;NOP;UNLOCK;DELETE;NOP;NOP;END;#
ADDi,R0,0,11,R2,4,4,0;ADDi,R0,0,11,R1,0,11,0;NOP;NOP;NOP;LOOKUP,R3,X0,0;OUTPUT,R0,X1,0;NOP;#
ADD,R0,0,11,R1,3,7,R1,5,5;ADDi,R0,0,11,R3,3,7,0;NOP;NOP;NOP;NOP;NOP;BNE,X0,X1,-5;#
ADDi,R0,0,11,R2,4,4,0;ADDi,R1,0,11,R3,0,11,0;NOP;NOP;NOP;RELEASE,R0,X0,0;NOP;NOP;#
ADDi,R2,6,4,R2,6,4,-1;ADDi,R2,4,4,R3,12,3,0;ADDi,R0,0,11,R0,0,11,0;NOP;NOP;NOP;NOP;BNE,X0,X2,-3;#
NOP;ADDi,R0,0,11,R1,0,11,0;NOP;NOP;NOP;NOP;OUTPUT,R0,X1,0;J,-8;#
ADDi,R0,0,11,R2,2,7,0;ADDi,R0,0,11,R1,3,7,0;NOP;NOP;NOP;NOP;NOP;BLT,X0,X1,2;#
ADDi,R1,10,0,R0,0,11,1;NOP;NOP;NOP;NOP;NOP;NOP;J,18;#
ADDi,R0,0,11,R1,0,11,0;ADDi,R6,0,11,R2,6,4,0;NOP;NOP;NOP;MALLOC,R4,X0,0;NOP;NOP;#
ADDi,R0,0,11,R2,12,3,0;ADDi,R0,0,11,R2,6,4,0;ADDi,R0,0,11,R0,0,11,0;NOP;NOP;LOOKUP,R3,X0,0;NOP;BNE,X1,X2,2;#
ADDi,R2,4,4,R4,0,3,0;ADDi,R2,12,3,R4,0,3,0;NOP;NOP;NOP;NOP;NOP;J,12;#
ADDi,R0,0,11,R1,3,7,0;ADD,R0,0,11,R3,3,7,R3,5,5;NOP;NOP;NOP;NOP;NOP;BGE,X0,X1,6;#
ADDi,R5,0,11,R2,4,4,0;NOP;NOP;NOP;NOP;LOOKUP,R3,X0,0;NOP;NOP;#
ADDi,R0,0,11,R3,3,7,0;ADD,R0,0,11,R1,3,7,R1,5,5;NOP;NOP;NOP;NOP;NOP;BLT,X0,X1,2;#
CAT,R0,0,11,R4,0,3,R5,0,3;ADDi,R2,4,4,R4,0,3,0;NOP;NOP;NOP;UPDATE0,R0,X0,0;NOP;J,8;#
ADDi,R0,0,11,R1,3,7,0;ADD,R0,0,11,R3,3,7,R3,5,5;NOP;NOP;NOP;NOP;NOP;BLT,X0,X1,-8;#
ADDi,R0,0,11,R3,12,3,0;ADDi,R6,0,11,R6,0,4,-1;ADDi,R0,0,11,R0,0,11,0;NOP;NOP;LOOKUP,R7,X0,0;NOP;BNE,X0,X2,2;#
CAT,R0,0,11,R5,0,3,R4,0,3;ADDi,R2,12,3,R4,0,3,0;NOP;NOP;NOP;UPDATE0,R0,X0,0;NOP;J,5;#
ADDi,R0,0,11,R7,3,7,0;ADD,R0,0,11,R1,3,7,R1,5,5;NOP;NOP;NOP;NOP;NOP;BLT,X0,X1,3;#
CAT,R0,0,11,R4,0,3,R3,12,3;NOP;NOP;NOP;NOP;UPDATE0,R0,X0,0;NOP;NOP;#
CAT,R0,0,11,R5,0,3,R4,0,3;NOP;NOP;NOP;NOP;UPDATE0,R0,X0,0;NOP;J,2;#
ADDi,R5,0,11,R3,12,3,0;ADDi,R3,0,11,R7,0,11,0;NOP;NOP;NOP;NOP;NOP;J,-6;#
ADDi,R2,6,4,R2,6,4,1;NOP;NOP;NOP;NOP;NOP;NOP;NOP;#
ADDi,R0,0,11,R1,0,11,0;ADDi,R0,0,11,R2,0,11,0;NOP;UNLOCK;UPDATE;NOP;NOP;END;#
NOP;ADDi,R0,0,11,R1,0,11,0;NOP;NOP;NOP;NOP;OUTPUT,R0,X1,0;END;#
ADDi,R0,0,11,R1,0,11,0;ADDi,R0,0,11,R1,0,11,0;NOP;UNLOCK;NOP;NOP;OUTPUT,R0,X1,0;END;#
