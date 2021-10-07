# uint8   return          0 [127,120]
# uint16  max_ptr         0 [119,104]
# uint16  min_ptr         0 [103, 88]
# bool    flags_syn       0 [83 , 83]
# bool    flags_fin       0 [82 , 82]
# bool    flags_rst       0 [81 , 81]
# bool    flags_ack       0 [80 , 80]
# uint16  pktID           0 [79 , 64]
# uint32  seq             0 [63 , 32]
# uint16  length          0 [31 , 16]
# uint16  root_ptr        0 [15 ,  0]
# uint16  new_node_ptr    1 [15 ,  0]
# tcp_pkt node            2 [99 , 32]
# uint16  node_right      2 [31 , 16]
# uint16  node_left       2 [15 ,  0]
# uint16  node_ptr_par    3 [15 ,  0]
# tcp_pkt min_node        5 [99 , 32]
# uint16  min_node_right  5 [31 , 16]
# uint16  min_node_left   5 [15 ,  0]
# tcp_pkt max_node        6 [99 , 32]
# uint16  max_node_right  6 [31 , 16]
# uint16  max_node_left   6 [15 ,  0]
# uint16  node_ptr        7 [47 , 32]
# uint32  seq+length      7 [31 ,  0]
INPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ;WEN; ; ; ;R0;0;0;
FT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0;MALLOC; ; ; ;R0;R1; ;0;0;
ALUA;EQ,s0,uint16,0,s1,uimm16,0,uint128,0;FTB,s0,uint32,0,s1,uint16,22,uint128,0;LOOKUP; ; ;R1;R0;R5; ;13;0xffff;
ALUA;NEQ,s0,uint16,0,s1,uimm16,0,uint128,0;FTB,s0,uint32,0,s1,uint16,0,uint16,4;LOOKUP; ;WEN;R0;R0;R2;R7;2;0xffff;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,0;CAT,s0,uint16,0,s0,uint16,0,uint32,11; ;WEN;WEN;R1; ;R0;R0;12;0;
GT;ADD,s0,uint32,8,s0,uint16,4,uint32,0;FTB,s0,uint32,0,s1,uint32,12,uint32,0; ;WEN; ;R0;R5;R7; ;2;0;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,11;CAT,s0,uint16,0,s1,uint16,22,uint128,0;UPDATE0;WEN; ;R1;R0;R0; ;10;0;
FT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s0,uint16,26,uint128,0;LOOKUP; ; ;R0; ;R6; ;0;0;
GT;ADD,s0,uint32,8,s0,uint16,4,uint32,0;FTB,s0,uint32,0,s1,uint32,12,uint32,0; ; ; ;R6;R0; ; ;2;0;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,13;CAT,s0,uint16,0,s1,uint16,26,uint128,0;UPDATE1;WEN; ;R1;R0;R0; ;7;0;
ALUA;GT,s0,uint32,0,s1,uint32,12,uint32,0;FTA,s0,uint16,8,s1,uint32,0,uint16,0; ; ;WEN;R7;R2;R3; ;3;0;
ALUA;NEQ,s0,uint16,0,s1,uimm16,0,uint32,0;FTB,s0,uint32,0,s0,uint16,0,uint16,4;LOOKUP; ;WEN;R2; ;R2;R7;-1;0xffff;
BR;FTA,s0,uint32,0,s1,uint32,0,uint128,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE0; ; ;R1;R3; ; ;4;0;
ALUA;NEQ,s0,uint16,4,s1,uimm16,0,uint32,0;FTB,s0,uint32,0,s0,uint16,4,uint16,4;LOOKUP; ;WEN;R2; ;R2;R7;-3;0xffff;
BR;FTA,s0,uint32,0,s1,uint32,0,uint128,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE1; ; ;R1;R3; ; ;2;0;
FT;FTB,s0,uint32,0,s1,uimm8,0,uint8,15;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ;WEN; ; ; ;R0; ;0;1;
OUTPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;R0;R0; ; ;0;0;