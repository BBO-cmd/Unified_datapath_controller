`timescale 1ns/1ps

module wino_kern_top_tb;

parameter WI=8;
parameter WWI = 12;
parameter WWO = 24; 
parameter WO=32;

reg clk;
reg rstn;
reg [ 9*WI-1:0] filter;
reg [16*WI-1:0] data;    
wire[ 4*WO-1:0] Y;

// wire [16*WWI-1:0] mtx_u;
// wire [16*WWI-1:0] mtx_v;
// wire [16*WWO-1:0] mtx_m;


// clock generation
parameter CLK_PERIOD = 10;
initial begin
    clk = 1'b1;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

//DUT
wino_kern_top u_wino_kern_top(
    .clk(clk),
    .rstn(rstn),
    .filter(filter),
    .data(data),
    .Y(Y)
);


//test case
initial begin

rstn <= 1'b0;
data <= 128'b0;
filter <= 72'b0;

#(4*CLK_PERIOD) rstn <= 1'b1;

#(2*CLK_PERIOD) @(posedge clk)
        filter = 72'h090807060504030201;
        data = 128'h04040404030303030202020201010101;


end

endmodule