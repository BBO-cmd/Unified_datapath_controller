`timescale 1ns / 1ps

module elementwise_mul_tb;
    reg clk;
    reg rstn;
    reg [127:0] U_entry; // 4x4 mtx in 1D tensor(len=16)
    reg [127:0] V_entry; // 4x4 mtx in 1D tensor(len=16)
    //output reg [127:0] M;       // 4x4 mtx in 1D tensor(len=16) 
//-------------------------------------------
// DUT: Elementwise multiplier
//-------------------------------------------
elementwise_mul u_elementwise_mul(
.clk(clk),
.rstn(rstn),
.U_entry(U_entry),
.V_entry(V_entry),
.M(M)
);


// Clock
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b1;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test cases
initial begin

    rstn = 1'b0;			// Reset, low active
    U_entry = 128'd0;
    V_entry = 128'd0;
    #(4*CLK_PERIOD) rstn = 1'b1;


    U_entry[7:0] = 8'd1;
    V_entry[7:0] = 8'd1;

    U_entry[15:8] = 8'd2;
    V_entry[15:8] = 8'd2;

    U_entry[23:16] = 8'd3;
    V_entry[23:16] = 8'd3;

    U_entry[31:24] = 8'd4;
    V_entry[31:24] = 8'd4;

    U_entry[39:32] = 8'd5;
    V_entry[39:32] = 8'd5;

    U_entry[47:40] = 8'd6;
    V_entry[47:40] = 8'd6;

    U_entry[55:48] = 8'd7;
    V_entry[55:48] = 8'd7;

    U_entry[63:56] = 8'd8;
    V_entry[63:56] = 8'd8;

    U_entry[71:64] = 8'd9;
    V_entry[71:64] = 8'd9;

    U_entry[79:72] = 8'd10;
    V_entry[79:72] = 8'd10;

    U_entry[87:80] = 8'd11;
    V_entry[87:80] = 8'd11;

    U_entry[95:88] = 8'd12;
    V_entry[95:88] = 8'd12;

    U_entry[103:96] = 8'd13;
    V_entry[103:96] = 8'd13;

    U_entry[111:104] = 8'd14;
    V_entry[111:104] = 8'd14;

    U_entry[119:112] = 8'd15;
    V_entry[119:112] = 8'd15;

    U_entry[127:120] = 8'd16;
    V_entry[127:120] = 8'd16;
    


    
    #(CLK_PERIOD) 
	@(posedge clk) 		
        U_entry = 128'd0;
        V_entry = 128'd0;
  		   
end
endmodule
