`timescale 1ns / 1ps
module elementwise_mul_tb;
parameter W=8;

    reg clk;
    reg rstn;
    reg [16*W-1:0] i_mtx_u; // 4x4 mtx in 1D tensor(len=16)
    reg [16*W-1:0] i_mtx_v; // 4x4 mtx in 1D tensor(len=16)
    wire [16*W-1:0] o_mtx_m; // 4x4 mtx in 1D tensor(len=16), each element = 16bit
//-------------------------------------------
// DUT: Elementwise multiplier
//-------------------------------------------
elementwise_mul u_elementwise_mul(
.clk(clk),
.rstn(rstn),
.i_mtx_u(i_mtx_u),
.i_mtx_v(i_mtx_v),
.o_mtx_m(o_mtx_m)
);


// Clock generation 
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b1;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test cases
initial begin

    rstn <= 1'b0;			
    i_mtx_u <= 128'd0;       
    i_mtx_v <= 128'd0;
    #(4*CLK_PERIOD) rstn <= 1'b1;


    i_mtx_u[7:0] <= 8'd1;
    i_mtx_v[7:0] <= 8'd1;

    i_mtx_u[15:8] <= 8'd2;
    i_mtx_v[15:8] <= 8'd2;

    i_mtx_u[23:16] <= 8'd3;
    i_mtx_v[23:16] <= 8'd3;

    i_mtx_u[31:24] <= 8'd4;
    i_mtx_v[31:24] <= 8'd4;

    i_mtx_u[39:32] <= 8'd1;
    i_mtx_v[39:32] <= 8'd1;

    i_mtx_u[47:40] <= 8'd2;
    i_mtx_v[47:40] <= 8'd2;

    i_mtx_u[55:48] <= 8'd3;
    i_mtx_v[55:48] <= 8'd3;

    i_mtx_u[63:56] <= 8'd4;
    i_mtx_v[63:56] <= 8'd4;

    i_mtx_u[71:64] <= 8'd1;
    i_mtx_v[71:64] <= 8'd1;

    i_mtx_u[79:72] <= 8'd2;
    i_mtx_v[79:72] <= 8'd2;

    i_mtx_u[87:80] <= 8'd3;
    i_mtx_v[87:80] <= 8'd3;

    i_mtx_u[95:88] <= 8'd4;
    i_mtx_v[95:88] <= 8'd4;

    i_mtx_u[103:96] <= 8'd1;
    i_mtx_v[103:96] <= 8'd1;

    i_mtx_u[111:104] <= 8'd2;
    i_mtx_v[111:104] <= 8'd2;

    i_mtx_u[119:112] <= 8'd3;
    i_mtx_v[119:112] <= 8'd3;

    i_mtx_u[127:120] <= 8'd4;
    i_mtx_v[127:120] <= 8'd4;
    

    #(CLK_PERIOD)
	@(posedge clk)
        i_mtx_u <= 128'd0;
        i_mtx_v <= 128'd0;
  		   
end
endmodule
