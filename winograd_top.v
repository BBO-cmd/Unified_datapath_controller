`timescale 1ns / 1ps


module winograd_top;

parameter W=8;

reg clk;
reg rstn; 
reg [127:0] data;
reg [71:0] filter;
wire [63:0] Y;

wire [127:0] filter_transformed;
wire [127:0] data_transformed;
wire [16*W*2-1:0] o_mtx_m;
reg [63:0] elementwise_op;


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

    #(4*CLK_PERIOD)

         @(posedge clk)
                filter = 72'h030303060606090909;
                data = 128'h01010101020202020303030304040404;

    //#(4*CLK_PERIOD) rstn <= 1'b0;

end

//DUT
filter_3x3_transform u_filter_3x3_transform(
    .clk(clk),
    .rstn(rstn),
    .filter(filter),
    .filter_out(filter_transformed)
);

data_4x4_transform u_data_4x4_transform(
    .clk(clk),
    .rstn(rstn),
    .data(data),
    .data_out(data_transformed)
);

elementwise_mul u_elementwise_mul(
    .clk(clk),
    .rstn(rstn),
    .i_mtx_u(data_transformed),
    .i_mtx_v(filter_transformed),
    .o_mtx_m(o_mtx_m)
);

output_2x2_transform u_output_2x2_transform(
    .clk(clk),
    .rstn(rstn),
    .M(o_mtx_m),
    .Y(Y)
);




endmodule

