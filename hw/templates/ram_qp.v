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
`timescale 1 ps / 1 ps
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
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
    tri1     clock;
    tri0     wren_a;
    tri0     wren_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

    wire [DWIDTH-1:0] sub_wire0;
    wire [DWIDTH-1:0] sub_wire1;
    wire [DWIDTH-1:0] q_a = sub_wire0[DWIDTH-1:0];
    wire [DWIDTH-1:0] q_b = sub_wire1[DWIDTH-1:0];

    altera_syncram  altera_syncram_component (
                .address2_a (read_address_a),
                .address2_b (read_address_b),
                .address_a (write_address_a),
                .address_b (write_address_b),
                .clock0 (clock),
                .data_a (data_a),
                .data_b (data_b),
                .wren_a (wren_a),
                .wren_b (wren_b),
                .q_a (sub_wire0),
                .q_b (sub_wire1),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus (),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .sclr (1'b0));
    defparam
        altera_syncram_component.address_aclr_a  = "NONE",
        altera_syncram_component.address_aclr_b  = "NONE",
        altera_syncram_component.address_reg_b  = "CLOCK0",
        altera_syncram_component.clock_enable_input_a  = "BYPASS",
        altera_syncram_component.clock_enable_input_b  = "BYPASS",
        altera_syncram_component.clock_enable_output_a  = "BYPASS",
        altera_syncram_component.clock_enable_output_b  = "BYPASS",
        altera_syncram_component.indata_reg_b  = "CLOCK0",
        altera_syncram_component.intended_device_family  = "Stratix 10",
        altera_syncram_component.lpm_type  = "altera_syncram",
        altera_syncram_component.numwords_a  = DEPTH,
        altera_syncram_component.numwords_b  = DEPTH,
        altera_syncram_component.operation_mode  = "QUAD_PORT",
        altera_syncram_component.outdata_aclr_a  = "NONE",
        altera_syncram_component.outdata_sclr_a  = "NONE",
        altera_syncram_component.outdata_aclr_b  = "NONE",
        altera_syncram_component.outdata_sclr_b  = "NONE",
        altera_syncram_component.outdata_reg_a  = "CLOCK0",
        altera_syncram_component.outdata_reg_b  = "CLOCK0",
        altera_syncram_component.power_up_uninitialized  = "FALSE",
        altera_syncram_component.ram_block_type  = "M20K",
        altera_syncram_component.enable_force_to_zero  = "FALSE",
        altera_syncram_component.read_during_write_mode_port_a  = "DONT_CARE",
        altera_syncram_component.read_during_write_mode_port_b  = "DONT_CARE",
        altera_syncram_component.read_during_write_mode_mixed_ports  = "NEW_A_OLD_B",
        altera_syncram_component.widthad_a  = AWIDTH,
        altera_syncram_component.widthad_b  = AWIDTH,
        altera_syncram_component.widthad2_a  = AWIDTH,
        altera_syncram_component.widthad2_b  = AWIDTH,
        altera_syncram_component.width_a  = DWIDTH,
        altera_syncram_component.width_b  = DWIDTH,
        altera_syncram_component.width_byteena_a  = 1,
        altera_syncram_component.width_byteena_b  = 1;



endmodule


