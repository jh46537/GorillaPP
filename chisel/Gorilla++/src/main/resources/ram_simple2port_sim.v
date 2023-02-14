// (C) 2001-2019 Intel Corporation. All rights reserved.
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
module  ram_simple2port #(
    parameter AWIDTH = 9,
    parameter DWIDTH = 16,
    parameter DEPTH = 512
    )  (
    clock,
    data,
    rdaddress,
    rden,
    wraddress,
    wren,
    q);

    input    clock;
    input  [DWIDTH-1:0]  data;
    input  [AWIDTH-1:0]  rdaddress;
    input    rden;
    input  [AWIDTH-1:0]  wraddress;
    input    wren;
    output [DWIDTH-1:0]  q;

    reg [DWIDTH-1:0] mem [0:DEPTH-1];

    reg [DWIDTH-1:0] data_r;
    reg [AWIDTH-1:0] rdaddress_r;
    reg [AWIDTH-1:0] wraddress_r;
    reg rden_r;
    reg wren_r;
    reg [DWIDTH-1:0] q_r;

    always @(posedge clock) begin
        data_r <= data;
        rdaddress_r <= rdaddress;
        wraddress_r <= wraddress;
        rden_r <= rden;
        wren_r <= wren;
    end

    always @(posedge clock) begin
        if (wren_r) begin
            mem[wraddress_r] <= data_r;
        end
        if (rden_r) begin
            q_r <= mem[rdaddress_r];
        end
    end

    assign q = q_r;

endmodule


