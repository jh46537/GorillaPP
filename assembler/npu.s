INPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;WEN;WEN;R0;R0;R5;R0;0;0
INPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;WEN;WEN;R0;R0;R1;R2;0;1
OR;NEQ,s0,uint8,30,s1,uimm8,0,uint128,0;NEQ,s0,uint8,2,s1,uimm8,0,uint128,0; ; ; ; ; ;R0;R0; ; ;6;0x4080
OR;LT,s0,uint16,24,s1,uimm8,0,uint128,0;NEQ,s0,uint4,31,s1,uimm8,0,uint128,0; ; ; ; ; ;R1;R0; ; ;5;0x414
FT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0;WEN;WEN; ; ; ;R2;R1;R3;R4;0;0
OR;EQ,s0,uint8,0,s1,uimm8,0,uint128,0;EQ,s0,uint8,0,s1,uimm8,0,uint128,0; ; ; ; ; ;R3;R4; ; ;3;0xffff
ALUA;EQ,s0,uint8,14,s1,uimm8,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ;EN; ; ;R1;R3; ; ;2;1
BR;SUB,s0,uint8,14,s1,uimm8,0,uint8,7;ADD,s0,uint16,8,s1,uimm8,0,uint16,4; ; ; ;WEN;WEN;R1; ;R1;R1;2;0x8001
FT;FTA,s0,uimm8,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ;WEN; ; ; ;R3; ;0;0xff
OUTPUT;FTA,s0,uint32,0,s1,uint32,0,uint128,0;FTB,s0,uint32,0,s1,uint32,0,uint128,0; ; ; ; ; ;R3;R1; ; ;0;0