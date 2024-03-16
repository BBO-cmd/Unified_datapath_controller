`timescale 1ns / 1ps

//for the fixed A_transpose(2x4)
module output_2x2_transform #(parameter W=16)(
    input clk,
    input rstn,
    input [255:0] M, //4x4, result of elementwise 16 multiplications
    output [63:0] Y //2z2
);

//A_transpose M A = Y_2x2
assign Y[0*W +: W] = M[0*W +: W] + M[1*W +: W] + M[2*W +: W] 
                   + M[4*W +: W] + M[5*W +: W] + M[6*W +: W]
                   + M[8*W +: W] + M[9*W +: W] + M[10*W +: W];

assign Y[1*W +: W] = M[1*W +: W] - M[2*W +: W] - M[3*W +: W] 
                   + M[5*W +: W] - M[6*W +: W] - M[7*W +: W]
                   + M[9*W +: W] - M[10*W +: W] - M[11*W +: W];

assign Y[2*W +: W] = M[4*W +: W] + M[5*W +: W] + M[6*W +: W] 
                   - M[8*W +: W] - M[9*W +: W] - M[10*W +: W]
                   - M[12*W +: W] - M[13*W +: W] - M[14*W +: W];

assign Y[3*W +: W] = M[5*W +: W] - M[6*W +: W] - M[7*W +: W] 
                   - M[9*W +: W] + M[10*W +: W] + M[11*W +: W]
                   - M[13*W +: W] + M[14*W +: W] + M[15*W +: W];

endmodule