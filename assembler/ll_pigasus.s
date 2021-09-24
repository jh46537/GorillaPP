# uint8   return          0 [91 , 84]
# bool    flags_syn       0 [83 , 83]
# bool    flags_fin       0 [82 , 82]
# bool    flags_rst       0 [81 , 81]
# bool    flags_ack       0 [80 , 80]
# uint16  pktID           0 [79 , 64]
# uint32  seq             0 [63 , 32]
# uint16  length          0 [31 , 16]
# uint16  ll_head         0 [15 ,  0]
# uint16  new_node_ptr    1 [15 ,  0]
# tcp_pkt node            2 [83 ,  0]
# uint16  node_ptr        3 [15 ,  0]
# tcp_pkt next_node       4 [83 ,  0]
INPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ;WEN; ; ; ;R0;0;0;
FT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0;MALLOC; ; ; ;R0;R1; ;0;0xffff;
ALUA;EQ,s0,uint16,0,s1,uimm16,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;R1; ; ; ;11;0xffff;
ALUA;NEQ,s0,uint16,0,s1,uimm16,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0;LOOKUP; ;WEN;R0;R0;R2;R3;2;0xffff;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ;WEN; ;R0; ;R0; ;10;0;
GT;ADD,s0,uint32,8,s0,uint16,4,uint32,0;FTB,s0,uint32,0,s1,uint32,8,uint32,0; ; ; ;R0;R2; ; ;2;0;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE;WEN; ;R1;R0;R0; ;8;0;
ALUA;EQ,s0,uint16,0,s1,uimm16,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0;LOOKUP; ; ;R2;R2;R4; ;5;0;
GT;ADD,s0,uint32,8,s0,uint16,4,uint128,0;FTB,s0,uint32,0,s1,uint32,8,uint128,0; ; ; ;R0;R4; ; ;3;0;
FT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE; ; ;R1;R2; ; ;0;0;
BR;FTA,s0,uint32,0,s1,uint32,0,uint128,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE; ; ;R3;R1; ; ;4;0;
BR;FTA,s0,uint16,0,s1,uint32,0,uint16,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ;WEN;WEN;R2;R4;R3;R2;-4;0;
BR;FTA,s0,uint32,0,s1,uint32,0,uint128,0;CAT,s0,uint16,0,s1,uint16,0,uint128,0;UPDATE; ; ;R3;R1; ; ;2;0;
FT;FTB,s0,uint32,0,s1,uimm16,0,uint8,21;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ;WEN; ; ; ;R0; ;0;1;
OUTPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;R0;R0; ; ;0;0;