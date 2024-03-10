`timescale 1ns / 1ps

module matmul_43x33(     //later: parameterize the mtx size
    input clk,
    input rstn,
    input [7:0] transformation_mtx[0:3][0:2],   // G(4x3)
    input [7:0] input_mtx[0:2][0:2],            // g(3x3)
    output reg [15:0] result_mtx[0:3][0:2]      // Gg(4x3)
);

always @(posedge clk) begin
    if(!rstn) begin
        result_mtx[0][0] <= 0;
        result_mtx[0][1] <= 0;
        result_mtx[0][2] <= 0;
        result_mtx[1][0] <= 0;
        result_mtx[1][1] <= 0;
        result_mtx[1][2] <= 0;
        result_mtx[2][0] <= 0;
        result_mtx[2][1] <= 0;
        result_mtx[2][2] <= 0;
        result_mtx[3][0] <= 0;
        result_mtx[3][1] <= 0;
        result_mtx[3][2] <= 0;
    end

    else begin
        result_mtx[0][0] <= transformation_mtx[0][0] * input_mtx[0][0] + transformation_mtx[0][1] * input_mtx[1][0] + transformation_mtx[0][2] * input_mtx[2][0];
        result_mtx[0][1] <= transformation_mtx[0][0] * input_mtx[0][1] + transformation_mtx[0][1] * input_mtx[1][1] + transformation_mtx[0][2] * input_mtx[2][1];
        result_mtx[0][2] <= transformation_mtx[0][0] * input_mtx[0][2] + transformation_mtx[0][1] * input_mtx[1][2] + transformation_mtx[0][2] * input_mtx[2][2];
        result_mtx[1][0] <= transformation_mtx[1][0] * input_mtx[0][0] + transformation_mtx[1][1] * input_mtx[1][0] + transformation_mtx[1][2] * input_mtx[2][0];
        result_mtx[1][1] <= transformation_mtx[1][0] * input_mtx[0][1] + transformation_mtx[1][1] * input_mtx[1][1] + transformation_mtx[1][2] * input_mtx[2][1];
        result_mtx[1][2] <= transformation_mtx[1][0] * input_mtx[0][2] + transformation_mtx[1][1] * input_mtx[1][2] + transformation_mtx[1][2] * input_mtx[2][2];
        result_mtx[2][0] <= transformation_mtx[2][0] * input_mtx[0][0] + transformation_mtx[2][1] * input_mtx[1][0] + transformation_mtx[2][2] * input_mtx[2][0];
        result_mtx[2][1] <= transformation_mtx[2][0] * input_mtx[0][1] + transformation_mtx[2][1] * input_mtx[1][1] + transformation_mtx[2][2] * input_mtx[2][1];
        result_mtx[2][2] <= transformation_mtx[2][0] * input_mtx[0][2] + transformation_mtx[2][1] * input_mtx[1][2] + transformation_mtx[2][2] * input_mtx[2][2];
        result_mtx[3][0] <= transformation_mtx[3][0] * input_mtx[0][0] + transformation_mtx[3][1] * input_mtx[1][0] + transformation_mtx[3][2] * input_mtx[2][0];
        result_mtx[3][1] <= transformation_mtx[3][0] * input_mtx[0][1] + transformation_mtx[3][1] * input_mtx[1][1] + transformation_mtx[3][2] * input_mtx[2][1];
        result_mtx[3][2] <= transformation_mtx[3][0] * input_mtx[0][2] + transformation_mtx[3][1] * input_mtx[1][2] + transformation_mtx[3][2] * input_mtx[2][2];
    end

end

endmodule