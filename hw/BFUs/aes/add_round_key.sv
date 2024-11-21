module add_round_key (
    input  [3:0][3:0][7:0] state, key,
    output [3:0][3:0][7:0] new_state
);

assign new_state = state ^ key;

endmodule : add_round_key
