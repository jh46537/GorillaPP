
#define SM_T_EGRESS_SPEC 0
#define SM_T_MCAST_GRP 1
#define SM_T_ETHERTYPE 2
#define PTP_L_T_RESERVED2 2 
#define HEADER_T_FIELD_0 0
#define IPV4_T_PROTOCOL 0 
#define ETH_T_DSTADDR 0
#define BUNDLE_T_TARGET 0
#define BUNDLE_T_PORT 1
#define SCALAR_TYPE 0

using bundle_t = int;
using ethernet_t = int;
using ptp_l_t = int;
using ptp_h_t = int;
using ipv4_t = int;
using tcp_t = int;
using udp_t = int;
using header_t = int;
using standard_metadata_t = int;

void insert(int a, int b, int c);
int extract(int a, int b);
int Input_header(int a);
void Input_done();
int forward_exact(int a);
int Output_meta(int a);
int Output_header(int a, int b);
void Output_done();