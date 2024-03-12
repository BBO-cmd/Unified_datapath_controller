`timescale 1ns/1ps

module matmul_mxnxl_tb;

    parameter W=8;
    parameter M=4;
    parameter N=3;
    parameter L=3;

    reg clk;
    reg rstn;
    reg [M*N*W-1:0] transformation_mtx;        // G(4x3)
    reg [N*L*W-1:0] input_mtx;                 // g(3x3)
    output [M*L*W-1:0] result_mtx;             // Gg(4x3)


    //-------------------------------------------
    // DUT: matmul_mxnxl.v
    //-------------------------------------------
    matmul_mxnxl u_matmul_mxnxl(
    .clk(clk),
    .rstn(rstn),
    .transformation_mtx(transformation_mtx),
    .input_mtx(input_mtx),
    .result_mtx(result_mtx)
    );

    // Clock
    parameter CLK_PERIOD = 10;	//100MHz
    initial begin
        clk = 1'b1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //Test cases
    initial begin

        rstn <= 1'b0;
        transformation_mtx <= 96'h0102030405060708090A0B0C;
        input_mtx <= 72'h010203040506070809;
        
        
        #(CLK_PERIOD)
        transformation_mtx = 96'h0;
        input_mtx = 72'h0;
    end
endmodule







        


