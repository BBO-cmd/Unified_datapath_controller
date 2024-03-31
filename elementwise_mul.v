`timescale 1ns / 1ps

module elementwise_mul #(parameter W=8)
(
    input clk, 
    input rstn, 
    input [16*W-1:0] i_mtx_u,   
    input [16*W-1:0] i_mtx_v,   
    output [16*W*2-1:0] o_mtx_m 
);

//internal signals
reg[2*W-1:0] y00; 
reg[2*W-1:0] y01; 
reg[2*W-1:0] y02; 
reg[2*W-1:0] y03;
reg[2*W-1:0] y04;
reg[2*W-1:0] y05;
reg[2*W-1:0] y06;
reg[2*W-1:0] y07;
reg[2*W-1:0] y08;
reg[2*W-1:0] y09;
reg[2*W-1:0] y10;
reg[2*W-1:0] y11;
reg[2*W-1:0] y12;
reg[2*W-1:0] y13;
reg[2*W-1:0] y14;
reg[2*W-1:0] y15;


//Doing elementwise multiplication
always @(posedge clk, negedge rstn) begin
    if(!rstn) begin //reg needs to be initialized
        y00 <= 0;
        y01 <= 0;
        y02 <= 0;
        y03 <= 0;
        y04 <= 0;
        y05 <= 0;
        y06 <= 0;
        y07 <= 0;
        y08 <= 0;
        y09 <= 0;
        y10 <= 0;
        y11 <= 0;
        y12 <= 0;
        y13 <= 0;
        y14 <= 0;
        y15 <= 0;
end

else begin
        y00 <= i_mtx_u[0*W +: W] * i_mtx_v[0*W +: W];
        y01 <= i_mtx_u[1*W +: W] * i_mtx_v[1*W +: W];
        y02 <= i_mtx_u[2*W +: W] * i_mtx_v[2*W +: W];
        y03 <= i_mtx_u[3*W +: W] * i_mtx_v[3*W +: W];
        y04 <= i_mtx_u[4*W +: W] * i_mtx_v[4*W +: W];
        y05 <= i_mtx_u[5*W +: W] * i_mtx_v[5*W +: W];
        y06 <= i_mtx_u[6*W +: W] * i_mtx_v[6*W +: W];
        y07 <= i_mtx_u[7*W +: W] * i_mtx_v[7*W +: W];
        y08 <= i_mtx_u[8*W +: W] * i_mtx_v[8*W +: W];
        y09 <= i_mtx_u[9*W +: W] * i_mtx_v[9*W +: W];
        y10 <= i_mtx_u[10*W +: W] * i_mtx_v[10*W +: W];
        y11 <= i_mtx_u[11*W +: W] * i_mtx_v[11*W +: W];
        y12 <= i_mtx_u[12*W +: W] * i_mtx_v[12*W +: W];
        y13 <= i_mtx_u[13*W +: W] * i_mtx_v[13*W +: W];
        y14 <= i_mtx_u[14*W +: W] * i_mtx_v[14*W +: W];
        y15 <= i_mtx_u[15*W +: W] * i_mtx_v[15*W +: W];
    end
end

assign o_mtx_m = {y15, y14, y13, y12, y11, y10, y09, y08, y07, y06, y05, y04, y03, y02, y01, y00};


endmodule















