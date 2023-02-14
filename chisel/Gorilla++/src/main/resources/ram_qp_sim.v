// (C) 2001-2020 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
// synopsys translate_on
module  ram_qp #(
    parameter AWIDTH = 9,
    parameter DWIDTH = 16,
    parameter DEPTH = 512
    )  (
    clock,
    data_a,
    data_b,
    read_address_a,
    read_address_b,
    wren_a,
    wren_b,
    write_address_a,
    write_address_b,
    q_a,
    q_b);

    input    clock;
    input  [DWIDTH-1:0]  data_a;
    input  [DWIDTH-1:0]  data_b;
    input  [AWIDTH-1:0]  read_address_a;
    input  [AWIDTH-1:0]  read_address_b;
    input    wren_a;
    input    wren_b;
    input  [AWIDTH-1:0]  write_address_a;
    input  [AWIDTH-1:0]  write_address_b;
    output [DWIDTH-1:0]  q_a;
    output [DWIDTH-1:0]  q_b;

    reg [DWIDTH-1:0] mem [0:DEPTH-1];

    reg wren_a_r;
    reg wren_b_r;
    reg [DWIDTH-1:0] data_a_r;
    reg [DWIDTH-1:0] data_b_r;
    reg [DWIDTH-1:0] q_a_r;
    reg [DWIDTH-1:0] q_b_r;
    reg [AWIDTH-1:0] read_address_a_r;
    reg [AWIDTH-1:0] read_address_b_r;
    reg [AWIDTH-1:0] write_address_a_r;
    reg [AWIDTH-1:0] write_address_b_r;


    always @(posedge clock) begin
        wren_a_r <= wren_a;
        wren_b_r <= wren_b;
        data_a_r <= data_a;
        data_b_r <= data_b;
        read_address_a_r <= read_address_a;
        read_address_b_r <= read_address_b;
        write_address_a_r <= write_address_a;
        write_address_b_r <= write_address_b;
    end

    always @(posedge clock) begin
        if (wren_a_r) begin
            mem[write_address_a_r] <= data_a_r;
        end
        if (wren_b_r) begin
            mem[write_address_b_r] <= data_b_r;
        end
    end

    always @(posedge clock) begin
        q_a_r <= mem[read_address_a_r];
        q_b_r <= mem[read_address_b_r];
    end

    assign q_a = q_a_r;
    assign q_b = q_b_r;

endmodule


