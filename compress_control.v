`timescale 1ns / 1ps

module compress_control#
(	parameter TILE_SIZE = 4'd8
)
(
input												clk,
input												rst_n,

//compress_receive
input												receive_o_valid,
input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				receive_b_data,
input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				receive_g_data,
input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				receive_r_data,
input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				receive_a_data,

//generate_data_abs
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_data,
output reg											generate_i_valid,

input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				generate_data_row_abs,
input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				generate_data_col_abs,
input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]				generate_flag_row_data_abs,
input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]				generate_flag_row,
input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]				generate_flag_col,
input												generate_o_valid,

//compare_judge
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_judge_flag_data,
output reg											cp_judge_i_valid,

input	[2*TILE_SIZE - 1 : 0]						cp_judge_judge,
input	[3*TILE_SIZE - 1 : 0]						cp_judge_diff_position,
input	[3*TILE_SIZE - 1 : 0]						cp_judge_diff_flag_data,
input	[3*TILE_SIZE - 1 : 0]						cp_judge_same_flag_data,
input												cp_judge_o_valid,

//calculate_size
output reg											calculate_i_valid,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			calculate_flag_data,
output reg	[2*TILE_SIZE - 1 : 0]					calculate_judge,
output reg	[3*TILE_SIZE - 1 : 0]					calculate_diff_flag_data,
output reg	[3*TILE_SIZE - 1 : 0]					calculate_same_flag_data,

input												calculate_o_valid,
input	[6 : 0]										calculate_all_data_byte_size,

//compress_core_data
output reg											compress_core_data_i_valid,  
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_data_data_abs,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_data_flag_data,

input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]				compress_core_data_data_abs_compressed,
input	[5 : 0]										compress_core_data_data_abs_compressed_bytesize,
input												compress_core_data_o_valid,

//compress_core_flag
output reg											compress_core_flag_i_valid,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_flag_data,
output reg	[2*TILE_SIZE - 1 : 0]					compress_core_judge,
output reg	[3*TILE_SIZE - 1 : 0]					compress_core_diff_position,
output reg	[3*TILE_SIZE - 1 : 0]					compress_core_diff_flag_data,
output reg	[3*TILE_SIZE - 1 : 0]					compress_core_same_flag_data,

input	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]		compress_core_flag_data_compressed,
input	[5 : 0]										compress_core_flag_data_compressed_bytesize,
input												compress_core_flag_o_valid,

//compare_bgr
output reg											cp_bgr_i_valid,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_b_flag,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_g_flag,
output reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_r_flag,

input	[6*7 - 1 : 0]								cp_bgr_diff_g_position,
input	[3*7 - 1 : 0]								cp_bgr_diff_g_flag,
input	[6*7 - 1 : 0]								cp_bgr_diff_r_position,
input	[3*7 - 1 : 0]								cp_bgr_diff_r_flag,
input	[2 : 0]										cp_bgr_g_diff_num,
input	[2 : 0]										cp_bgr_r_diff_num,
input												cp_bgr_similar_g,
input												cp_bgr_similar_r,
input												cp_bgr_o_valid,

//compress_core_flag_bgr_same
output reg											compress_bgr_same_i_valid,
output reg	[6*7 - 1 : 0]							compress_bgr_same_diff_position,
output reg	[3*7 - 1 : 0]							compress_bgr_same_diff_flag,
output reg	[2 : 0]									compress_bgr_same_diff_num,

input	[76 : 0]									compress_bgr_flag_data_compressed,
input	[3 : 0]										compress_bgr_flag_data_compressed_bytesize,
input												compress_bgr_o_valid,

//tidy_data
output reg											tidy_i_valid,
output reg											tidy_similar_g,
output reg											tidy_similar_r,
output reg											tidy_row_col,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_b_data_abs_compressed,
output reg	[5 : 0]									tidy_b_data_abs_compressed_bytesize,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_g_data_abs_compressed,
output reg	[5 : 0]									tidy_g_data_abs_compressed_bytesize,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_r_data_abs_compressed,
output reg	[5 : 0]									tidy_r_data_abs_compressed_bytesize,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_a_data_abs_compressed,
output reg	[5 : 0]									tidy_a_data_abs_compressed_bytesize,
output reg	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_b_flag_data_compressed,
output reg	[5 : 0]									tidy_b_flag_data_compressed_bytesize,
output reg	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_g_flag_data_compressed,
output reg	[5 : 0]									tidy_g_flag_data_compressed_bytesize,
output reg	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_r_flag_data_compressed,
output reg	[5 : 0]									tidy_r_flag_data_compressed_bytesize,
output reg	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_a_flag_data_compressed,
output reg	[5 : 0]									tidy_a_flag_data_compressed_bytesize,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_b_data,//Receive-data
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_g_data,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_r_data,
output reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_a_data
);

reg	[3 : 0]	state, next_state, pre_state;
parameter IDLE      = 4'd0;
parameter GENERATE  = 4'd1;
parameter JUDGE_AB  = 4'd2;
parameter CALCULATE = 4'd3;
parameter JUDGE_GR  = 4'd4;
parameter COMP_DATA = 4'd5;
parameter CP_BGR    = 4'd6;
parameter COMP_FLAG = 4'd7;
parameter TIDY      = 4'd8;

reg	[2 : 0]							cnt;
reg	[4 : 0]							cnt_valid;

//generate data
reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	b_data_row_abs;
reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	b_data_col_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	b_flag_row_data_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	b_flag_row;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	b_flag_col;

reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	g_data_row_abs;
reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	g_data_col_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	g_flag_row_data_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	g_flag_row;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	g_flag_col;

reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	r_data_row_abs;
reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	r_data_col_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	r_flag_row_data_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	r_flag_row;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	r_flag_col;

reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	a_data_row_abs;
reg	[8*TILE_SIZE*TILE_SIZE - 1 : 0]	a_data_col_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	a_flag_row_data_abs;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	a_flag_row;
reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	a_flag_col;

//judge_ab
reg	[15 : 0]						a_row_judge;
reg	[23 : 0]						a_row_diff_position;
reg	[23 : 0]						a_row_diff_flag_data;
reg	[23 : 0]						a_row_same_flag_data;

reg	[15 : 0]						a_col_judge;
reg	[23 : 0]						a_col_diff_position;
reg	[23 : 0]						a_col_diff_flag_data;
reg	[23 : 0]						a_col_same_flag_data;

reg	[15 : 0]						b_row_judge;
reg	[23 : 0]						b_row_diff_position;
reg	[23 : 0]						b_row_diff_flag_data;
reg	[23 : 0]						b_row_same_flag_data;

reg	[15 : 0]						b_col_judge;
reg	[23 : 0]						b_col_diff_position;
reg	[23 : 0]						b_col_diff_flag_data;
reg	[23 : 0]						b_col_same_flag_data;

//calculate_size
reg	[7 : 0]							a_row_all_data_byte_size;
reg	[7 : 0]							a_col_all_data_byte_size;
reg	[7 : 0]							b_row_all_data_byte_size;
reg	[7 : 0]							b_col_all_data_byte_size;

//reg row_col;

//judge_gr
reg	[15 : 0]						g_judge;
reg	[23 : 0]						g_diff_position;
reg	[23 : 0]						g_diff_flag_data;
reg	[23 : 0]						g_same_flag_data;

reg	[15 : 0]						r_judge;
reg	[23 : 0]						r_diff_position;
reg	[23 : 0]						r_diff_flag_data;
reg	[23 : 0]						r_same_flag_data;

//cp_bgr
reg	[6*7 - 1 : 0]					diff_g_position;
reg	[3*7 - 1 : 0]					diff_g_flag;
reg	[6*7 - 1 : 0]					diff_r_position;
reg	[3*7 - 1 : 0]					diff_r_flag;
reg	[2 : 0]							g_diff_num;
reg	[2 : 0]							r_diff_num;

always @(*)
begin
	tidy_row_col <= ((a_row_all_data_byte_size + b_row_all_data_byte_size) >= (a_col_all_data_byte_size + b_col_all_data_byte_size)) ? 1'b0 : 1'b1;
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		pre_state <= IDLE;
	end
	else
	begin
		pre_state <= state;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		state <= IDLE;
	end
	else if(receive_o_valid)
	begin
		state <= GENERATE;
	end
	else if(pre_state == GENERATE && cnt == 3'd4)
	begin
		state <= JUDGE_AB;
	end
	else if(pre_state == JUDGE_AB && cnt == 3'd4)
	begin
		state <= CALCULATE;
	end
	else if(pre_state == CALCULATE && cnt == 3'd4)
	begin
		state <= JUDGE_GR;
	end
	else if(pre_state == JUDGE_GR && cnt == 3'd2)
	begin
		state <= COMP_DATA;
	end
	else if(pre_state == COMP_DATA && cnt == 3'd4)
	begin
		state <= CP_BGR;
	end
	else if(pre_state == CP_BGR && cp_bgr_o_valid)
	begin
		state <= COMP_FLAG;
	end
	else if(pre_state == COMP_FLAG && cnt == 3'd4)
	begin
		state <= TIDY;
	end
	else 
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cnt <= 3'd0;
	end
	else if(cnt == 3'd4)
	begin
		cnt <= 3'd0;
	end
	else if(state == JUDGE_GR && cnt == 3'd2)
	begin
		cnt <= 3'd0;
	end
	else
	begin
		case(state)
		GENERATE:
		begin
			cnt <= cnt + (generate_o_valid ? 1'b1 : 1'b0);
		end
		JUDGE_AB:
		begin
			cnt <= cnt + (cp_judge_o_valid ? 1'b1 : 1'b0);
		end
		CALCULATE:
		begin
			cnt <= cnt + (calculate_o_valid ? 1'b1 : 1'b0);
		end
		JUDGE_GR:
		begin
			cnt <= cnt + (cp_judge_o_valid ? 1'b1 : 1'b0);
		end
		COMP_DATA:
		begin
			cnt <= cnt + (compress_core_data_o_valid ? 1'b1 : 1'b0);
		end
		COMP_FLAG:
		begin
			cnt <= cnt + ((compress_core_flag_o_valid || compress_bgr_o_valid) ? 1'b1 : 1'b0);
		end
		default:
		begin
			
		end
		endcase
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cnt_valid <= 5'd0;
	end
	else if(receive_o_valid)
	begin
		cnt_valid <= 5'd1;
	end
	else
	begin
		case(state)
		GENERATE:
		begin
			cnt_valid <= generate_o_valid ? 5'd0 : (cnt_valid + 1'b1);
		end
		JUDGE_AB:
		begin
			cnt_valid <= cp_judge_o_valid ? 5'd0 : (cnt_valid + 1'b1);
		end
		CALCULATE:
		begin
			cnt_valid <= calculate_o_valid ? 5'd0 : (cnt_valid + 1'b1);
		end
		JUDGE_GR:
		begin
			cnt_valid <= cp_judge_o_valid ? 5'd0 : (cnt_valid + 1'b1);
		end
		COMP_DATA:
		begin
			cnt_valid <= compress_core_data_o_valid ? 5'd0 : (cnt_valid + 1'b1);
		end
		COMP_FLAG:
		begin
			cnt_valid <= (compress_core_flag_o_valid || compress_bgr_o_valid) ? 5'd0 : (cnt_valid + 1'b1);
		end
		default:
		begin
			
		end
		endcase
	end
end

//receive_data

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_b_data <= 512'b0;
		tidy_g_data <= 512'b0;
		tidy_r_data <= 512'b0;
		tidy_a_data <= 512'b0;
	end
	else if(receive_o_valid)
	begin
		tidy_b_data <= receive_b_data;
		tidy_g_data <= receive_g_data;
		tidy_r_data <= receive_r_data;
		tidy_a_data <= receive_a_data;
	end
	else 
	begin
		
	end
end

//generate_data_abs

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		generate_i_valid <= 1'b0;
	end
	else if(state == GENERATE && cnt_valid > 4'd0 && cnt_valid < 4'd10)
	begin
		generate_i_valid <= 1'b1;
	end
	else 
	begin
		generate_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		generate_data <= 512'b0;
	end
	else if(state == GENERATE && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd0)
	begin
		generate_data <= tidy_b_data;
	end
	else if(state == GENERATE && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd1)
	begin
		generate_data <= tidy_g_data;
	end
	else if(state == GENERATE && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd2)
	begin
		generate_data <= tidy_r_data;
	end
	else if(state == GENERATE && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd3)
	begin
		generate_data <= tidy_a_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		b_data_row_abs      <= 512'b0;
		b_data_col_abs      <= 512'b0;
		b_flag_row_data_abs <= 192'b0;
		b_flag_row          <= 192'b0;
		b_flag_col          <= 192'b0;
	end
	else if(state == GENERATE && cnt == 1'b0 && generate_o_valid)
	begin
		b_data_row_abs      <= generate_data_row_abs;
		b_data_col_abs      <= generate_data_col_abs;
		b_flag_row_data_abs <= generate_flag_row_data_abs;
		b_flag_row          <= generate_flag_row;
		b_flag_col          <= generate_flag_col;
	end
	else 
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		g_data_row_abs      <= 512'b0;
		g_data_col_abs      <= 512'b0;
		g_flag_row_data_abs <= 192'b0;
		g_flag_row          <= 192'b0;
		g_flag_col          <= 192'b0;
	end
	else if(state == GENERATE && cnt == 1'b1 && generate_o_valid)
	begin
		g_data_row_abs      <= generate_data_row_abs;
		g_data_col_abs      <= generate_data_col_abs;
		g_flag_row_data_abs <= generate_flag_row_data_abs;
		g_flag_row          <= generate_flag_row;
		g_flag_col          <= generate_flag_col;
	end
	else 
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		r_data_row_abs      <= 512'b0;
		r_data_col_abs      <= 512'b0;
		r_flag_row_data_abs <= 192'b0;
		r_flag_row          <= 192'b0;
		r_flag_col          <= 192'b0;
	end
	else if(state == GENERATE && cnt == 3'd2 && generate_o_valid)
	begin
		r_data_row_abs      <= generate_data_row_abs;
		r_data_col_abs      <= generate_data_col_abs;
		r_flag_row_data_abs <= generate_flag_row_data_abs;
		r_flag_row          <= generate_flag_row;
		r_flag_col          <= generate_flag_col;
	end
	else 
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		a_data_row_abs      <= 512'b0;
		a_data_col_abs      <= 512'b0;
		a_flag_row_data_abs <= 192'b0;
		a_flag_row          <= 192'b0;
		a_flag_col          <= 192'b0;
	end
	else if(state == GENERATE && cnt == 3'd3 && generate_o_valid)
	begin
		a_data_row_abs      <= generate_data_row_abs;
		a_data_col_abs      <= generate_data_col_abs;
		a_flag_row_data_abs <= generate_flag_row_data_abs;
		a_flag_row          <= generate_flag_row;
		a_flag_col          <= generate_flag_col;
	end
	else 
	begin
		
	end
end

//compare_judge
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cp_judge_i_valid <= 1'b0;
	end
	else if(state == JUDGE_AB && cnt_valid > 4'd0 && cnt_valid < 4'd10)
	begin
		cp_judge_i_valid <= 1'b1;
	end
	else if(state == JUDGE_GR && cnt_valid > 4'd0 && cnt_valid < 4'd10)
	begin
		cp_judge_i_valid <= 1'b1;
	end
	else
	begin
		cp_judge_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cp_judge_flag_data <= 192'b0;
	end
	else if(state == JUDGE_AB && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd0)
	begin
		cp_judge_flag_data <= a_flag_row;
	end
	else if(state == JUDGE_AB && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd1)
	begin
		cp_judge_flag_data <= a_flag_col;
	end
	else if(state == JUDGE_AB && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd2)
	begin
		cp_judge_flag_data <= b_flag_row;
	end
	else if(state == JUDGE_AB && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd3)
	begin
		cp_judge_flag_data <= b_flag_col;
	end
	else if(state == JUDGE_GR && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd0)
	begin
		cp_judge_flag_data <= tidy_row_col ? g_flag_row : g_flag_col;
	end
	else if(state == JUDGE_GR && cnt_valid > 4'd0 && cnt_valid < 4'd10 && cnt == 3'd1)
	begin
		cp_judge_flag_data <= tidy_row_col ? r_flag_row : r_flag_col;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		a_row_judge <= 16'b0;
		a_row_diff_position <= 24'b0;
		a_row_diff_flag_data <= 24'b0;
		a_row_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_AB && cnt == 1'b0 && cp_judge_o_valid)
	begin
		a_row_judge          <= cp_judge_judge;
		a_row_diff_position  <= cp_judge_diff_position;
		a_row_diff_flag_data <= cp_judge_diff_flag_data;
		a_row_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		a_col_judge <= 16'b0;
		a_col_diff_position <= 24'b0;
		a_col_diff_flag_data <= 24'b0;
		a_col_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_AB && cnt == 1'b1 && cp_judge_o_valid)
	begin
		a_col_judge          <= cp_judge_judge;
		a_col_diff_position  <= cp_judge_diff_position;
		a_col_diff_flag_data <= cp_judge_diff_flag_data;
		a_col_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		b_row_judge <= 16'b0;
		b_row_diff_position <= 24'b0;
		b_row_diff_flag_data <= 24'b0;
		b_row_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_AB && cnt == 3'd2 && cp_judge_o_valid)
	begin
		b_row_judge          <= cp_judge_judge;
		b_row_diff_position  <= cp_judge_diff_position;
		b_row_diff_flag_data <= cp_judge_diff_flag_data;
		b_row_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		b_col_judge <= 16'b0;
		b_col_diff_position <= 24'b0;
		b_col_diff_flag_data <= 24'b0;
		b_col_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_AB && cnt == 3'd3 && cp_judge_o_valid)
	begin
		b_col_judge          <= cp_judge_judge;
		b_col_diff_position  <= cp_judge_diff_position;
		b_col_diff_flag_data <= cp_judge_diff_flag_data;
		b_col_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		g_judge <= 16'b0;
		g_diff_position <= 24'b0;
		g_diff_flag_data <= 24'b0;
		g_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_GR && cnt == 3'd0 && cp_judge_o_valid)
	begin
		g_judge          <= cp_judge_judge;
		g_diff_position  <= cp_judge_diff_position;
		g_diff_flag_data <= cp_judge_diff_flag_data;
		g_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		r_judge <= 16'b0;
		r_diff_position <= 24'b0;
		r_diff_flag_data <= 24'b0;
		r_same_flag_data <= 24'b0;
	end
	else if(state == JUDGE_GR && cnt == 3'd1 && cp_judge_o_valid)
	begin
		r_judge          <= cp_judge_judge;
		r_diff_position  <= cp_judge_diff_position;
		r_diff_flag_data <= cp_judge_diff_flag_data;
		r_same_flag_data <= cp_judge_same_flag_data;
	end
	else
	begin
		
	end
end

//calculate_size
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		calculate_i_valid <= 1'b0;
	end
	else if(state == CALCULATE && cnt_valid > 4'd0 && cnt_valid < 5'd16)
	begin
		calculate_i_valid <= 1'b1;
	end
	else
	begin
		calculate_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		calculate_flag_data <= 1'b0;
		calculate_judge <= 1'b0;
		calculate_diff_flag_data <= 1'b0;
		calculate_same_flag_data <= 1'b0;
	end
	else if(state == CALCULATE && cnt_valid > 4'd0 && cnt_valid < 5'd16 && cnt == 3'd0)
	begin
		calculate_flag_data      <= a_flag_row;
		calculate_judge          <= a_row_judge;
		calculate_diff_flag_data <= a_row_diff_flag_data;
		calculate_same_flag_data <= a_row_same_flag_data;
	end
	else if(state == CALCULATE && cnt_valid > 4'd0 && cnt_valid < 5'd16 && cnt == 3'd1)
	begin
		calculate_flag_data      <= a_flag_col;
		calculate_judge          <= a_col_judge;
		calculate_diff_flag_data <= a_col_diff_flag_data;
		calculate_same_flag_data <= a_col_same_flag_data;
	end
	else if(state == CALCULATE && cnt_valid > 4'd0 && cnt_valid < 5'd16 && cnt == 3'd2)
	begin
		calculate_flag_data      <= b_flag_row;
		calculate_judge          <= b_row_judge;
		calculate_diff_flag_data <= b_row_diff_flag_data;
		calculate_same_flag_data <= b_row_same_flag_data;
	end
	else if(state == CALCULATE && cnt_valid > 4'd0 && cnt_valid < 5'd16 && cnt == 3'd3)
	begin
		calculate_flag_data      <= b_flag_col;
		calculate_judge          <= b_col_judge;
		calculate_diff_flag_data <= b_col_diff_flag_data;
		calculate_same_flag_data <= b_col_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		a_row_all_data_byte_size <= 7'b0;
	end
	else if(state == CALCULATE && cnt == 3'd0 && calculate_o_valid)
	begin
		a_row_all_data_byte_size <= calculate_all_data_byte_size;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		a_col_all_data_byte_size <= 7'b0;
	end
	else if(state == CALCULATE && cnt == 3'd1 && calculate_o_valid)
	begin
		a_col_all_data_byte_size <= calculate_all_data_byte_size;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		b_row_all_data_byte_size <= 7'b0;
	end
	else if(state == CALCULATE && cnt == 3'd2 && calculate_o_valid)
	begin
		b_row_all_data_byte_size <= calculate_all_data_byte_size;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		b_col_all_data_byte_size <= 7'b0;
	end
	else if(state == CALCULATE && cnt == 3'd3 && calculate_o_valid)
	begin
		b_col_all_data_byte_size <= calculate_all_data_byte_size;
	end
	else
	begin
		
	end
end

//compress_core_data
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_core_data_i_valid <= 1'b0;
	end
	else if(state == COMP_DATA && cnt_valid > 4'd0 && cnt_valid < 4'd13)
	begin
		compress_core_data_i_valid <= 1'b1;
	end
	else
	begin
		compress_core_data_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_core_data_data_abs <= 512'b0;
		compress_core_data_flag_data <= 192'b0;
	end
	else if(state == COMP_DATA && cnt_valid > 4'd0 && cnt_valid < 4'd13 && cnt == 3'd0)
	begin
		compress_core_data_data_abs  <= tidy_row_col ? b_data_row_abs : b_data_col_abs;
		compress_core_data_flag_data <= tidy_row_col ? b_flag_row_data_abs : b_flag_col;
	end
	else if(state == COMP_DATA && cnt_valid > 4'd0 && cnt_valid < 4'd13 && cnt == 3'd1)
	begin
		compress_core_data_data_abs  <= tidy_row_col ? g_data_row_abs : g_data_col_abs;
		compress_core_data_flag_data <= tidy_row_col ? g_flag_row_data_abs : g_flag_col;
	end
	else if(state == COMP_DATA && cnt_valid > 4'd0 && cnt_valid < 4'd13 && cnt == 3'd2)
	begin
		compress_core_data_data_abs  <= tidy_row_col ? r_data_row_abs : r_data_col_abs;
		compress_core_data_flag_data <= tidy_row_col ? r_flag_row_data_abs : r_flag_col;
	end
	else if(state == COMP_DATA && cnt_valid > 4'd0 && cnt_valid < 4'd13 && cnt == 3'd3)
	begin
		compress_core_data_data_abs  <= tidy_row_col ? a_data_row_abs : a_data_col_abs;
		compress_core_data_flag_data <= tidy_row_col ? a_flag_row_data_abs : a_flag_col;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_b_data_abs_compressed <= 512'b0;
		tidy_b_data_abs_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_DATA && cnt == 3'd0 && compress_core_data_o_valid)
	begin
		tidy_b_data_abs_compressed          <= compress_core_data_data_abs_compressed;
		tidy_b_data_abs_compressed_bytesize <= compress_core_data_data_abs_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_g_data_abs_compressed <= 512'b0;
		tidy_g_data_abs_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_DATA && cnt == 3'd1 && compress_core_data_o_valid)
	begin
		tidy_g_data_abs_compressed          <= compress_core_data_data_abs_compressed;
		tidy_g_data_abs_compressed_bytesize <= compress_core_data_data_abs_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_r_data_abs_compressed <= 512'b0;
		tidy_r_data_abs_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_DATA && cnt == 3'd2 && compress_core_data_o_valid)
	begin
		tidy_r_data_abs_compressed          <= compress_core_data_data_abs_compressed;
		tidy_r_data_abs_compressed_bytesize <= compress_core_data_data_abs_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_a_data_abs_compressed <= 512'b0;
		tidy_a_data_abs_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_DATA && cnt == 3'd3 && compress_core_data_o_valid)
	begin
		tidy_a_data_abs_compressed          <= compress_core_data_data_abs_compressed;
		tidy_a_data_abs_compressed_bytesize <= compress_core_data_data_abs_compressed_bytesize;
	end
	else
	begin
		
	end
end

//compare_bgr
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cp_bgr_i_valid <= 1'b0;
	end
	else if(pre_state == COMP_DATA && cnt == 3'd4)
	begin
		cp_bgr_i_valid <= 1'b1;
	end
	else
	begin
		cp_bgr_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		cp_bgr_b_flag <= 192'b0;
		cp_bgr_g_flag <= 192'b0;
		cp_bgr_r_flag <= 192'b0;
	end
	else if(pre_state == COMP_DATA && cnt == 3'd4)
	begin
		cp_bgr_b_flag <= tidy_row_col ? b_flag_row_data_abs : b_flag_col;
		cp_bgr_g_flag <= tidy_row_col ? g_flag_row_data_abs : g_flag_col;
		cp_bgr_r_flag <= tidy_row_col ? r_flag_row_data_abs : r_flag_col;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		diff_g_position <= 1'b0;
		diff_g_flag <= 1'b0;
		diff_r_position <= 1'b0;
		diff_r_flag <= 1'b0;
		g_diff_num <= 1'b0;
		r_diff_num <= 1'b0;
		tidy_similar_g <= 1'b0;
		tidy_similar_r <= 1'b0;
	end
	else if(cp_bgr_o_valid)
	begin
		diff_g_position <= cp_bgr_diff_g_position;
		diff_g_flag     <= cp_bgr_diff_g_flag    ;
		diff_r_position <= cp_bgr_diff_r_position;
		diff_r_flag     <= cp_bgr_diff_r_flag    ;
		g_diff_num      <= cp_bgr_g_diff_num     ;
		r_diff_num      <= cp_bgr_r_diff_num     ;
		tidy_similar_g  <= cp_bgr_similar_g 	 ;
		tidy_similar_r  <= cp_bgr_similar_r 	 ;
	end
	else
	begin
		
	end
end

//compress_flag
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_core_flag_i_valid <= 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && (cnt == 3'd0 || cnt == 3'd1))
	begin
		compress_core_flag_i_valid <= 1'b1;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && (cnt == 3'd2))
	begin
		compress_core_flag_i_valid <= tidy_similar_g ? 1'b0 : 1'b1;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && (cnt == 3'd3))
	begin
		compress_core_flag_i_valid <= tidy_similar_r ? 1'b0 : 1'b1;
	end
	else
	begin
		compress_core_flag_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_bgr_same_i_valid <= 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid == 1'b1 && (cnt == 3'd2))
	begin
		compress_bgr_same_i_valid <= tidy_similar_g ? 1'b1 : 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid == 1'b1 && (cnt == 3'd3))
	begin
		compress_bgr_same_i_valid <= tidy_similar_r ? 1'b1 : 1'b0;
	end
	else
	begin
		compress_bgr_same_i_valid <= 1'b0;
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_core_flag_data <= 1'b0;
		compress_core_judge <= 1'b0;
		compress_core_diff_position <= 1'b0;
		compress_core_diff_flag_data <= 1'b0;
		compress_core_same_flag_data <= 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd0)
	begin
		compress_core_flag_data      <= tidy_row_col ? a_flag_row : a_flag_col;
		compress_core_judge          <= tidy_row_col ? a_row_judge : a_col_judge;
		compress_core_diff_position  <= tidy_row_col ? a_row_diff_position : a_col_diff_position;
		compress_core_diff_flag_data <= tidy_row_col ? a_row_diff_flag_data : a_col_diff_flag_data;
		compress_core_same_flag_data <= tidy_row_col ? a_row_same_flag_data : a_col_same_flag_data;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd1)
	begin
		compress_core_flag_data      <= tidy_row_col ? b_flag_row : b_flag_col;
		compress_core_judge          <= tidy_row_col ? b_row_judge : b_col_judge;
		compress_core_diff_position  <= tidy_row_col ? b_row_diff_position : b_col_diff_position;
		compress_core_diff_flag_data <= tidy_row_col ? b_row_diff_flag_data : b_col_diff_flag_data;
		compress_core_same_flag_data <= tidy_row_col ? b_row_same_flag_data : b_col_same_flag_data;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd2)
	begin
		compress_core_flag_data      <= tidy_similar_g ? 1'b0 : (tidy_row_col ? g_flag_row : g_flag_col);
		compress_core_judge          <= tidy_similar_g ? 1'b0 : g_judge;
		compress_core_diff_position  <= tidy_similar_g ? 1'b0 : g_diff_position;
		compress_core_diff_flag_data <= tidy_similar_g ? 1'b0 : g_diff_flag_data;
		compress_core_same_flag_data <= tidy_similar_g ? 1'b0 : g_same_flag_data;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd3)
	begin
		compress_core_flag_data      <= tidy_similar_r ? 1'b0 : (tidy_row_col ? r_flag_row : r_flag_col);
		compress_core_judge          <= tidy_similar_r ? 1'b0 : r_judge;
		compress_core_diff_position  <= tidy_similar_r ? 1'b0 : r_diff_position;
		compress_core_diff_flag_data <= tidy_similar_r ? 1'b0 : r_diff_flag_data;
		compress_core_same_flag_data <= tidy_similar_r ? 1'b0 : r_same_flag_data;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		compress_bgr_same_diff_position <= 1'b0;
		compress_bgr_same_diff_flag     <= 1'b0;
		compress_bgr_same_diff_num      <= 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd2)
	begin
		compress_bgr_same_diff_position  <= tidy_similar_g ? diff_g_position : 1'b0;
		compress_bgr_same_diff_flag      <= tidy_similar_g ? diff_g_flag     : 1'b0;
		compress_bgr_same_diff_num       <= tidy_similar_g ? g_diff_num      : 1'b0;
	end
	else if(state == COMP_FLAG && cnt_valid > 4'd0 && cnt_valid < 4'd14 && cnt == 3'd3)
	begin
		compress_bgr_same_diff_position  <= tidy_similar_r ? diff_r_position : 1'b0;
		compress_bgr_same_diff_flag      <= tidy_similar_r ? diff_r_flag     : 1'b0;
		compress_bgr_same_diff_num       <= tidy_similar_r ? r_diff_num      : 1'b0;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_a_flag_data_compressed <= 336'b0;
		tidy_a_flag_data_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_FLAG && cnt == 3'd0 && compress_core_flag_o_valid)
	begin
		tidy_a_flag_data_compressed          <= compress_core_flag_data_compressed;
		tidy_a_flag_data_compressed_bytesize <= compress_core_flag_data_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_b_flag_data_compressed <= 336'b0;
		tidy_b_flag_data_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_FLAG && cnt == 3'd1 && compress_core_flag_o_valid)
	begin
		tidy_b_flag_data_compressed          <= compress_core_flag_data_compressed;
		tidy_b_flag_data_compressed_bytesize <= compress_core_flag_data_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_g_flag_data_compressed <= 336'b0;
		tidy_g_flag_data_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_FLAG && cnt == 3'd2 && compress_core_flag_o_valid)
	begin
		tidy_g_flag_data_compressed          <= compress_core_flag_data_compressed;
		tidy_g_flag_data_compressed_bytesize <= compress_core_flag_data_compressed_bytesize;
	end
	else if(state == COMP_FLAG && cnt == 3'd2 && compress_bgr_o_valid)
	begin
		tidy_g_flag_data_compressed          <= compress_bgr_flag_data_compressed;
		tidy_g_flag_data_compressed_bytesize <= compress_bgr_flag_data_compressed_bytesize;
	end
	else
	begin
		
	end
end

always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_r_flag_data_compressed <= 336'b0;
		tidy_r_flag_data_compressed_bytesize <= 6'b0;
	end
	else if(state == COMP_FLAG && cnt == 3'd3 && compress_core_flag_o_valid)
	begin
		tidy_r_flag_data_compressed          <= compress_core_flag_data_compressed;
		tidy_r_flag_data_compressed_bytesize <= compress_core_flag_data_compressed_bytesize;
	end
	else if(state == COMP_FLAG && cnt == 3'd3 && compress_bgr_o_valid)
	begin
		tidy_r_flag_data_compressed          <= compress_bgr_flag_data_compressed;
		tidy_r_flag_data_compressed_bytesize <= compress_bgr_flag_data_compressed_bytesize;
	end
	else
	begin
		
	end
end

//tidt_data
always @(negedge rst_n or posedge clk)
begin
	if(!rst_n)
	begin
		tidy_i_valid <= 1'b0;
	end
	else if(state == TIDY)
	begin
		tidy_i_valid <= 1'b1;
	end
end

endmodule