typedef struct {
  uint16_t dPort;
  uint16_t sPort;
  uint32_t dIP;
  uint32_t sIP;
} tuple_t;

typedef struct {
  uint56_t last_7_bytes;
  uint2_t pdu_flag;
  uint3_t pkt_flags;
  uint9_t tcp_flags;
  uint9_t hdr_len;
  uint5_t flits;
  uint6_t empty;
  uint10_t pktID;
  uint16_t len;
  uint32_t seq;
  tuple_t tuple;
  uint8_t prot;
} metadata_t;

typedef struct {
  uint12_t addr3;
  uint12_t addr2;
  uint12_t addr1;
  uint12_t addr0;
  tuple_t tuple;
} fce_meta_t;

typedef struct {
  uint32_t seq;
  uint56_t last_7_bytes;
  uint4_t padding;
  uint12_t addr3;
  uint12_t addr2;
  uint12_t addr1;
  uint12_t addr0;
  tuple_t tuple;
} ftInsert_t;

typedef struct {
  uint12_t addr3;
  uint12_t addr2;
  uint12_t addr1;
  uint12_t addr0;
  uint56_t last_7_bytes;
  uint10_t slow_cnt;
  uint1_t ll_valid;
  uint9_t pointer;
  uint32_t seq;
  tuple_t tuple;
} fce_t;

typedef struct {
  uint3_t ch0_opcode;
  fce_meta_t ch0_meta;
} ftCh0Input_t;

typedef struct {
  uint5_t ch0_bit_map;
  fce_t ch0_q;
} ftCh0Output_t;

typedef struct {
  uint3_t ch1_opcode;
  uint5_t ch1_bit_map;
  fce_t ch1_data;
} ftCh1Input_t;

typedef struct {
  uint9_t ptr1;
  uint9_t ptr0;
  metadata_t pkt;
} llNode_t;

typedef struct {
  uint2_t opcode;
  llNode_t node;
} dyMemInput_t;