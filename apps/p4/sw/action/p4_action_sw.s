# R0: 0
# R1: ETHERNET
# R2: PTP_L
# R3: PTP_H
# R4: HEADER_0
# R5: HEADER_1
# R6: HEADER_2
# R7: HEADER_3
# R8: HEADER_4
# R9: HEADER_5
# R10: HEADER_6
# R11: HEADER_7
# R12: HEADER_8
# R13: HEADER_9
# R14: HEADER_10
# R15: HEADER_11
# R16: HEADER_12
# R17: HEADER_13
# R18: HEADER_14
# R19: HEADER_15
# R20: TMP
# R21: PORT
# R22: HDR_VALID
#
# SRC_POS=0 16 32 40 48 64 80 96 112 128 160 
# SRC_MODE=8 16 40 48 112 192 192
#ALU0;ALU1;BFU0;MEM;INPUT_OUTPUT;BRANCH;
#
NOP;NOP;LUi,R0,36864;SCATTER,R20,X2,0,1;NOP;NOP;NOP;NOP;EXTRACTi,R1,X1,14;NOP;#
GATHER,R0,R1,7,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,-1801;SCATTER,R20,X6,0,1;NOP;BNE,X2,X6,40;#
GATHER,R0,R0,0,1;NOP;ADDi,R0,X0,1;SCATTER,R20,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,1;SCATTER,R22,X6,0,1;EXTRACTi,R2,X1,20;NOP;#
GATHER,R0,R2,3,0;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,0;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R20,X6,0,1;EXTRACTi,R3,X1,24;BNE,X2,X6,32;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,1;SCATTER,R22,X2,0,1;NOP;NOP;NOP;NOP;EXTRACTi,R4,X1,16;NOP;#
GATHER,R0,R4,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,0;NOP;ADDi,R0,X4,0;SCATTER,R0,X6,0,0;NOP;BEQ,X2,X6,24;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,1;SCATTER,R22,X2,0,1;NOP;NOP;NOP;NOP;EXTRACTi,R5,X1,16;NOP;#
GATHER,R0,R5,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,0;NOP;ADDi,R0,X4,0;SCATTER,R0,X6,0,0;NOP;BEQ,X2,X6,16;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,1;SCATTER,R22,X2,0,1;NOP;NOP;NOP;NOP;EXTRACTi,R6,X1,16;NOP;#
GATHER,R0,R6,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,0;NOP;ADDi,R0,X4,0;SCATTER,R0,X6,0,0;NOP;BEQ,X2,X6,8;#
GATHER,R0,R1,0,3;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;GATHER,R0,R22,0,1;NOP;ADDi,R0,X4,1;SCATTER,R22,X6,0,1;EXTRACTi_DONE,R7,X1,8;JR,X2,44;#
GATHER,R0,R1,0,3;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;PARSE_DONE;JR,X2,44;#
GATHER,R0,R0,0,1;NOP;ADDi,R0,X0,1;SCATTER,R4,X2,0,1;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R20,0;J,8;#
GATHER,R0,R0,0,1;NOP;ADDi,R0,X0,1;SCATTER,R4,X2,0,1;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R0,511;NOP;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,1;SCATTER,R0,X6,0,1;EMIT,R1,X1,14;BLT,X2,X6,28;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;EMIT,R2,X1,20;NOP;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,2;SCATTER,R0,X6,0,1;EMIT,R3,X1,24;BLT,X2,X6,20;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,3;SCATTER,R0,X6,0,1;EMIT,R4,X1,16;BLT,X2,X6,16;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,4;SCATTER,R0,X6,0,1;EMIT,R5,X1,16;BLT,X2,X6,12;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,5;SCATTER,R0,X6,0,1;EMIT,R6,X1,16;BLT,X2,X6,8;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;EMIT_DONE,R7,X1,16;END;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;DEPARSE_DONE,R22;END;#
