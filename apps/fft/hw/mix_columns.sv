///////////////////////////////////////////
/* mixes the columns of the input matrix */
///////////////////////////////////////////
module mix_columns(
    input  logic [3:0][3:0][7:0] input_matrix,
    output logic [3:0][3:0][7:0] output_matrix
);
/*
[0,0][1,0][2,0][3,0]
[0,1][1,1][2,1][3,1]
[0,2][1,2][2,2][3,2]
[0,3][1,3][2,3][3,3]
*/

logic [3:0][3:0][7:0] shift, gm2;

genvar i, j;
// for each column
for (i = 0; i < 4; i++) begin
    for (j = 0; j < 4; j++) begin
        assign shift[i][j] = input_matrix[i][j] << 1;
        assign gm2[i][j] = input_matrix[i][j][7] ? shift[i][j] ^ 8'h1B : shift[i][j];
    end

    assign output_matrix[i][0] = gm2[i][0] ^ input_matrix[i][3] ^ input_matrix[i][2] ^ gm2[i][1] ^ input_matrix[i][1];
    assign output_matrix[i][1] = gm2[i][1] ^ input_matrix[i][0] ^ input_matrix[i][3] ^ gm2[i][2] ^ input_matrix[i][2];
    assign output_matrix[i][2] = gm2[i][2] ^ input_matrix[i][1] ^ input_matrix[i][0] ^ gm2[i][3] ^ input_matrix[i][3];
    assign output_matrix[i][3] = gm2[i][3] ^ input_matrix[i][2] ^ input_matrix[i][1] ^ gm2[i][0] ^ input_matrix[i][0];
end

endmodule : mix_columns
