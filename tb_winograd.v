`timescale 1ns / 1ns

//`include "../src/define.v"
module tb_winograd;

// Check your file path
parameter IFM_FILE   = "C:\Users\gram14\Desktop\winograd\sim\inout_data_sw\log_feamap\CONV00_input_32b.hex"; 
parameter WGT_FILE   = "C:\Users\gram14\Desktop\winograd\sim\inout_data_sw\log_param\CONV00_param_weight.hex"; 
parameter OUTFILE00  = "C:\Users\gram14\Desktop\winograd\sim\inout_data_hw\CONV00_ch00.bmp"; 
parameter OUTFILE01  = "C:\Users\gram14\Desktop\winograd\sim\inout_data_hw\CONV00_ch01.bmp"; 
parameter OUTFILE02  = "C:\Users\gram14\Desktop\winograd\sim\inout_data_hw\CONV00_ch02.bmp"; 
parameter OUTFILE03  = "C:\Users\gram14\Desktop\winograd\sim\inout_data_hw\CONV00_ch03.bmp"; 

localparam MEM_ADDRW = 22;
localparam MEM_DW = 16;
localparam A = 32;
localparam D = 32;
localparam I = 4;
localparam L = 8;
localparam M = D/8;

// Clock
parameter CLK_PERIOD = 10;   //100MHz
reg clk;
reg rstn;

initial begin
   clk = 1'b1;
   forever #(CLK_PERIOD/2) clk = ~clk;
end

//--------------------------------------------------------------------
// Insert your Winograd module
//--------------------------------------------------------------------

reg [127:0] data; 
reg [71:0] filter;
wire [63:0] Y;

winograd_top_module u_winograd_top_module(
	.clk(clk),
	.rstn(rstn),
	.data(data),
	.filter(filter),
	.Y(Y)
);


//--------------------------------------------------------------------
// For debugging: Check load inputs
//--------------------------------------------------------------------
parameter IFM_DATA_SIZE = 256*256;		// Layer 00 //이걸 4x4로 잘라서 사용해야 함
parameter IFM_WORD_SIZE = 8; // 원래 32였는데, int8로 일단 설정했으므로 8로 바꿈
parameter Fx = 3, Fy = 3; //filter크기 3x3
parameter Ni = 3, No = 16; // channel size, filter 개수인듯
parameter WGT_DATA_SIZE = Fx*Fy*Ni*No;	// Layer 00
parameter WGT_WORD_SIZE = 8; //마찬가지로 원래 32에서 8로 일단 수정

// 결과적으로: 둘다 word size는 8(int8)를 target하지만 일단은 32->8 truncated
// 나중에 quantized input넣어주면 됨

// size는 data: 256x256
// filter: 3x3x3x16

reg  [IFM_WORD_SIZE-1:0] d_mem[0:IFM_DATA_SIZE-1];  // Infmap //한 frame 다 laod
reg  [WGT_WORD_SIZE-1:0] g_mem[0:WGT_DATA_SIZE-1];	// Filter //한 layer에 대한 filter 모두 다 load
reg  preload; //control signal(1bit)

// Load memory from file
integer i;
initial begin: PROC_SimmemLoad
	for (i = 0; i< IFM_DATA_SIZE; i=i+1) begin
		d_mem[i] = 0;
	end

	$display ("Loading input feature maps from file: %s", IFM_FILE);
	$readmemh(IFM_FILE, d_mem);
	
	for (i = 0; i< WGT_DATA_SIZE; i=i+1) begin
		g_mem[i] = 0;
	end

	$display ("Loading input feature maps from file: %s", WGT_FILE);
	$readmemh(WGT_FILE, g_mem);	
end

integer j;
integer row;
integer col;

