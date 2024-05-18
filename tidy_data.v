`timescale 1ns / 1ps

module tidy_data#
(	parameter TILE_SIZE = 4'd8
)
(
	input											clk,
	input											rst_n,
	input											i_valid,
	
	input											similar_g,
	input											similar_r,
	input											row_col,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_b_data_abs_compressed,
	input	[5 : 0]									i_b_data_abs_compressed_bytesize,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_g_data_abs_compressed,
	input	[5 : 0]									i_g_data_abs_compressed_bytesize,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_r_data_abs_compressed,
	input	[5 : 0]									i_r_data_abs_compressed_bytesize,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_a_data_abs_compressed,
	input	[5 : 0]									i_a_data_abs_compressed_bytesize,
	input	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	i_b_flag_data_compressed,
	input	[5 : 0]									i_b_flag_data_compressed_bytesize,
	input	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	i_g_flag_data_compressed,
	input	[5 : 0]									i_g_flag_data_compressed_bytesize,
	input	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	i_r_flag_data_compressed,
	input	[5 : 0]									i_r_flag_data_compressed_bytesize,
	input	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	i_a_flag_data_compressed,
	input	[5 : 0]									i_a_flag_data_compressed_bytesize,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_b_data,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_g_data,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_r_data,
	input	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			i_a_data,

	output reg	[TILE_SIZE*TILE_SIZE*4 - 1 : 0]		o_all_data_compressed,
	output reg	[8 : 0]								o_all_data_bytesize,

	output reg										o_valid
    );
	
	reg	[3 : 0]								state;

	reg	[8*TILE_SIZE*TILE_SIZE*4 - 1 : 0]	all_data_compressed;

	reg										stage_0_valid;
	//reg										stage_1_valid;
	reg										stage_2_valid;
	reg										stage_3_valid;


	reg	[7 : 0]								first_byte;
	reg [3 : 0]								BGRA_64;
	reg [3 : 0]								BGRA_63;

	reg	[3 : 0]								cnt;
	reg [3 : 0]								cnt_0;
	reg	[6 : 0]								cnt_1;
	reg	[8 : 0]								cnt_2;

	reg	[7 : 0]								b_compressed_bytesize;
	reg	[7 : 0]								g_compressed_bytesize;
	reg	[7 : 0]								r_compressed_bytesize;
	reg	[7 : 0]								a_compressed_bytesize;

	reg	[8 : 0]								bgr_cpmpressed_bytesize;

	reg										similar_g_r;
	reg										unnecessary_compress;

	reg	[7 : 0]								temp_data;

	reg										b_similar;

	always @(*)
	begin
		b_compressed_bytesize <= i_b_data_abs_compressed_bytesize + i_b_flag_data_compressed_bytesize;
		g_compressed_bytesize <= i_g_data_abs_compressed_bytesize + i_g_flag_data_compressed_bytesize;
		r_compressed_bytesize <= i_r_data_abs_compressed_bytesize + i_r_flag_data_compressed_bytesize;
		a_compressed_bytesize <= i_a_data_abs_compressed_bytesize + i_a_flag_data_compressed_bytesize;
	end

	/*always @(*)
	begin
		bgr_cpmpressed_bytesize <= b_compressed_bytesize + g_compressed_bytesize + r_compressed_bytesize;
	end*/

	always @(*)
	begin
		similar_g_r <= similar_r || similar_g;
	end

	always @(*)
	begin
		unnecessary_compress <= (first_byte[3] & first_byte[4] & first_byte[5] & first_byte[6]) || ((BGRA_64[0] + BGRA_64[1] + BGRA_64[2] + BGRA_64[3]) == 4'd4) 
							 || (((BGRA_64[0] + BGRA_64[1] + BGRA_64[2] + BGRA_64[3]) == 4'd3) && (BGRA_63[0] + BGRA_63[1] + BGRA_63[2] + BGRA_63[3]) == 4'd4);
	end

	always @(*)
	begin
		b_similar <= ((similar_g_r) && (bgr_cpmpressed_bytesize < 191)) ? 1'b0 : 1'b1;
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			cnt_0 <= 4'd0;
		end
		else if(i_valid && cnt_0 == 4'd0)
		begin
			cnt_0 <= 4'd1;
		end
		else if(cnt_0 > 4'd1)
		begin
			cnt_0 <= 4'd3;
		end
		else if(cnt_0 > 4'd0)
		begin
			cnt_0 <= cnt_0 + 1;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			stage_0_valid <= 1'b0;
		end
		else if(cnt_0 > 4'd1)
		begin
			stage_0_valid <= 1'b1;
		end
		else 
		begin
			stage_0_valid <= 1'b0;
		end
	end

	/*always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			stage_1_valid <= 1'b0;
		end
		else if(stage_0_valid)
		begin
			stage_1_valid <= 1'b1;
		end
		else 
		begin
			
		end
	end*/

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			first_byte[0] <= 1'b0;
			first_byte[1] <= 1'b0;
			first_byte[2] <= 1'b0;
		end
		else if(i_valid)
		begin
			first_byte[0] <= similar_r ? 1'b1 : 1'b0;
			first_byte[1] <= similar_g ? 1'b1 : 1'b0;
			first_byte[2] <= row_col ? 1'b1 : 1'b0;
		end
		else 
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			BGRA_64 <= 4'b0;
		end
		else if(cnt_0 == 1)
		begin
			BGRA_64[0] <= (b_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			BGRA_64[1] <= (g_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			BGRA_64[2] <= (r_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			BGRA_64[3] <= (a_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
		end
		else 
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			BGRA_63 <= 4'b0;
		end
		else if(cnt_0 == 4'd1)
		begin
			BGRA_63[0] <= (b_compressed_bytesize >= TILE_SIZE*TILE_SIZE - 1) ? 1'b1 : 1'b0;
			BGRA_63[1] <= (g_compressed_bytesize >= TILE_SIZE*TILE_SIZE - 1) ? 1'b1 : 1'b0;
			BGRA_63[2] <= (r_compressed_bytesize >= TILE_SIZE*TILE_SIZE - 1) ? 1'b1 : 1'b0;
			BGRA_63[3] <= (a_compressed_bytesize >= TILE_SIZE*TILE_SIZE - 1) ? 1'b1 : 1'b0;
		end
		else 
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			bgr_cpmpressed_bytesize <= 9'b0;
		end
		else if(cnt_0 == 4'd1)
		begin
			bgr_cpmpressed_bytesize <= b_compressed_bytesize + ((BGRA_64[1] & similar_g_r) ? TILE_SIZE*TILE_SIZE : g_compressed_bytesize);
		end
		else if(cnt_0 == 4'd2)
		begin
			bgr_cpmpressed_bytesize <= bgr_cpmpressed_bytesize + ((BGRA_64[2] & similar_g_r) ? TILE_SIZE*TILE_SIZE : r_compressed_bytesize);
		end
		else 
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			first_byte[3] <= 1'b0;
			first_byte[4] <= 1'b0;
			first_byte[5] <= 1'b0;
			first_byte[6] <= 1'b0;
			first_byte[7] <= 1'b0;
		end
		else if(stage_0_valid && (similar_g_r) && (bgr_cpmpressed_bytesize >= 191))
		begin
			first_byte[3] <= 1'b1;
			first_byte[4] <= 1'b1;
			first_byte[5] <= 1'b1;
			first_byte[6] <= (a_compressed_bytesize >= TILE_SIZE*TILE_SIZE - 1) ? 1'b1 : 1'b0;
		end
		else if(stage_0_valid && (similar_g_r) && (bgr_cpmpressed_bytesize < 191))
		begin
			first_byte[3] <= (b_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[4] <= (g_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[5] <= (r_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[6] <= (a_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
		end
		else if(stage_0_valid && (!similar_g_r))
		begin
			first_byte[3] <= (b_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[4] <= (g_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[5] <= (r_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
			first_byte[6] <= (a_compressed_bytesize >= TILE_SIZE*TILE_SIZE) ? 1'b1 : 1'b0;
		end
		else
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			stage_2_valid <= 1'b0;
		end
		else if(stage_0_valid && !unnecessary_compress && (state == 4'd0))
		begin
			stage_2_valid <= 1'd1;
		end
		else 
		begin
			stage_2_valid <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			state <= 4'b0;
		end
		else
		begin
			if(stage_0_valid && !unnecessary_compress && (state == 4'd0))
			begin
				state <= 4'd1;
			end
			else if((state == 4'd1) && !(first_byte[3] & b_similar))
			begin
				state <= 4'd2;
			end
			else if((state == 4'd1) && (first_byte[3] & b_similar))
			begin
				state <= 4'd3;
			end
			else if((state == 4'd2) && !first_byte[4] && (cnt_1 == b_compressed_bytesize))
			begin
				state <= 4'd4;
			end
			else if((state == 4'd2) && first_byte[4] && (cnt_1 == b_compressed_bytesize))
			begin
				state <= 4'd5;
			end
			else if((state == 4'd3) && !first_byte[4] && (cnt_1 == 7'd64))
			begin
				state <= 4'd4;
			end
			else if((state == 4'd3) && first_byte[4] && (cnt_1 == 7'd64))
			begin
				state <= 4'd5;
			end
			else if((state == 4'd4) && !first_byte[5] && (cnt_1 == g_compressed_bytesize))
			begin
				state <= 4'd6;
			end
			else if((state == 4'd4) && first_byte[5] && (cnt_1 == g_compressed_bytesize))
			begin
				state <= 4'd7;
			end
			else if((state == 4'd5) && !first_byte[5] && (cnt_1 == 7'd64))
			begin
				state <= 4'd6;
			end
			else if((state == 4'd5) && first_byte[5] && (cnt_1 == 7'd64))
			begin
				state <= 4'd7;
			end
			else if((state == 4'd6) && !first_byte[6] && (cnt_1 == r_compressed_bytesize))
			begin
				state <= 4'd8;
			end
			else if((state == 4'd6) && first_byte[6] && (cnt_1 == r_compressed_bytesize))
			begin
				state <= 4'd9;
			end
			else if((state == 4'd7) && !first_byte[6] && (cnt_1 == 7'd64))
			begin
				state <= 4'd8;
			end
			else if((state == 4'd7) && first_byte[6] && (cnt_1 == 7'd64))
			begin
				state <= 4'd9;
			end
			else if((state == 4'd8) && (cnt_1 > (a_compressed_bytesize)))
			begin
				state <= 4'd10;
			end
			else if((state == 4'd9) && (cnt_1 > (7'd64)))
			begin
				state <= 4'd10;
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
			cnt_1 <= 7'b0;
		end
		else
		begin
			if((state == 4'd2) && (cnt_1 == (b_compressed_bytesize)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd3) && (cnt_1 == (7'd64)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd4) && (cnt_1 == (g_compressed_bytesize)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd5) && (cnt_1 == (7'd64)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd6) && (cnt_1 == (r_compressed_bytesize)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd7) && (cnt_1 == (7'd64)))
			begin
				cnt_1 <= 7'd1;
			end
			else if((state == 4'd8) && (cnt_1 > (a_compressed_bytesize)))
			begin
				cnt_1 <= 7'b0;
			end
			else if((state == 4'd9) && (cnt_1 > (7'd64)))
			begin
				cnt_1 <= 7'b0;
			end
			else if(stage_2_valid)
			begin
				cnt_1 <= 7'd1;
			end
			else if(cnt_1 > 7'd0)
			begin
				cnt_1 <= cnt_1 + 1;
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
			cnt_2 <= 9'b0;
		end
		else
		begin
			if(stage_2_valid)
			begin
				cnt_2 <= 9'd1;
			end
			else if((state == 4'd8) && (cnt_1 > (a_compressed_bytesize)))
			begin
				cnt_2 <= 9'b0;
			end
			else if((state == 4'd9) && (cnt_1 > (7'd64)))
			begin
				cnt_2 <= 9'b0;
			end
			else if(cnt_2 > 9'd0)
			begin
				cnt_2 <= cnt_2 + 1'b1;
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
			stage_3_valid <= 1'b0;
		end
		else
		begin
			if((state == 4'd8) && (cnt_1 > (a_compressed_bytesize)))
			begin
				stage_3_valid <= 1'b1;
			end
			else if((state == 4'd9) && (cnt_1 > (7'd64)))
			begin
				stage_3_valid <= 1'b1;
			end
			else 
			begin
				stage_3_valid <= 1'b0;
			end
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			temp_data <= 8'b0;
		end
		else
		begin
			case(state)
				4'd1:
				begin
					temp_data <= first_byte;
				end
				4'd2:
				begin
					temp_data <= (cnt_1 <= i_b_flag_data_compressed_bytesize) 
								? i_b_flag_data_compressed[cnt_1*8 - 1 -: 8] 
								: i_b_data_abs_compressed[(cnt_1 - i_b_flag_data_compressed_bytesize)*8 - 1 -: 8];
				end
				4'd3:
				begin
					temp_data <= i_b_data[cnt_1*8 - 1 -: 8];
				end
				4'd4:
				begin
					temp_data <= (cnt_1 <= i_g_flag_data_compressed_bytesize) 
								? i_g_flag_data_compressed[cnt_1*8 - 1 -: 8] 
								: i_g_data_abs_compressed[(cnt_1 - i_g_flag_data_compressed_bytesize)*8 - 1 -: 8];
				end
				4'd5:
				begin
					temp_data <= i_g_data[cnt_1*8 - 1 -: 8];
				end
				4'd6:
				begin
					temp_data <= (cnt_1 <= i_r_flag_data_compressed_bytesize) 
								? i_r_flag_data_compressed[cnt_1*8 - 1 -: 8] 
								: i_r_data_abs_compressed[(cnt_1 - i_r_flag_data_compressed_bytesize)*8 - 1 -: 8];
				end
				4'd7:
				begin
					temp_data <= i_r_data[cnt_1*8 - 1 -: 8];
				end
				4'd8:
				begin
					temp_data <= (cnt_1 <= i_a_flag_data_compressed_bytesize) 
								? i_a_flag_data_compressed[cnt_1*8 - 1 -: 8] 
								: i_a_data_abs_compressed[(cnt_1 - i_a_flag_data_compressed_bytesize)*8 - 1 -: 8];
				end
				4'd9:
				begin
					if(cnt_1 < 7'd65)
					begin
					temp_data <= i_a_data[cnt_1*8 - 1 -: 8];
					end
					else 
					begin
						
					end
				end
				default:
				begin
					temp_data <= 8'b0;
				end
			endcase
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			all_data_compressed <= 2048'b0;
		end
		else
		begin
			if(cnt_2 > 9'b0)
			begin
				all_data_compressed[cnt_2*8 - 1 -: 8] <= temp_data;
			end
			else if(unnecessary_compress)
			begin
				all_data_compressed <= {i_a_data,i_r_data,i_g_data,i_b_data};
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
			cnt <= 4'b0;
		end
		else
		begin
			if(unnecessary_compress && (cnt == 4'd0))
			begin
				cnt <= 4'd1;
			end
			else if(stage_3_valid && (cnt == 4'd0))
			begin
				cnt <= 4'd1;
			end
			else if(cnt > 4'd0 && cnt < 4'd8)
			begin
				cnt <= cnt +4'd1;
			end
			else if(cnt > 4'd7)
			begin
				cnt <= 4'd0;
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
			o_valid <= 1'b0;
		end
		else if(cnt > 4'd0)
		begin
			o_valid <= 1'b1;
		end
		else if(cnt > 4'd7)
		begin
			o_valid <= 1'b0;
		end
		else 
		begin
			o_valid <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			o_all_data_compressed <= 256'b0;
			o_all_data_bytesize <= 9'b0;
		end
		else
		begin
			if(cnt > 4'd0)
			begin
				o_all_data_compressed <= all_data_compressed[cnt*256 - 1 -: 256];

				o_all_data_bytesize <= (unnecessary_compress) ? 9'd256 :(((first_byte[3] & b_similar) ? 7'd64 : b_compressed_bytesize) + (first_byte[4] ? 7'd64 : g_compressed_bytesize)
									 + (first_byte[5] ? 7'd64 : r_compressed_bytesize) + (first_byte[6] ? 7'd64 : a_compressed_bytesize)
									 +  1'b1);
			end
			else 
			begin
			end
		end
	end

	integer a,b,c;
	reg [7:0] dis_all_data_compressed[255:0];
	reg [7:0] dis_i_b_data_abs_compressed[63:0];
	reg [7:0] dis_i_b_flag_data_compressed[41:0];
	always @(*)
	begin
	    for(a = 0; a <= 255; a = a + 1)
	    begin
	        dis_all_data_compressed[a] <= all_data_compressed[8*a + 7 -: 8];
	    end
	    for(b = 0;b<64;b=b+1)
	    begin
	    	dis_i_b_data_abs_compressed[b] <= i_b_data_abs_compressed[b*8 + 7 -: 8];
	    end
	    for(c=0;c<42;c=c+1)
	    begin
	    	dis_i_b_flag_data_compressed[c] <= i_b_flag_data_compressed[c*8 + 7 -: 8];
	    end

	end
endmodule
