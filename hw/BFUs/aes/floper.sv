module floper #(parameter WIDTH) (
    input  logic clk, rst, en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  always @(posedge clk) begin
    if (rst)
      q <= '0;
    else if (en)
      q <= d;
  end

endmodule : floper
