`timescale 1ns / 1ps

//for the fixed A_transpose(2x4)
module output_2x2_transform #(parameter W=16)(
    input clk,
    input rstn,
    input [255:0] M, //4x4, result of elementwise 16 multiplications
    output [63:0] Y //2x2
);

reg [W*8-1:0] A_TM;
reg [W*4-1:0] output_transformed;

always @(posedge clk, negedge rstn) begin
        
        if (!rstn) begin
            A_TM <= 0;
            output_transformed <= 0;
        end

        else begin            

            //A_TM
            A_TM[0*W +: W] <= M[0*W +: W] + M[4*W +: W] + M[8*W +: W];
            A_TM[1*W +: W] <= M[1*W +: W] + M[5*W +: W] + M[9*W +: W];
            A_TM[2*W +: W] <= M[2*W +: W] + M[6*W +: W] + M[10*W +: W];
            A_TM[3*W +: W] <= M[3*W +: W] + M[7*W +: W] + M[11*W +: W];


            A_TM[4*W +: W] <= M[4*W +: W] - M[8*W +: W] - M[12*W +: W];
            A_TM[5*W +: W] <= M[5*W +: W] - M[9*W +: W] - M[13*W +: W];
            A_TM[6*W +: W] <= M[6*W +: W] - M[10*W +: W] - M[14*W +: W];
            A_TM[7*W +: W] <= M[7*W +: W] - M[11*W +: W] - M[15*W +: W];

        end
end

always @(posedge clk, negedge rstn) begin
            //A_transpos M A = Y 2x2
            output_transformed[0*W +: W] <= A_TM[0*W +: W] + A_TM[1*W +: W] + A_TM[2*W +: W];
            output_transformed[1*W +: W] <= A_TM[1*W +: W] - A_TM[2*W +: W] - A_TM[3*W +: W];
            output_transformed[2*W +: W] <= A_TM[4*W +: W] + A_TM[5*W +: W] + A_TM[6*W +: W];
end


assign Y = output_transformed;

endmodule
