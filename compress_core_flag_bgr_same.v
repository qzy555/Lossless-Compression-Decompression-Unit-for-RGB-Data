`timescale 1ns / 1ps

module compress_core_flag_bgr_same#
(
    parameter TILE_SIZE = 4'd8
)
(
    input					clk,
    input					rst_n,
	input					i_valid,
	
    input	[6*7 - 1 : 0]	diff_position,
	input	[3*7 - 1 : 0]	diff_flag,
    input   [2 : 0]         diff_num,

	output reg	[76 : 0]	flag_data_compressed,
	output reg	[3 : 0]		flag_data_compressed_bytesize,
	output reg				o_valid
    );

	reg	[2 : 0]	shift_data [6 : 0];
    reg	[4 : 0]	add_data [6 : 0];

    reg [6*7 - 1 : 0]   temp_diff_position;
    reg [3*7 - 1 : 0]   temp_diff_flag;
    reg [2 : 0]         temp_diff_num;

    reg [6 : 0] flag_data_compressed_bitsize;

    reg stage_0_valid;

    reg [3 : 0] cnt;

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            shift_data[0] <= 3'd0;
            shift_data[1] <= 3'd0;
            shift_data[2] <= 3'd0;
            shift_data[3] <= 3'd0;
            shift_data[4] <= 3'd0;
            shift_data[5] <= 3'd0;
            shift_data[6] <= 3'd0;
        end
        else
        begin
            shift_data[0] <= 3'd2;
            shift_data[1] <= 3'd2;
            shift_data[2] <= 3'd2;
            shift_data[3] <= 3'd3;
            shift_data[4] <= 3'd4;
            shift_data[5] <= 3'd5;
            shift_data[6] <= 3'd5;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            add_data[0]   <= 5'd0;
            add_data[1]   <= 5'd0;
            add_data[2]   <= 5'd0;
            add_data[3]   <= 5'd0;
            add_data[4]   <= 5'd0;
            add_data[5]   <= 5'd0;
            add_data[6]   <= 5'd0;
        end
        else
        begin
            add_data[0]   <= 5'd1;
            add_data[1]   <= 5'd0;
            add_data[2]   <= 5'd2;
            add_data[3]   <= 5'd3;
            add_data[4]   <= 5'd7;
            add_data[5]   <= 5'd15;
            add_data[6]   <= 5'd31;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            temp_diff_position <= 42'b0;
            temp_diff_flag <= 21'b0;
            temp_diff_num <= 3'b0;
        end
        else if(i_valid)
        begin
            temp_diff_position <= diff_position;
            temp_diff_flag <= diff_flag;
            temp_diff_num <= diff_num;
        end
        else if(stage_0_valid)
        begin
            temp_diff_position <= 42'b0;
            temp_diff_flag <= 21'b0;
            temp_diff_num <= 3'b0;
        end
        else 
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            cnt <= 4'b0;
        end
        else if(i_valid)
        begin
            cnt <= 4'd1;
        end
        else if(cnt > temp_diff_num)
        begin
            cnt <= 4'b0;
        end
        else if(cnt > 4'b0)
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
            stage_0_valid <= 1'b0;
        end
        else if(cnt > temp_diff_num)
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
            o_valid <= 1'b0;
        end
        else if(stage_0_valid)
        begin
            o_valid <= 1'b1;
        end
        else begin
            o_valid <= 1'b0;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_compressed <= 77'b0;
            flag_data_compressed_bitsize <= 7'b0;
        end
        else if(cnt == 4'd1)
        begin
            flag_data_compressed <= temp_diff_num;
            flag_data_compressed_bitsize <= 2'd3;
        end
        else if(cnt > 4'd1)
        begin
            flag_data_compressed <= flag_data_compressed | ({add_data[temp_diff_flag[3*(cnt - 2) + 2 -: 3]],temp_diff_position[6*(cnt - 2) + 5 -: 6]} << (flag_data_compressed_bitsize));
            flag_data_compressed_bitsize <= flag_data_compressed_bitsize + shift_data[temp_diff_flag[3*(cnt - 2) + 2 -: 3]] + 4'd6;
        end
        else if(o_valid || stage_0_valid)
        begin
            flag_data_compressed <= flag_data_compressed;
        end
        else
        begin
            flag_data_compressed <= 56'b0;
            flag_data_compressed_bitsize <= 7'b0;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_compressed_bytesize <= 4'b0;
        end
        else if(stage_0_valid)
        begin
            flag_data_compressed_bytesize <= (flag_data_compressed_bitsize[2 : 0] == 1'b0) ? (flag_data_compressed_bitsize[6 : 3]) : (flag_data_compressed_bitsize[6 : 3] + 1);
        end
        else if(o_valid)
        begin
            flag_data_compressed_bytesize <= flag_data_compressed_bytesize;
        end
        else 
        begin
            flag_data_compressed_bytesize <= 4'b0;
        end
    end
    
    reg [7:0] dis_flag_data_compressed[6:0];
    reg [5:0] dis_diff_position[6:0];
    
    integer i , j;
    always @(*)
    begin
        for(i=0;i<7;i=i + 1)
        begin
            dis_flag_data_compressed[i] <= flag_data_compressed[i*8 + 7 -: 8];
        end
        for(j=0;j<6;j=j+1)
        begin
            dis_diff_position[j] <= diff_position[6*j + 5 -: 6];
        end
    end
    

endmodule
