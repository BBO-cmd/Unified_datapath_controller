`timescale 1ns / 1ps

//for the fixed G(4x3)
module filter_3x3_transform_tb;

parameter W=10;
reg clk;
reg rstn;
reg [71:0] filter;
wire [127:0] filter_transformed;


//DUT: filter_3x3_transform
filter_3x3_transform u_filter_3x3_transform(
.clk(clk),
.rstn(rstn),
.filter(filter), 
.filter_out(filter_transformed)
);


// Clock generation
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b1;
	forever #(CLK_PERIOD/2) clk = ~clk;
end


//Test case
    initial begin
        rstn <= 1'b0;
        filter <= 72'd0;
        #(4*CLK_PERIOD) rstn <= 1'b1;
        filter=72'h010203040506070809; 
        #(4*CLK_PERIOD)
        rstn <= 1'b0;
        

    end

endmodule

