# R0: 0
# R1: ETHERNET
# R2: IPV4
# R3: TCP
# R4: UDP
# R20: TMP
# R21: PORT
# R22: HDR_VALID
#
# SRC_POS=0 16 32 48 64 72 80 96 112 
# SRC_MODE=8 16 48 64 72 80 160 160 
#ALU0;ALU1;BFU0;MEM;INPUT_OUTPUT;BRANCH;
#
NOP;NOP;LUi,R0,4096;SCATTER,R20,X2,0,1;NOP;NOP;NOP;NOP;EXTRACTi,R1,X1,14;NOP;#
GATHER,R0,R1,7,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,-2048;SCATTER,R20,X6,0,1;NOP;BNE,X2,X6,40;#
NOP;NOP;NOP;NOP;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,1;SCATTER,R22,X6,0,1;EXTRACTi,R2,X1,20;NOP;#
GATHER,R0,R2,5,0;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,0;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,6;SCATTER,R0,X6,0,1;NOP;BNE,X2,X6,8;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,2;SCATTER,R22,X6,0,1;EXTRACTi_DONE,R3,X1,20;JR,X2,28;#
GATHER,R0,R2,5,0;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,0;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,17;SCATTER,R0,X6,0,1;NOP;BNE,X2,X6,8;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,3;SCATTER,R22,X6,0,1;EXTRACTi_DONE,R4,X1,8;JR,X2,28;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;PARSE_DONE;JR,X2,28;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,1;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,36;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,1;SCATTER,R20,X2,0,6;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,511;SCATTER,R21,X6,0,1;NOP;JR,X2,36;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,2;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,44;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,2;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,44;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,3;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,52;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,3;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,52;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,4;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,60;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,4;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,60;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,5;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,68;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,5;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,68;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,6;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,76;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,6;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,76;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,7;SCATTER,R20,X2,0,6;GATHER,R0,R20,0,1;NOP;ADDi,R0,X4,0;SCATTER,R21,X6,0,1;NOP;JR,X2,84;#
GATHER,R0,R1,0,2;NOP;MATCH,R0,X0,7;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,84;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R20,0;J,8;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R21,0;NOP;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,1;SCATTER,R0,X6,0,1;EMIT,R1,X1,14;BLT,X2,X6,20;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,2;SCATTER,R0,X6,0,1;EMIT,R2,X1,20;BLT,X2,X6,16;#
GATHER,R0,R22,0,1;NOP;ADDi,R0,X0,0;SCATTER,R0,X2,0,1;GATHER,R0,R0,0,1;NOP;ADDi,R0,X4,3;SCATTER,R0,X6,0,1;NOP;BGE,X2,X6,8;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;EMIT_DONE,R3,X1,20;END;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;EMIT_DONE,R4,X1,8;END;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;DEPARSE_DONE,R22;END;#
