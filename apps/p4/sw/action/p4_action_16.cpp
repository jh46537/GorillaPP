#include "p4_action.h"

#define NUM_ACTION 32

// #pragma primate blue Output 1 1
// void Output(standard_metadata_t &standard_metadata);
void Output_meta(standard_metadata_t &standard_metadata);
void Output(ethernet_t &eth);
void Output(ptp_l_t &ptp_l);
void Output(ptp_h_t &ptp_h);
void Output(header_0_t &header_0);
void Output_done();
void Input_eth(const int &length, ethernet_t &eth);
void Input_ptpl(const int &length, ptp_l_t &ptp);
void Input_ptph(const int &length, ptp_h_t &ptp);
void Input_h0(const int &length, header_0_t &header_0);
void Input_done();
#pragma primate blue Match_table0 1 1
int forward_exact(macAddr_t &dstAddr, egressSpec_t &port);

void p4_parse() {
	// Parse
	ethernet_t eth;
	ptp_l_t ptp_l;
	ptp_h_t ptp_h;
	header_0_t header_0;
	header_0_t header_1;
	standard_metadata_t standard_metadata;
	// standard_metadata.egress_rid = 5;
	standard_metadata.egress_spec = 0;
	standard_metadata.mcast_grp = 0;
	uint16_t hdr_valid = 0;
	Input_eth(14, eth);
	if (eth.etherType == 0x88f7) {
		Input_ptpl(20, ptp_l);
		Input_ptph(24, ptp_h);
		hdr_valid++;
		if (ptp_l.reserved2 == 1) {
			Input_h0(16, header_0);
			Input_h0(16, header_1);
			hdr_valid++;
		}
	}
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
	header_0.field_0 = 1;
#if NUM_ACTION > 1
	header_0.field_1 = header_0.field_0;
	header_0.field_1 -= 3;
	header_0.field_1 += 3 - (standard_metadata.egress_rid - 3);
	header_0.field_2 = header_0.field_1;
	header_0.field_2 *= 2;
	header_0.field_2 += 2*(standard_metadata.egress_rid*2);
	header_0.field_3 = header_0.field_2;
#endif
#if NUM_ACTION > 8
	header_0.field_3 += 6;
	header_0.field_3 += 6 + (standard_metadata.egress_rid + 6);
	header_0.field_4 = header_0.field_3;
	header_0.field_4 += 7;
	header_0.field_4 += 7 - (standard_metadata.egress_rid - 7);
	header_0.field_5 = header_0.field_4;
	header_0.field_5 -= 9;
	header_0.field_5 += 2*(standard_metadata.egress_rid*2);
#endif
#if NUM_ACTION > 16
	header_0.field_6 = header_0.field_5;
	header_0.field_6 = header_0.field_6;
	header_0.field_6 += 1 + (standard_metadata.egress_rid + 1);
	header_0.field_7 = header_0.field_6;
	header_0.field_7 += 3;
	header_0.field_7 += 3 - (standard_metadata.egress_rid - 3);
	header_1.field_0 = header_0.field_7;
	header_1.field_0 += 5;
#endif
#if NUM_ACTION > 24
	header_1.field_0 += 2*(standard_metadata.egress_rid*2);
	header_1.field_1 = header_1.field_0;
	header_1.field_1 -= 6;
	header_1.field_1 += 6 + (standard_metadata.egress_rid + 6);
	header_1.field_2 = header_1.field_1;
	header_1.field_2 *= 2;
	header_1.field_2 += 7 - (standard_metadata.egress_rid - 7);
	header_1.field_3 *= 2;
#endif

	// Output(standard_metadata);
	Output_meta(standard_metadata);
	if (hdr_valid < 1) {
		Output(eth);
	}
	if (hdr_valid < 2) {
		Output(ptp_l);
		Output(ptp_h);
	}
	if (hdr_valid < 3) {
		Output(header_0);
	}
	Output_done();
}
