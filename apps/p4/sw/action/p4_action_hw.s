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
NOP;NOP;NOP;NOP;PARSE_DONE;NOP;#
ADDi,R0,0,0,R1,0,3,0;NOP;MATCH,R20,X0,0;NOP;NOP;JR,X2,0;#
ADDi,R4,0,1,R0,0,1,1;ADDi,R21,0,1,R20,0,1,0;NOP;NOP;OUTPUT_META,R21,X1,0;J,8;#
ADDi,R4,0,1,R0,0,1,1;ADDi,R21,0,1,R0,0,1,511;NOP;NOP;OUTPUT_META,R21,X1,0;NOP;#
NOP;ADDi,R0,0,1,R22,0,1,0;NOP;NOP;DEPARSE_DONE;END;#
