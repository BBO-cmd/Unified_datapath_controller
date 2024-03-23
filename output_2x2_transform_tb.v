`timescale 1ns / 1ps

module output_2x2_transform_tb;

parameter W=16;
reg clk;
reg rstn;
reg [255:0] M; //4x4
wire [63:0] output_transformed; //2x2

//DUT : output 2x2 transform
output_2x2_transform u_output_2x2_transform(
    .clk(clk),
    .rstn(rstn),
    .M(M),
    .Y(output_transformed)
);

//clock generation 
parameter CLK_PERIOD = 10;
initial begin 
    clk = 1'b1;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

//Test case
    initial begin
        rstn <= 1'b0;
        M <= 256'd0;
        #(4*CLK_PERIOD) rstn <= 1'b1;

        M = 256'h0001000100010001000200020002000200030003000300030004000400040004;

        #(4*CLK_PERIOD)
        rstn <= 1'b0;

    end

    endmodule
