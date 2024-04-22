#include <stdint.h>
#include "../../common/primate-hardware.hpp"
#include "tcp_parse.h"

void primate_main() {
    ethernet_t eth;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;

    eth = PRIMATE::input<ethernet_t>();
    PRIMATE::output<ethernet_t>(eth);
    if (eth.etherType == 0x800) {
        ipv4 = PRIMATE::input<ipv4_t>();
        PRIMATE::output<ipv4_t>(ipv4);
        if (ipv4.protocol == 6) {
            tcp = PRIMATE::input<tcp_t>();
            PRIMATE::output<tcp_t>(tcp);
            if (tcp.dataOffset > 0) {
                int hdr_byte_left = 4*(((unsigned)tcp.dataOffset) - 5);
                int n = 0;
                while (hdr_byte_left > 0) {
                    unsigned _ExtInt(8) kind;
                    kind = PRIMATE::input<unsigned _ExtInt(8)>(1);
                    if (kind == 0) {
                        // end
                        hdr_byte_left--;
                        unsigned _ExtInt(8) tcp_option;
                        tcp_option = kind;
                        PRIMATE::output<unsigned _ExtInt(8)>(tcp_option);
                        int i = 0;
                        unsigned _ExtInt(128) padding;
                        while (hdr_byte_left > 16) {
                            padding = PRIMATE::input<unsigned _ExtInt(128)>();
                            PRIMATE::output<unsigned _ExtInt(128)>(padding);
                            hdr_byte_left -= 16;
                        }
                        padding = PRIMATE::input<unsigned _ExtInt(128)>(16);
                        PRIMATE::output<unsigned _ExtInt(128)>(padding);
                        break;
                    } else if (kind == 1) {
                        // nop
                        unsigned _ExtInt(8) tcp_option;
                        tcp_option = kind;
                        hdr_byte_left--;
                        PRIMATE::output<unsigned _ExtInt(8)>(tcp_option);
                    }
                    n++;
                }
            }
        } else if (ipv4.protocol == 0x11) {
            udp = PRIMATE::input<udp_t>(8);
            PRIMATE::output<udp_t>(udp);
        }
    }
    PRIMATE::input_done();
    PRIMATE::output_done();

}
