module flopr #(parameter WIDTH) (
    input  logic clk, rst,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  always @(posedge clk) begin
    if (rst)
      q <= '0;
    else
      q <= d;
  end

endmodule : flopr
