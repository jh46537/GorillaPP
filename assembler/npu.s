INPUT, , , ,WEN,WEN, , ,R0,R1,0,0
INPUT, , , ,WEN, , , ,R2, ,0,1
ETHERNET, , , , , ,R0, , , ,6,0
IPV4, , , , , ,R0, , , ,5,0
LOOKUP,WEN,WEN, , , ,R2,R1,R3,R4,0,0
LOOKUP_POST, , , , , ,R3,R4, , ,3,0
UPDATE, , ,EN, , ,R1,R3, , ,2,0
UPDATE_POST, , , ,WEN, ,R1, ,R1, ,2,0
EXCEPTION, , , ,WEN, , , ,R3, ,0,0
OUTPUT, , , , , ,R3,R1, , ,0,0
