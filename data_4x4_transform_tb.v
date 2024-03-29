`timescale 1ns / 1ps

module data_4x4_transform_tb;

parameter W=8;
reg clk;
reg rstn;
reg [127:0] data;
wire [W*16-1:0] data_transformed;


//DUT: data_4x4_transform
data_4x4_transform u_data_4x4_transform(
    .clk(clk),
    .rstn(rstn),
    .data(data),
    .data_out(data_transformed)
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
        data <= 128'd0;
        #(4*CLK_PERIOD) rstn <= 1'b1;

        data = 128'h04040404030303030202020201010101;

        #(4*CLK_PERIOD)
        rstn <= 1'b0;
    end


endmodule


