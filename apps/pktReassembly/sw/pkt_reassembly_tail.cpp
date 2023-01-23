#include "pkt_reassembly.h"
#define TCP_FIN 0
#define TCP_SYN 1
#define TCP_RST 2
#define TCP_FACK 4
#define PROT_UDP 0x11
#define PKT_FORWARD 0
#define PKT_DROP 1
#define PKT_CHECK 2
#define INSERT 1
#define UPDATE 2
#define DELETE 3

#pragma primate blue Output 1 1
void Output(output_t *output);
#pragma primate blue flowTable_ch0 5 1
int flow_table_read(input_t *meta, fce_t *fte);
#pragma primate blue flowTable_ch0 5 1
void flow_table_unlock(input_t *meta);
#pragma primate blue flowTable_ch1 5 1
void flow_table_delete(fce_t *fte);
#pragma primate blue flowTable_ch1 5 1
void flow_table_update(fce_t *fte);
#pragma primate blue dynamicMem_io 4 1
void dymem_lookup(_ExtInt(9) *ptr, dymem_t *pkt);
#pragma primate blue dynamicMem_io 1 1
void dymem_new(input_t *input, _ExtInt(9) *ptr);
#pragma primate blue dynamicMem_io 1 1
void dymem_update(_ExtInt(18) &ptr_next_ptr);


void pkt_reassembly(input_t input) {
    fce_t fte;
    int flag;
    flag = flow_table_read(&input, &fte);
    if (flag == 0) {
        // fast path
        flow_table_unlock(&input);
        Output((output_t*)(&input));
        return;
    } else if (flag == 1) {
        //release packet
        goto RELEASE;
    } else {
        goto INSERT_PKT;
    }

    RELEASE: 
        dymem_t pkt;
        pkt.meta = input;
        dymem_t pkt_next;
    RELEASE_LOOP:
        Output((output_t*)(&input));
        dymem_lookup((_ExtInt(9)*)&(fte.pointer), &pkt_next);
        if (pkt.meta.seq + pkt.meta.len == pkt_next.meta.seq) {
            fte.pointer = pkt_next.next;
            Output((output_t*)(&(pkt.meta)));
            pkt = pkt_next;
            if ((--fte.slow_cnt) > 0)
                goto RELEASE_LOOP;
        }
        // update FT
        if (input.tcp_flags & (1 << TCP_FIN) | (input.tcp_flags & (1 << TCP_RST))) {
            flow_table_unlock(&input);
            flow_table_delete(&fte);
        } else {
            fte.seq = pkt.meta.seq + pkt.meta.len;
            flow_table_unlock(&input);
            flow_table_update(&fte);
        }
        Output((output_t*)(&(pkt.meta)));
        return;

    INSERT_PKT:
        _ExtInt(9) new_node_ptr;
        dymem_new(&input, &new_node_ptr);
        int slow_cnt = fte.slow_cnt;
        dymem_t head;
        dymem_t tail;
        dymem_lookup((_ExtInt(9)*)&(fte.pointer), &head); // lookup tail
        dymem_lookup(&(fte.pointer2), &tail); // lookup tail
        _ExtInt(9) node_ptr = fte.pointer;
        if (slow_cnt != 0) {
            if (input.seq > tail.meta.seq + tail.meta.len) {
                fte.pointer2 = new_node_ptr;
                fte.slow_cnt ++;
                _ExtInt(18) ptr_new_ptr = ((_ExtInt(18))fte.pointer2 << 9) + (_ExtInt(18))new_node_ptr;
                dymem_update(ptr_new_ptr);
                flow_table_update(&fte);
            } else if (input.seq + input.len < head.meta.seq) {
                _ExtInt(18) ptr_new_ptr = ((_ExtInt(18))new_node_ptr << 9) + (_ExtInt(18))(fte.pointer);  //new_node_ptr -> next = fte.pointer
                dymem_update(ptr_new_ptr);
                fte.pointer = new_node_ptr;
                fte.slow_cnt ++;
                flow_table_update(&fte);
            } else {
    INSERT_LOOP:
                if (input.seq < head.meta.seq + head.meta.len) {
                    //overlap packet, drop
                    input.pkt_flags = PKT_DROP;
                    flow_table_unlock(&input);
                    Output((output_t*)(&input));
                    return;
                } else {
                    dymem_t next_node;
                    dymem_lookup(&(head.next), &next_node);
                    if ((--slow_cnt) == 0) {
                        // insert to tail
                        fte.pointer2 = new_node_ptr;
                        fte.slow_cnt ++;
                        _ExtInt(18) ptr_new_ptr = ((_ExtInt(18))node_ptr << 9) + (_ExtInt(18))new_node_ptr;
                        dymem_update(ptr_new_ptr);
                        flow_table_update(&fte);
                    } else if (input.seq + input.len > next_node.meta.seq) {
                        node_ptr = head.next;
                        head = next_node;
                        goto INSERT_LOOP;
                    } else {
                        // insert
                        fte.slow_cnt ++;
                        flow_table_update(&fte);
                        _ExtInt(18) ptr_new_ptr0 = ((_ExtInt(18))node_ptr << 9) + (_ExtInt(18))new_node_ptr;
                        dymem_update(ptr_new_ptr0);
                        _ExtInt(18) ptr_new_ptr1 = ((_ExtInt(18))new_node_ptr << 9) + (_ExtInt(18))head.next;
                        dymem_update(ptr_new_ptr1);
                    }
                }
            }
        }
        flow_table_unlock(&input);
        return;
}