initial begin
   rstn = 1'b0;         // Reset, low active   
   preload = 1'b0;
   #(4*CLK_PERIOD) rstn = 1'b1; 	

   #(100*CLK_PERIOD) 	// reset disable 하고나서 100 cycle 이후에(load됨) 
        @(posedge clk)
            preload = 1'b1;		//load완료

	// Show the filter			
   #(100*CLK_PERIOD) //다음 filter가 load됨과 동시에
        @(posedge clk)
		for (j=0; j < No; j=j+1) begin //16 filter에 대해서
			$display("Filter och=%02d: \n",j); 
			
			for(i = 0; i < 3; i = i + 1) begin //3channel에 대해서
				$display("%d\t%d\t%d", //filter size(cell 9개)

					$signed(g_mem[(j*Fx*Fy*Ni) + (3*i  )][7:0]),
					$signed(g_mem[(j*Fx*Fy*Ni) + (3*i+1)][7:0]),
					$signed(g_mem[(j*Fx*Fy*Ni) + (3*i+2)][7:0]));

					//feed the filter input to the DUT
					filter <= {g_mem[(j*Fx*Fy*Ni) + (3*i  )][7:0],g_mem[(j*Fx*Fy*Ni) + (3*i+1)][7:0], g_mem[(j*Fx*Fy*Ni) + (3*i+2)][7:0]};
			end
			$display("\n");						
		end
		
   #(100*CLK_PERIOD) 
        @(posedge clk)
            preload = 1'b0;		//load 다시 시작

	// *****************************************			
	// Insert your code to test Winograd
	// *****************************************		
end

	always@(*) begin
		for(row = 0; row < 256; row = row + 1)	begin 
			#(100*CLK_PERIOD)//data load

			for (col = 0; col < 256; col = col + 1) begin

				//slidig window
				data = 128'd0;

					//Tiled IFM data
					data[ 7: 0] = d_mem[(row-1) * 256 + (col-1)];
					data[15: 8] = d_mem[(row-1) * 256 +  col   ];
					data[23:16] = d_mem[(row-1) * 256 + (col+1)];
					data[31:24] = d_mem[(row-1) * 256 + (col+2)];
					
					data[39:32] = d_mem[ row  * 256 +  (col-1) ];
					data[47:40] = d_mem[ row  * 256 +     col  ];
					data[55:48] = d_mem[ row  * 256 + (col+1)  ];
					data[63:56] = d_mem[ row  * 256 + (col+2)  ];
					
					data[71:64] = d_mem[(row+1) * 256 + (col-1)];
					data[79:72] = d_mem[(row+1) * 256 + (col)  ];
					data[87:80] = d_mem[(row+1) * 256 + (col+1)];
					data[95:88] = d_mem[(row+1) * 256 + (col+2)];
					
					data[103:96] = d_mem[(row+2) * 256 + (col-1)];
					data[111:104] = d_mem[(row+2) * 256 + (col  )];
					data[119:112] = d_mem[(row+2) * 256 + (col+1)];
					data[127:120] = d_mem[(row+2) * 256 + (col+2)];
					




					// // Tiled IFM data
					// data[ 7: 0] = (is_first_row||is_first_col) ? 8'd0 : d_mem[(row-1) * IFM_WIDTH + (col-1)];
					// data[15: 8] = (is_first_row				 ) ? 8'd0 : d_mem[(row-1) * IFM_WIDTH +  col   ];
					// data[23:16] = (is_first_row				 ) ? 8'd0 : d_mem[(row-1) * IFM_WIDTH + (col+1)];
					// data[31:24] = (is_first_row||is_last_col ) ? 8'd0 : d_mem[(row-1) * IFM_WIDTH + (col+2)];
					
					// data[39:32] = (   			 is_first_col) ? 8'd0 : d_mem[ row  * IFM_WIDTH +  (col-1) ];
					// data[47:40] = 										d_mem[ row  * IFM_WIDTH +     col  ];
					// data[55:48] = 										d_mem[ row  * IFM_WIDTH + (col+1)  ];
					// data[63:56] = (   			  is_last_col) ? 8'd0 : d_mem[ row  * IFM_WIDTH + (col+2)  ];
					
					// data[71:64] = (   			 is_first_col) ? 8'd0 : d_mem[(row+1) * IFM_WIDTH + (col-1)];
					// data[79:72] = 										d_mem[(row+1) * IFM_WIDTH + (col)  ];
					// data[87:80] = 										d_mem[(row+1) * IFM_WIDTH + (col+1)];
					// data[95:88] = (   			  is_last_col) ? 8'd0 : d_mem[(row+1) * IFM_WIDTH + (col+2)];
					
					// data[103:96] = (is_last_row||is_first_col) ? 8'd0 : d_mem[(row+2) * IFM_WIDTH + (col-1)];
					// data[111:104] = (is_last_row			 ) ? 8'd0 : d_mem[(row+2) * IFM_WIDTH + (col  )];
					// data[119:112] = (is_last_row			 ) ? 8'd0 : d_mem[(row+2) * IFM_WIDTH + (col+1)];
					// data[127:120] = (is_last_row||is_last_col) ? 8'd0 : d_mem[(row+2) * IFM_WIDTH + (col+2)];
					// end


			
			end
		end
	end
	

