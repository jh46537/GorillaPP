#! /usr/bin/env python3
import sys
import itertools

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

def main():
    num_packets = 1024
    input_width = 512
    hex_digits = (input_width + 3)/4

    eth_w = [48, 48, 16]
    ptp_w = [4, 4, 4, 4, 16, 8, 8, 16, 64, 32, 80, 16, 8, 8, 80]
    ##################################
    # Parsing
    header_0_w = [16, 16, 16, 16]   # uncomment for parsing
    headers_w = [eth_w, ptp_w, header_0_w]  # 1 header
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w]  # 2 headers
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w, header_0_w, header_0_w]  # 4 headers
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w]  # 6 headers
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w, header_0_w]  # 8 headers
    ##################################
    # Action
    # header_0_w = [16, 16, 16, 16, 16, 16, 16, 16]   # uncomment for action
    # headers_w = [eth_w, ptp_w, header_0_w]  # 1 or 8 action
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w]  # 16 action
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w, header_0_w]  # 24 action
    # headers_w = [eth_w, ptp_w, header_0_w, header_0_w, header_0_w, header_0_w]  # 32 action
    ##################################
    # Pipeline
    # ipv4_w = [4, 4, 8, 16, 16, 3, 13, 8, 8, 16, 32, 32]   # uncomment for Pipeline
    # tcp_w = [16, 16, 32, 32, 4, 3, 3, 6, 16, 16, 16]   # uncomment for Pipeline
    # udp_w = [16, 16, 16, 16]   # uncomment for Pipeline
    # headers_w = [eth_w, ipv4_w, tcp_w]   # uncomment for Pipeline
    ##################################


    ptp_val = [0, 0, 0, 1, 8, 0, 1, 0, 0xcafe, 0, 0, 0xbeef, 0, 0, 0xaaaa]
    ##################################
    # Parsing
    eth_val = [0xdead, 0xbeef, 0x88f7]   # uncomment for parsing
    header_0_val = [1, 2, 3, 4]   # uncomment for parsing
    header_end_val = [0, 2, 3, 4]   # uncomment for parsing
    headers_val = [eth_val, ptp_val, header_end_val]  # 1 header
    # headers_val = [eth_val, ptp_val, header_0_val, header_end_val]  # 2 headers
    # headers_val = [eth_val, ptp_val, header_0_val, header_0_val, header_0_val, header_end_val]  # 4 headers
    # headers_val = [eth_val, ptp_val, header_0_val, header_0_val, header_0_val, header_0_val, header_0_val, header_end_val]  # 6 headers
    # headers_val = [eth_val, ptp_val, header_0_val, header_0_val, header_0_val, header_0_val, header_0_val, header_0_val, header_0_val, header_end_val]  # 8 headers
    ##################################
    # Action
    # eth_val = [0xdead, 0xbeef, 0x88f7]   # uncomment for action
    # header_0_val = [1, 2, 3, 4, 5, 6, 7, 8]   # uncomment for action
    # header_end_val = [0, 2, 3, 4, 5, 6, 7, 8]   # uncomment for action
    # headers_val = [eth_val, ptp_val, header_end_val]  # 1 or 8 action
    # headers_val = [eth_val, ptp_val, header_0_val, header_end_val]  # 16 action
    # headers_val = [eth_val, ptp_val, header_0_val, header_0_val, header_end_val]  # 24 action
    # headers_val = [eth_val, ptp_val, header_0_val, header_0_val, header_0_val, header_end_val]  # 32 action
    ##################################
    # Pipeline
    # eth_val = [0xdead, 0xbeef, 0x800]   # uncomment for Pipeline
    # ipv4_val = [1, 0, 0, 384, 8, 7, 10, 1, 6, 0, 0xbb, 0xcc]   # uncomment for Pipeline
    # tcp_val = [1, 2, 256, 128, 0, 0, 0, 5, 15, 0xabc, 0]   # uncomment for Pipeline
    # headers_val = [eth_val, ipv4_val, tcp_val]   # uncomment for Pipeline

    f = open("input.txt", "w")

    for i in range(num_packets):
        width = 0
        result = 0
        for (hdr_w, hdr_val) in zip(headers_w, headers_val):
            for (w, val) in zip(hdr_w, hdr_val):
                if width + w <= input_width:
                    result += (val << width)
                    if width + w == input_width:
                        f.write("0 0 " + f"{result:x}" + "\n")
                        result = 0
                        width = 0
                    else:
                        width += w
                else:
                    w_rem = input_width - width
                    val_rem = val & ((1 << w_rem) - 1)
                    result += (val_rem << width)
                    f.write("0 0 " + f"{result:x}" + "\n")
                    new_width = w - w_rem
                    if new_width >= input_width:
                        sys.exit("Field width too large")
                    result = (val >> w_rem)
                    width = new_width
        if width > 0:
            f.write("0 0 " + f"{result:x}" + "\n")
        dummy_line = fill_dummy(input_width)
        # f.write("0 0 " + dummy_line + "\n")   # uncomment for Pipeline
        f.write("0 0 " + dummy_line + "\n")
        f.write("1 0 " + dummy_line + "\n")

    f.close()

if __name__=='__main__':
    main()
