module aes_reduced_round_freq (
    input  logic clk, rst, en,
    input  logic [3:0][3:0][7:0] key, state,
    output logic [3:0][3:0][7:0] new_state
);

  logic [3:0][3:0][7:0] sub, shift, rkey;

  genvar i,j;
  for (i=0; i<4; i++) begin : subrowgen
    for (j=0; j<4; j++) begin : subcolgen
      sub_bytes_freq subrow (.clk, .rst, .en, .bytes_in(state[i][j]), .bytes_out(sub[i][j]));
    end
  end
  shift_rows shfrow (.input_matrix(sub), .output_matrix(shift));
  
  add_round_key xorkey (.key, .state(shift), .new_state(rkey));
  floper #(128) flop (clk, rst, en, rkey, new_state);

endmodule : aes_reduced_round
