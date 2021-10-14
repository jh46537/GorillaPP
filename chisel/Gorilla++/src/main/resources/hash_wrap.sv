module hash_func (
    input                   clk,
    input                   rst,
    input                   stall,
    input   logic [31:0]    initval,
    input   tuple_t         tuple_in,
    input                   tuple_in_valid,
    output  logic           hashed_valid,
    output  logic [31:0]    hashed
);

logic [31:0] a;
logic [31:0] b;
logic [31:0] c;
logic [31:0] a1;
logic [31:0] b1;
logic [31:0] c1;
logic [31:0] a2;
logic [31:0] b2;
logic [31:0] c2;
logic [31:0] a3;
logic [31:0] b3;
logic [31:0] c3;
logic [31:0] a4;
logic [31:0] b4;
logic [31:0] c4;
logic [31:0] a5;
logic [31:0] b5;
logic [31:0] c5;
logic [31:0] a6;
logic [31:0] b6;
logic [31:0] c6;

logic valid;
logic valid1;
logic valid2;
logic valid3;
logic valid4;
logic valid5;
logic valid6;

logic [95:0] key;
assign key = {tuple_in.sIP, tuple_in.sPort,
              tuple_in.dIP, tuple_in.dPort};

// Pipelined design
always @(posedge clk) begin
    if (!stall) begin
        valid <= tuple_in_valid;
        valid1 <= valid;
        valid2 <= valid1;
        valid3 <= valid2;
        valid4 <= valid3;
        valid5 <= valid4;
        valid6 <= valid5;
        hashed_valid <= valid6;

        a <= 32'hdeadbefb + key[31:0] + initval;
        b <= 32'hdeadbefb + key[63:32] + initval;
        c <= 32'hdeadbefb + key[95:64] + initval;

        a1 <= a;
        b1 <= b;
        c1 <= (c ^ b) - {b[17:0], b[31:18]};

        a2 <= (a1 ^ c1) - {c1[20:0], c1[31:21]};
        b2 <= b1;
        c2 <= c1;

        a3 <= a2;
        b3 <= (b2 ^ a2) - {a2[6:0], a2[31:7]};
        c3 <= c2;

        a4 <= a3;
        b4 <= b3;
        c4 <= (c3 ^ b3) - {b3[15:0], b3[31:16]};

        a5 <= (a4 ^ c4) - {c4[27:0], c4[31:28]};
        b5 <= b4;
        c5 <= c4;

        a6 <= a5;
        b6 <= (b5 ^ a5) - {a5[17:0], a5[31:18]};
        c6 <= c5;

        hashed <= (c6 ^ b6) - {b6[7:0], b6[31:8]};
    end
end

endmodule

module hashV (
	input clk,
	input rst,
	
	input [31:0] sIP,
	input [31:0] dIP,
	input [15:0] sPort,
	input [15:0] dPort,
	input tuple_in_valid,
	output [11:0] h0_hashed,
	output [11:0] h1_hashed,
	output [11:0] h2_hashed,
	output [11:0] h3_hashed,
	output [31:0] sIP_out,
	output [31:0] dIP_out,
	output [15:0] sPort_out,
	output [15:0] dPort_out,
	output hashed_valid
);

tuple_t         tuple_in;
tuple_t         tuple_in_d0;
tuple_t         tuple_in_d1;
tuple_t         tuple_in_d2;
tuple_t         tuple_in_d3;
tuple_t         tuple_in_d4;
tuple_t         tuple_in_d5;
tuple_t         tuple_in_d6;
tuple_t         tuple_in_d7;

assign tuple_in.sIP = sIP;
assign tuple_in.dIP = dIP;
assign tuple_in.sPort = sPort;
assign tuple_in.dPort = dPort;

always @(posedge clk) begin
	tuple_in_d0 <= tuple_in;
	tuple_in_d1 <= tuple_in_d0;
	tuple_in_d2 <= tuple_in_d1;
	tuple_in_d3 <= tuple_in_d2;
	tuple_in_d4 <= tuple_in_d3;
	tuple_in_d5 <= tuple_in_d4;
	tuple_in_d6 <= tuple_in_d5;
	tuple_in_d7 <= tuple_in_d6;
end

assign sIP_out = tuple_in_d7.sIP;
assign dIP_out = tuple_in_d7.dIP;
assign sPort_out = tuple_in_d7.sPort;
assign dPort_out = tuple_in_d7.dPort;

hash_func hash0 (
    .clk            (clk),
    .rst            (rst),
    .stall          ('b0),
    .tuple_in       (tuple_in),
    .initval        (32'd0),
    .tuple_in_valid (tuple_in_valid),
    .hashed         (h0_hashed),
    .hashed_valid   (hashed_valid)
);
hash_func hash1 (
    .clk            (clk),
    .rst            (rst),
    .stall          ('b0),
    .tuple_in       (tuple_in),
    .initval        (32'd1),
    .tuple_in_valid (tuple_in_valid),
    .hashed         (h1_hashed),
    .hashed_valid   ()
);
hash_func hash2 (
    .clk            (clk),
    .rst            (rst),
    .stall          ('b0),
    .tuple_in       (tuple_in),
    .initval        (32'd2),
    .tuple_in_valid (tuple_in_valid),
    .hashed         (h2_hashed),
    .hashed_valid   ()
);
hash_func hash3 (
    .clk            (clk),
    .rst            (rst),
    .stall          ('b0),
    .tuple_in       (tuple_in),
    .initval        (32'd3),
    .tuple_in_valid (tuple_in_valid),
    .hashed         (h3_hashed),
    .hashed_valid   ()
);

endmodule