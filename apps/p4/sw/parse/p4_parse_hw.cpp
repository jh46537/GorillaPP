#include "p4_parse.h"

// #pragma primate blue Output 1 1
// void Output(standard_metadata_t &standard_metadata);
void Output(ethernet_t &eth, ptp_l_t &ptp_l, ptp_h_t &ptp_h, header_0_t &header_0, header_1_t &header_1, header_2_t &header_2, header_3_t &header_3, standard_metadata_t &standard_metadata);
// #pragma primate blue Input 1 1
void Input(const int &length, // input
	ethernet_t &eth, ptp_l_t &ptp_l, ptp_h_t &ptp_h, header_0_t &header_0, header_1_t &header_1, header_2_t &header_2, header_3_t &header_3); // outputs
#pragma primate blue Match_table0 1 1
int forward_exact(macAddr_t &dstAddr, egressSpec_t &port);

void p4_parse() {
	// Parse
	ethernet_t eth;
	ptp_l_t ptp_l;
	ptp_h_t ptp_h;
	header_0_t header_0;
	header_1_t header_1;
	header_2_t header_2;
	header_3_t header_3;
	standard_metadata_t standard_metadata;
	standard_metadata.egress_spec = 0;
	standard_metadata.mcast_grp = 0;
	Input(14, eth, ptp_l, ptp_h, header_0, header_1, header_2, header_3);
	// Ingress
	int flag;
	egressSpec_t port;
	flag = forward_exact(eth.dstAddr, port);
	if (flag == 0) {
		//ipv4 forward
		standard_metadata.egress_spec = port;
	} else {
		//default drop
		standard_metadata.egress_spec = 511;
	}
	// Output(standard_metadata);
	Output(eth, ptp_l, ptp_h, header_0, header_1, header_2, header_3, standard_metadata);
}