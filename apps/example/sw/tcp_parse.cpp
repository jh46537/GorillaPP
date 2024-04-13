#include "tcp_parse.h"

// #pragma primate blue Output 1 1
// void Output(standard_metadata_t &standard_metadata);
void Output_meta(standard_metadata_t &standard_metadata); //outputMeta inst
#pragma primate blue Output 1 1
void Output(const int &length, ethernet_t &eth);
void Output(const int &length, ipv4_t &ipv4);
void Output(const int &length, tcp_t &tcp);
void Output(const int &length, udp_t &udp);
void Output(const int &length, tcp_option_t &tcp_option);
void Output(const int &length, padding_t &padding);
void Output_done();
void Input_eth(const int &length, ethernet_t &eth);
void Input_ipv4(const int &length, ipv4_t &ipv4);
void Input_tcp(const int &length, tcp_t &tcp);
void Input_udp(const int &length, udp_t &udp);
void Input_tcp_option(const int &length, tcp_option_t &tcp_option);
void Input_padding(const int &length, padding_t &padding);
void Input_done();

void p4_parse() {
    // Parse
    ethernet_t eth;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
    tcp_option_t tcp_option;
    padding_t padding;

    uint16_t hdr_valid = 0;
    Input_eth(14, eth);
    Output(14, eth);
    if (eth.etherType == 0x800) {
        Input_ipv4(20, ipv4);
        Output(20, ipv4);
        if (ipv4.protocol == 6) {
            Input_tcp(20, tcp);
            Output(20, tcp);
            if (tcp.dataOffset > 0) {
                int hdr_byte_left = 4*(((int)tcp.dataOffset) - 5);
                while (hdr_byte_left > 0) {
                    Input_tcp_option(1, tcp_option);
                    if (tcp_option.kind == 0) {
                        // end
                        hdr_byte_left--;
                        Output(1, tcp_option);
                        while (hdr_byte_left > 32) {
                            Input_padding(32, padding);
                            Output(32, padding);
                            hdr_byte_left -= 32;
                        }
                        Input_padding(hdr_byte_left, padding);
                        Output(32, padding);
                        break;
                    } else if (tcp_option.kind == 1) {
                        hdr_byte_left--;
                        Output(1, tcp_option);
                    }
                }
            }
        } else if (ipv4.protocol == 0x11) {
            Input_udp(8, udp);
            Output(8, udp);
        }
    }

}
