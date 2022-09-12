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

#pragma primate blue output 1 1
void Output(output_t *output);
#pragma primate blue flow_table_read 5 1
int flow_table_read(input_t *meta, fce_t *fte);
#pragma primate blue flow_table_write 5 2
void flow_table_write(int op, fce_t *fte);
#pragma primate blue dymem 4 1
void dymem_lookup(_ExtInt(9) *ptr, dymem_t *pkt);
#pragma primate blue dymem 1 1
void dymem_new(input_t *input, _ExtInt(9) *ptr);
#pragma primate blue dymem 1 2
void dymem_update(_ExtInt(9) *ptr, _ExtInt(9) *next_ptr);


void pkt_reassembly(input_t input) {
    fce_t fte;
    int flag;
    flag = flow_table_read(&input, &fte);
    if (flag == 0) {
        // fast path
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
            flow_table_write(DELETE, &fte);
        } else {
            fte.seq = pkt.meta.seq + pkt.meta.len;
            flow_table_write(UPDATE, &fte);
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
                dymem_update(&(fte.pointer2), &new_node_ptr);
                flow_table_write(UPDATE, &fte);
            } else if (input.seq + input.len < head.meta.seq) {
                dymem_update(&new_node_ptr, (_ExtInt(9)*)&(fte.pointer)); //new_node_ptr -> next = fte.pointer
                fte.pointer = new_node_ptr;
                fte.slow_cnt ++;
                flow_table_write(UPDATE, &fte);
            } else {
    INSERT_LOOP:
                if (input.seq < head.meta.seq + head.meta.len) {
                    //overlap packet, drop
                    input.pkt_flags = PKT_DROP;
                    Output((output_t*)(&input));
                    return;
                } else {
                    dymem_t next_node;
                    dymem_lookup(&(head.next), &next_node);
                    if ((--slow_cnt) == 0) {
                        // insert to tail
                        fte.pointer2 = new_node_ptr;
                        fte.slow_cnt ++;
                        dymem_update(&node_ptr, &new_node_ptr);
                        flow_table_write(UPDATE, &fte);
                    } else if (input.seq + input.len > next_node.meta.seq) {
                        node_ptr = head.next;
                        head = next_node;
                        goto INSERT_LOOP;
                    } else {
                        // insert
                        fte.slow_cnt ++;
                        flow_table_write(UPDATE, &fte);
                        dymem_update(&node_ptr, &new_node_ptr);
                        dymem_update(&new_node_ptr, &(head.next));
                    }
                }
            }
        }
        return;
}

