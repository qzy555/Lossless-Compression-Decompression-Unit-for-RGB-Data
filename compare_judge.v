`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/10 09:35:07
// Design Name: 
// Module Name: compare_judge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module compare_judge#
(
	parameter TILE_SIZE = 4'd8
)
(
	input									clk,
	input									rst_n,
	input									i_valid,

	input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	flag_data,

	output reg	[2*TILE_SIZE - 1 : 0]		judge,
	output reg	[3*TILE_SIZE - 1 : 0]		diff_position,
	output reg	[3*TILE_SIZE - 1 : 0]		diff_flag_data,
	output reg	[3*TILE_SIZE - 1 : 0]		same_flag_data,

	output reg								o_valid
    );

	integer i;
	integer j;
	integer k;
	integer l;

	reg [3 : 0] cnt;//9 cycle

	reg [2 : 0] temp_diff_position;

	reg temp_diff_position_0[6 : 0];
	reg temp_diff_position_1[5 : 0];

	//reg [7 : 0] diff_position_0[7 : 0];
	//reg [7 : 0] diff_position_1[7 : 0];
	reg [3 : 0] diff_num_0;
	reg [3 : 0] diff_num_1;

	always @(*)
	begin
		if(cnt == 1'b1)
		begin
			temp_diff_position_0[0] <= 1'b0;
			for(i=1;i<7;i=i + 1)
			begin
				temp_diff_position_0[i] <= (flag_data[(i + 1)*3 + 2 -: 3] == flag_data[3 + 2 -: 3]) ? 1'b0 : 1'b1;
			end
			diff_num_0 <= temp_diff_position_0[0] + temp_diff_position_0[1] + temp_diff_position_0[2] + temp_diff_position_0[3]
						+ temp_diff_position_0[4] + temp_diff_position_0[5] + temp_diff_position_0[6];
			temp_diff_position_1[0] <= 1'b0;
			for(j=1;j<6;j=j + 1)
			begin
				temp_diff_position_1[j] <= (flag_data[(j + 2)*3 + 2 -: 3] == flag_data[3*2 + 2 -: 3]) ? 1'b0 : 1'b1;
			end
			diff_num_1 <= temp_diff_position_1[0] + temp_diff_position_1[1] + temp_diff_position_1[2] + temp_diff_position_1[3]
						+ temp_diff_position_1[4] + temp_diff_position_1[5];
			if((diff_num_0 == 4'd6) && (diff_num_1 == 1'b0))
			begin
				temp_diff_position <= 3'd1;
			end
			else if(diff_num_0 == 4'd1)
			begin
				temp_diff_position <= temp_diff_position_0[1]*2 + temp_diff_position_0[2]*3 + temp_diff_position_0[3]*4 
									+ temp_diff_position_0[4]*5 + temp_diff_position_0[5]*6 + temp_diff_position_0[6]*7;
			end
			else 
			begin
				temp_diff_position <= 3'b0;
			end
			//temp_diff_position[2 : 0] <= ((diff_num_0 == 4'd6) && (diff_num_1 == 1'b0)) ? 3'b1 : (temp_diff_position_0[0]*1 + temp_diff_position_0[1]*2 + temp_diff_position_0[2]*3
							   						 //+ temp_diff_position_0[3]*4 + temp_diff_position_0[4]*5 + temp_diff_position_0[5]*6 + temp_diff_position_0[6]*7);
		end
		else if(cnt > 1'b1)
		begin
			for(k=0;k<7;k=k + 1)
			begin
				temp_diff_position_0[k] <= (flag_data[(cnt - 1)*3*TILE_SIZE + (k + 1)*3 + 2 -: 3] == flag_data[(cnt - 1)*3*TILE_SIZE + 2 -: 3]) ? 1'b0 : 1'b1;
			end
			diff_num_0 <= temp_diff_position_0[0] + temp_diff_position_0[1] + temp_diff_position_0[2] + temp_diff_position_0[3]
						+ temp_diff_position_0[4] + temp_diff_position_0[5] + temp_diff_position_0[6];
			for(l=0;l<6;l=l + 1)
			begin
				temp_diff_position_1[l] <= (flag_data[(cnt - 1)*3*TILE_SIZE + (l + 2)*3 + 2 -: 3] == flag_data[(cnt - 1)*3*TILE_SIZE + 1*3 + 2 -: 3]) ? 1'b0 : 1'b1;
			end
			diff_num_1 <= temp_diff_position_1[0] + temp_diff_position_1[1] + temp_diff_position_1[2] + temp_diff_position_1[3]
						+ temp_diff_position_1[4] + temp_diff_position_1[5];
			if((diff_num_0 == 4'd7) && (diff_num_1 == 1'b0))
			begin
				temp_diff_position <= 3'b0;
			end
			else if(diff_num_0 == 4'd1)
			begin
				temp_diff_position <= temp_diff_position_0[0]*1 + temp_diff_position_0[1]*2 + temp_diff_position_0[2]*3 
									+ temp_diff_position_0[3]*4 + temp_diff_position_0[4]*5 + temp_diff_position_0[5]*6 + temp_diff_position_0[6]*7;
			end
			else 
			begin
				temp_diff_position <= 3'b0;
			end
			//temp_diff_position[(cnt - 1)*3 + 2 -: 3] <= ((diff_num_0 == 4'd7) && (diff_num_1 == 1'b0)) ? 3'b0 : (temp_diff_position_0[0]*1 + temp_diff_position_0[1]*2 + temp_diff_position_0[2]*3
							   						 //+ temp_diff_position_0[3]*4 + temp_diff_position_0[4]*5 + temp_diff_position_0[5]*6 + temp_diff_position_0[6]*7);
		end
		else
		begin
			diff_num_0 <= 4'b0;
			diff_num_1 <= 4'b0;
			temp_diff_position <= 24'b0;
			for(i = 0; i < 7; i = i + 1)
			begin
				temp_diff_position_0[i] <= 1'b0;
			end
			for(j = 0;j < 6; j=j + 1)
			begin
			    temp_diff_position_1[j] <= 1'b0;
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			cnt <= 4'd0;
		end
		else
		begin
			if(i_valid && cnt == 4'd0)
			begin
				cnt <= 1'b1;	
			end
			else if(cnt > 4'd7)
			begin
				cnt <= 4'd0;
			end
			else if(cnt > 4'd0)
			begin
				cnt <= cnt + 1'b1;
			end
			else 
			begin
				
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			o_valid <= 1'd0;
		end
		else if(cnt > 4'd7)
		begin
			o_valid <= 1'b1;
		end
		else 
		begin
			o_valid <= 1'd0;
		end
	end


	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			judge <= 16'b0;
		end
		else
		begin
			if(cnt == 1'd1)
			begin
				if(diff_num_0 == 1'b0)
				begin
					judge[1 : 0] <= 2'b0;
				end
				else if(diff_num_0 == 1'b1 || ((diff_num_0 == 4'd6) && (diff_num_1 == 1'b0)))
				begin
					judge[1 : 0] <= 2'd1;
				end
				else 
				begin
					judge[1 : 0] <= 2'd3;
				end
			end
			else if(cnt > 1'd1)
			begin
				if(diff_num_0 == 1'b0)
				begin
					judge[((cnt - 1))*2 + 1 -: 2] <= 2'b0;
				end
				else if(diff_num_0 == 1'b1 || ((diff_num_0 == 4'd7) && (diff_num_1 == 1'b0)))
				begin
					judge[((cnt - 1))*2 + 1 -: 2] <= 2'd1;
				end
				else 
				begin
					judge[((cnt - 1))*2 + 1 -: 2] <= 2'd3;
				end
			end
			/*else if(o_valid)
			begin
				judge <= judge;
			end*/
			else 
			begin
				judge <= 16'b0;
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			diff_flag_data <= 24'b0;
			same_flag_data <= 24'b0;
			diff_position <= 24'b0;
		end
		else
		begin
			if(cnt == 1'd1)
			begin
				if(diff_num_0 == 1'b1 || ((diff_num_0 == 4'd6) && (diff_num_1 == 1'b0)))
				begin
					diff_position[2 : 0] <= temp_diff_position;
					diff_flag_data[2 : 0] <= flag_data[temp_diff_position*3 + 2 -: 3];

					same_flag_data[2 : 0] <= (temp_diff_position == 3'b1) 
									    	? flag_data[2*3 + 2 -: 3] 
									    	: flag_data[3 + 2 -: 3];
				end
				else 
				begin
					diff_position[2 : 0] <= 3'b0;
					diff_flag_data[2 : 0] <= 3'b0;
					same_flag_data[2 : 0] <= 3'b0;
				end
			end
			else if(cnt > 1'd1)
			begin
				if(diff_num_0 == 1'b1 || ((diff_num_0 == 4'd7) && (diff_num_1 == 1'b0)))
				begin
					diff_position[(cnt - 1)*3 + 2 -: 3] <= temp_diff_position;
					diff_flag_data[((cnt - 1))*3 + 2 -: 3] <= flag_data[(cnt - 1)*3*TILE_SIZE + temp_diff_position*3 + 2 -: 3];
	
					same_flag_data[((cnt - 1))*3 + 2 -: 3] <= (temp_diff_position == 3'b0) 
													  		? flag_data[(cnt - 1)*3*TILE_SIZE + 3 + 2 -: 3] 
													  		: flag_data[(cnt - 1)*3*TILE_SIZE + 2 -: 3];
				end
				else 
				begin
					diff_position[(cnt - 1)*3 + 2 -: 3] <= 3'b0;
					diff_flag_data[((cnt - 1))*3 + 2 -: 3] <= 3'b0;
	
					same_flag_data[((cnt - 1))*3 + 2 -: 3] <= 3'b0;
				end
			end
			/*else if(o_valid)
			begin
				diff_flag_data <= diff_flag_data;
				same_flag_data <= same_flag_data;
				diff_position <= diff_position;
			end*/
			else 
			begin
				diff_flag_data <= 24'b0;
				same_flag_data <= 24'b0;
				diff_position <= 24'b0;
			end
		end
	end
	
    reg [3 - 1 : 0] 	dis_flag_data[63:0];
    reg	[2 - 1 : 0]		dis_judge[7:0];          
    reg	[3 - 1 : 0]		dis_diff_position[7:0];  
    reg	[3 - 1 : 0]		dis_diff_flag_data[7:0];
    reg	[3 - 1 : 0]		dis_same_flag_data[7:0];

    always @(*)
    begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_flag_data[i] <= flag_data[i*3 + 2 -: 3];
    end
    for(i = 0; i <= 7; i = i + 1)
    begin
        dis_judge[i] <= judge[i*2 + 1 -: 2];
        dis_diff_position[i] <= diff_position[i*3 + 2 -: 3];
        dis_diff_flag_data[i] <= diff_flag_data[i*3 + 2 -: 3];
        dis_same_flag_data[i] <= same_flag_data[i*3 + 2 -: 3];
    end
    end
endmodule
