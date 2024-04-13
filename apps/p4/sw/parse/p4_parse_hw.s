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
#EXTRACT0;EXTRACT1;ALU0;INSERT;EXTRACT0;EXTRACT1;ALU1;INSERT;INOUTPUT;BRANCH;
#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;PARSE_DONE;NOP;#
GATHER,R0,R1,0,3;NOP;MATCH,R0,X0,0;SCATTER,R20,X2,0,6;GATHER,R0,R0,0,6;NOP;ADDi,R0,X4,511;SCATTER,R21,X6,0,6;NOP;JR,X2,4;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;OUTPUT_META,R0,R20,0;J,8;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;OUTPUT_META,R0,R21,0;NOP;#
NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;DEPARSE_DONE_SPEC,R22;END;#
