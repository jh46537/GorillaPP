#include "p4_parse_simple.h"

// #pragma primate blue Output 1 1
void Output_meta(standard_metadata_t &standard_metadata); //outputMeta inst
void Output(const int &length, ethernet_t &eth); //outputEmiti inst
void Output(const int &length, ptp_l_t &ptp_l);
void Output(const int &length, ptp_h_t &ptp_h);
void Output(const int &length, header_0_t &header_0);
void Output(const int &length, header_1_t &header_1);
void Output_done(); // outputDone inst
void Input_eth(const int &length, ethernet_t &eth); // inputExtracti inst
void Input_ptpl(const int &length, ptp_l_t &ptp);
void Input_ptph(const int &length, ptp_h_t &ptp);
void Input_h0(const int &length, header_0_t &header_0);
void Input_h1(const int &length, header_1_t &header_1);
void Input_done(); // inputDone inst
#pragma primate blue matchTable 1 1
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
	uint16_t hdr_valid = 0;
	Input_eth(14, eth);
	if (eth.etherType == 0x88f7) {
		Input_ptpl(20, ptp_l);
		Input_ptph(24, ptp_h);
		hdr_valid++;
		if (ptp_l.reserved2 == 1) {
			Input_h0(8, header_0);
			hdr_valid++;
			if (header_0.field_0 != 0) {
				Input_h1(8, header_1);
				hdr_valid++;
			}
		}
	}
	Input_done();
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
	Output_meta(standard_metadata);
	Output(14, eth);
	if (hdr_valid > 0) {
		Output(20, ptp_l);
		Output(24, ptp_h);
		if (hdr_valid > 1) {
			Output(8, header_0);
			if (hdr_valid > 2) {
				Output(8, header_1);
			}
		}
	}
	Output_done();
	// Output(eth, ptp_l, ptp_h, header_0, header_1, header_2, header_3, standard_metadata);
}
