`timescale 1ns / 1ps

module cnn_ctrl_res50_tb;

reg[2:0] Fx; //upto 8x8 conv
reg[2:0] Fy;
reg[11:0] Ni; //upto 2048

//for res50_fsm.v
parameter W_SIZE  = 8;
parameter W_FRAME_SIZE  = 2 * W_SIZE + 3;	
parameter W_DELAY = 12;
parameter VSYNC_DELAY = 100;
parameter HSYNC_DELAY = 100;

reg clk, rstn;
reg [W_SIZE-1 :0] q_width;
reg [W_SIZE-1 :0] q_height;
reg [W_SIZE-1 :0] q_channel;
reg [W_SIZE-1 :0] q_step_x;
reg [W_SIZE-1 :0] q_step_y;
reg [W_DELAY-1:0] q_vsync_delay;
reg [W_DELAY-1:0] q_hsync_delay;
reg [2*W_SIZE :0] q_frame_size; //사용x
reg q_start;

wire 			     ctrl_vsync_run;
wire [W_DELAY-1:0]	 ctrl_vsync_cnt;
wire 				 ctrl_hsync_run;
wire [W_DELAY-1:0]	 ctrl_hsync_cnt;
wire 				 ctrl_data_run;
wire [W_SIZE-1:0] 	 row;
wire [W_SIZE-1:0] 	 col;
wire [W_SIZE-1:0] 	 chn;
wire [2*W_SIZE :0]data_count;

//-------------------------------------------------
// Controller (FSM)
//-------------------------------------------------
res50_fsm u_cnn_ctrl (
.clk			(clk			),
.rstn			(rstn			),
// Inputs
.q_width		(q_width		),
.q_height		(q_height		),
.q_channel		(q_channel      ),
.q_step_x		(q_step_x	    ),
.q_step_y		(q_step_y	    ),
.q_vsync_delay	(q_vsync_delay	),
.q_hsync_delay	(q_hsync_delay	),
.q_frame_size	(q_frame_size	), //사용x
.q_start		(q_start		),
//output
.o_ctrl_vsync_run(ctrl_vsync_run),
.o_ctrl_vsync_cnt(ctrl_vsync_cnt),
.o_ctrl_hsync_run(ctrl_hsync_run),
.o_ctrl_hsync_cnt(ctrl_hsync_cnt),
.o_ctrl_data_run(ctrl_data_run	),
.o_row			(row			),
.o_col			(col			),
.o_chn          (chn            ),
.o_data_count	(data_count		),
.o_end_frame	(end_frame		)
);

// Clock
parameter CLK_PERIOD = 10;	//100MHz
initial begin
	clk = 1'b1;
	forever #(CLK_PERIOD/2) clk = ~clk;
end

// Generate din, win
// wino last row last col should be -2 instead of -1
wire is_first_row = (row == 0) ? 1'b1 : 1'b0;
wire is_last_row  = (row == q_height-2) ? 1'b1 : 1'b0;
wire is_first_col = (col == 0) ? 1'b1 : 1'b0;
wire is_last_col  = (col == q_width -2) ? 1'b1 : 1'b0;


reg [7:0] p00, p01, p02, p03, p04, p05, p06, 
		  p10, p11, p12, p13, p14, p15, p16,
		  p20, p21, p22, p23, p24, p25, p26,
		  p30, p31, p32, p33, p34, p35, p36,
          p40, p41, p42, p43, p44, p45, p46,
          p50, p51, p52, p53, p54, p55, p56,
          p60, p61, p62, p63, p64, p65, p66;


always@(*) begin
	d_in = 0;
	g_in = 0;		
	vld_i = 0;
	vld_i_st = 0;
	vld_i_ed = 0;
	{p00, p01, p02, p03, p04, p05, p06, 
    p10, p11, p12, p13, p14, p15, p16,
    p20, p21, p22, p23, p24, p25, p26,
    p30, p31, p32, p33, p34, p35, p36,
    p40, p41, p42, p43, p44, p45, p46,
    p50, p51, p52, p53, p54, p55, p56,
    p60, p61, p62, p63, p64, p65, p66}=0;
	


    if(Fx==7) begin
        if(ctrl_data_run) begin
            vld_i    = 1;
            vld_i_st = (chn == 0)?1:0;
            vld_i_ed = (chn == IFM_CHANNEL-1)?1:0;

            p00 = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-3) * q_width + (col-3)][chn*8+:8];
            p01 = (is_first_row                ) ? 8'd0 : in_img[(row-3) * q_width + (col-2)][chn*8+:8];
            p02 = (is_first_row                ) ? 8'd0 : in_img[(row-3) * q_width + (col-1)][chn*8+:8];
            p03 = (is_first_row                ) ? 8'd0 : in_img[(row-3) * q_width + (col  )][chn*8+:8];
            p04 = (is_first_row                ) ? 8'd0 : in_img[(row-3) * q_width + (col+1)][chn*8+:8];
            p05 = (is_first_row                ) ? 8'd0 : in_img[(row-3) * q_width + (col+2)][chn*8+:8];
            p06 = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-3) * q_width + (col+3)][chn*8+:8];

            p10 = (                is_first_col) ? 8'd0 : in_img[(row-2) * q_width + (col-3)][chn*8+:8];
            p11 =                                         in_img[(row-2) * q_width + (col-2)][chn*8+:8];
            p12 =                                         in_img[(row-2) * q_width + (col-1)][chn*8+:8];
            p13 =                                         in_img[(row-2) * q_width + (col  )][chn*8+:8];
            p14 =                                         in_img[(row-2) * q_width + (col+1)][chn*8+:8];
            p15 =                                         in_img[(row-2) * q_width + (col+2)][chn*8+:8];
            p16 = (                 is_last_col) ? 8'd0 : in_img[(row-2) * q_width + (col+3)][chn*8+:8];

            p20 = (                is_first_col) ? 8'd0 : in_img[(row-1) * q_width + (col-3)][chn*8+:8];
            p21 =                                         in_img[(row-1) * q_width + (col-2)][chn*8+:8];
            p22 =                                         in_img[(row-1) * q_width + (col-1)][chn*8+:8];
            p23 =                                         in_img[(row-1) * q_width + (col  )][chn*8+:8];
            p24 =                                         in_img[(row-1) * q_width + (col+1)][chn*8+:8];
            p25 =                                         in_img[(row-1) * q_width + (col+2)][chn*8+:8];
            p26 = (                 is_last_col) ? 8'd0 : in_img[(row-1) * q_width + (col+3)][chn*8+:8];

            p30 = (                is_first_col) ? 8'd0 : in_img[(row  ) * q_width + (col-3)][chn*8+:8];
            p31 =                                         in_img[(row  ) * q_width + (col-2)][chn*8+:8];
            p32 =                                         in_img[(row  ) * q_width + (col-1)][chn*8+:8];
            p33 =                                         in_img[(row  ) * q_width + (col  )][chn*8+:8];
            p34 =                                         in_img[(row  ) * q_width + (col+1)][chn*8+:8];
            p35 =                                         in_img[(row  ) * q_width + (col+2)][chn*8+:8];
            p36 = (                 is_last_col) ? 8'd0 : in_img[(row  ) * q_width + (col+3)][chn*8+:8];

            p40 = (                is_first_col) ? 8'd0 : in_img[(row+1) * q_width + (col-3)][chn*8+:8];
            p41 =                                         in_img[(row+1) * q_width + (col-2)][chn*8+:8];
            p42 =                                         in_img[(row+1) * q_width + (col-1)][chn*8+:8];
            p43 =                                         in_img[(row+1) * q_width + (col  )][chn*8+:8];
            p44 =                                         in_img[(row+1) * q_width + (col+1)][chn*8+:8];
            p45 =                                         in_img[(row+1) * q_width + (col+2)][chn*8+:8];
            p46 = (                 is_last_col) ? 8'd0 : in_img[(row+1) * q_width + (col+3)][chn*8+:8];

            p50 = (                is_first_col) ? 8'd0 : in_img[(row+2) * q_width + (col-3)][chn*8+:8];
            p51 =                                         in_img[(row+2) * q_width + (col-2)][chn*8+:8];
            p52 =                                         in_img[(row+2) * q_width + (col-1)][chn*8+:8];
            p53 =                                         in_img[(row+2) * q_width + (col  )][chn*8+:8];
            p54 =                                         in_img[(row+2) * q_width + (col+1)][chn*8+:8];
            p55 =                                         in_img[(row+2) * q_width + (col+2)][chn*8+:8];
            p56 = (                 is_last_col) ? 8'd0 : in_img[(row+2) * q_width + (col+3)][chn*8+:8];

            p60 = (is_last_row || is_first_col ) ? 8'd0 : in_img[(row+3) * q_width + (col-3)][chn*8+:8];
            p61 = (is_last_row                 ) ? 8'd0 : in_img[(row+3) * q_width + (col-2)][chn*8+:8];
            p62 = (is_last_row                 ) ? 8'd0 : in_img[(row+3) * q_width + (col-1)][chn*8+:8];
            p63 = (is_last_row                 ) ? 8'd0 : in_img[(row+3) * q_width + (col  )][chn*8+:8];
            p64 = (is_last_row                 ) ? 8'd0 : in_img[(row+3) * q_width + (col+1)][chn*8+:8];
            p65 = (is_last_row                 ) ? 8'd0 : in_img[(row+3) * q_width + (col+2)][chn*8+:8];
            p66 = (is_last_row || is_last_col  ) ? 8'd0 : in_img[(row+3) * q_width + (col+3)][chn*8+:8];
        end
    end

    if(Fx==3) begin
        if(ctrl_data_run) begin
            vld_i    = 1;
            vld_i_st = (chn == 0)?1:0;
            vld_i_ed = (chn == IFM_CHANNEL-1)?1:0;

            {p00, p01, p02, p03, p04, p05, p06, 
            p10, p11, p12, p13, p14, p15, p16,
            p20, p21, p22, p23, p24, p25, p26,
            p30, p31, p32, p33, p34, p35, p36,
            p40, p41, p42, p43, p44, p45, p46,
            p50, p51, p52, p53, p54, p55, p56,
            p60, p61, p62, p63, p64, p65, p66}=0;

            p00 = (is_first_row || is_first_col) ? 8'd0 : in_img[(row-1) * q_width + (col-1)][chn*8+:8];
            p01 = (is_first_row                ) ? 8'd0 : in_img[(row-1) * q_width +  col   ][chn*8+:8];
            p02 = (is_first_row                ) ? 8'd0 : in_img[(row-1) * q_width + (col+1)][chn*8+:8];
            p03 = (is_first_row || is_last_col ) ? 8'd0 : in_img[(row-1) * q_width + (col+2)][chn*8+:8];

            p10 = (                is_first_col) ? 8'd0 : in_img[ row    * q_width + (col-1)][chn*8+:8];
            p11 = 								          in_img[ row    * q_width +  col   ][chn*8+:8];
            p12 = 								          in_img[ row    * q_width + (col+1)][chn*8+:8];
            p13 = (                is_last_col ) ? 8'd0 : in_img[ row    * q_width + (col+2)][chn*8+:8];
            
            p20 = (			       is_first_col) ? 8'd0 : in_img[(row+1) * q_width + (col-1)][chn*8+:8];
            p21 =  								          in_img[(row+1) * q_width +  col   ][chn*8+:8];
            p22 =  								          in_img[(row+1) * q_width + (col+1)][chn*8+:8];
            p23 = (                is_last_col ) ? 8'd0 : in_img[(row+1) * q_width + (col+2)][chn*8+:8];
            
            p30 = (is_last_row  || is_first_col) ? 8'd0 : in_img[(row+2) * q_width + (col-1)][chn*8+:8];
            p31 = (is_last_row                 ) ? 8'd0 : in_img[(row+2) * q_width +  col   ][chn*8+:8];
            p32 = (is_last_row                 ) ? 8'd0 : in_img[(row+2) * q_width + (col+1)][chn*8+:8];
            p33 = (is_last_row  || is_last_col ) ? 8'd0 : in_img[(row+2) * q_width + (col+2)][chn*8+:8];	
        end
    end

    if(Fx==1) begin
        if(ctrl_data_run) begin
            vld_i    = 1;
            vld_i_st = (chn == 0)?1:0;
            vld_i_ed = (chn == q_channel-1)?1:0;

            {p00, p01, p02, p03, p04, p05, p06, 
            p10, p11, p12, p13, p14, p15, p16,
            p20, p21, p22, p23, p24, p25, p26,
            p30, p31, p32, p33, p34, p35, p36,
            p40, p41, p42, p43, p44, p45, p46,
            p50, p51, p52, p53, p54, p55, p56,
            p60, p61, p62, p63, p64, p65, p66}=0;

            p00= in_img[ row    * q_width +  col   ][chn*8+:8];
            
        end
    end
    
		// ======================================================================
		// Tiled IFM data: Winograd		
		// ======================================================================
        d_in[  7:  0] = p00;
        d_in[ 15:  8] = p01;
        d_in[ 23: 16] = p02;
        d_in[ 31: 24] = p03;
        d_in[ 39: 32] = p04;
        d_in[ 47: 40] = p05;
        d_in[ 55: 48] = p06;

        d_in[ 63: 56] = p10;
        d_in[ 71: 64] = p11;
        d_in[ 79: 72] = p12;
        d_in[ 87: 80] = p13;
        d_in[ 95: 88] = p14;
        d_in[103: 96] = p15;
        d_in[111:104] = p16;

        d_in[119:112] = p20;
        d_in[127:120] = p21;
        d_in[135:128] = p22;
        d_in[143:136] = p23;
        d_in[151:144] = p24;
        d_in[159:152] = p25;
        d_in[167:160] = p26;

        d_in[175:168] = p30;
        d_in[183:176] = p31;
        d_in[191:184] = p32;
        d_in[199:192] = p33;
        d_in[207:200] = p34;
        d_in[215:208] = p35;
        d_in[223:216] = p36;

        d_in[231:224] = p40;
        d_in[239:232] = p41;
        d_in[247:240] = p42;
        d_in[255:248] = p43;
        d_in[263:256] = p44;
        d_in[271:264] = p45;
        d_in[279:272] = p46;

        d_in[287:280] = p50;
        d_in[295:288] = p51;
        d_in[303:296] = p52;
        d_in[311:304] = p53;
        d_in[319:312] = p54;
        d_in[327:320] = p55;
        d_in[335:328] = p56;

        d_in[343:336] = p60;
        d_in[351:344] = p61;
        d_in[359:352] = p62;
        d_in[367:360] = p63;
        d_in[375:368] = p64;
        d_in[383:376] = p65;
        d_in[391:384] = p66;


		// ======================================================================	
		// Tiled Filters: winograd
		// ======================================================================
		g_in[ 79: 72] = filter[chn*Fx*Fy +  9][7:0];
        g_in[ 87: 80] = filter[chn*Fx*Fy + 10][7:0];
        g_in[ 95: 88] = filter[chn*Fx*Fy + 11][7:0];
        g_in[103: 96] = filter[chn*Fx*Fy + 12][7:0];
        g_in[111:104] = filter[chn*Fx*Fy + 13][7:0];
        g_in[119:112] = filter[chn*Fx*Fy + 14][7:0];
        g_in[127:120] = filter[chn*Fx*Fy + 15][7:0];
        g_in[135:128] = filter[chn*Fx*Fy + 16][7:0];
        g_in[143:136] = filter[chn*Fx*Fy + 17][7:0];
        g_in[151:144] = filter[chn*Fx*Fy + 18][7:0];
        g_in[159:152] = filter[chn*Fx*Fy + 19][7:0];
        g_in[167:160] = filter[chn*Fx*Fy + 20][7:0];
        g_in[175:168] = filter[chn*Fx*Fy + 21][7:0];
        g_in[183:176] = filter[chn*Fx*Fy + 22][7:0];
        g_in[191:184] = filter[chn*Fx*Fy + 23][7:0];
        g_in[199:192] = filter[chn*Fx*Fy + 24][7:0];
        g_in[207:200] = filter[chn*Fx*Fy + 25][7:0];
        g_in[215:208] = filter[chn*Fx*Fy + 26][7:0];
        g_in[223:216] = filter[chn*Fx*Fy + 27][7:0];
        g_in[231:224] = filter[chn*Fx*Fy + 28][7:0];
        g_in[239:232] = filter[chn*Fx*Fy + 29][7:0];
        g_in[247:240] = filter[chn*Fx*Fy + 30][7:0];
        g_in[255:248] = filter[chn*Fx*Fy + 31][7:0];
        g_in[263:256] = filter[chn*Fx*Fy + 32][7:0];
        g_in[271:264] = filter[chn*Fx*Fy + 33][7:0];
        g_in[279:272] = filter[chn*Fx*Fy + 34][7:0];
        g_in[287:280] = filter[chn*Fx*Fy + 35][7:0];
        g_in[295:288] = filter[chn*Fx*Fy + 36][7:0];
        g_in[303:296] = filter[chn*Fx*Fy + 37][7:0];
        g_in[311:304] = filter[chn*Fx*Fy + 38][7:0];
        g_in[319:312] = filter[chn*Fx*Fy + 39][7:0];
        g_in[327:320] = filter[chn*Fx*Fy + 40][7:0];
        g_in[335:328] = filter[chn*Fx*Fy + 41][7:0];
        g_in[343:336] = filter[chn*Fx*Fy + 42][7:0];
        g_in[351:344] = filter[chn*Fx*Fy + 43][7:0];
        g_in[359:352] = filter[chn*Fx*Fy + 44][7:0];
        g_in[367:360] = filter[chn*Fx*Fy + 45][7:0];
        g_in[375:368] = filter[chn*Fx*Fy + 46][7:0];
        g_in[383:376] = filter[chn*Fx*Fy + 47][7:0];
        g_in[391:384] = filter[chn*Fx*Fy + 48][7:0];
	end    


//------------------------------------------------------------------------------------------------------
// ResNet-50 
//------------------------------------------------------------------------------------------------------

always@(posedge clk or negedge rstn) begin
    if(!rstn) 
        layer_done <= 1'b0;
    else begin
        if(q_start)
            layer_done <= 1'b0;
        else if(end_frame)
            layer_done <= 1'b1;            
    end
end

initial begin
	rstn = 1'b0;			// Reset, low active	
	q_width 		= 224;
	q_height 		= 224;
    q_channel       = 3;
    q_step_x        = 1; //stride=1
    q_step_y        = 1; 
    Fx              = 1; //1x1 conv
    Fy              = 1;
    Ni              = 64;

	q_vsync_delay 	= VSYNC_DELAY;
	q_hsync_delay 	= HSYNC_DELAY;		
	q_frame_size 	= 0; //사용x
	q_start 		= 1'b0;	
	
	#(4*CLK_PERIOD) rstn = 1'b1;
	
    //------------------------------------------------------------------   
	// Layer 1: 224*224*3 / 7x7 conv 64/ stride=2
	//------------------------------------------------------------------
    q_width  = 224;
	q_height = 224;
    q_channel = 3;

	Fx = 7;
    Fy = 7;
    Ni = 64;
    q_step_x = 2;
    q_step_y = 2; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(112*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_01: Done !!!");    


    //------------------------------------------------------------------   
	// Max-pooling layer, /2
	//------------------------------------------------------------------



    //------------------------------------------------------------------   
	// Layer 2: 1x1 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 1;
    Fy = 1;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_02: Done !!!");   
    //------------------------------------------------------------------   
	// Layer 3: 3x3 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 3;
    Fy = 3;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_03: Done !!!");  			
    
    //------------------------------------------------------------------   
	// Layer 4: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_04: Done !!!"); 



    //------------------------------------------------------------------   
	// Layer 5: 1x1 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_05: Done !!!");   
    //------------------------------------------------------------------   
	// Layer 6: 3x3 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 3;
    Fy = 3;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_06: Done !!!");  			
    
    //------------------------------------------------------------------   
	// Layer 7: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_07: Done !!!"); 


    //------------------------------------------------------------------   
	// Layer 8: 1x1 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_08: Done !!!");   
    //------------------------------------------------------------------   
	// Layer 9: 3x3 conv, 64/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 3;
    Fy = 3;
    Ni = 64;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_09: Done !!!");  			
    
    //------------------------------------------------------------------   
	// Layer 10: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 112;
	q_height = 112;
    q_channel = 64;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(56*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_10: Done !!!"); 


    //------------------------------------------------------------------   
	// Max-pooling layer, /2
	//------------------------------------------------------------------



    //------------------------------------------------------------------   
	// Layer 11: 1x1 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_11: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 12: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 3;
    Fy = 3;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_12: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 13: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_13: Done !!!");  			
    

    
    //------------------------------------------------------------------   
	// Layer 14: 1x1 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_11: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 15: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 3;
    Fy = 3;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_15: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 16: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_16: Done !!!");  

    
    //------------------------------------------------------------------   
	// Layer 17: 1x1 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_17: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 18: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 3;
    Fy = 3;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_18: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 19: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_19: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 20: 1x1 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_20: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 21: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 3;
    Fy = 3;
    Ni = 128;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_21: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 22: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 56;
	q_height = 56;
    q_channel = 128;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(28*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_22: Done !!!");  

    //-----------------------------------------------------------------
    // Max-Pool layer, /2
    //-----------------------------------------------------------------

    //------------------------------------------------------------------   
	// Layer 23: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_23: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 24: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_24: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 25: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_25: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 26: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_26: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 27: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_27: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 28: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_28: Done !!!");     

    //------------------------------------------------------------------   
	// Layer 29: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_29: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 30: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_30: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 31: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_31: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 32: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_32: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 33: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_33: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 34: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_34: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 35: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_35: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 36: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_36: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 37: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_37: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 38: 1x1 conv, 256/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_38: Done !!!");   


    //------------------------------------------------------------------   
	// Layer 39: 3x3 conv, 128/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 3;
    Fy = 3;
    Ni = 256;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_39: Done !!!");   

    //------------------------------------------------------------------   
	// Layer 40: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 28;
	q_height = 28;
    q_channel = 256;

	Fx = 1;
    Fy = 1;
    Ni = 1024;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(14*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_40: Done !!!");   

    //------------------------------------------------------------------   
	// Max-Pool, /2
	//------------------------------------------------------------------

    
    //------------------------------------------------------------------   
	// Layer 41: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 1024;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_41: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 42: 3x3 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 3;
    Fy = 3;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_42: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 43: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 2048;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_43: Done !!!");  

   
    //------------------------------------------------------------------   
	// Layer 44: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 2048;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_44: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 45: 3x3 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 3;
    Fy = 3;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_45: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 46: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 2048;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_46: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 47: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 2048;

	Fx = 1;
    Fy = 1;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_47: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 48: 3x3 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 3;
    Fy = 3;
    Ni = 512;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_48: Done !!!");  

    //------------------------------------------------------------------   
	// Layer 49: 1x1 conv, 512/ stide=1
	//------------------------------------------------------------------
    q_width  = 14;
	q_height = 14;
    q_channel = 512;

	Fx = 1;
    Fy = 1;
    Ni = 2048;
    q_step_x = 1;
    q_step_y = 1; 
	
    #(100*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b1;
	#(4*CLK_PERIOD) 
        @(posedge clk)
            q_start = 1'b0;
    while(!layer_done) begin
        #(7*CLK_PERIOD) @(posedge clk);
    end

    $display("CONV_49: Done !!!");  

    //------------------------------------------------------------------   
	// Average Pool, /2
	//------------------------------------------------------------------

end
endmodule
