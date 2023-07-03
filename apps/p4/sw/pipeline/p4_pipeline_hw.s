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
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;PARSE_DONE;NOP;#
GATHER,R0,R1,0,3;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;NOP;NOP;NOP;NOP;NOP;JR,X2,4;#
GATHER,R0,R0,0,1;NOP;ADDi,R0,X0,1;SCATTER,R4,X2,0,1;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R20,0;J,8;#
GATHER,R0,R0,0,1;NOP;ADDi,R0,X0,1;SCATTER,R4,X2,0,1;NOP;NOP;NOP;NOP;OUTPUT_META,R21,R0,511;NOP;#
NOP;NOP;NOP;NOP;GATHER,R0,R22,0,1;NOP;ADDi,R0,X4,0;SCATTER,R0,X6,0,1;DEPARSE_DONE,R22;END;#
