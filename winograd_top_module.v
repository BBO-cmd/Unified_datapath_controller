`timescale 1ns / 1ps

module winograd_top_module #(parameter W=8)(
    input clk,
    input rstn,
    input[127:0] data,
    input[71:0] filter,
    output[255:0] Y
);

wire [127:0] filter_transformed;
wire [127:0] data_transformed;
wire [16*W*2-1:0] o_mtx_m;
reg [255:0] elementwise_op;

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
    .o_mtx_m(elementwise_op)
);

output_2x2_transform u_output_2x2_transform(
    .clk(clk),
    .rstn(rstn),
    .M(elementwise_op),
    .Y(Y)
);

endmodule

