#include "p4_pipeline.h"

#define NUM_TABLE 16

// #pragma primate blue Output 1 1
// void Output(standard_metadata_t &standard_metadata);
void Output_meta(standard_metadata_t &standard_metadata);
void Output(const int &length, ethernet_t &eth);
void Output(const int &length, ipv4_t &ipv4);
void Output(const int &length, tcp_t &tcp);
void Output(const int &length, udp_t &udp);
void Output_done();
void Input_eth(const int &length, ethernet_t &eth);
void Input_ipv4(const int &length, ipv4_t &ptp);
void Input_tcp(const int &length, tcp_t &tcp);
void Input_udp(const int &length, udp_t &udp);
void Input_done();
#pragma primate blue Match_table0 1 1
int forward_exact(const int &table_id, macAddr_t &dstAddr, egressSpec_t &port);

void p4_pipeline() {
	// Parse
	ethernet_t eth;
	ipv4_t ipv4;
	tcp_t tcp;
	udp_t udp;
	standard_metadata_t standard_metadata;
	// standard_metadata.egress_rid = 5;
	standard_metadata.egress_spec = 0;
	standard_metadata.mcast_grp = 0;
	uint16_t hdr_valid = 0;
	Input_eth(14, eth);
	if (eth.etherType == 0x800) {
		Input_ipv4(20, ipv4);
		hdr_valid = 1;
		if (ipv4.protocol == 6) {
			Input_tcp(20, tcp);
			hdr_valid = 2;
		} else if (ipv4.protocol == 0x11) {
			Input_udp(8, udp);
			hdr_valid = 3;
		}
	}
	// Ingress
	int flag;
	egressSpec_t port;
	flag = forward_exact(0, eth.dstAddr, port);
	if (flag == 0) {
		//ipv4 forward
		standard_metadata.egress_spec = port;
	} else {
		//default drop
		standard_metadata.egress_spec = 511;
	}
#if NUM_TABLE > 1
	flag = forward_exact(1, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(2, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(3, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(4, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(5, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(6, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(7, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
#endif
#if NUM_TABLE > 8
	flag = forward_exact(8, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(9, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(10, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(11, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(12, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(13, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(14, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(15, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
#endif
#if NUM_TABLE > 16
	flag = forward_exact(16, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(17, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(18, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(19, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(20, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(21, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(22, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(23, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
#endif
#if NUM_TABLE > 24
	flag = forward_exact(24, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(25, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(26, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(27, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(28, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(29, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(30, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
	flag = forward_exact(31, eth.dstAddr, port);
	if (flag == 0) standard_metadata.egress_spec = port;
#endif


	// Output(standard_metadata);
	Output_meta(standard_metadata);
	Output(14, eth);
	if (hdr_valid > 0) {
		Output(20, ipv4);
		if (hdr_valid == 2) {
			Output(20, tcp);
		} else if (hdr_valid == 3) {
			Output(8, udp);
		}
	}

	Output_done();
}
