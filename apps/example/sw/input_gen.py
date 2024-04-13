#! /usr/bin/env python3
import sys
import itertools

input_width = 512
hex_digits = (input_width + 3)/4

def fill_dummy(data_width):
    width = 0
    line = ""
    i = 0
    while (width < data_width):
        hex_digits = 8 if (data_width - width) >= 32 else ((data_width - width + 3)/4)
        line = f"{i:0{hex_digits}x}" + line
        width += 32
        i += 1
    return line

def gen_packet(f, pkt_type, num_pkt):
    num_nops = 31

    eth_w = [48, 48, 16]
    ##################################
    ipv4_w = [4, 4, 8, 16, 16, 3, 13, 8, 8, 16, 32, 32]   # uncomment for Pipeline
    tcp_w = [16, 16, 32, 32, 4, 3, 3, 6, 16, 16, 16]   # uncomment for Pipeline
    udp_w = [16, 16, 16, 16]   # uncomment for Pipeline
    tcp_option_w = []
    for i in range(num_nops+1):
        tcp_option_w.append(8)

    if (pkt_type == "tcp"):
        headers_w = [eth_w, ipv4_w, tcp_w]
    elif (pkt_type == "udp"):
        headers_w = [eth_w, ipv4_w, udp_w]
    elif (pkt_type == "tcp_option"):
        headers_w = [eth_w, ipv4_w, tcp_w, tcp_option_w]
    ##################################
    # Pipeline
    eth_val = [0xdead, 0xbeef, 0x800]   # uncomment for Pipeline
    ipv4_val = [1, 0, 0, 384, 8, 7, 10, 1, 6, 0, 0xbb, 0xcc]   # uncomment for Pipeline tcp
    ipv4_val2 = [1, 0, 0, 384, 8, 7, 10, 1, 0x11, 0, 0xbb, 0xcc]   # uncomment for Pipeline tcp
    udp_val = [0xaaa, 0xbbb, 0xccc, 0xddd]
    tcp_val = [1, 2, 256, 128, 0, 0, 0, 5, 15, 0xabc, 0]   # uncomment for Pipeline
    tcp_val2 = [1, 2, 256, 128, 15, 0, 0, 5, 15, 0xabc, 0]   # uncomment for Pipeline
    tcp_option_val = []
    for i in range(num_nops):
        tcp_option_val.append(1)
    tcp_option_val.append(0)
    if (pkt_type == "tcp"):
        headers_val = [eth_val, ipv4_val, tcp_val]
    elif (pkt_type == "udp"):
        headers_val = [eth_val, ipv4_val2, udp_val]
    elif (pkt_type == "tcp_option"):
        headers_val = [eth_val, ipv4_val, tcp_val2, tcp_option_val]

    for i in range(num_pkt):
        width = 0
        result = 0
        for (hdr_w, hdr_val) in zip(headers_w, headers_val):
            for (w, val) in zip(hdr_w, hdr_val):
                if width + w <= input_width:
                    result += (val << width)
                    if width + w == input_width:
                        f.write("0 0 " + f"{result:0{128}x}" + "\n")
                        result = 0
                        width = 0
                    else:
                        width += w
                else:
                    w_rem = input_width - width
                    val_rem = val & ((1 << w_rem) - 1)
                    result += (val_rem << width)
                    f.write("0 0 " + f"{result:0{128}x}" + "\n")
                    new_width = w - w_rem
                    if new_width >= input_width:
                        sys.exit("Field width too large")
                    result = (val >> w_rem)
                    width = new_width
        if width > 0:
            f.write("0 0 " + f"{result:0{128}x}" + "\n")
        dummy_line = fill_dummy(input_width)
        # f.write("0 0 " + dummy_line + "\n")   # uncomment for Pipeline
        if pkt_type != "tcp_option" or num_nops < 10:
            f.write("0 0 " + dummy_line + "\n")
        f.write("1 0 " + dummy_line + "\n")

def main():
    num_udp = 128
    num_tcp = 320
    num_tcp_option = 128

    f = open("input.txt", "w")

    gen_packet(f, "udp", num_udp)
    gen_packet(f, "tcp", num_tcp)
    gen_packet(f, "tcp_option", num_tcp_option)

    f.close()

if __name__=='__main__':
    main()
