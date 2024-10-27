module aes_standard_round (
    input  logic clk, rst, en,
    input  logic [3:0][3:0][7:0] key, state,
    output logic [3:0][3:0][7:0] new_state
);

  logic [3:0][3:0][7:0] sub, shift, shift_flop1, shift_flop2, mix, rkey;

  genvar i;
  for (i=0; i<4; i++) begin : subrowgen
    sub_bytes subrow (.bytes_in(state[i]), .bytes_out(sub[i]));
  end
  shift_rows shfrow (.input_matrix(sub), .output_matrix(shift));
  floper #(128) flop1 (clk, rst, en, shift, shift_flop1);
  floper #(128) flop2 (clk, rst, en, shift_flop1, shift_flop2);

  mix_columns mixcol (.input_matrix(shift_flop2), .output_matrix(mix));
  add_round_key xorkey (.key, .state(mix), .new_state(rkey));
  floper #(128) flop3 (clk, rst, en, rkey, new_state);

endmodule : aes_standard_round
