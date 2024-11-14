#include "../../../common/primate-hardware.hpp"
#include "p4_parse_simple.h"

#pragma primate blue matchTable 1 1
forward_result_t forward_exact(forward_exact_t);

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
  eth = PRIMATE::input<ethernet_t>();
  if (eth.etherType == 0x88f7) {
    ptp_l = PRIMATE::input<ptp_l_t>();
    ptp_h = PRIMATE::input<ptp_h_t>();
    hdr_valid++;
    if (ptp_l.reserved2 == 1) {
      header_0 = PRIMATE::input<header_0_t>();
      hdr_valid++;
      if (header_0.field_0 != 0) {
	header_1 = PRIMATE::input<header_1_t>();
	hdr_valid++;
      }
    }
  }
  PRIMATE::input_done();
  // Ingress
  int flag;
  egressSpec_t port;
  flag = forward_exact({eth.dstAddr, port}).flag;
  switch(flag) {
  case 0:
    standard_metadata.egress_spec = port;
    break;
  case 1:
    standard_metadata.egress_spec = 511;
    break;
  }
  PRIMATE::output(standard_metadata);
  PRIMATE::output(eth);
  if (hdr_valid > 0) {
    PRIMATE::output(ptp_l);
    PRIMATE::output(ptp_h);
    if (hdr_valid > 1) {
      PRIMATE::output(header_0);
      if (hdr_valid > 2) {
	PRIMATE::output(header_1);
      }
    }
  }
  PRIMATE::output_done();
}
