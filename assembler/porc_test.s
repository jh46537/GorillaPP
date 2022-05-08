# uint128    stringl        0 [127,   0]
# uint128    stringh        0 [255, 128]
# uint5      length         0 [260, 256]
# uint4      idx            0 [264, 261]
#
# uint16     matched        1 [ 15,   0]
# uint4      match_pos0     1 [ 19,  16]
# uint4      match_pos1     1 [ 23,  20]
# uint4      match_pos2     1 [ 27,  24]
# uint4      match_pos3     1 [ 31,  28]
# uint4      match_pos4     1 [ 35,  32]
# uint4      match_pos5     1 [ 39,  36]
# uint4      match_pos6     1 [ 43,  40]
# uint4      match_pos7     1 [ 47,  44]
# uint4      match_pos8     1 [ 51,  48]
# uint4      match_pos9     1 [ 55,  52]
# uint4      match_pos10    1 [ 59,  56]
# uint4      match_pos11    1 [ 63,  60]
# uint4      match_pos12    1 [ 67,  64]
# uint4      match_pos13    1 [ 71,  68]
# uint4      match_pos14    1 [ 75,  72]
# uint4      match_pos15    1 [ 79,  76]
#
#
# 0, 1,  2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25
# 0, 8, 96, 104, 108, 120, 128, 132, 136, 137, 138, 148, 152, 162, 168, 173, 182, 191, 194, 196, 204, 216, 228, 240, 252, 261
#
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;4;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;LOAD; ; ; ; ; ;0;0;0;4;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;34;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;LOAD; ; ; ; ; ;0;0;0;2;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;69;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;LOAD; ; ; ; ; ;0;0;0;5;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;4;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;MATCH; ; ; ;R1; ;0;0;0;4;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;4;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;MATCH; ; ; ;R1; ;0;0;0;4;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;2;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;MATCH; ; ; ;R1; ;0;0;0;2;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;7;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;MATCH; ; ; ;R1; ;0;0;0;7;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTA,R0,uimm9,0,R1,uint,0,uint9,18; ; ;WEN;WEN;R0;R0;0;0;0;0;7;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0;MATCH; ; ; ;R1; ;0;0;0;7;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;ISDIGIT; ; ;R2; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;7;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;ISDIGIT; ; ;R2; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;6;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;ISDIGIT; ; ;R2; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;11;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;ISDIGIT; ; ;R2; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;6;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;EXDIGIT; ; ;R3; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;16;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;EXDIGIT; ; ;R3; ;0;0;0;0;0;
INPUTSEEK;FTA,R0,uimm9,0,R1,uint,0,uint,0;FTA,R0,uint,0,R1,uint,0,uint,0; ; ; ; ; ; ;0;0;0;16;0;
INPUT;FTA,R0,uint,0,R1,uint,0,uint128,0;FTB,R0,uint,0,R1,uint,0,uint,0; ;EXDIGIT; ; ;R3; ;0;0;0;0;0;
OUTPUTRET;FTA,R0,uint,0,R1,uint,0,uint,0;FTB,R0,uint,0,R1,uint,0,uint,0;RESET; ; ; ; ; ;0;0;0;0;0;