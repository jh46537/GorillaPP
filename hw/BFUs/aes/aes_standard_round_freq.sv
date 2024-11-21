module aes_standard_round_freq (
    input  logic clk, rst, en,
    input  logic [3:0][3:0][7:0] key, state,
    output logic [3:0][3:0][7:0] new_state
);

  logic [3:0][3:0][7:0] sub, shift, shift_flop, mix, mix_flop;

  genvar i, j;
  for (i=0; i<4; i++) begin : subrowgen
    for (j=0; j<4; j++) begin : subcolgen
      sub_bytes_freq subrow (.clk, .rst, .en, .bytes_in(state[i][j]), .bytes_out(sub[i][j]));
	 end
  end
  shift_rows shfrow (.input_matrix(sub), .output_matrix(shift));
  floper #(128) flop1 (clk, rst, en, shift, shift_flop);

  mix_columns mixcol (.clk, .rst, .en, .input_matrix(shift_flop), .output_matrix(mix));
  floper #(128) flop2 (clk, rst, en, mix, mix_flop);
  add_round_key xorkey (.key, .state(mix_flop), .new_state);


endmodule : aes_standard_round
