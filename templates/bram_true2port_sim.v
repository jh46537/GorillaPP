module bram_true2port #(
    parameter AWIDTH = 12,
    parameter DWIDTH = 253,
    parameter DEPTH = 2048)
(
    input [AWIDTH-1:0] address_a,
    input [AWIDTH-1:0] address_b,
    input clock,
    input [DWIDTH-1:0] data_a,
    input [DWIDTH-1:0] data_b,
    input rden_a,
    input rden_b,
    input wren_a,
    input wren_b,
    output reg [DWIDTH-1:0] q_a,
    output reg [DWIDTH-1:0] q_b
);

logic [DWIDTH-1:0] mem [0:DEPTH-1];
logic [AWIDTH-1:0] address_a_r;
logic [AWIDTH-1:0] address_b_r;
logic [DWIDTH-1:0] data_a_r;
logic [DWIDTH-1:0] data_b_r;
logic wren_a_r;
logic wren_b_r;
logic rden_a_r;
logic rden_b_r;

always @(posedge clock) begin
    wren_a_r <= wren_a;
    wren_b_r <= wren_b;
    rden_a_r <= rden_a;
    rden_b_r <= rden_b;
    address_a_r <= address_a;
    address_b_r <= address_b;
    data_a_r <= data_a;
    data_b_r <= data_b;
    if (wren_a_r) begin
        mem[address_a_r] <= data_a_r;
    end
    if (rden_a_r) begin
        q_a <= mem[address_a_r];
    end
    if (wren_b_r) begin
        mem[address_b_r] <= data_b_r;
    end
    if (rden_b_r) begin
        q_b <= mem[address_b_r];
    end
end

endmodule
