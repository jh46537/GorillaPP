typedef struct {
  uint4_t flags;
  uint16_t pktID;
  uint32_t seq;
  uint16_t length;
} pktMeta_t;

typedef struct {
  uint8_t res;
  uint4_t padding;
  uint16_t ptr1;
  uint16_t ptr0;
  pktMeta_t pkt;
  uint16_t head_ptr;
} insertIfc_t;

typedef struct {
  pktMeta_t pkt;
  uint16_t ptr1;
  uint16_t ptr0;
} node_t;