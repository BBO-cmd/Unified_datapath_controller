`timescale 1ns / 1ps

module wino_output_transform #(parameter WI=24, parameter WO = 32)(
    input clk,
    input rstn,
    input [16*WI-1:0] M, 
    output[4*WO-1:0] Y 
);

//reg [8*WO-1:0] A_TM;
reg [WO-1:0] At_M_00;
reg [WO-1:0] At_M_01;
reg [WO-1:0] At_M_02;
reg [WO-1:0] At_M_03;
reg [WO-1:0] At_M_04;
reg [WO-1:0] At_M_05;
reg [WO-1:0] At_M_06;
reg [WO-1:0] At_M_07;

//reg [4*WO-1:0] output_transformed;
reg [WO-1:0] At_M_A_00;
reg [WO-1:0] At_M_A_01;
reg [WO-1:0] At_M_A_02;
reg [WO-1:0] At_M_A_03;

wire [4*WO-1:0] output_transformed;


always @(posedge clk, negedge rstn) begin

	//reg initialization
	if (!rstn) begin
		
		At_M_00 <= 0;
		At_M_01 <= 0;
		At_M_02 <= 0;
		At_M_03 <= 0;
		At_M_04 <= 0;
		At_M_05 <= 0;
		At_M_06 <= 0;
		At_M_07 <= 0;

		At_M_A_00 <= 0;
		At_M_A_01 <= 0;
		At_M_A_02 <= 0;
		At_M_A_03 <= 0;

	end
	
	else begin
		// ------------------------------------------------------------
		// Stage 1: Compute A' * M
		// ------------------------------------------------------------
		At_M_00 <= $signed($signed(M[0*WI +: WI]) + $signed(M[4*WI +: WI]) + $signed(M[ 8*WI +: WI]));
		At_M_01 <= $signed($signed(M[1*WI +: WI]) + $signed(M[5*WI +: WI]) + $signed(M[ 9*WI +: WI]));
		At_M_02 <= $signed($signed(M[2*WI +: WI]) + $signed(M[6*WI +: WI]) + $signed(M[10*WI +: WI]));
		At_M_03 <= $signed($signed(M[3*WI +: WI]) + $signed(M[7*WI +: WI]) + $signed(M[11*WI +: WI]));

		At_M_04 <= $signed($signed(M[4*WI +: WI]) - $signed(M[ 8*WI +: WI]) - $signed(M[12*WI +: WI]));
		At_M_05 <= $signed($signed(M[5*WI +: WI]) - $signed(M[ 9*WI +: WI]) - $signed(M[13*WI +: WI]));
		At_M_06 <= $signed($signed(M[6*WI +: WI]) - $signed(M[10*WI +: WI]) - $signed(M[14*WI +: WI]));
		At_M_07 <= $signed($signed(M[7*WI +: WI]) - $signed(M[11*WI +: WI]) - $signed(M[15*WI +: WI])); 
		
		// ------------------------------------------------------------
		// Stage 2: Compute (A' * M) * A
		// ------------------------------------------------------------
		At_M_A_00 <= $signed($signed(At_M_00) + $signed(At_M_01) + $signed(At_M_02));
		At_M_A_01 <= $signed($signed(At_M_01) - $signed(At_M_02) - $signed(At_M_03));
		At_M_A_02 <= $signed($signed(At_M_04) + $signed(At_M_05) + $signed(At_M_06));
		At_M_A_03 <= $signed($signed(At_M_05) - $signed(At_M_06) - $signed(At_M_07));
	end
end


assign output_transformed = {At_M_A_00, At_M_A_01, At_M_A_02, At_M_A_03}; 
assign Y = output_transformed;

endmodule
