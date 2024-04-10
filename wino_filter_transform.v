`timescale 1ns / 1ps

//for the fixed G(4x3)
module wino_filter_transform #(parameter WI=8, parameter WO = 12)(
    input clk,
    input rstn,
    input  [ 9*WI-1:0] filter,
    output [16*WO-1:0] filter_out
);

//reg [12*WO-1:0] Gg;
reg [WO-1:0] Gg_00;
reg [WO-1:0] Gg_01;
reg [WO-1:0] Gg_02;
reg [WO-1:0] Gg_03;
reg [WO-1:0] Gg_04;
reg [WO-1:0] Gg_05;
reg [WO-1:0] Gg_06;
reg [WO-1:0] Gg_07;
reg [WO-1:0] Gg_08;
reg [WO-1:0] Gg_09;
reg [WO-1:0] Gg_10;
reg [WO-1:0] Gg_11;

//reg [16*WO-1:0] filter_transformed;
reg [WO-1:0] GgGt_00;
reg [WO-1:0] GgGt_01;
reg [WO-1:0] GgGt_02;
reg [WO-1:0] GgGt_03;
reg [WO-1:0] GgGt_04;
reg [WO-1:0] GgGt_05;
reg [WO-1:0] GgGt_06;
reg [WO-1:0] GgGt_07;
reg [WO-1:0] GgGt_08;
reg [WO-1:0] GgGt_09;
reg [WO-1:0] GgGt_10;
reg [WO-1:0] GgGt_11;
reg [WO-1:0] GgGt_12;
reg [WO-1:0] GgGt_13;
reg [WO-1:0] GgGt_14;
reg [WO-1:0] GgGt_15;


wire [16*WO-1:0] filter_transformed;


//reg initialization
always@(posedge clk, negedge rstn) begin
    if(!rstn) begin 
        Gg_00 <= 0;
        Gg_01 <= 0;
        Gg_02 <= 0;
        Gg_03 <= 0;
        Gg_04 <= 0;
        Gg_05 <= 0;
        Gg_06 <= 0;
        Gg_07 <= 0;
        Gg_08 <= 0;
        Gg_09 <= 0;
        Gg_10 <= 0;
        Gg_11 <= 0;

        GgGt_00 <= 0;
        GgGt_01 <= 0;
        GgGt_02 <= 0;
        GgGt_03 <= 0;
        GgGt_04 <= 0;
        GgGt_05 <= 0;
        GgGt_06 <= 0;
        GgGt_07 <= 0;
        GgGt_08 <= 0;
        GgGt_09 <= 0;
        GgGt_10 <= 0;
        GgGt_11 <= 0;
        GgGt_12 <= 0;
        GgGt_13 <= 0;
        GgGt_14 <= 0;
        GgGt_15 <= 0;

    end    
    else begin
		// ------------------------------------------------------------
		// Stage 1: Compute G *g 
		// ------------------------------------------------------------
        Gg_00 <= $signed(filter[0*WI +: WI]);
        Gg_01 <= $signed(filter[1*WI +: WI]);
        Gg_02 <= $signed(filter[2*WI +: WI]);

        Gg_03 <= $signed($signed(($signed(filter[0*WI +: WI]) + $signed(filter[3*WI +: WI]) + $signed(filter[6*WI +: WI]))) >>> 1) ;
        Gg_04 <= $signed($signed(($signed(filter[1*WI +: WI]) + $signed(filter[4*WI +: WI]) + $signed(filter[7*WI +: WI]))) >>> 1) ;
        Gg_05 <= $signed($signed(($signed(filter[2*WI +: WI]) + $signed(filter[5*WI +: WI]) + $signed(filter[8*WI +: WI]))) >>> 1) ;

        Gg_06 <= $signed($signed(($signed(filter[0*WI +: WI]) - $signed(filter[3*WI +: WI]) + $signed(filter[6*WI +: WI]))) >>> 1) ;
        Gg_07 <= $signed($signed(($signed(filter[1*WI +: WI]) - $signed(filter[4*WI +: WI]) + $signed(filter[7*WI +: WI]))) >>> 1) ;
        Gg_08 <= $signed($signed(($signed(filter[2*WI +: WI]) - $signed(filter[5*WI +: WI]) + $signed(filter[8*WI +: WI]))) >>> 1) ;

        Gg_09 <= $signed(filter[6*WI +: WI]);
        Gg_10 <= $signed(filter[7*WI +: WI]);
        Gg_11 <= $signed(filter[8*WI +: WI]);

		// ------------------------------------------------------------
        // Stage 2: Compute (G*g) * G'
		// ------------------------------------------------------------
        GgGt_00<=  $signed(Gg_00);
        GgGt_01<=  $signed($signed(($signed(Gg_00) + $signed(Gg_01) + $signed(Gg_02))) >>> 1) ;
        GgGt_02<=  $signed($signed(($signed(Gg_00) - $signed(Gg_01) + $signed(Gg_02))) >>> 1) ;
        GgGt_03<=  $signed(Gg_02);

        GgGt_04<=  $signed(Gg_03);
        GgGt_05<=  $signed($signed(($signed(Gg_03) + $signed(Gg_04) + $signed(Gg_05))) >>> 1) ;
        GgGt_06<=  $signed($signed(($signed(Gg_03) - $signed(Gg_04) + $signed(Gg_05))) >>> 1) ;
        GgGt_07<=  $signed(Gg_05);

        GgGt_08 <=  $signed(Gg_06);
        GgGt_09 <=  $signed($signed(($signed(Gg_06) + $signed(Gg_07) + $signed(Gg_08))) >>> 1) ;
        GgGt_10 <=  $signed($signed(($signed(Gg_06) - $signed(Gg_07) + $signed(Gg_08))) >>> 1) ;
        GgGt_11 <=  $signed(Gg_08);

        GgGt_12 <=  $signed(Gg_09);
        GgGt_13 <=  $signed($signed(($signed(Gg_09) + $signed(Gg_10) + $signed(Gg_11))) >>> 1) ;
        GgGt_14 <=  $signed($signed(($signed(Gg_09) - $signed(Gg_10) + $signed(Gg_11))) >>> 1) ;
        GgGt_15 <=  $signed(Gg_11);

    end

end

assign filter_transformed = {GgGt_00, GgGt_01, GgGt_02, GgGt_03, 
							GgGt_04, GgGt_05, GgGt_06,GgGt_07,
							GgGt_08, GgGt_09, GgGt_10, GgGt_11, 
							GgGt_12, GgGt_13, GgGt_14,GgGt_15
							}; 
assign filter_out = filter_transformed;

endmodule


