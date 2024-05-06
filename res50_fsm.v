`timescale 1ns / 1ps

module res50_fsm(
clk,
rstn,
// Inputs
q_width,
q_height,
q_channel,
q_step_x,
q_step_y,
q_vsync_delay,
q_hsync_delay,
q_frame_size,
q_start,
//output
o_ctrl_vsync_run,
o_ctrl_vsync_cnt,
o_ctrl_hsync_run,
o_ctrl_hsync_cnt,
o_ctrl_data_run,
o_row,
o_col,
o_chn,
o_data_count,
o_end_frame
);

parameter W_SIZE  = 8;					
parameter W_FRAME_SIZE  = 2 * W_SIZE + 3;	
parameter W_DELAY = 12;

input clk, rstn;
input [W_SIZE-1 :0] q_width;
input [W_SIZE-1 :0] q_height;
input [W_SIZE-1 :0] q_channel;
input [W_SIZE-1 :0] q_step_x;
input [W_SIZE-1 :0] q_step_y;
input [W_DELAY-1:0] q_vsync_delay;
input [W_DELAY-1:0] q_hsync_delay;
input [W_FRAME_SIZE-1:0] q_frame_size;
input q_start;

output 					 o_ctrl_vsync_run;
output [W_DELAY-1:0]	 o_ctrl_vsync_cnt;
output 					 o_ctrl_hsync_run;
output [W_DELAY-1:0]	 o_ctrl_hsync_cnt;
output 					 o_ctrl_data_run;
output [W_SIZE-1:0] 	 o_row;
output [W_SIZE-1:0] 	 o_col;
output [W_SIZE-1:0] 	 o_chn;
output [W_FRAME_SIZE-1:0]o_data_count;
output o_end_frame;
//-------------------------------------------------
// Internal signals
//-------------------------------------------------
localparam		ST_IDLE 	= 2'b00,
				ST_VSYNC	= 2'b01,
				ST_HSYNC	= 2'b10,
				ST_DATA		= 2'b11;
reg [1:0] cstate, nstate;
reg 				ctrl_vsync_run;
reg [W_DELAY-1:0]	ctrl_vsync_cnt;
reg 				ctrl_hsync_run;
reg [W_DELAY-1:0]	ctrl_hsync_cnt;
reg 				ctrl_data_run;
reg [W_SIZE-1:0] 	row;
reg [W_SIZE-1:0] 	col;
reg [W_SIZE-1:0] 	chn;
reg [W_FRAME_SIZE-1:0] data_count;
wire end_frame;
//-------------------------------------------------
// FSM
//-------------------------------------------------
always@(posedge clk, negedge rstn)
begin
    if(!rstn) begin
        cstate <= ST_IDLE;
    end
    else begin
        cstate <= nstate;
    end
end
always @(*) begin
    case(cstate)
		ST_IDLE: begin
			if(q_start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
        end		
        ST_VSYNC: begin
			if(ctrl_vsync_cnt == q_vsync_delay) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
        end	
        ST_HSYNC: begin
			if(ctrl_hsync_cnt == q_hsync_delay) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
        end		
        ST_DATA: begin
			if(end_frame)		//end of frame
				nstate = ST_IDLE;
			else begin
				if((col == q_width - q_step_x) && (chn == q_channel-1))    //end of line
				nstate = ST_HSYNC;
			else
				nstate = ST_DATA;
			end
        end
        default: nstate = ST_IDLE;
    endcase
end
always @(*) begin
	ctrl_vsync_run = 0;
	ctrl_hsync_run = 0;
	ctrl_data_run  = 0;
	case(cstate)
		ST_VSYNC: 	begin ctrl_vsync_run = 1; end
		ST_HSYNC: 	begin ctrl_hsync_run = 1; end
		ST_DATA: 	begin ctrl_data_run  = 1; end
	endcase
end
always@(posedge clk, negedge rstn)
begin
    if(!rstn) begin
        ctrl_vsync_cnt <= 0;
		ctrl_hsync_cnt <= 0;
    end
    else begin
        if(ctrl_vsync_run)
			ctrl_vsync_cnt <= ctrl_vsync_cnt + 1;
		else 
			ctrl_vsync_cnt <= 0;
			
        if(ctrl_hsync_run)
			ctrl_hsync_cnt <= ctrl_hsync_cnt + 1;			
		else
			ctrl_hsync_cnt <= 0;
    end
end
always@(posedge clk, negedge rstn)
begin
    if(!rstn) begin
        row <= 0;
		col <= 0;
		chn <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(chn == q_channel-1) begin 
				if(col == q_width - q_step_x) begin
					if(row == q_height - q_step_y)
						row <= 0;			
					else 
						row <= row + q_step_y;
				end
				if(col == q_width - q_step_x) 
					col <= 0;
				else 
					col <= col + q_step_x;			
			end 
			if(chn == q_channel - 1) 
				chn <= 0;
			else 
				chn <= chn + 1;				
		end
	end
end
always@(posedge clk, negedge rstn)
begin
    if(!rstn) begin
        data_count <= 0;
    end
    else begin
        if(ctrl_data_run && (chn == q_channel-1)) begin
			if(!end_frame)
				data_count <= data_count + 1;
			else
				data_count <= 0;
		end
    end
end
assign end_frame = ((row == q_height - q_step_y) 
                 && (col == q_width - q_step_x)
				 && (chn == q_channel-1))? 1'b1: 1'b0;			

//-------------------------------------------------
// Outputs
//-------------------------------------------------
assign o_ctrl_vsync_run = ctrl_vsync_run;
assign o_ctrl_vsync_cnt = ctrl_vsync_cnt;
assign o_ctrl_hsync_run = ctrl_hsync_run;
assign o_ctrl_hsync_cnt = ctrl_hsync_cnt;
assign o_ctrl_data_run  = ctrl_data_run ;
assign o_row = row;
assign o_col = col;
assign o_chn = chn;
assign o_data_count = data_count;
assign o_end_frame = end_frame;
endmodule
