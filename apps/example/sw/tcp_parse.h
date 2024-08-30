
typedef unsigned _ExtInt(16) uint16_t;
typedef unsigned _ExtInt(8) uint8_t;
typedef unsigned _ExtInt(32) ip4Addr_t;
typedef unsigned _ExtInt(16) egressSpec_t;
typedef unsigned _ExtInt(48) macAddr_t;

typedef struct
{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    uint16_t  etherType;
} ethernet_t;

typedef struct
{
    _ExtInt(72)  version_ttl;
    uint8_t     protocol;
    _ExtInt(80) hdrChecksum_dstAddr;
} ipv4_t;

typedef struct
{
    _ExtInt(96)  srcPort_ackNo;
    _ExtInt(4)   dataOffset;
    _ExtInt(60)  res_urgentPtr;
} tcp_t;

typedef struct
{
    _ExtInt(8)  kind;
} tcp_option_t;

typedef struct
{
    _ExtInt(256) padding;
} padding_t;

typedef struct
{
    _ExtInt(64)  srcPort_checksum;
} udp_t;

typedef struct
{
    egressSpec_t egress_spec;
    uint16_t mcast_grp;
} standard_metadata_t;
