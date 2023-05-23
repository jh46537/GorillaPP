#include "p4_parse.h"

#pragma primate blue Output 1 6
void Output(ethernet_t &eth, ptp_t &ptp, headers_0_t &headers_0, headers_1_t &headers_1, headers_2_t &headers_2, headers_3_t &headers_3, standard_metadata_t &standard_metadata);
#pragma primate blue Input 1 0
void Input(ethernet_t &eth, ptp_t &ptp, headers_0_t &headers_0, headers_1_t &headers_1, headers_2_t &headers_2, headers_3_t &headers_3);
#pragma primate blue Match_table0 1 1
int Ipv4_exact(ip4Addr_t &dstAddr, egressSpec_t &port);

void p4_parse() {
	// Parse
	ethernet_t eth;
	ptp_t ptp;
	headers_0_t headers_0;
	headers_1_t headers_1;
	headers_2_t headers_2;
	headers_3_t headers_3;
	standard_metadata_t standard_metadata;
	standard_metadata.egress_spec = 0;
	standard_metadata.mcast_grp = 0;
	Input(eth, ptp, headers_0, headers_1, headers_2, headers_3);
	// Ingress
	int flag;
	egressSpec_t port;
	flag = Ipv4_exact(eth.dstAddr, port);
	if (flag == 0) {
		//ipv4 forward
		standard_metadata.egress_spec = port;
	} else {
		//default drop
		standard_metadata.egress_spec = 511;
	}
	Output(eth, ptp, headers_0, headers_1, headers_2, headers_3, standard_metadata);
}