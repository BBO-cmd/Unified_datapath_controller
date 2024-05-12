//----------------------------------------------------------------+
// Project: Deep Learning Hardware Design Contest
// Module: yolo_engine
// Description:
//		Load parameters and input feature map from DRAM via AXI4
//
// 2023.04.05 by NXT (truongnx@capp.snu.ac.kr)
//----------------------------------------------------------------+
module yolo_engine #(
    parameter AXI_WIDTH_AD = 32,
    parameter AXI_WIDTH_ID = 4,
    parameter AXI_WIDTH_DA = 32,
    parameter AXI_WIDTH_DS = AXI_WIDTH_DA/8,
    parameter OUT_BITS_TRANS = 18,
    parameter WBUF_AW = 9,
    parameter WBUF_DW = 8*3*3*16,
    parameter WBUF_DS = WBUF_DW/8,
    parameter MEM_BASE_ADDR = 'h8000_0000,
    parameter MEM_DATA_BASE_ADDR = 4096
)
(
    input                          clk
    , input                          rstn

    , input [31:0] i_ctrl_reg0    // network_start, // {debug_big(1), debug_buf_select(16), debug_buf_addr(9)}
    , input [31:0] i_ctrl_reg1    // Read address base
    , input [31:0] i_ctrl_reg2    // Write address base
	, input [31:0] i_ctrl_reg3    // Write address base

    , output                         M_ARVALID
    , input                          M_ARREADY
    , output  [AXI_WIDTH_AD-1:0]     M_ARADDR
    , output  [AXI_WIDTH_ID-1:0]     M_ARID
    , output  [7:0]                  M_ARLEN
    , output  [2:0]                  M_ARSIZE
    , output  [1:0]                  M_ARBURST
    , output  [1:0]                  M_ARLOCK
    , output  [3:0]                  M_ARCACHE
    , output  [2:0]                  M_ARPROT
    , output  [3:0]                  M_ARQOS
    , output  [3:0]                  M_ARREGION
    , output  [3:0]                  M_ARUSER
    , input                          M_RVALID
    , output                         M_RREADY
    , input  [AXI_WIDTH_DA-1:0]      M_RDATA
    , input                          M_RLAST
    , input  [AXI_WIDTH_ID-1:0]      M_RID
    , input  [3:0]                   M_RUSER
    , input  [1:0]                   M_RRESP
       
    , output                         M_AWVALID
    , input                          M_AWREADY
    , output  [AXI_WIDTH_AD-1:0]     M_AWADDR
    , output  [AXI_WIDTH_ID-1:0]     M_AWID
    , output  [7:0]                  M_AWLEN
    , output  [2:0]                  M_AWSIZE
    , output  [1:0]                  M_AWBURST
    , output  [1:0]                  M_AWLOCK
    , output  [3:0]                  M_AWCACHE
    , output  [2:0]                  M_AWPROT
    , output  [3:0]                  M_AWQOS
    , output  [3:0]                  M_AWREGION
    , output  [3:0]                  M_AWUSER
    
    , output                         M_WVALID
    , input                          M_WREADY
    , output  [AXI_WIDTH_DA-1:0]     M_WDATA
    , output  [AXI_WIDTH_DS-1:0]     M_WSTRB
    , output                         M_WLAST
    , output  [AXI_WIDTH_ID-1:0]     M_WID
    , output  [3:0]                  M_WUSER
    
    , input                          M_BVALID
    , output                         M_BREADY
    , input  [1:0]                   M_BRESP
    , input  [AXI_WIDTH_ID-1:0]      M_BID
    , input                          M_BUSER
    
    , output network_done
    , output network_done_led   
);
`include "define.v"

parameter BUFF_DEPTH    = 256;
parameter BUFF_ADDR_W   = $clog2(BUFF_DEPTH);
localparam BIT_TRANS = BUFF_ADDR_W;

//CSR
reg ap_start;
reg ap_ready;
reg ap_done;
reg interrupt;

reg [31:0] dram_base_addr_rd;
reg [31:0] dram_base_addr_wr;
reg [31:0] reserved_register;

// Signals for dma read  
wire ctrl_read;
wire read_done;
wire [AXI_WIDTH_AD-1:0] read_addr;
wire [AXI_WIDTH_DA-1:0] read_data;
wire                    read_data_vld;
wire [BIT_TRANS   -1:0] read_data_cnt;

// Signals for dma write
wire ctrl_write_done;
wire ctrl_write;
wire write_done;
wire indata_req_wr;
wire [BIT_TRANS   -1:0] write_data_cnt;
wire [AXI_WIDTH_AD-1:0] write_addr;
wire [AXI_WIDTH_DA-1:0] write_data;

// FIX ME
wire[BIT_TRANS   -1:0] num_trans        = 16;           // BURST_LENGTH = 16
wire[            15:0] max_req_blk_idx  = (256*256)/16; // The number of blocks
//----------------------------------------------------------------
// Control signals
//----------------------------------------------------------------
always @ (*) begin
    ap_done     = ctrl_write_done;
    ap_ready    = 1;
end
assign network_done     = interrupt;
assign network_done_led = interrupt;


always @ (posedge clk, negedge rstn) begin
    if(~rstn) begin
        ap_start <= 0;
    end
    else begin 
        if(!ap_start && i_ctrl_reg0[0])
            ap_start <= 1;
        else if (ap_done)
            ap_start <= 0;    
    end 
end

always @(posedge clk, negedge rstn) begin
    if(~rstn) begin
        interrupt <= 0;
    end
    else begin        
        if(i_ctrl_reg0[0])
            interrupt <= 0;         
        else if (ap_done)
            interrupt <= 1;                   
    end
end

// Parse the control registers
always @ (posedge clk, negedge rstn) begin
    if(~rstn) begin
        dram_base_addr_rd <= 0;
        dram_base_addr_wr <= 0;
        reserved_register <= 0; // unused 
    end
    else begin 
        if(!ap_start && i_ctrl_reg0[0]) begin 
            dram_base_addr_rd <= i_ctrl_reg1; // Base Address for READ  (Input image, Model parameters)
            dram_base_addr_wr <= i_ctrl_reg2; // Base Address for WRITE (Intermediate feature maps, Outputs)
            reserved_register <= i_ctrl_reg3; // reserved
        end 
        else if (ap_done) begin 
            dram_base_addr_rd <= 0;
            dram_base_addr_wr <= 0;
            reserved_register <= 0; 
        end 
    end 
end
//----------------------------------------------------------------
// DUTs
//----------------------------------------------------------------
// DMA Controller
axi_dma_ctrl #(.BIT_TRANS(BIT_TRANS))
u_dma_ctrl(
    .clk              (clk              )
   ,.rstn             (rstn             )
   ,.i_start          (i_ctrl_reg0[0]   )
   ,.i_base_address_rd(dram_base_addr_rd)
   ,.i_base_address_wr(dram_base_addr_wr)
   ,.i_num_trans      (num_trans        )
   ,.i_max_req_blk_idx(max_req_blk_idx  )
   // DMA Read
   ,.i_read_done      (read_done        )
   ,.o_ctrl_read      (ctrl_read        )
   ,.o_read_addr      (read_addr        )
   // DMA Write
   ,.i_indata_req_wr  (indata_req_wr    )
   ,.i_write_done     (write_done       )
   ,.o_ctrl_write     (ctrl_write       )
   ,.o_write_addr     (write_addr       )
   ,.o_write_data_cnt (write_data_cnt   )
   ,.o_ctrl_write_done(ctrl_write_done  )
);


// DMA read module
axi_dma_rd #(
        .BITS_TRANS(BIT_TRANS),
        .OUT_BITS_TRANS(OUT_BITS_TRANS),    
        .AXI_WIDTH_USER(1),             // Master ID
        .AXI_WIDTH_ID(4),               // ID width in bits
        .AXI_WIDTH_AD(AXI_WIDTH_AD),    // address width
        .AXI_WIDTH_DA(AXI_WIDTH_DA),    // data width
        .AXI_WIDTH_DS(AXI_WIDTH_DS)     // data strobe width
    )
u_dma_read(
    //AXI Master Interface
    //Read address channel
    .M_ARVALID	(M_ARVALID	  ),  // address/control valid handshake
    .M_ARREADY	(M_ARREADY	  ),  // Read addr ready
    .M_ARADDR	(M_ARADDR	  ),  // Address Read 
    .M_ARID		(M_ARID		  ),  // Read addr ID
    .M_ARLEN	(M_ARLEN	  ),  // Transfer length
    .M_ARSIZE	(M_ARSIZE	  ),  // Transfer width
    .M_ARBURST	(M_ARBURST	  ),  // Burst type
    .M_ARLOCK	(M_ARLOCK	  ),  // Atomic access information
    .M_ARCACHE	(M_ARCACHE	  ),  // Cachable/bufferable infor
    .M_ARPROT	(M_ARPROT	  ),  // Protection info
    .M_ARQOS	(M_ARQOS	  ),  // Quality of Service
    .M_ARREGION	(M_ARREGION	  ),  // Region signaling
    .M_ARUSER	(M_ARUSER	  ),  // User defined signal
 
    //Read data channel
    .M_RVALID	(M_RVALID	  ),  // Read data valid 
    .M_RREADY	(M_RREADY	  ),  // Read data ready (to Slave)
    .M_RDATA	(M_RDATA	  ),  // Read data bus
    .M_RLAST	(M_RLAST	  ),  // Last beat of a burst transfer
    .M_RID		(M_RID		  ),  // Read ID
    .M_RUSER	(M_RUSER	  ),  // User defined signal
    .M_RRESP	(M_RRESP	  ),  // Read response
     
    //Functional Ports
    .start_dma	(ctrl_read    ),
    .num_trans	(num_trans    ), //Number of 128-bit words transferred
    .start_addr	(read_addr    ), //iteration_num * 4 * 16 + read_address_d	
    .data_o		(read_data    ),
    .data_vld_o	(read_data_vld),
    .data_cnt_o	(read_data_cnt),
    .done_o		(read_done    ),

    //Global signals
    .clk        (clk          ),
    .rstn       (rstn         )
);


// dpram_256x32
dpram_wrapper #(
    .DEPTH  (BUFF_DEPTH     ),
    .AW     (BUFF_ADDR_W    ),
    .DW     (AXI_WIDTH_DA   ))
u_data_buffer(    
    .clk	(clk		    ),
    .ena	(1'd1		    ),
	.addra	(read_data_cnt  ),
	.wea	(read_data_vld  ),
	.dia	(read_data      ),
    .enb    (1'd1           ),  // Always Read       
    .addrb	(write_data_cnt ),
    .dob	(write_data     )
);

// DMA write module
axi_dma_wr #(
        .BITS_TRANS(BIT_TRANS),
        .OUT_BITS_TRANS(BIT_TRANS),    
        .AXI_WIDTH_USER(1),           // Master ID
        .AXI_WIDTH_ID(4),             // ID width in bits 
        .AXI_WIDTH_AD(AXI_WIDTH_AD),  // address width
        .AXI_WIDTH_DA(AXI_WIDTH_DA),  // data width
        .AXI_WIDTH_DS(AXI_WIDTH_DS)   // data strobe width
    )
u_dma_write(
    .M_AWID		(M_AWID		),  // Address ID
    .M_AWADDR	(M_AWADDR	),  // Address Write
    .M_AWLEN	(M_AWLEN	),  // Transfer length
    .M_AWSIZE	(M_AWSIZE	),  // Transfer width
    .M_AWBURST	(M_AWBURST	),  // Burst type
    .M_AWLOCK	(M_AWLOCK	),  // Atomic access information
    .M_AWCACHE	(M_AWCACHE	),  // Cachable/bufferable infor
    .M_AWPROT	(M_AWPROT	),  // Protection info
    .M_AWREGION	(M_AWREGION	),
    .M_AWQOS	(M_AWQOS	),
    .M_AWVALID	(M_AWVALID	),  // address/control valid handshake
    .M_AWREADY	(M_AWREADY	),
    .M_AWUSER   (           ),
    //Write data channel
    .M_WID		(M_WID		),  // Write ID
    .M_WDATA	(M_WDATA	),  // Write Data bus
    .M_WSTRB	(M_WSTRB	),  // Write Data byte lane strobes
    .M_WLAST	(M_WLAST	),  // Last beat of a burst transfer
    .M_WVALID	(M_WVALID	),  // Write data valid
    .M_WREADY	(M_WREADY	),  // Write data ready
    .M_WUSER    (           ),
    .M_BUSER    (           ),    
    //Write response chaDnel
    .M_BID		(M_BID		),  // buffered response ID
    .M_BRESP	(M_BRESP	),  // Buffered write response
    .M_BVALID	(M_BVALID	),  // Response info valid
    .M_BREADY	(M_BREADY	),  // Response info ready (to slave)
    //Read address channDl
    //User interface
    .start_dma	(ctrl_write     ),
    .num_trans	(num_trans      ), //Number of words transferred
    .start_addr	(write_addr     ),
    .indata		(write_data     ),
    .indata_req_o(indata_req_wr ),
    .done_o		(write_done     ), //Blk transfer done
    .fail_check (               ),
    //User signals
    .clk        (clk            ),
    .rstn       (rstn           )
);


//------------------------------------------------------------------
// computing kernel & CNN controller
//------------------------------------------------------------------

// parameter IFM_WIDTH     = 256;
// parameter IFM_HEIGHT    = 256;
// parameter IFM_CHANNEL   = 3;

// *****************************************			
// Loop for convolutions
// *****************************************		
//{{{

#(100*CLK_PERIOD) 
    for(row = 0; row < IFM_HEIGHT; row = row + 1)	begin //ofmap의 row에 대해
        @(posedge clk)
            ctrl_data_run  = 0;
        #(100*CLK_PERIOD) @(posedge clk);
            ctrl_data_run  = 1;	
        for (col = 0; col < IFM_WIDTH; col = col + 1) begin 			
            for (chn = 0; chn < IFM_CHANNEL; chn = chn + 1) begin  	//ofmap의 channel은 j로(loop을 하나더 만드는게 아니라 output channe을 j개로 늘림)			
                @(posedge clk) begin 
                    if((col == IFM_WIDTH-1) && (chn == IFM_CHANNEL-1))
                        ctrl_data_run = 0;
                end 
            end
        end 
    end
@(posedge clk)
        ctrl_data_run = 1'b0;			
//}}}

#(100*CLK_PERIOD) 
    $display("Layer done !!!");
    $stop;		

// Generate din, win
wire is_first_row = (row == 0) ? 1'b1: 1'b0;
wire is_last_row  = (row == IFM_HEIGHT-1) ? 1'b1: 1'b0;
wire is_first_col = (col == 0) ? 1'b1: 1'b0;
wire is_last_col  = (col == IFM_WIDTH-1) ? 1'b1 : 1'b0;


//Input Buffer
//dpram_1000x32(use 3*8=24bit only)
//store upto 224*4th row  
dpram_wrapper #(
    .DEPTH  (BUFF_DEPTH     ), 
    .AW     (BUFF_ADDR_W    ),
    .DW     (AXI_WIDTH_DA   ))
u_data_buffer(    
    .clk	(clk		    ),
    .ena	(1'd1		    ),
	.addra	(read_data_cnt  ),
	.wea	(read_data_vld  ),
	.dia	(read_data      ),
    .enb    (1'd1           ),  // Always Read       
    .addrb	(write_data_cnt ),
    .dob	(write_data     )
);



//Weight Buffer
//dpram_2048*8
//store only 1 filter(50layers*3channel*9pixels= 1350)
dpram_wrapper #(
    .DEPTH  (BUFF_DEPTH     ), //set to 2048
    .AW     (BUFF_ADDR_W    ), 
    .DW     (AXI_WIDTH_DA   )) 
u_weight_buffer(    
    .clk	(clk		    ),
    .ena	(1'd1		    ),
	.addra	(read_data_cnt  ),
	.wea	(read_data_vld  ),
	.dia	(read_data      ),
    .enb    (1'd1           ),  // Always Read       
    .addrb	(write_data_cnt ),
    .dob	(write_data     )
);
//weight buffer를 16개 만들고 output channel을 16개 만들면 parallel 가능?


AXI_WIDTH_DA = 32
wire [AXI_WIDTH_DA-1:0] read_data;


reg filter_ready;
reg [127:0] win[0:15];
reg [127:0] din;

reg  [IFM_WORD_SIZE_32-1:0] in_img[0:IFM_DATA_SIZE_32-1];  // Infmap
reg  [IFM_WORD_SIZE_32-1:0] filter[0:WGT_DATA_SIZE   -1];	// Filter


//concatenate the read data of 9 cycles
always@(posedge clk, negedge rstn)begin
    if(!rstn)begin 
        din <= 128'b0;
        din_ready=1'b0;
    end

    else begin
        integer i;
        for(i=0; i<9; i=i+1) begin
            in_img =( in_img << 8 ) | read_data[7:0];
        end
        din_ready = 1'b1;
    end 
end


always@(*) begin
	vld_i = 0;
    din = 128'd0;
    win[0] = 0;
	win[1] = 0;
	win[2] = 0;
	win[3] = 0;
    if(ctrl_data_run || din_ready) begin
		vld_i = 1;
		// Tiled IFM data
        din[ 7: 0] = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col-1)][chn*8+:8];
        din[15: 8] = (is_first_row                ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH +  col   ][chn*8+:8];
        din[23:16] = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * IFM_WIDTH + (col+1)][chn*8+:8];
		
        din[31:24] = (                is_first_col) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col-1)][chn*8+:8];
        din[39:32] =                                         in_img[ row    * IFM_WIDTH +  col   ][chn*8+:8];
        din[47:40] = (                is_last_col ) ? 8'd0 : in_img[ row    * IFM_WIDTH + (col+1)][chn*8+:8];
        
		din[55:48] = (is_last_row ||  is_first_col) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col-1)][chn*8+:8];
        din[63:56] = (is_last_row                 ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH +  col   ][chn*8+:8];
        din[71:64] = (is_last_row ||  is_last_col ) ? 8'd0 : in_img[(row+1) * IFM_WIDTH + (col+1)][chn*8+:8];
		
        // Tiled Filters
		for(j = 0; j < 16; j=j+1) begin 	// Four sets <=> Four output channels
			win[j][ 7: 0] = filter[(j*Fx*Fy*Ni) + chn*9    ][7:0];
			win[j][15: 8] = filter[(j*Fx*Fy*Ni) + chn*9 + 1][7:0];
			win[j][23:16] = filter[(j*Fx*Fy*Ni) + chn*9 + 2][7:0];			
			win[j][31:24] = filter[(j*Fx*Fy*Ni) + chn*9 + 3][7:0];
			win[j][39:32] = filter[(j*Fx*Fy*Ni) + chn*9 + 4][7:0];
			win[j][47:40] = filter[(j*Fx*Fy*Ni) + chn*9 + 5][7:0];			
			win[j][55:48] = filter[(j*Fx*Fy*Ni) + chn*9 + 6][7:0];
			win[j][63:56] = filter[(j*Fx*Fy*Ni) + chn*9 + 7][7:0];
			win[j][71:64] = filter[(j*Fx*Fy*Ni) + chn*9 + 8][7:0];			
		end 
    end    
end 

//-------------------------------------------
// DUT: MACs
//-------------------------------------------
mac u_mac_00(
./*input 		 */clk	(clk	 ), 
./*input 		 */rstn	(rstn	 ), 
./*input 		 */vld_i(vld_i	 ), 
./*input [127:0] */win	(win[0]	 ), 
./*input [127:0] */din	(din	 ),
./*output[ 19:0] */acc_o(acc_o[0]), 
./*output        */vld_o(vld_o[0])
);
mac u_mac_01(
./*input 		 */clk	(clk	 ), 
./*input 		 */rstn	(rstn	 ), 
./*input 		 */vld_i(vld_i	 ), 
./*input [127:0] */win	(win[1]	 ), 
./*input [127:0] */din	(din	 ),
./*output[ 19:0] */acc_o(acc_o[1]), 
./*output        */vld_o(vld_o[1])
);
mac u_mac_02(
./*input 		 */clk	(clk     ), 
./*input 		 */rstn	(rstn    ), 
./*input 		 */vld_i(vld_i   ), 
./*input [127:0] */win	(win[2]  ), 
./*input [127:0] */din	(din     ),
./*output[ 19:0] */acc_o(acc_o[2]), 
./*output        */vld_o(vld_o[2])
);
mac u_mac_03(
./*input 		 */clk	(clk     ), 
./*input 		 */rstn (rstn    ), 
./*input 		 */vld_i(vld_i   ), 
./*input [127:0] */win  (win[3]  ), 
./*input [127:0] */din  (din     ),
./*output[ 19:0] */acc_o(acc_o[3]), 
./*output        */vld_o(vld_o[3])
);

reg [15:0] chn_idx;
reg [31:0] psum[0:3];
wire valid_out = vld_o[0];

always@(posedge clk, negedge rstn) begin 
	if(!rstn) begin 
		chn_idx <= 0;		
	end 
	else begin
		if(valid_out) begin 
			if(chn_idx == IFM_CHANNEL-1) 
				chn_idx <= 0;
			else 
				chn_idx <= chn_idx + 1;			
		end  
	end 
end 
reg write_pixel_ena;
always@(posedge clk, negedge rstn) begin 
	if(!rstn) begin 
		psum[0] <= 0;		
		psum[1] <= 0;		
		psum[2] <= 0;		
		psum[3] <= 0;
		write_pixel_ena <= 0;		
	end 
	else begin
		if(valid_out) begin 
			if(chn_idx == 0) begin 
				psum[0] <= $signed(acc_o[0]);
				psum[1] <= $signed(acc_o[1]);
				psum[2] <= $signed(acc_o[2]);
				psum[3] <= $signed(acc_o[3]);
			end 
			else begin 
				psum[0] <= $signed(psum[0]) + $signed(acc_o[0]);
				psum[1] <= $signed(psum[1]) + $signed(acc_o[1]);
				psum[2] <= $signed(psum[2]) + $signed(acc_o[2]);
				psum[3] <= $signed(psum[3]) + $signed(acc_o[3]);
			end 

			if(chn_idx == IFM_CHANNEL-1)
				write_pixel_ena <= 1;
			else 
				write_pixel_ena <= 0; 
		end  
		else
			write_pixel_ena <= 0; 
	end 
end



//--------------------------------------------------------------------
// DEBUGGING: Save the results in images
//--------------------------------------------------------------------
// synthesis_off
`ifdef CHECK_DMA_WRITE
	bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_00(
		./*input 			*/clk	(clk            ),
		./*input 			*/rstn	(rstn           ),
		./*input [WI-1:0]   */din	(i_WDATA[7:0]   ),
		./*input 			*/vld	(i_WVALID       ),
		./*output reg 		*/frame_done(           )
	);
	bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_01(
		./*input 			*/clk	(clk            ),
		./*input 			*/rstn	(rstn           ),
		./*input [WI-1:0]   */din	(i_WDATA[15:8]  ),
		./*input 			*/vld	(i_WVALID       ),
		./*output reg 		*/frame_done(           )
	);
	bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_02(
		./*input 			*/clk	(clk            ),
		./*input 			*/rstn	(rstn           ),
		./*input [WI-1:0]   */din	(i_WDATA[23:16] ),
		./*input 			*/vld	(i_WVALID       ),
		./*output reg 		*/frame_done(           )
	);
	bmp_image_writer #(.OUTFILE(CONV_OUTPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_03(
		./*input 			*/clk	(clk            ),
		./*input 			*/rstn	(rstn           ),
		./*input [WI-1:0]   */din	(i_WDATA[31:24] ),
		./*input 			*/vld	(i_WVALID       ),
		./*output reg 		*/frame_done(           )
	);

