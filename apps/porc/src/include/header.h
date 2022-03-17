typedef struct {
  uint16_t word;
} porcIn_t;

typedef struct {
  uint64_t idx;
} porcOut_t;

typedef struct {
  uint16_t word;
} mspmIn_t;

typedef struct {
  uint16_t match_idx_vec;
  uint4_t match_pos0;
  uint4_t match_pos1;
  uint4_t match_pos2;
  uint4_t match_pos3;
  uint4_t match_pos4;
  uint4_t match_pos5;
  uint4_t match_pos6;
  uint4_t match_pos7;
  uint4_t match_pos8;
  uint4_t match_pos9;
  uint4_t match_pos10;
  uint4_t match_pos11;
  uint4_t match_pos12;
  uint4_t match_pos13;
  uint4_t match_pos14;
  uint4_t match_pos15;
} mspmOut_t;

typedef struct {
  uint16_t string;
} asciiIn_t;

typedef struct {
  uint16_t integer;
} asciiOut_t;
