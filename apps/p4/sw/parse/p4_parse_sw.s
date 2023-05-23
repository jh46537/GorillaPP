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
# SRC_POS=0 16 32 40 48 64 96 112 160 
# SRC_MODE=8 16 40 48 112 192 192 
#ALU0;ALU1;BFU0;MEM;INPUT_OUTPUT;BRANCH;
#
LUi,R20,0,1,36864;NOP;NOP;NOP;EXTRACTi,R1,X1,14;NOP;#
ADDi,R0,0,1,R1,6,1,0;ADDi,R20,0,1,R20,0,1,-1801;NOP;NOP;NOP;BNE,X0,X1,72;#
ADDi,R20,0,1,R0,0,1,1;ADDi,R22,0,1,R0,0,1,1;NOP;NOP;EXTRACTi,R2,X1,20;NOP;#
ADDi,R0,0,0,R2,3,0,0;ADDi,R20,0,1,R20,0,1,0;NOP;NOP;EXTRACTi,R3,X1,24;BNE,X0,X1,64;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R4,X1,8;NOP;#
ADDi,R0,0,1,R4,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,56;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R5,X1,8;NOP;#
ADDi,R0,0,1,R5,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,48;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R6,X1,8;NOP;#
ADDi,R0,0,1,R6,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,40;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R7,X1,8;NOP;#
ADDi,R0,0,1,R7,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,32;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R8,X1,8;NOP;#
ADDi,R0,0,1,R8,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,24;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R9,X1,8;NOP;#
ADDi,R0,0,1,R9,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,16;#
ADDi,R22,0,1,R22,0,1,1;NOP;NOP;NOP;EXTRACTi,R10,X1,8;NOP;#
ADDi,R0,0,1,R10,0,1,0;ADDi,R0,0,0,R0,0,0,0;NOP;NOP;NOP;BEQ,X0,X1,8;#
ADDi,R0,0,0,R1,0,3,0;ADDi,R22,0,1,R22,0,1,1;MATCH,R20,X0,0;NOP;EXTRACTi_DONE,R11,X1,8;JR,X2,0;#
ADDi,R0,0,0,R1,0,3,0;NOP;MATCH,R20,X0,0;NOP;PARSE_DONE;JR,X2,0;#
NOP;ADDi,R21,0,1,R20,0,1,0;NOP;NOP;OUTPUT_META,R21,X1,0;J,8;#
NOP;ADDi,R21,0,1,R0,0,1,511;NOP;NOP;OUTPUT_META,R21,X1,0;NOP;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,1;NOP;NOP;EMIT,R1,X1,14;BLT,X0,X1,28;#
NOP;NOP;NOP;EMIT,R2,X1,20;NOP;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,2;NOP;NOP;EMIT,R3,X1,24;BLT,X0,X1,36;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,3;NOP;NOP;EMIT,R4,X1,8;BLT,X0,X1,32;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,4;NOP;NOP;EMIT,R5,X1,8;BLT,X0,X1,28;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,5;NOP;NOP;EMIT,R6,X1,8;BLT,X0,X1,24;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,6;NOP;NOP;EMIT,R7,X1,8;BLT,X0,X1,20;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,7;NOP;NOP;EMIT,R8,X1,8;BLT,X0,X1,16;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,8;NOP;NOP;EMIT,R9,X1,8;BLT,X0,X1,12;#
ADDi,R0,0,1,R22,0,1,0;ADDi,R0,0,1,R0,0,1,9;NOP;NOP;EMIT,R10,X1,8;BLT,X0,X1,8;#
NOP;NOP;NOP;NOP;EMIT_DONE,R11,X1,8;END;#
NOP;NOP;NOP;NOP;DEPARSE_DONE;END;#