
typedef unsigned _ExtInt(16) uint16_t;
typedef unsigned _ExtInt(32) uint32_t;
typedef unsigned _ExtInt(8) uint8_t;
typedef _ExtInt(16) egressSpec_t;
typedef _ExtInt(48) macAddr_t;
typedef uint32_t ip4Addr_t;

typedef struct {
  macAddr_t dstAddr;
  egressSpec_t port;
} forward_exact_t;
typedef struct {
  uint32_t flag;
} forward_result_t;

typedef struct
{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    uint16_t  etherType;
} ethernet_t;

typedef struct
{
    _ExtInt(40)  transportSpecific_domainNumber;
    uint8_t     reserved2;
    _ExtInt(112) flags_reserved3;
} ptp_l_t;

typedef struct
{
  _ExtInt(128) sourcePortIdentity;
  _ExtInt(64) originTimestamp;
} ptp_h_t;

typedef struct
{
    uint16_t field_0;
    _ExtInt(48) field_1_field_3;
} header_0_t;

typedef struct
{
    uint16_t field_0;
    _ExtInt(48) field_1_field_3;
} header_1_t;

typedef struct
{
    uint16_t field_0;
    _ExtInt(48) field_1_field_3;
} header_2_t;

typedef struct
{
    uint16_t field_0;
    _ExtInt(48) field_1_field_3;
} header_3_t;

typedef struct
{
    egressSpec_t egress_spec;
    uint16_t mcast_grp;
} standard_metadata_t;
