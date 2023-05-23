#include <stdint.h>

typedef _ExtInt(9) egressSpec_t;
typedef _ExtInt(48) macAddr_t;

typedef struct ethernet_t
{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    uint16_t  etherType;
};

typedef struct ptp_t
{
    _ExtInt(4)  transportSpecific;
    _ExtInt(4)  messageType;
    _ExtInt(4)  reserved;
    _ExtInt(4)  versionPTP;
    _ExtInt(16) messageLength;
    _ExtInt(8)  domainNumber;
    _ExtInt(8)  reserved2;
    _ExtInt(16) flags;
    _ExtInt(64) correction;
    _ExtInt(32) reserved3;
    _ExtInt(80) sourcePortIdentity;
    _ExtInt(16) sequenceId;
    _ExtInt(8)  PTPcontrol;
    _ExtInt(8)  logMessagePeriod;
    _ExtInt(80) originTimestamp;
};

typedef struct header_0_t {
    uint16_t field_0;
};

typedef struct header_1_t {
    uint16_t field_1;
};

typedef struct standard_metadata_t
{
    egressSpec_t egress_spec;
    uint16_t mcast_grp;
};