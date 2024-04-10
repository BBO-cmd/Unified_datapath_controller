`timescale 1ns / 1ps

module wino_kern_top #(parameter WI=8, parameter WWI = 12, parameter WWO = 24, parameter WO=32)(
    input clk,
    input rstn,
    input [ 9*WI-1:0] filter,
	input [16*WI-1:0] data,    
    output[ 4*WO-1:0] Y
);

wire [16*WWI-1:0] mtx_u;
wire [16*WWI-1:0] mtx_v;
wire [16*WWO-1:0] mtx_m;

//DUT
wino_filter_transform #(.WI(WI),.WO(WWI)) 
u_wino_filter_transform(
 .clk        (clk   ),
 .rstn       (rstn  ),
 .filter     (filter),
 .filter_out (mtx_v )
);

wino_data_transform #(.WI(WI),.WO(WWI))
u_wino_data_transform(
 .clk        (clk   ),
 .rstn       (rstn  ),
 .data       (data  ),
 .data_out   (mtx_u )
);

wino_elementwise_mul #(.WI(WWI),.WO(WWO))
u_wino_elementwise_mul(
 .clk        (clk   ),
 .rstn       (rstn  ),
 .i_mtx_u    (mtx_u ),
 .i_mtx_v    (mtx_v ),
 .o_mtx_m    (mtx_m )
);

wino_output_transform #(.WI(WWO),.WO(WO))
u_wino_output_transform(
 .clk        (clk   ),
 .rstn       (rstn  ),
 .M          (mtx_m ),
 .Y          (Y     )
);

endmodule

