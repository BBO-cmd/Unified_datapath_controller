`timescale 1ns / 1ps

//for the fixed B_transpose(4x4)
module data_4x4_transform #(parameter W=8)(
    input clk,
    input rstn, 
    input [127:0] data,
    output [W*16-1:0] data_out
    );

reg [W*16-1:0] B_Td;
reg [W*16-1:0] data_transformed;

always @(posedge clk, negedge rstn)
     
    begin 
        if(rstn) begin
            B_Td <= 0; //always posedge...에는 항상 non-blocking 사용 권장
            data_transformed <= 0;
        end
        



        else begin

            //B_Td = 4x4
            B_Td[0*W +: W] <= data[0*W +: W] - data[8*W +: W];
            B_Td[1*W +: W] <= data[1*W +: W] - data[9*W +: W];
            B_Td[2*W +: W] <= data[2*W +: W] - data[10*W +: W];
            B_Td[3*W +: W] <= data[3*W +: W] - data[11*W +: W];


            B_Td[4*W +: W] <= data[4*W +: W] + data[8*W +: W];
            B_Td[5*W +: W] <= data[5*W +: W] + data[9*W +: W];
            B_Td[6*W +: W] <= data[6*W +: W] + data[10*W +: W];
            B_Td[7*W +: W] <= data[7*W +: W] + data[11*W +: W];


            B_Td[8*W +: W] <= - data[4*W +: W] + data[8*W +: W];
            B_Td[9*W +: W] <= - data[5*W +: W] + data[9*W +: W];
            B_Td[10*W +: W] <= - data[6*W +: W] + data[10*W +: W];
            B_Td[11*W +: W] <= - data[7*W +: W] + data[11*W +: W];


            B_Td[12*W +: W] <= data[4*W +: W] - data[12*W +: W];
            B_Td[13*W +: W] <= data[5*W +: W] - data[13*W +: W];
            B_Td[14*W +: W] <= data[6*W +: W] - data[14*W +: W];
            B_Td[15*W +: W] <= data[7*W +: W] - data[15*W +: W];


            //B_transpose d B = 4x4
            data_transformed[0*W +: W] <= B_Td[0*W +: W] - B_Td[2*W +: W];
            data_transformed[1*W +: W] <= B_Td[1*W +: W] + B_Td[2*W +: W];
            data_transformed[2*W +: W] <= - B_Td[1*W +: W] + B_Td[2*W +: W];
            data_transformed[3*W +: W] <= B_Td[1*W +: W] - B_Td[3*W +: W];


            data_transformed[4*W +: W] <= B_Td[4*W +: W] - B_Td[6*W +: W];
            data_transformed[5*W +: W] <= B_Td[5*W +: W] + B_Td[6*W +: W];
            data_transformed[6*W +: W] <= - B_Td[5*W +: W] + B_Td[6*W +: W];
            data_transformed[7*W +: W] <= B_Td[5*W +: W] - B_Td[7*W +: W];


            data_transformed[8*W +: W] <= B_Td[8*W +: W] - B_Td[10*W +: W];
            data_transformed[9*W +: W] <= B_Td[9*W +: W] + B_Td[10*W +: W];
            data_transformed[10*W +: W] <= - B_Td[9*W +: W] + B_Td[10*W +: W];
            data_transformed[11*W +: W] <= B_Td[9*W +: W] - B_Td[11*W +: W];


            data_transformed[12*W +: W] <= B_Td[12*W +: W] - B_Td[14*W +: W];
            data_transformed[13*W +: W] <= B_Td[13*W +: W] + B_Td[14*W +: W];
            data_transformed[14*W +: W] <= - B_Td[13*W +: W] + B_Td[14*W +: W];
            data_transformed[15*W +: W] <= B_Td[13*W +: W] - B_Td[15*W +: W];

        end 
    end

assign data_out = data_transformed;


endmodule
