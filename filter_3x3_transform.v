`timescale 1ns / 1ps

//for the fixed G(4x3)
module filter_3x3_transform #(parameter W=10)(
    input clk,
    input rstn,
    input [71:0] filter,
    output [16*W-1:0] filter_out
);

reg [W*12-1:0] Gg; //곱이지만 사실상 합으로 구현했으므로 width는 8+8+8을 고려하여 10으로 param 설정
reg [W*16-1:0] filter_transformed; //same as above

//Gg
always@(posedge clk, negedge rstn)

begin
    if(!rstn) begin 
        Gg <= 0;
        filter_transformed <= 0;
    end

    //Gg = 4x3
    else begin
        Gg[0*W +: W] <= filter[0*W +: W];
        Gg[1*W +: W] <= filter[1*W +: W];
        Gg[2*W +: W] <= filter[2*W +: W];

        Gg[3*W +: W] <= ( filter[0*W +: W] + filter[3*W +: W] + filter[6*W +: W] ) >>> 1 ;
        Gg[4*W +: W] <= ( filter[1*W +: W] + filter[4*W +: W] + filter[7*W +: W] ) >>> 1 ;
        Gg[5*W +: W] <= ( filter[2*W +: W] + filter[5*W +: W] + filter[8*W +: W] ) >>> 1 ;

        Gg[6*W +: W] <= ( filter[0*W +: W] - filter[3*W +: W] + filter[6*W +: W] ) >>> 1 ;
        Gg[7*W +: W] <= ( filter[1*W +: W] - filter[4*W +: W] + filter[7*W +: W] ) >>> 1 ;
        Gg[8*W +: W] <= ( filter[2*W +: W] - filter[5*W +: W] + filter[8*W +: W] ) >>> 1 ;

        Gg[9*W +: W] <= filter[6*W +: W];
        Gg[10*W +: W] <= filter[7*W +: W];
        Gg[11*W +: W] <= filter[8*W +: W];


        //Gg G_transpose = 4x4
        filter_transformed[0*W +: W] <= Gg[0*W +: W];
        filter_transformed[1*W +: W] <= ( Gg[0*W +: W] + Gg[1*W +: W] + Gg[2*W +: W] ) >>> 1 ;
        filter_transformed[2*W +: W] <= ( Gg[0*W +: W] - Gg[1*W +: W] + Gg[2*W +: W] ) >>> 1 ;
        filter_transformed[3*W +: W] <= Gg[2*W +: W];

        filter_transformed[4*W +: W] <= Gg[3*W +: W];
        filter_transformed[5*W +: W] <= ( Gg[3*W +: W] + Gg[4*W +: W] + Gg[5*W +: W] ) >>> 1 ;
        filter_transformed[6*W +: W] <= ( Gg[3*W +: W] - Gg[4*W +: W] + Gg[5*W +: W] ) >>> 1 ;
        filter_transformed[7*W +: W] <= Gg[5*W +: W];

        filter_transformed[8*W +: W] <= Gg[6*W +: W];
        filter_transformed[9*W +: W] <= ( Gg[6*W +: W] + Gg[7*W +: W] + Gg[8*W +: W] ) >>> 1 ;
        filter_transformed[10*W +: W] <= ( Gg[6*W +: W] - Gg[7*W +: W] + Gg[8*W +: W] ) >>> 1 ;
        filter_transformed[11*W +: W] <= Gg[8*W +: W];

        filter_transformed[12*W +: W] <= Gg[9*W +: W];
        filter_transformed[13*W +: W] <= ( Gg[9*W +: W] + Gg[10*W +: W] + Gg[11*W +: W] ) >>> 1 ;
        filter_transformed[14*W +: W] <= ( Gg[9*W +: W] - Gg[10*W +: W] + Gg[11*W +: W] ) >>> 1 ;
        filter_transformed[15*W +: W] <= Gg[11*W +: W];
        
    end

end

assign filter_out = filter_transformed;


endmodule

