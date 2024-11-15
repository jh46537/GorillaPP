//////////////////////////////////////////
/* rotates the rows of the input matrix */
//////////////////////////////////////////
module shift_rows(
    input  logic [3:0][3:0][7:0] input_matrix,
    output logic [3:0][3:0][7:0] output_matrix
);
/* Column Major
[3,3][2,3][1,3][0,3]  =>  [3,3][2,3][1,3][0,3]
[3,2][2,2][1,2][0,2]  =>  [2,2][1,2][0,2][3,2]
[3,1][2,1][1,1][0,1]  =>  [1,1][0,1][3,1][2,1]
[3,0][2,0][1,0][0,0]  =>  [0,0][3,0][2,0][1,0]
*/

genvar i;
for (i = 0; i < 4; i++) begin
    assign output_matrix[i][3] = input_matrix[i][3];
    assign output_matrix[i][2] = input_matrix[(i+3)%4][2];
    assign output_matrix[i][1] = input_matrix[(i+2)%4][1];
    assign output_matrix[i][0] = input_matrix[(i+1)%4][0];
end

endmodule : shift_rows
