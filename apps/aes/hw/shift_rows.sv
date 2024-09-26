//////////////////////////////////////////
/* rotates the rows of the input matrix */
//////////////////////////////////////////
module shift_rows(
    input  logic [3:0][3:0][7:0] input_matrix,
    output logic [3:0][3:0][7:0] output_matrix
);
/*
[0,0][0,1][0,2][0,3]  =>  [0,0][0,1][0,2][0,3]
[1,0][1,1][1,2][1,3]  =>  [1,1][1,2][1,3][1,0]
[2,0][2,1][2,2][2,3]  =>  [2,2][2,3][2,0][2,1]
[3,0][3,1][3,2][3,3]  =>  [3,3][3,0][3,1][3,2]
*/

genvar i;
for (i = 0; i < 4; i++) begin
    assign output_matrix[0][i] = input_matrix[0][i];
    assign output_matrix[1][i] = input_matrix[1][(i+1)%4];
    assign output_matrix[2][i] = input_matrix[2][(i+2)%4];
    assign output_matrix[3][i] = input_matrix[3][(i+3)%4];
end

endmodule : shift_rows
