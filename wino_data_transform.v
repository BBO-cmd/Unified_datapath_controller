`timescale 1ns / 1ps

//for the fixed B_transpose(4x4)
module wino_data_transform #(parameter WI=8, parameter WO = 12)(
    input clk,
    input rstn, 
    input  [16*WI-1:0] data,
    output [16*WO-1:0] data_out
);

//reg [16*WO-1:0] B_Td;
reg[WO-1:0] Bt_d_00;
reg[WO-1:0] Bt_d_01;
reg[WO-1:0] Bt_d_02;
reg[WO-1:0] Bt_d_03;
reg[WO-1:0] Bt_d_04;
reg[WO-1:0] Bt_d_05;
reg[WO-1:0] Bt_d_06;
reg[WO-1:0] Bt_d_07;
reg[WO-1:0] Bt_d_08;
reg[WO-1:0] Bt_d_09;
reg[WO-1:0] Bt_d_10;
reg[WO-1:0] Bt_d_11;
reg[WO-1:0] Bt_d_12;
reg[WO-1:0] Bt_d_13;
reg[WO-1:0] Bt_d_14;
reg[WO-1:0] Bt_d_15;

//reg [16*WO-1:0] data_transformed;
reg[WO-1:0] Bt_d_B_00;
reg[WO-1:0] Bt_d_B_01;
reg[WO-1:0] Bt_d_B_02;
reg[WO-1:0] Bt_d_B_03;
reg[WO-1:0] Bt_d_B_04;
reg[WO-1:0] Bt_d_B_05;
reg[WO-1:0] Bt_d_B_06;
reg[WO-1:0] Bt_d_B_07;
reg[WO-1:0] Bt_d_B_08;
reg[WO-1:0] Bt_d_B_09;
reg[WO-1:0] Bt_d_B_10;
reg[WO-1:0] Bt_d_B_11;
reg[WO-1:0] Bt_d_B_12;
reg[WO-1:0] Bt_d_B_13;
reg[WO-1:0] Bt_d_B_14;
reg[WO-1:0] Bt_d_B_15;

wire[16*WO-1:0] data_transformed;

always @(posedge clk, negedge rstn) begin 
	if(!rstn) begin
		Bt_d_00 <= 0;
		Bt_d_01 <= 0;
		Bt_d_02 <= 0;
		Bt_d_03 <= 0;
		Bt_d_04 <= 0;
		Bt_d_05 <= 0;
		Bt_d_06 <= 0;
		Bt_d_07 <= 0;
		Bt_d_08 <= 0;
		Bt_d_09 <= 0;
		Bt_d_10 <= 0;
		Bt_d_11 <= 0;
		Bt_d_12 <= 0;
		Bt_d_13 <= 0;
		Bt_d_14 <= 0;
		Bt_d_15 <= 0;

		Bt_d_B_00 <= 0;
		Bt_d_B_01 <= 0;
		Bt_d_B_02 <= 0;
		Bt_d_B_03 <= 0;
		Bt_d_B_04 <= 0;
		Bt_d_B_05 <= 0;
		Bt_d_B_06 <= 0;
		Bt_d_B_07 <= 0;
		Bt_d_B_08 <= 0;
		Bt_d_B_09 <= 0;
		Bt_d_B_10 <= 0;
		Bt_d_B_11 <= 0;
		Bt_d_B_12 <= 0;
		Bt_d_B_13 <= 0;
		Bt_d_B_14 <= 0;
		Bt_d_B_15 <= 0;

	end	

	else begin
		// ------------------------------------------------------------
		// Stage 1: Compute B' * d  
		// ------------------------------------------------------------
		//12bit per cell
		Bt_d_00 <= $signed($signed(data[0*WI +: WI]) - $signed(data[ 8*WI +: WI]));
		Bt_d_01 <= $signed($signed(data[1*WI +: WI]) - $signed(data[ 9*WI +: WI]));
		Bt_d_02 <= $signed($signed(data[2*WI +: WI]) - $signed(data[10*WI +: WI]));
		Bt_d_03 <= $signed($signed(data[3*WI +: WI]) - $signed(data[11*WI +: WI]));

		Bt_d_04 <= $signed($signed(data[4*WI +: WI]) + $signed(data[ 8*WI +: WI]));
		Bt_d_05 <= $signed($signed(data[5*WI +: WI]) + $signed(data[ 9*WI +: WI]));
		Bt_d_06 <= $signed($signed(data[6*WI +: WI]) + $signed(data[10*WI +: WI]));
		Bt_d_07 <= $signed($signed(data[7*WI +: WI]) + $signed(data[11*WI +: WI]));

		Bt_d_08 <= $signed(- $signed(data[4*WI +: WI]) + $signed(data[ 8*WI +: WI]));
		Bt_d_09 <= $signed(- $signed(data[5*WI +: WI]) + $signed(data[ 9*WI +: WI]));
		Bt_d_10 <= $signed(- $signed(data[6*WI +: WI]) + $signed(data[10*WI +: WI]));
		Bt_d_11 <= $signed(- $signed(data[7*WI +: WI]) + $signed(data[11*WI +: WI]));

		Bt_d_12 <= $signed(+ $signed(data[4*WI +: WO]) - $signed(data[12*WI +: WI])); 
		Bt_d_13 <= $signed(+ $signed(data[5*WI +: WO]) - $signed(data[13*WI +: WI]));
		Bt_d_14 <= $signed(+ $signed(data[6*WI +: WO]) - $signed(data[14*WI +: WI]));
		Bt_d_15 <= $signed(+ $signed(data[7*WI +: WO]) - $signed(data[15*WI +: WI]));

		// ------------------------------------------------------------
		// Stage 2: (B' * d) * B
		// ------------------------------------------------------------
		Bt_d_B_00 <= $signed(  $signed(Bt_d_00) - $signed(Bt_d_02)); 
		Bt_d_B_01 <= $signed(  $signed(Bt_d_01) + $signed(Bt_d_02));
		Bt_d_B_02 <= $signed(- $signed(Bt_d_01) + $signed(Bt_d_02));
		Bt_d_B_03 <= $signed(+ $signed(Bt_d_01) - $signed(Bt_d_03)); 

		Bt_d_B_04 <= $signed(  $signed(Bt_d_04) - $signed(Bt_d_06));
		Bt_d_B_05 <= $signed(  $signed(Bt_d_05) + $signed(Bt_d_06));
		Bt_d_B_06 <= $signed(- $signed(Bt_d_05) + $signed(Bt_d_06));
		Bt_d_B_07 <= $signed(+ $signed(Bt_d_05) - $signed(Bt_d_07)); 

		Bt_d_B_08  <= $signed(  $signed(Bt_d_08) - $signed(Bt_d_10));
		Bt_d_B_09  <= $signed(  $signed(Bt_d_09) + $signed(Bt_d_10));
		Bt_d_B_10  <= $signed(- $signed(Bt_d_09) + $signed(Bt_d_10));
		Bt_d_B_11  <= $signed(+ $signed(Bt_d_09) - $signed(Bt_d_11)); 

		Bt_d_B_12  <= $signed(  $signed(Bt_d_12) - $signed(Bt_d_14));
		Bt_d_B_13  <= $signed(  $signed(Bt_d_13) + $signed(Bt_d_14));
		Bt_d_B_14  <= $signed(- $signed(Bt_d_13) + $signed(Bt_d_14));
		Bt_d_B_15  <= $signed(+ $signed(Bt_d_13) - $signed(Bt_d_15)); 

	end 
end


assign data_transformed = {Bt_d_B_00, Bt_d_B_01, Bt_d_B_02, Bt_d_B_03, 
							Bt_d_B_04, Bt_d_B_05, Bt_d_B_06,Bt_d_B_07,
							Bt_d_B_08, Bt_d_B_09, Bt_d_B_10, Bt_d_B_11, 
							Bt_d_B_12, Bt_d_B_13, Bt_d_B_14,Bt_d_B_15
							}; 
assign data_out = data_transformed;

endmodule
