#include <p4_header_add.h>

#pragma primate blue Output 1 1
void Output(ethernet_t &eth, ptp_t &ptp, header_0_t &header_0, header_1_t &header_1, standard_metadata_t &standard_metadata);
#pragma primate blue Input 1 1
void Input(ethernet_t &input);
#pragma primate blue Input 1 1
void Input(ptp_t &input);
#pragma primate blue Input 1 1
void Input(header_0_t &input);
#pragma primate blue Input 1 1
void Input(header_1_t &input);
#pragma primate blue Match_table0 1 1
int forward_exact(macAddr_t &dstAddr, egressSpec_t &port);

void p4_header_add() {
    //Parse
    ethernet_t eth;
    ptp_t ptp;
    header_0_t header_0;
    header_1_t header_1;
    standard_metadata_t standard_metadata;
    standard_metadata.egress_spec = 0;
    standard_metadata.mcast_grp = 0;
    Input(eth);
    if (eth.etherType == 0x88f7) {
        Input(ptp);
        if (ptp.reserved2 == 1) {
            Input(header_0);
            if (header_0.field_0 != 0) {
                Input(header_1);
            }
        }
    }
    int flag;
    egressSpec_t port;
    flag = forward_exact(eth.dstAddr, port);
    if (flag == 0) {
        standard_metadata.egress_spec = port;
    } else {
        standard_metadata.egress_spec = 511;
    }
    ptp.reserved2 = 1;
    Output(eth, ptp, header_0, header_1, standard_metadata);
}