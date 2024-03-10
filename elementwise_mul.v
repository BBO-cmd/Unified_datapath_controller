`timescale 1ns / 1ps

module elementwise_mul(
    input clk,
    input rstn,
    input [127:0] U_entry, // 4x4 mtx in 1D tensor(len=16)
    input [127:0] V_entry, // 4x4 mtx in 1D tensor(len=16)
    output [127:0] M       // 4x4 mtx in 1D tensor(len=16) 
);



//internal signals
wire[15:0] y00;
wire[15:0] y01;
wire[15:0] y02;
wire[15:0] y03;
wire[15:0] y04;
wire[15:0] y05;
wire[15:0] y06;
wire[15:0] y07;
wire[15:0] y08;
wire[15:0] y09;
wire[15:0] y10;
wire[15:0] y11;
wire[15:0] y12;
wire[15:0] y13;
wire[15:0] y14;
wire[15:0] y15;


//Doing elementwise multiplication
assign y00 = U_entry[7:0] * V_entry[7:0];
assign y01 = U_entry[15:8] * V_entry[15:8];
assign y02 = U_entry[23:16] * V_entry[23:16];
assign y03 = U_entry[31:24] * V_entry[31:24];
assign y04 = U_entry[39:32] * V_entry[39:32];
assign y05 = U_entry[47:40] * V_entry[47:40];
assign y06 = U_entry[55:48] * V_entry[55:48];
assign y07 = U_entry[63:56] * V_entry[63:56];
assign y08 = U_entry[71:64] * V_entry[71:64];
assign y09 = U_entry[79:72] * V_entry[79:72];
assign y10 = U_entry[87:80] * V_entry[87:80];
assign y11 = U_entry[95:88] * V_entry[95:88];
assign y12 = U_entry[103:96] * V_entry[103:96];
assign y13 = U_entry[111:104] * V_entry[111:104];
assign y14 = U_entry[119:112] * V_entry[119:112];
assign y15 = U_entry[127:120] * V_entry[127:120];


assign M = {y00, y01, y02, y03, y04, y05, y06, y07, y08, y09, y10, y11, y12, y13, y14, y15};


endmodule







