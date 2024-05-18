`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/09 11:15:54
// Design Name: 
// Module Name: compress_receive_data
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


module compress_receive_data#
(	parameter TILE_SIZE = 4'd8
)
(
	input wire					clk,
	input wire					rst_n,
	
	input wire	[32 - 1 : 0]	data_width,
	// i_data_valid == 1 for 8 cycles
	input wire					i_valid,
	input wire	[512 - 1 : 0]	i_data,
	
	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	b_data,
	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	g_data,
	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	r_data,
	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	a_data,
	output reg					o_valid
    );

	/*reg [512 - 1 : 0] b_data;
	reg [512 - 1 : 0] g_data;
	reg [512 - 1 : 0] r_data;
	reg [512 - 1 : 0] a_data;*/

	reg [4 : 0] cnt;
	reg [4 : 0] cnt_up;

	always @(*)
	begin
		cnt_up <= (8*TILE_SIZE*TILE_SIZE*4)/data_width - 1;
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			cnt <= 5'b0;
		end
		else
		begin
			/*if(i_valid && cnt == 3'b0)
			begin
				cnt <= 5'd1;
			end
			else*/ 
			if(i_valid && cnt < cnt_up)
			begin
				cnt <= cnt + 1;
			end
			else if(cnt == cnt_up)
			begin
				cnt <= 5'd0;
			end
			else 
			begin
				cnt <= 5'd0;
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			o_valid <= 1'b0;
		end
		else
		begin
			if(cnt == cnt_up)
			begin
				o_valid <= 1'b1;
			end
			else 
			begin
				o_valid <= 1'b0;
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			b_data <= 512'b0;
			g_data <= 512'b0;
			r_data <= 512'b0;
			a_data <= 512'b0;
		end
		else if(i_valid)
		begin
			//if(cnt > 5'd0)
			//begin
				if(data_width == 128)
				begin
					b_data[cnt*32 + 31 -: 32] <= {i_data[103 : 96],i_data[71 : 64],i_data[39 : 32],i_data[7 : 0]};
					g_data[cnt*32 + 31 -: 32] <= {i_data[111 : 104],i_data[79 : 72],i_data[47 : 40],i_data[15 : 8]};
					r_data[cnt*32 + 31 -: 32] <= {i_data[119 : 112],i_data[87 : 80],i_data[55 : 48],i_data[23 : 16]};
					a_data[cnt*32 + 31 -: 32] <= {i_data[127 : 120],i_data[95 : 88],i_data[63 : 56],i_data[31 : 24]};
				end
				else if(data_width == 256)
				begin
					b_data[cnt*64 + 63 -: 64] <= {i_data[231 : 224],i_data[199 : 192],i_data[167 : 160],i_data[135 : 128],i_data[103 : 96],i_data[71 : 64],i_data[39 : 32],i_data[7 : 0]};
					g_data[cnt*64 + 63 -: 64] <= {i_data[239 : 232],i_data[207 : 200],i_data[175 : 168],i_data[143 : 136],i_data[111 : 104],i_data[79 : 72],i_data[47 : 40],i_data[15 : 8]};
					r_data[cnt*64 + 63 -: 64] <= {i_data[247 : 240],i_data[215 : 208],i_data[183 : 176],i_data[151 : 144],i_data[119 : 112],i_data[87 : 80],i_data[55 : 48],i_data[23 : 16]};
					a_data[cnt*64 + 63 -: 64] <= {i_data[255 : 248],i_data[223 : 216],i_data[191 : 184],i_data[159 : 152],i_data[127 : 120],i_data[95 : 88],i_data[63 : 56],i_data[31 : 24]};
				end
				else if(data_width == 512)
				begin
					b_data[cnt*128 + 127 -: 128] <= {i_data[487 : 480],i_data[455 : 448],i_data[423 : 416],i_data[391 : 384],i_data[359 : 352],i_data[327 : 320],i_data[295 : 288],i_data[263 : 256],i_data[231 : 224],i_data[199 : 192],i_data[167 : 160],i_data[135 : 128],i_data[103 : 96],i_data[71 : 64],i_data[39 : 32],i_data[7 : 0]};
					g_data[cnt*128 + 127 -: 128] <= {i_data[495 : 488],i_data[463 : 456],i_data[431 : 424],i_data[399 : 392],i_data[367 : 360],i_data[335 : 328],i_data[303 : 296],i_data[271 : 264],i_data[239 : 232],i_data[207 : 200],i_data[175 : 168],i_data[143 : 136],i_data[111 : 104],i_data[79 : 72],i_data[47 : 40],i_data[15 : 8]};
					r_data[cnt*128 + 127 -: 128] <= {i_data[503 : 496],i_data[471 : 464],i_data[439 : 432],i_data[407 : 400],i_data[375 : 368],i_data[343 : 336],i_data[311 : 304],i_data[279 : 272],i_data[247 : 240],i_data[215 : 208],i_data[183 : 176],i_data[151 : 144],i_data[119 : 112],i_data[87 : 80],i_data[55 : 48],i_data[23 : 16]};
					a_data[cnt*128 + 127 -: 128] <= {i_data[511 : 504],i_data[479 : 472],i_data[447 : 440],i_data[415 : 408],i_data[383 : 376],i_data[351 : 344],i_data[319 : 312],i_data[287 : 280],i_data[255 : 248],i_data[223 : 216],i_data[191 : 184],i_data[159 : 152],i_data[127 : 120],i_data[95 : 88],i_data[63 : 56],i_data[31 : 24]};
				end
				else 
				begin
					
				end
			//end
			//else 
			//begin
			
			//end
		end
	end


reg [7 : 0] dis_b_data[63 : 0];
reg [7 : 0] dis_g_data[63 : 0];
reg [7 : 0] dis_r_data[63 : 0];
reg [7 : 0] dis_a_data[63 : 0];
reg [7 : 0] dis_i_data[63 : 0];
integer i;
always @(*)
begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_b_data[i] <= b_data[i*8 + 7 -: 8];
        dis_g_data[i] <= g_data[i*8 + 7 -: 8];
        dis_r_data[i] <= r_data[i*8 + 7 -: 8];
        dis_a_data[i] <= a_data[i*8 + 7 -: 8];
        dis_i_data[i] <= i_data[i*8 + 7 -: 8];
    end
end
endmodule