`else   // Check DMA_READ 
	bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG00),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_00(
		./*input 			*/clk	(clk             ),
		./*input 			*/rstn	(rstn            ),
		./*input [WI-1:0]   */din	(read_data[7:0]  ),
		./*input 			*/vld	(read_data_vld   ),
		./*output reg 		*/frame_done(            )
	);
	bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG01),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_01(
		./*input 			*/clk	(clk             ),
		./*input 			*/rstn	(rstn            ),
		./*input [WI-1:0]   */din	(read_data[15:8] ),
		./*input 			*/vld	(read_data_vld   ),
		./*output reg 		*/frame_done(            )
	);
	bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG02),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_02(
		./*input 			*/clk	(clk             ),
		./*input 			*/rstn	(rstn            ),
		./*input [WI-1:0]   */din	(read_data[23:16]),
		./*input 			*/vld	(read_data_vld   ),
		./*output reg 		*/frame_done(            )
	);
	bmp_image_writer #(.OUTFILE(CONV_INPUT_IMG03),.WIDTH(IFM_WIDTH),.HEIGHT(IFM_HEIGHT))
	u_bmp_image_writer_03(
		./*input 			*/clk	(clk             ),
		./*input 			*/rstn	(rstn            ),
		./*input [WI-1:0]   */din	(read_data[31:24]),
		./*input 			*/vld	(read_data_vld   ),
		./*output reg 		*/frame_done(            )
	);
`endif    
// synthesis_on

endmodule
