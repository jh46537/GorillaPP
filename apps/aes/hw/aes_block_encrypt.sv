module aes_block_encrypt #(parameter KEYLEN=128) (
    input  logic clk, rst,
    input  logic valid_in,
    output logic valid_out,
    input  logic ready_out,
    output logic ready_in,
    input  logic [KEYLEN/32+6:0][127:0] expanded_key,
    input  logic [3:0][3:0][7:0] plaintext,
    output logic [3:0][3:0][7:0] ciphertext
);

  // longer KEYLEN = more rounds, more cycles, longer pipe

  genvar i;
  localparam STD_ROUND_COUNT = KEYLEN/32+5;

  logic [STD_ROUND_COUNT+1:0] ivalid;
  logic [STD_ROUND_COUNT+1:0][3:0][3:0][7:0] short_key;
  logic [STD_ROUND_COUNT:0][3:0][3:0][7:0] round_interm, ri_preflop;
  
  //TODO: skid buffer? when does ready_out deassert
  assign ready_in = ready_out;

  // propagate a valid signal through the pipe
  assign ivalid[0] = valid_in;
  assign valid_out = ivalid[STD_ROUND_COUNT+1];
  for (i=0; i<STD_ROUND_COUNT+1; i++) begin : valid
    floper #(1) flop (clk, rst, ready_out, ivalid[i], ivalid[i+1]);
  end

  // repartition keys
  // figure out key expansion order and remove this
  for (i=0; i<STD_ROUND_COUNT+2; i++) begin : key_part
    block_partition bp1 (.in(expanded_key[i]), .out(short_key[i]));
  end

  add_round_key ark1 (.state(plaintext), .key(short_key[0]), .new_state(round_interm[0]));

  for (i=0; i<STD_ROUND_COUNT; i++) begin : stdround
    aes_standard_round aesrnd (.key(short_key[i+1]), .state(round_interm[i]), .new_state(ri_preflop[i]));
    floper #(128) flop (clk, rst, ready_out, ri_preflop[i], round_interm[i+1]);
  end

  aes_reduced_round aesrnd_short (.key(short_key[STD_ROUND_COUNT+1]),
    .state(round_interm[STD_ROUND_COUNT]), .new_state(ri_preflop[STD_ROUND_COUNT]));
  floper #(128) flop (clk, rst, ready_out, ri_preflop[STD_ROUND_COUNT], ciphertext);

endmodule : aes_block_encrypt
