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
    _ExtInt(4)  transportSpecific;
    _ExtInt(4)  messageType;
    _ExtInt(4)  reserved;
    _ExtInt(4)  versionPTP;
    uint16_t    messageLength;
    uint8_t     domainNumber;
    uint8_t     reserved2;
    uint16_t    flags;
    uint64_t    correction;
    uint32_t    reserved3;
} ptp_l_t;

typedef struct
{
    _ExtInt(80) sourcePortIdentity;
    uint16_t    sequenceId;
    uint8_t     PTPcontrol;
    uint8_t     logMessagePeriod;
    _ExtInt(80) originTimestamp;
} ptp_h_t;

typedef struct
{
    uint16_t field_0;
    uint16_t field_1;
    uint16_t field_2;
    uint16_t field_3;
} header_0_t;

typedef struct
{
    uint16_t field_0;
    uint16_t field_1;
    uint16_t field_2;
    uint16_t field_3;
} header_1_t;

typedef struct
{
    uint16_t field_0;
    uint16_t field_1;
    uint16_t field_2;
    uint16_t field_3;
} header_2_t;

typedef struct
{
    uint16_t field_0;
    uint16_t field_1;
    uint16_t field_2;
    uint16_t field_3;
} header_3_t;

typedef struct
{
    egressSpec_t egress_spec;
    uint16_t mcast_grp;
} standard_metadata_t;