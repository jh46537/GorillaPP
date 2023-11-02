#include "primate.h"

void primate_main() {
    int hdr_count;
    ethernet_t eth;
    ptp_l_t ptp_l;
    ptp_h_t ptp_h;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
    header_t header_0;
    header_t header_1;
    header_t header_2;
    header_t header_3;
    header_t header_4;
    header_t header_5;
    header_t header_6;
    header_t header_7;
    standard_metadata_t standard_metadata;
    int hdr_count;

    // standard_metadata.egress_spec = 0; 
    insert(standard_metadata, SM_T_EGRESS_SPEC, 0);
    // standard_metadata.mcast_grp = 0; 
    insert(standard_metadata, SM_T_MCAST_GRP, 0);

    insert(hdr_count, SCALAR_TYPE, 0);
    eth = Input_header(14); // eth = input(14)
    if (extract(eth, SM_T_ETHERTYPE) == 0x88f7) {
        ptp_l = Input_header(20); // PTP_L_T
        ptp_h = Input_header(24); // PTP_H_T
        hdr_count = 1;
        if (extract(ptp_l, PTP_L_T_RESERVED2) == 1) {
            header_0 = Input_header(8);
            insert(hdr_count, SCALAR_TYPE, 2);
            if (extract(header_0, HEADER_T_FIELD_0) != 0) {
                header_1 = Input_header(8);
                insert(hdr_count, SCALAR_TYPE, 3);
                if (extract(header_1, HEADER_T_FIELD_0) != 0) {
                    header_2 = Input_header(8);
                    insert(hdr_count, SCALAR_TYPE, 4);
                    if (extract(header_2, HEADER_T_FIELD_0) != 0) {
                        header_3 = Input_header(8);
                        insert(hdr_count, SCALAR_TYPE, 5);
                        if (extract(header_3, HEADER_T_FIELD_0) != 0) {
                            header_4 = Input_header(8);
                            insert(hdr_count, SCALAR_TYPE, 6);
                            if (extract(header_4, HEADER_T_FIELD_0) != 0) {
                                header_5 = Input_header(8);
                                insert(hdr_count, SCALAR_TYPE, 7);
                                if (extract(header_5, HEADER_T_FIELD_0) != 0) {
                                    header_6 = Input_header(8);
                                    insert(hdr_count, SCALAR_TYPE, 8);
                                    if (extract(header_6, HEADER_T_FIELD_0) != 0) {
                                        header_7 = Input_header(8);
                                        insert(hdr_count, SCALAR_TYPE, 9);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } else if (extract(eth, SM_T_ETHERTYPE) == 0x800) {
        // struct ipv4_t
        ipv4 = Input_header(20);
        insert(hdr_count, SCALAR_TYPE, 10);
        if (extract(ipv4, IPV4_T_PROTOCOL) == 6) {
            tcp = Input_header(20);
            insert(hdr_count, SCALAR_TYPE, 11);
        } else if (extract(ipv4, IPV4_T_PROTOCOL) == 0x11) {
            udp = Input_header(8);
            insert(hdr_count, SCALAR_TYPE, 12);
        }
    }
    Input_done();

    // Ingress
    bundle_t bundle;
    bundle = forward_exact(extract(eth, ETH_T_DSTADDR));
    switch (extract(bundle, BUNDLE_T_TARGET)) {
    case 0:
        insert(standard_metadata, SM_T_EGRESS_SPEC, extract(bundle, BUNDLE_T_PORT));
        break;
    case 1:
        insert(standard_metadata, SM_T_EGRESS_SPEC, 0x1ff);
        break;
    }

    Output_meta(standard_metadata);
    Output_header(14, eth);
    if (hdr_count < 10) {
        Output_header(20, ptp_l);
        Output_header(24, ptp_h);
        if (hdr_count > 1) {
            Output_header(8, header_0);
            if (hdr_count > 2) {
                Output_header(8, header_1);
                if (hdr_count > 3) {
                    Output_header(8, header_2);
                    if (hdr_count > 4) {
                        Output_header(8, header_3);
                        if (hdr_count > 5) {
                            Output_header(8, header_4);
                            if (hdr_count > 6) {
                                Output_header(8, header_5);
                                if (hdr_count > 7) {
                                    Output_header(8, header_6);
                                    if (hdr_count > 8) {
                                        Output_header(8, header_7);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        Output_header(20, ipv4);
        if (hdr_count == 11) {
            Output_header(20, tcp);
        } else {
            Output_header(8, udp);
        }
    }
    Output_done();
}
