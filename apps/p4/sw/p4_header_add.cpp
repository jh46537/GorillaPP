#include "p4_header_add.h"
#include "../../common/primate-hardware.h"

#pragma primate blue Match_table0 1 1
int forward_exact(forward_data_t);

void p4_header_add() {
  //Parse
  ethernet_t eth;
  ptp_t ptp;
  header_0_t header_0;
  header_1_t header_1;
  standard_metadata_t standard_metadata;
  standard_metadata.egress_spec = 0;
  standard_metadata.mcast_grp = 0;
  eth = PRIMATE::input<ethernet_t>();
  if (eth.etherType == 0x88f7) {
    ptp = PRIMATE::input<ptp_t>(ptp);
    if (ptp.reserved2 == 1) {
      header_0 = PRIMATE::input<header_0_t>();
      if (header_0.field_0 != 0) {
	header_1 = PRIMATE::input<header_1_t>(header_1);
      }
    }
  }
  int flag;
  egressSpec_t port;
  flag = forward_exact({eth.dstAddr, port});
  switch (flag) {
  case 0:
    standard_metadata.egress_spec = port;
    break;
  case 1:
    standard_metadata.egress_spec = 511;
    break;
  }
  ptp.reserved2 = 1;
  PRIMATE::output<ethernet_t>(eth);
  PRIMATE::output<ptp_t>(ptp);
  PRIMATE::output<header_0_t>(header_0);
  PRIMATE::output<header_1_t>(header_1);
  PRIMATE::output<standard_metadata_1>(standard_metadata);
}
