// Takes a single 128 bit long bitvector and partitions it into a 4x4 block of bytes

module block_partition (
    input  logic [3:0][31:0] in,
    output logic [3:0][31:0] out
);

  genvar i;

  for (i=0; i<4; i++) begin
      assign out[i] = in[3-i];
  end

endmodule : block_partition
