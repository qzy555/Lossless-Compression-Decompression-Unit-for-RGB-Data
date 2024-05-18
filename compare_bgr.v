`timescale 1ns / 1ps

module compare_bgr#
(
	parameter TILE_SIZE = 4'd8
)
(
	input									clk,
    input									rst_n,
    input									i_valid,

    input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	b_flag,
    input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	g_flag,
    input	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	r_flag,

    output reg	[6*7 - 1 : 0]				diff_g_position,
    output reg	[3*7 - 1 : 0]				diff_g_flag,
    output reg	[6*7 - 1 : 0]				diff_r_position,
    output reg	[3*7 - 1 : 0]				diff_r_flag,
    output reg	[2 : 0]						g_diff_num,
	output reg	[2 : 0]						r_diff_num,

    output reg								similar_g,
    output reg								similar_r,
    output reg								o_valid
    );

	reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	temp_b_flag;
	reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	temp_g_flag;
	reg	[3*TILE_SIZE*TILE_SIZE - 1 : 0]	temp_r_flag;

	reg [7 : 0] temp_g_diff_num;
	reg [7 : 0] temp_r_diff_num;

	reg [5 : 0] cnt;
	reg stage_0_valid;

	reg distin_valid;

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			temp_b_flag <= 192'b0;
			temp_g_flag <= 192'b0;
			temp_r_flag <= 192'b0;
		end
		else if(i_valid)
		begin
			temp_b_flag <= b_flag;
			temp_g_flag <= g_flag;
			temp_r_flag <= r_flag;
		end
		else if(cnt == 6'd0)
		begin
			temp_b_flag <= 192'b0;
			temp_g_flag <= 192'b0;
			temp_r_flag <= 192'b0;
		end
		else 
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			cnt <= 6'b0;
		end
		else if(i_valid)
		begin
			cnt <= 6'd1;
		end
		else if(cnt == 6'd63)
		begin
			cnt <= 6'b0;
		end
		else if(o_valid)
		begin
			cnt <= 6'b0;
		end
		else if(cnt > 6'b0)
		begin
			cnt <= cnt + 1'b1;
		end
		else
		begin
			
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			distin_valid <= 1'b0;
		end
		else if(cnt == 6'd63 || stage_0_valid)
		begin
			distin_valid <= 1'b1;
		end
		else 
		begin
			distin_valid <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			stage_0_valid <= 1'b0;
		end
		else if(cnt == 6'd63)
		begin
			stage_0_valid <= 1'b1;
		end
		else
		begin
			stage_0_valid <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			diff_g_position <= 42'b0;
			diff_g_flag <= 21'b0;
			temp_g_diff_num <= 4'b0;
		end
		else if(cnt > 7'd0)
		begin
			diff_g_position <= diff_g_position | ((temp_b_flag[cnt*3 + 2 -: 3] != temp_g_flag[cnt*3 + 2 -: 3]) ? (cnt << temp_g_diff_num*6) : 1'b0);
			diff_g_flag <= diff_g_flag | ((temp_b_flag[cnt*3 + 2 -: 3] != temp_g_flag[cnt*3 + 2 -: 3]) ? (temp_g_flag[cnt*3 + 2 -: 3] << temp_g_diff_num*3) : 1'b0);
			temp_g_diff_num <= temp_g_diff_num + ((temp_b_flag[cnt*3 + 2 -: 3] != temp_g_flag[cnt*3 + 2 -: 3]) ? 1'b1 : 1'b0);
		end
		else if(distin_valid)
		begin
			diff_g_position <= diff_g_position;
			diff_g_flag <= diff_g_flag;
			temp_g_diff_num <= temp_g_diff_num;
		end
		else
		begin
			diff_g_position <= 42'b0;
			diff_g_flag <= 21'b0;
			temp_g_diff_num <= 4'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			diff_r_position <= 42'b0;
			diff_r_flag <= 21'b0;
			temp_r_diff_num <= 4'b0;
		end
		else if(cnt > 7'd0)
		begin
			diff_r_position <= diff_r_position | ((temp_b_flag[cnt*3 + 2 -: 3] != temp_r_flag[cnt*3 + 2 -: 3]) ? (cnt << temp_r_diff_num*6) : 1'b0);
			diff_r_flag <= diff_r_flag | ((temp_b_flag[cnt*3 + 2 -: 3] != temp_r_flag[cnt*3 + 2 -: 3]) ? (temp_r_flag[cnt*3 + 2 -: 3] << temp_r_diff_num*3) : 1'b0);
			temp_r_diff_num <= temp_r_diff_num + ((temp_b_flag[cnt*3 + 2 -: 3] != temp_r_flag[cnt*3 + 2 -: 3]) ? 1'b1 : 1'b0);
		end
		else if(distin_valid)
		begin
			diff_r_position <= diff_r_position;
			diff_r_flag <= diff_r_flag;
			temp_r_diff_num <= temp_r_diff_num;
		end
		else
		begin
			diff_r_position <= 42'b0;
			diff_r_flag <= 21'b0;
			temp_r_diff_num <= 4'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			similar_g <= 1'b0;
		end
		else if(temp_g_diff_num >= 4'd8)
		begin
			similar_g <= 1'b0;
		end
		else if(stage_0_valid && temp_g_diff_num <= 4'd7)
		begin
			similar_g <= 1'b1;
		end
		else if(o_valid)
		begin
			similar_g <= similar_g;
		end
		else
		begin
			similar_g <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			similar_r <= 1'b0;
		end
		else if(temp_r_diff_num >= 4'd8)
		begin
			similar_r <= 1'b0;
		end
		else if(stage_0_valid && temp_r_diff_num <= 4'd7)
		begin
			similar_r <= 1'b1;
		end
		else if(o_valid)
		begin
			similar_r <= similar_r;
		end
		else
		begin
			similar_r <= 1'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			g_diff_num <= 3'b0;
			r_diff_num <= 3'b0;
		end
		else if(stage_0_valid)
		begin
			g_diff_num <= temp_g_diff_num;
			r_diff_num <= temp_r_diff_num;
		end
		else if(o_valid)
		begin
			g_diff_num <= g_diff_num;
			r_diff_num <= r_diff_num;
		end
		else 
		begin
			g_diff_num <= 3'b0;
			r_diff_num <= 3'b0;
		end
	end

	always @(negedge rst_n or posedge clk)
	begin
		if(!rst_n)
		begin
			o_valid <= 1'b0;
		end
		else if(stage_0_valid)
		begin
			o_valid <= 1'b1;
		end
		else if(temp_g_diff_num >= 4'd8 && temp_r_diff_num >= 4'd8)
		begin
			o_valid <= 1'b1;
		end
		else
		begin
			o_valid <= 1'b0;
		end
	end
	
	reg	[3 - 1 : 0]	dis_b_flag[63:0];
	reg	[3 - 1 : 0]	dis_g_flag[63:0];
	reg	[3 - 1 : 0]	dis_r_flag[63:0];

	reg	[6 - 1 : 0]	dis_diff_g_position[6:0];
	reg	[3 - 1 : 0]	dis_diff_g_flag[6:0];
	reg	[6 - 1 : 0]	dis_diff_r_position[6:0];
	reg	[3 - 1 : 0]	dis_diff_r_flag[6:0];

    integer i;
    always @(*)
    begin
        for(i = 0; i <= 63; i = i + 1)
        begin
            dis_b_flag[i] <= temp_b_flag[i*3 + 2 -: 3];
            dis_g_flag[i] <= temp_g_flag[i*3 + 2 -: 3];
            dis_r_flag[i] <= temp_r_flag[i*3 + 2 -: 3];
        end
    
        for(i = 0; i < 7; i = i + 1)
        begin
            dis_diff_g_position[i] <= diff_g_position[6*i + 5 -: 6];
            dis_diff_g_flag[i]     <= diff_g_flag[3*i + 2 -: 3];
            dis_diff_r_position[i] <= diff_r_position[6*i + 5 -: 6];
            dis_diff_r_flag[i]     <= diff_r_flag[3*i + 2 -: 3];
        end
    
    end

endmodule 
