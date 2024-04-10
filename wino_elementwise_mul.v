`timescale 1ns / 1ps

module wino_elementwise_mul #(parameter WI=12, parameter WO = 24)
(
    input clk, 
    input rstn, 
    input  [16*WI-1:0] i_mtx_u,   
    input  [16*WI-1:0] i_mtx_v,   
    output [16*WO-1:0] o_mtx_m 
);


//reg [16*WO-1:0] y; 
reg [WO-1:0] y_00;
reg [WO-1:0] y_01;
reg [WO-1:0] y_02;
reg [WO-1:0] y_03;
reg [WO-1:0] y_04;
reg [WO-1:0] y_05;
reg [WO-1:0] y_06;
reg [WO-1:0] y_07;
reg [WO-1:0] y_08;
reg [WO-1:0] y_09;
reg [WO-1:0] y_10;
reg [WO-1:0] y_11;
reg [WO-1:0] y_12;
reg [WO-1:0] y_13;
reg [WO-1:0] y_14;
reg [WO-1:0] y_15;

wire [16*WO-1:0] elementwise_result;



//Doing elementwise multiplication
always @(posedge clk, negedge rstn) begin
    if(!rstn) begin //reg needs to be initialized
        y_00 <= 0;
        y_01 <= 0;
        y_02 <= 0;
        y_03 <= 0;
        y_04 <= 0;
        y_05 <= 0;
        y_06 <= 0;
        y_07 <= 0;
        y_08 <= 0;
        y_09 <= 0;
        y_10 <= 0;
        y_11 <= 0;
        y_12 <= 0;
        y_13 <= 0;
        y_14 <= 0;
        y_15 <= 0;
	end

	else begin
        y_00 <= $signed($signed(i_mtx_u[ 0*WI +: WI]) * $signed(i_mtx_v[ 0*WI +: WI]));
        y_01 <= $signed($signed(i_mtx_u[ 1*WI +: WI]) * $signed(i_mtx_v[ 1*WI +: WI]));
        y_02 <= $signed($signed(i_mtx_u[ 2*WI +: WI]) * $signed(i_mtx_v[ 2*WI +: WI]));
        y_03 <= $signed($signed(i_mtx_u[ 3*WI +: WI]) * $signed(i_mtx_v[ 3*WI +: WI]));
        y_04 <= $signed($signed(i_mtx_u[ 4*WI +: WI]) * $signed(i_mtx_v[ 4*WI +: WI]));
        y_05 <= $signed($signed(i_mtx_u[ 5*WI +: WI]) * $signed(i_mtx_v[ 5*WI +: WI]));
        y_06 <= $signed($signed(i_mtx_u[ 6*WI +: WI]) * $signed(i_mtx_v[ 6*WI +: WI]));
        y_07 <= $signed($signed(i_mtx_u[ 7*WI +: WI]) * $signed(i_mtx_v[ 7*WI +: WI]));
        y_08 <= $signed($signed(i_mtx_u[ 8*WI +: WI]) * $signed(i_mtx_v[ 8*WI +: WI]));
        y_09 <= $signed($signed(i_mtx_u[ 9*WI +: WI]) * $signed(i_mtx_v[ 9*WI +: WI]));
        y_10 <= $signed($signed(i_mtx_u[10*WI +: WI]) * $signed(i_mtx_v[10*WI +: WI]));
        y_11 <= $signed($signed(i_mtx_u[11*WI +: WI]) * $signed(i_mtx_v[11*WI +: WI]));
        y_12 <= $signed($signed(i_mtx_u[12*WI +: WI]) * $signed(i_mtx_v[12*WI +: WI]));
        y_13 <= $signed($signed(i_mtx_u[13*WI +: WI]) * $signed(i_mtx_v[13*WI +: WI]));
        y_14 <= $signed($signed(i_mtx_u[14*WI +: WI]) * $signed(i_mtx_v[14*WI +: WI]));
        y_15 <= $signed($signed(i_mtx_u[15*WI +: WI]) * $signed(i_mtx_v[15*WI +: WI]));
    end
end

assign elementwise_result = {y_00, y_01, y_02, y_03, 
							y_04, y_05, y_06, y_07,
							y_08, y_09, y_10, y_11, 
							y_12, y_13, y_14, y_15
							}; 

assign o_mtx_m = elementwise_result;

endmodule















