#include <stdint.h>

typedef struct {
    uint16_t sPort;
    uint16_t dPort;
    uint32_t sIP;
    uint32_t dIP;
} tuple_t;

typedef struct {
    uint8_t prot;
    _ExtInt(96) tuple;
    uint32_t seq;
    uint16_t len;
    _ExtInt(30) hdr_len_flits_empty_pktID;
    _ExtInt(9) tcp_flags;
    _ExtInt(3) pkt_flags;
    _ExtInt(58) last_7_bytes_pdu_flag;
} input_t;

typedef struct {
    uint8_t prot;
    _ExtInt(96) tuple;
    uint32_t seq;
    uint16_t len;
    _ExtInt(30) hdr_len_flits_empty_pktID;
    _ExtInt(9) tcp_flags;
    _ExtInt(3) pkt_flags;
    _ExtInt(58) last_7_bytes_pdu_flag;
} output_t;

typedef struct {
    _ExtInt(96) tuple;
    _ExtInt(32) seq;
    _ExtInt(10) pointer;
    _ExtInt(10) slow_cnt;
    _ExtInt(104) addr3_addr2_addr1_addr0_last_7_bytes;
    _ExtInt(9) pointer2;
    _ExtInt(5) ch0_bit_map;
} fce_t;

typedef struct {
    input_t meta;
    _ExtInt(9) next;
} dymem_t;