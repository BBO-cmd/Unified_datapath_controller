`timescale 1ns / 1ps

//for the fixed G(4x3)
module filter_3x3_transform #(parameter W=8)(
    input clk,
    input rstn,
    input [71:0] filter,
    output [127:0] filter_transformed
);


//G g G_transpose = 4x4
assign filter_transformed[0*W +: W] = filter[0*W +: W];
assign filter_transformed[1*W +: W] = ( filter[0*W +: W] + filter[1*W +: W] + filter[2*W +: W] ) >>> 1 ;
assign filter_transformed[2*W +: W] = ( filter[0*W +: W] - filter[1*W +: W] + filter[2*W +: W] ) >>> 1 ;
assign filter_transformed[3*W +: W] = filter[2*W +: W];


assign filter_transformed[4*W +: W] = ( filter[0*W +: W] + filter[3*W +: W] + filter[6*W +: W] ) >>> 1 ;
assign filter_transformed[5*W +: W] = ( filter[0*W +: W] + filter[1*W +: W] + filter[2*W +: W]
                                + filter[3*W +: W] + filter[4*W +: W] + filter[5*W +: W]
                                + filter[6*W +: W] + filter[7*W +: W] + filter[8*W +: W]  ) >>> 2 ;
assign filter_transformed[6*W +: W] = ( filter[0*W +: W] + filter[3*W +: W] + filter[6*W +: W]
                                - filter[1*W +: W] - filter[4*W +: W] - filter[7*W +: W]
                                + filter[2*W +: W] + filter[5*W +: W] + filter[8*W +: W]  ) >>> 2 ;
assign filter_transformed[7*W +: W] = ( filter[2*W +: W] + filter[5*W +: W] + filter[8*W +: W] ) >>> 1 ;


assign filter_transformed[8*W +: W] = ( filter[0*W +: W] - filter[3*W +: W] + filter[6*W +: W] ) >>> 1 ;
assign filter_transformed[9*W +: W] = ( filter[0*W +: W] - filter[3*W +: W] + filter[6*W +: W]
                                + filter[1*W +: W] - filter[4*W +: W] + filter[7*W +: W]
                                + filter[2*W +: W] - filter[5*W +: W] + filter[8*W +: W]  ) >>> 2 ;
assign filter_transformed[10*W +: W] = ( filter[0*W +: W] - filter[1*W +: W] + filter[2*W +: W]
                                - filter[3*W +: W] + filter[4*W +: W] - filter[5*W +: W]
                                + filter[6*W +: W] - filter[7*W +: W] + filter[8*W +: W]  ) >>> 2 ;
assign filter_transformed[11*W +: W] = ( filter[2*W +: W] - filter[5*W +: W] + filter[8*W +: W] ) >>> 1 ;


assign filter_transformed[12*W +: W] = filter[6*W +: W];
assign filter_transformed[13*W +: W] = ( filter[6*W +: W] + filter[7*W +: W] + filter[8*W +: W] ) >>> 1 ;
assign filter_transformed[14*W +: W] = ( filter[6*W +: W] - filter[7*W +: W] + filter[8*W +: W] ) >>> 1 ;
assign filter_transformed[15*W +: W] = filter[8*W +: W];


endmodule