// The code  to check 
reg 		dbg_write_image;
reg 		dbg_write_image_done;
reg [31:0]	dbg_pix_idx;
always @(posedge clk, negedge rstn) begin
	if(!rstn) begin
		dbg_write_image 		<= 0;
		dbg_write_image_done 	<= 0;
		dbg_pix_idx 			<= 0;
	end 
	else begin 
		if(dbg_write_image) begin 
			if(dbg_pix_idx < IFM_DATA_SIZE) begin 
				if(dbg_pix_idx == IFM_DATA_SIZE - 1) begin 
					dbg_write_image 		<= 0;
					dbg_write_image_done 	<= 1;
					dbg_pix_idx 			<= 0;		
				end 
				else 
					dbg_pix_idx <= dbg_pix_idx + 1;
			end 
		end 
		else if(preload) begin
			dbg_write_image 		<= 1;
			dbg_write_image_done 	<= 0;
			dbg_pix_idx 			<= 0;			
		end
	end 
end
bmp_image_writer #(.OUTFILE(OUTFILE00),.WIDTH(256),.HEIGHT(256))
u_bmp_image_writer_00(
	./*input 			*/clk		(clk						),
	./*input 			*/rstn		(rstn						),
	./*input [WI-1:0] 	*/din		(d_mem[dbg_pix_idx][7:0]	),
	./*input 			*/vld		(dbg_write_image			),
	./*output reg 		*/frame_done(							)
);
bmp_image_writer #(.OUTFILE(OUTFILE01),.WIDTH(256),.HEIGHT(256))
u_bmp_image_writer_01(
	./*input 			*/clk		(clk					 	),
	./*input 			*/rstn		(rstn					 	),
	./*input [WI-1:0] 	*/din		(d_mem[dbg_pix_idx][15:8]	),
	./*input 			*/vld		(dbg_write_image		 	),
	./*output reg 		*/frame_done(						 	)
);
bmp_image_writer #(.OUTFILE(OUTFILE02),.WIDTH(256),.HEIGHT(256))
u_bmp_image_writer_02(
	./*input 			*/clk		(clk					  	),
	./*input 			*/rstn		(rstn					  	),
	./*input [WI-1:0] 	*/din		(d_mem[dbg_pix_idx][23:16]	),
	./*input 			*/vld		(dbg_write_image		  	),
	./*output reg 		*/frame_done(					 		)
);
bmp_image_writer #(.OUTFILE(OUTFILE03),.WIDTH(256),.HEIGHT(256))
u_bmp_image_writer_03(
	./*input 			*/clk		(clk						),
	./*input 			*/rstn		(rstn						),
	./*input [WI-1:0] 	*/din		(d_mem[dbg_pix_idx][31:24]	),
	./*input 			*/vld		(dbg_write_image			),
	./*output reg 		*/frame_done(							)
);

