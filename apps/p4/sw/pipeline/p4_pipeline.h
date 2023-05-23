#include <stdint.h>

typedef _ExtInt(16) egressSpec_t;
typedef _ExtInt(48) macAddr_t;
typedef uint32_t ip4Addr_t;

typedef struct
{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    uint16_t  etherType;
} ethernet_t;

// typedef struct ptp_t
// {
//     _ExtInt(4)  transportSpecific;
//     _ExtInt(4)  messageType;
//     _ExtInt(4)  reserved;
//     _ExtInt(4)  versionPTP;
//     uint16_t    messageLength;
//     uint8_t     domainNumber;
//     uint8_t     reserved2;
//     uint16_t    flags;
//     uint64_t    correction;
//     uint32_t    reserved3;
//     _ExtInt(80) sourcePortIdentity;
//     uint16_t    sequenceId;
//     uint8_t     PTPcontrol;
//     uint8_t     logMessagePeriod;
//     _ExtInt(80) originTimestamp;
// };

typedef struct
{
    _ExtInt(72)  version_ttl;
    uint8_t     protocol;
    _ExtInt(80) hdrChecksum_dstAddr;
} ipv4_t;

typedef struct
{
    _ExtInt(160) srcPort_urgentPtr;
} tcp_t;

typedef struct
{
    _ExtInt(64) srcPort_checksum;
} udp_t;

typedef struct
{
    egressSpec_t egress_spec;
    uint16_t mcast_grp;
    uint16_t egress_rid;
} standard_metadata_t;