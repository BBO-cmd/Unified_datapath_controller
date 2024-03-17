`timescale 1ns / 1ps

module winograd_top_tb;

reg clk;
reg rstn; 

reg [127:0] data;
reg [71:0] filter;
wire [63:0] ofmap;


//DUT: winograd_top module
winograd_top u_winograd_top(
    .clk(clk),
    .rstn(rstn),
    .data(data),
    .filter(filter),
    .ofmap(ofmap)
);

//clock generation
parameter CLK_PERIOD = 10;
initial begin 
    clk = 1'b1;
    forever #(CLK_PERIOD/2) clk = ~clk;
end


//test case
initial begin
    rstn <= 1'b0;
    data <= 128'b0;
    filter <= 64'b0;
    #(4*CLK_PERIOD) rstn <= 1'b1;

    filter = 72'h030303060606090909;
    data = 128'h01010101020202020303030304040404;

    #(4*CLK_PERIOD) rstn <= 1'b0;

end
endmodule



