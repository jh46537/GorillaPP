INPUT;FTA,uint32,0,uint32,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0; ; ; ;WEN;WEN;R0;R0;R5;R0;0;0
INPUT;FTA,uint32,0,uint32,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0; ; ; ;WEN;WEN;R0;R0;R1;R2;0;1
OR;NEQ,uint8,30,uimm8,0,uint128,0;NEQ,uint8,2,uimm8,0,uint128,0; ; ; ; ; ;R0;R0; ; ;6;0x4080
OR;LT,uint16,24,uimm8,0,uint128,0;NEQ,uint4,31,uimm8,0,uint128,0; ; ; ; ; ;R1;R0; ; ;5;0x414
FT;FTA,uint32,0,uint32,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0;WEN;WEN; ; ; ;R2;R1;R3;R4;0;0
OR;EQ,uint8,0,uimm8,0,uint128,0;EQ,uint8,0,uimm8,0,uint128,0; ; ; ; ; ;R3;R4; ; ;3;0xffff
ALUA;EQ,uint8,14,uimm8,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0; ; ;EN; ; ;R1;R3; ; ;2;1
BR;SUB,uint8,14,uimm8,0,uint8,7;ADD,uint16,8,uimm8,0,uint16,4; ; ; ;WEN;WEN;R1; ;R1;R1;2;0x8001
FT;FTA,uimm8,0,uint32,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0; ; ; ;WEN; ; ; ;R3; ;0;0xff
OUTPUT;FTA,uint32,0,uint32,0,uint128,0;FTB,uint32,0,uint32,0,uint128,0; ; ; ; ; ;R3;R1; ; ;0;0