////AXI Master IF0 for input/out access
//wire  [I-1:0]     i_AWID;       // Address ID
//wire  [A-1:0]     i_AWADDR;     // Address Write
//wire  [L-1:0]     i_AWLEN;      // Transfer length
//wire  [2:0]       i_AWSIZE;     // Transfer width
//wire  [1:0]       i_AWBURST;    // Burst type
//wire  [1:0]       i_AWLOCK;     // Atomic access information
//wire  [3:0]       i_AWCACHE;    // Cachable/bufferable infor
//wire  [2:0]       i_AWPROT;     // Protection info
//wire              i_AWVALID;    // address/control valid handshake
//wire              i_AWREADY;
//wire  [I-1:0]     i_WID;        // Write ID
//wire  [D-1:0]     i_WDATA;      // Write Data bus
//wire  [M-1:0]     i_WSTRB;      // Write Data byte lane strobes
//wire              i_WLAST;      // Last beat of a burst transfer
//wire              i_WVALID;     // Write data valid
//wire              i_WREADY;     // Write data ready
//wire [I-1:0]      i_BID;        // buffered response ID
//wire [1:0]        i_BRESP;      // Buffered write response
//wire              i_BVALID;     // Response info valid
//wire              i_BREADY;     // Response info ready (to slave)
//wire  [I-1:0]     i_ARID;       // Read addr ID
//wire  [A-1:0]     i_ARADDR;     // Address Read 
//wire  [L-1:0]     i_ARLEN;      // Transfer length
//wire  [2:0]       i_ARSIZE;     // Transfer width
//wire  [1:0]       i_ARBURST;    // Burst type
//wire  [1:0]       i_ARLOCK;     // Atomic access information
//wire  [3:0]       i_ARCACHE;    // Cachable/bufferable infor
//wire  [2:0]       i_ARPROT;     // Protection info
//wire              i_ARVALID;    // address/control valid handshake
//wire              i_ARREADY;
//wire  [I-1:0]     i_RID;        // Read ID
//wire  [D-1:0]     i_RDATA;      // Read data bus
//wire  [1:0]       i_RRESP;      // Read response
//wire              i_RLAST;      // Last beat of a burst transfer
//wire              i_RVALID;     // Read data valid 
//wire              i_RREADY;     // Read data ready (to Slave)
//
//// Memory ports for input (activation)
//wire [MEM_ADDRW-1:0]   mem_addr;
//wire                   mem_we;
//wire [MEM_DW-1:0]      mem_di;
//wire [MEM_DW-1:0]      mem_do;
//
////--------------------------------------------------------------------
////AXI Slave External Memory: Input
////--------------------------------------------------------------------
//axi_sram_if #(  //New
//   .MEM_ADDRW(MEM_ADDRW), .MEM_DW(MEM_DW),
//   .A(A), .I(I), .L(L), .D(D), .M(M))
//u_axi_ext_mem_if_input(
//   .ACLK(clk), .ARESETn(rstn),
//    
//   //AXI Slave IF
//   .AWID(i_AWID),       // Address ID
//   .AWADDR(i_AWADDR),     // Address Write
//   .AWLEN(i_AWLEN),      // Transfer length
//   .AWSIZE(i_AWSIZE),     // Transfer width
//   .AWBURST(i_AWBURST),    // Burst type
//   .AWLOCK(i_AWLOCK),     // Atomic access information
//   .AWCACHE(i_AWCACHE),    // Cachable/bufferable infor
//   .AWPROT(i_AWPROT),     // Protection info
//   .AWVALID(i_AWVALID),    // address/control valid handshake
//   .AWREADY(i_AWREADY),
//   //Write data channel
//   .WID(i_WID),        // Write ID
//   .WDATA(i_WDATA),      // Write Data bus
//   .WSTRB(i_WSTRB),      // Write Data byte lane strobes
//   .WLAST(i_WLAST),      // Last beat of a burst transfer
//   .WVALID(i_WVALID),     // Write data valid
//   .WREADY(i_WREADY),     // Write data ready
//    //Write response channel
//   .BID(i_BID),        // buffered response ID
//   .BRESP(i_BRESP),      // Buffered write response
//   .BVALID(i_BVALID),     // Response info valid
//   .BREADY(i_BREADY),     // Response info ready (from Master)
//      
//   .ARID    (i_ARID),   // Read addr ID
//   .ARADDR  (i_ARADDR),   // Address Read 
//   .ARLEN   (i_ARLEN),   // Transfer length
//   .ARSIZE  (i_ARSIZE),   // Transfer width
//   .ARBURST (i_ARBURST),   // Burst type
//   .ARLOCK  (i_ARLOCK),   // Atomic access information
//   .ARCACHE (i_ARCACHE),   // Cachable/bufferable infor
//   .ARPROT  (i_ARPROT),   // Protection info
//   .ARVALID (i_ARVALID),   // address/control valid handshake
//   .ARREADY (i_ARREADY),
//   .RID     (i_RID),   // Read ID
//   .RDATA   (i_RDATA),   // Read data bus
//   .RRESP   (i_RRESP),   // Read response
//   .RLAST   (i_RLAST),   // Last beat of a burst transfer
//   .RVALID  (i_RVALID),   // Read data valid 
//   .RREADY  (i_RREADY),   // Read data ready (to Slave)
//
//   //Interface to SRAM 
//   .mem_addr   (mem_addr),
//   .mem_we     (mem_we),
//   .mem_di     (mem_di),
//   .mem_do     (mem_do)
//);
//
//
//// Input
////IMEM for SIM
//// Inputs
//sram #(
//   .FILE_NAME(IFM_FILE),
//   .SIZE(2**MEM_ADDRW),
//   .WL_ADDR(MEM_ADDRW),
//   .WL_DATA(MEM_DW))
//u_ext_mem_input (
//   .clk   (clk),
//   .rst   (rstn),
//   .addr  (mem_addr),
//   .wdata (mem_di),
//   .rdata (mem_do),
//   .ena   (1'b0)     // Read only
//   );
//
////--------------------------------------------------------------------
//// CNN Accelerator
////--------------------------------------------------------------------
//reg [31:0] i_0;
//reg [31:0] i_1;
//reg [31:0] i_2;
//	
//`ifdef PRELOAD
//reg preload;
//reg [4:0] preload_layer_idx;
//wire network_done;
//wire network_done_led;
//wire [4:0] layer_num_idx;
///*
//Layer 6: 3
//Layer 8: 4
//Layer 10: 5
//Layer 12: 6
//Layer 13: 7
//Layer 16: 8
//Layer 19: 9
//Layer 20: 10
//*/
//`endif
//yolo_engine #(
//    .AXI_WIDTH_AD(A),
//    .AXI_WIDTH_ID(4),
//    .AXI_WIDTH_DA(D),
//    .AXI_WIDTH_DS(M),
//    .MEM_BASE_ADDR(2048),
//    .MEM_DATA_BASE_ADDR(2048)
//)
//u_yolo_engine
//(
//    .clk(clk),
//    .rstn(rstn),
//    .network_done_led(network_done_led),
//    .layer_num_idx(layer_num_idx),
//    
//    .i_0(i_0), // network_start
//    .i_1(i_1), // {debug_big(1), debug_buf_select(16), debug_buf_addr(9)}
//    .i_2(i_2),
//`ifdef PRELOAD
//    .preload(preload),
//    .preload_layer_idx(preload_layer_idx),
//`endif
//     
//    .i_ARVALID(i_ARVALID),
//    .i_ARREADY(i_ARREADY),
//    .i_ARADDR(i_ARADDR),
//    .i_ARID(i_ARID),
//    .i_ARLEN(i_ARLEN),
//    .i_ARSIZE(i_ARSIZE),
//    .i_ARBURST(i_ARBURST),
//    .i_ARLOCK(i_ARLOCK),
//    .i_ARCACHE(i_ARCACHE),
//    .i_ARPROT(i_ARPROT),
//    .i_ARQOS(),
//    .i_ARREGION(),
//    .i_ARUSER(),
//    .i_RVALID(i_RVALID),
//    .i_RREADY(i_RREADY),
//    .i_RDATA(i_RDATA),
//    .i_RLAST(i_RLAST),
//    .i_RID(i_RID),
//    .i_RUSER(),
//    .i_RRESP(i_RRESP),
//    
//    .i_AWVALID(i_AWVALID),
//    .i_AWREADY(i_AWREADY),
//    .i_AWADDR(i_AWADDR),
//    .i_AWID(i_AWID),
//    .i_AWLEN(i_AWLEN),
//    .i_AWSIZE(i_AWSIZE),
//    .i_AWBURST(i_AWBURST),
//    .i_AWLOCK(i_AWLOCK),
//    .i_AWCACHE(i_AWCACHE),
//    .i_AWPROT(i_AWPROT),
//    .i_AWQOS(),
//    .i_AWREGION(),
//    .i_AWUSER(),
//    
//    .i_WVALID(i_WVALID),
//    .i_WREADY(i_WREADY),
//    .i_WDATA(i_WDATA),
//    .i_WSTRB(i_WSTRB),
//    .i_WLAST(i_WLAST),
//    .i_WID(i_WID),
//    .i_WUSER(),
//    
//    .i_BVALID(i_BVALID),
//    .i_BREADY(i_BREADY),
//    .i_BRESP(i_BRESP),
//    .i_BID(i_BID),
//    .i_BUSER(),
//    
//    .network_done(network_done)
//);
//
//
//initial begin
//   rstn = 1'b0;         // Reset, low active   
//   i_0 = 0;
//   i_1 = 0;
//   i_2 = 0;
//`ifdef DEBUG
//   resume_counter = 0;
//`endif
//`ifdef PRELOAD
//   preload = 1'b0;
//   preload_layer_idx = 4;
//`endif
//   
//   #(4*CLK_PERIOD) rstn = 1'b1; 
//   #(100*CLK_PERIOD) 
//        @(posedge clk)
//            i_0 = 32'd1;
//    `ifdef PRELOAD
//            preload <= 1'b1;
//            preload_layer_idx <= 4;
//    `endif
//    `ifdef PRELOAD
//     #(CLK_PERIOD) @(posedge clk)
//        preload <= 1'b0;
//        preload_layer_idx <= 0;
//    `endif
//end

endmodule