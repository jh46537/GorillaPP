module aes_reduced_round (
    //input  logic clk, rst,
    input  logic [3:0][3:0][7:0] key, state,
    output logic [3:0][3:0][7:0] new_state
);

  logic [3:0][3:0][7:0] sub, shift;

  genvar i;
  for (i=0; i<4; i++) begin
    sub_bytes subrow (.bytes_in(state[i]), .bytes_out(sub[i]));
  end
  shift_rows shfrow (.input_matrix(sub), .output_matrix(shift));
  add_round_key xorkey (.key, .state(shift), .new_state);

endmodule : aes_reduced_round
