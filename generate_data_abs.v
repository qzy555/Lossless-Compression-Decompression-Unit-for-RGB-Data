`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/08 20:58:46
// Design Name: 
// Module Name: generate_data_abs
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
module generate_data_abs#
(
	parameter TILE_SIZE = 4'd8
)
(
	input										clk,
	input										rst_n,
	input										i_valid,

	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]		data,

	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	data_row_abs,
	output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	data_col_abs,

	output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0] flag_row_data_abs,
	output reg  [3*TILE_SIZE*TILE_SIZE - 1 : 0]	flag_row,
	output reg  [3*TILE_SIZE*TILE_SIZE - 1 : 0]	flag_col,
	output reg									o_valid
    );
integer i;
integer j;
integer k;
integer l;

reg [3 : 0] cnt;

reg [7 : 0] temp_data_diff_row_abs[7 : 0];
reg [7 : 0] temp_data_diff_col_abs[7 : 0];
reg np_row[7 : 0];
reg np_col[7 : 0];

always @(*)
begin
	if(cnt == 1'b1)
	begin
	np_row[0] <= 1'b0;
	temp_data_diff_row_abs[0] <= data[7 : 0];
	np_col[0] <= 1'b0;
	temp_data_diff_col_abs[0] <= data[7 : 0];

	for(j=1;j<8;j= j + 1)//np:1-后大于前?0-前大于后?
	begin
		np_row[j] <= (data[j*8*TILE_SIZE + 7 -: 8] >= data[(j - 1)*8*TILE_SIZE + 7 -: 8]) ? 1'b1 : 1'b0;
		temp_data_diff_row_abs[j] <= (np_row[j]
									? (data[j*8*TILE_SIZE + 7 -: 8] - data[(j - 1)*8*TILE_SIZE + 7 -: 8])
									: (data[(j - 1)*8*TILE_SIZE + 7 -: 8] - data[j*8*TILE_SIZE + 7 -: 8]));
		np_col[j] <= (data[j*8 + 7 -: 8] >= data[(j - 1)*8 + 7 -: 8]) ? 1'b1 : 1'b0;
		temp_data_diff_col_abs[j] <= (np_col[j]
									? (data[j*8 + 7 -: 8] - data[(j - 1)*8 + 7 -: 8])
									: (data[(j - 1)*8 + 7 -: 8] - data[j*8 + 7 -: 8]));
	end
	end
	else if(cnt > 1'b1 && cnt < 4'd9)
	begin
		for(i = 0; i < TILE_SIZE; i = i + 1)
		begin
			np_col[i] <= (data[(cnt - 1)*TILE_SIZE*8 + i*8 + 7 -: 8] >= data[(cnt - 2)*TILE_SIZE*8 + i*8 + 7 -: 8]) ? 1'b1 : 1'b0;
			temp_data_diff_col_abs[i] <= (np_col[i] 
										? (data[(cnt - 1)*TILE_SIZE*8 + i*8 + 7 -: 8] - data[(cnt - 2)*TILE_SIZE*8 + i*8 + 7 -: 8]) 
										: (data[(cnt - 2)*TILE_SIZE*8 + i*8 + 7 -: 8] - data[(cnt - 1)*TILE_SIZE*8 + i*8 + 7 -: 8]));
			np_row[i] <= (data[i*8*TILE_SIZE + (cnt - 1)*8 + 7 -: 8] >= data[i*8*TILE_SIZE + (cnt - 2)*8 + 7 -: 8]) ? 1'b1 : 1'b0;
			temp_data_diff_row_abs[i] <= (np_row[i]
										? (data[i*8*TILE_SIZE + (cnt - 1)*8 + 7 -: 8] - data[i*8*TILE_SIZE + (cnt - 2)*8 + 7 -: 8])
										: (data[i*8*TILE_SIZE + (cnt - 2)*8 + 7 -: 8] - data[i*8*TILE_SIZE + (cnt - 1)*8 + 7 -: 8]));
		end
	end
	else
	begin
	   for(i=0;i<8;i=i + 1)
	   begin
	       np_row[i] <= 1'b0;
	       np_col[i] <= 1'b0;
	       temp_data_diff_row_abs[i] <= 8'b0;
	       temp_data_diff_col_abs[i] <= 8'b0;
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
			cnt <= 4'd1;
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
	else
	begin
		if(cnt > 4'd7)//&& !o_valid
		begin
			o_valid <= 1'd1;
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
		data_row_abs <= 512'd0;
		data_col_abs <= 512'd0;
		flag_row <= 192'b0;
		flag_col <= 192'b0;
	end
	else if(i_valid)
	begin
		if(cnt > 1'd0)
		begin
			for(k=0;k<8;k=k + 1)
			begin
				data_row_abs[k*8*TILE_SIZE + (cnt - 1)*8 + 7 -: 8] <= temp_data_diff_row_abs[k];
	
				if(temp_data_diff_row_abs[k] == 1'b0)
				begin
					flag_row[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= 3'd0;
				end
				else if(temp_data_diff_row_abs[k][7 : 2] == 6'b0)
				begin
					flag_row[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= (np_row[k] ? 3'd1 : 3'd2);
				end
				else if(temp_data_diff_row_abs[k][7 : 4] == 4'b0)
				begin
					flag_row[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= (np_row[k] ? 3'd3 : 3'd4);
				end
				else 
				begin
					flag_row[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= (np_row[k] ? 3'd5 : 3'd6);
				end

				data_col_abs[k*8 + (cnt - 1)*8*TILE_SIZE + 7 -: 8] <= temp_data_diff_col_abs[k];

				if(temp_data_diff_col_abs[k] == 1'b0)
				begin
					flag_col[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= 3'd0;
				end
				else if(temp_data_diff_col_abs[k][7 : 2] == 6'b0)
				begin
					flag_col[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= np_col[k] ? 3'd1 : 3'd2;
				end
				else if(temp_data_diff_col_abs[k][7 : 4] == 4'b0)
				begin
					flag_col[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= np_col[k] ? 3'd3 : 3'd4;
				end
				else 
				begin
					flag_col[k*3 + (cnt - 1)*3*TILE_SIZE + 2 -: 3] <= np_col[k] ? 3'd5 : 3'd6;
				end
			end
		end
		else 
		begin
			
		end
	end
	/*else if(o_valid)
	begin
		data_row_abs <= data_row_abs;
		data_col_abs <= data_col_abs;
		flag_row <= flag_row;
		flag_col <= flag_col;	
	end*/
	else
	begin
		data_row_abs <= 512'b0;
		data_col_abs <= 512'b0;
		flag_row <= 192'b0;
		flag_col <= 192'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		flag_row_data_abs <= 192'b0;
	end
	else if(cnt == 4'd8)
	begin
		for(l=0;l<7;l=l + 1)
		begin
			flag_row_data_abs[l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 2 -: 3];
			flag_row_data_abs[1*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 1*3 + 2 -: 3];
			flag_row_data_abs[2*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 2*3 + 2 -: 3];
			flag_row_data_abs[3*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 3*3 + 2 -: 3];
			flag_row_data_abs[4*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 4*3 + 2 -: 3];
			flag_row_data_abs[5*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 5*3 + 2 -: 3];
			flag_row_data_abs[6*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 6*3 + 2 -: 3];
			flag_row_data_abs[7*TILE_SIZE*3 + l*3 + 2 -: 3] <= flag_row[l*3*TILE_SIZE + 7*3 + 2 -: 3];
		end
		for(k=0;k<8;k=k + 1)
		begin
			if(temp_data_diff_row_abs[k] == 1'b0)
			begin
				flag_row_data_abs[k*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3] <= 3'd0;
			end
			else if(temp_data_diff_row_abs[k][7 : 2] == 6'b0)
			begin
				flag_row_data_abs[k*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3] <= (np_row[k] ? 3'd1 : 3'd2);
			end
			else if(temp_data_diff_row_abs[k][7 : 4] == 4'b0)
			begin
				flag_row_data_abs[k*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3] <= (np_row[k] ? 3'd3 : 3'd4);
			end
			else 
			begin
				flag_row_data_abs[k*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3] <= (np_row[k] ? 3'd5 : 3'd6);
			end
		end
	end
	else
	begin
		flag_row_data_abs <= 192'b0;
	end
end


reg [7:0] dis_data_row_abs[63:0];
reg [7:0] dis_data_col_abs[63:0];
reg [2:0] dis_flag_row_data_abs[63:0];
reg [2:0] dis_flag_row[63:0];
reg [2:0] dis_flag_col[63:0];
reg [7:0] dis_data[63:0];

always @(*)
begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_data_row_abs[i] <= data_row_abs[i*8 + 7 -: 8];
		dis_data_col_abs[i] <= data_col_abs[i*8 + 7 -: 8];
		dis_flag_row_data_abs[i] <= flag_row_data_abs[i*3 + 2 -: 3];
		dis_flag_row[i] <= flag_row[i*3 + 2 -: 3];
		dis_flag_col[i] <= flag_col[i*3 + 2 -: 3];
		dis_data[i] <= data[i*8 + 7 -: 8];
    end
end

endmodule
