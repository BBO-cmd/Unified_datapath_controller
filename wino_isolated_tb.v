`timescale 1ns / 1ps


module wino_isolated_tb;

parameter W=8;

reg clk;
reg rstn; 
reg [127:0] data;
reg [71:0] filter;
wire [127:0] Y;

wire [191:0] filter_transformed;
wire [191:0] data_transformed;
wire [383:0] o_mtx_m;


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
                filter = 72'h090807060504030201;
                data = 128'h04040404030303030202020201010101;



end

//DUT
wino_filter_transform u_wino_filter_transform(
    .clk(clk),
    .rstn(rstn),
    .filter(filter),
    .filter_out(filter_transformed)
);

wino_data_transform u_wino_data_transform(
    .clk(clk),
    .rstn(rstn),
    .data(data),
    .data_out(data_transformed)
);

wino_elementwise_mul u_wino_elementwise_mul(
    .clk(clk),
    .rstn(rstn),
    .i_mtx_u(data_transformed),
    .i_mtx_v(filter_transformed),
    .o_mtx_m(o_mtx_m)
);

wino_output_transform u_wino_output_transform(
    .clk(clk),
    .rstn(rstn),
    .M(o_mtx_m),
    .Y(Y)
);




endmodule

