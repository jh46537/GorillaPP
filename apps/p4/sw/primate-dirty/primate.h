
#define SM_T_EGRESS_SPEC 0
#define SM_T_MCAST_GRP 1
#define SM_T_ETHERTYPE 2
#define PTP_L_T_RESERVED2 3 
#define HEADER_T_FIELD_0 4
#define IPV4_T_PROTOCOL 5
#define ETH_T_DSTADDR 6
#define BUNDLE_T_TARGET 7
#define BUNDLE_T_PORT 8
#define SCALAR_TYPE 9

using bundle_t = int;
using ethernet_t = int;
using ptp_l_t = int;
using ptp_h_t = int;
using ipv4_t = int;
using tcp_t = int;
using udp_t = int;
using header_t = int;
using standard_metadata_t = int;

int Insert(int a, int b, int c);
int Extract(int a, int b);
int Input_header(int a);
void Input_done();
int forward_exact(int a);
void Output_meta(int a);
void Output_header(int a, int b);
void Output_done();
int init();
