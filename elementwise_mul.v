`timescale 1ns / 1ps



module elementwise_mul #(parameter W=8)
(
    input clk, 
    input rstn, 
    input [16*W-1:0] i_mtx_u,   // 4x4 mtx in 1D tensor(len=16)
    input [16*W-1:0] i_mtx_v,   // 4x4 mtx in 1D tensor(len=16)
    output [16*W*2-1:0] o_mtx_m // 4x4 mtx in 1D tensor(len=16), each element = 16bit
);


//internal signals
wire[2*W-1:0] y00; 
wire[2*W-1:0] y01; 
wire[2*W-1:0] y02; 
wire[2*W-1:0] y03;
wire[2*W-1:0] y04;
wire[2*W-1:0] y05;
wire[2*W-1:0] y06;
wire[2*W-1:0] y07;
wire[2*W-1:0] y08;
wire[2*W-1:0] y09;
wire[2*W-1:0] y10;
wire[2*W-1:0] y11;
wire[2*W-1:0] y12;
wire[2*W-1:0] y13;
wire[2*W-1:0] y14;
wire[2*W-1:0] y15;


//Doing elementwise multiplication
assign y00 = i_mtx_u[0*W +: W] * i_mtx_v[0*W +: W];
assign y01 = i_mtx_u[1*W +: W] * i_mtx_v[1*W +: W];
assign y02 = i_mtx_u[2*W +: W] * i_mtx_v[2*W +: W];
assign y03 = i_mtx_u[3*W +: W] * i_mtx_v[3*W +: W];
assign y04 = i_mtx_u[4*W +: W] * i_mtx_v[4*W +: W];
assign y05 = i_mtx_u[5*W +: W] * i_mtx_v[5*W +: W];
assign y06 = i_mtx_u[6*W +: W] * i_mtx_v[6*W +: W];
assign y07 = i_mtx_u[7*W +: W] * i_mtx_v[7*W +: W];
assign y08 = i_mtx_u[8*W +: W] * i_mtx_v[8*W +: W];
assign y09 = i_mtx_u[9*W +: W] * i_mtx_v[9*W +: W];
assign y10 = i_mtx_u[10*W +: W] * i_mtx_v[10*W +: W];
assign y11 = i_mtx_u[11*W +: W] * i_mtx_v[11*W +: W];
assign y12 = i_mtx_u[12*W +: W] * i_mtx_v[12*W +: W];
assign y13 = i_mtx_u[13*W +: W] * i_mtx_v[13*W +: W];
assign y14 = i_mtx_u[14*W +: W] * i_mtx_v[14*W +: W];
assign y15 = i_mtx_u[15*W +: W] * i_mtx_v[15*W +: W];


assign o_mtx_m = {y15, y14, y13, y12, y11, y10, y09, y08, y07, y06, y05, y04, y03, y02, y01, y00};


endmodule







