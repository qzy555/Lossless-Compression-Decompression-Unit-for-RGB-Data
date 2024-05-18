`timescale 1ns / 1ps

module calculate_size_core #
(
	parameter TILE_SIZE = 4'd8
	)
(
    input                                   clk,
    input                                   rst_n,
    input                                   i_valid,

    input   [3*TILE_SIZE*TILE_SIZE - 1 : 0] flag_data,

    input   [2*TILE_SIZE - 1 : 0]           judge,
    input   [3*TILE_SIZE - 1 : 0]           diff_flag_data,
    input   [3*TILE_SIZE - 1 : 0]           same_flag_data,

    output reg                              o_valid,
    output reg  [6 : 0]                     all_data_byte_size
    );
    integer i;//15 cycles

    reg [2 : 0] shift_data [6 : 0];
    reg [3:0]   data_bit_count [6:0];

    reg [3 : 0] cnt;

    reg [5 : 0] flag_data_bit_size_0[7 : 0];
    reg [6 : 0] data_abs_bit_size_0[7 : 0];
    reg [6 : 0] flag_data_bit_size_1[3 : 0];
    reg [7 : 0] data_abs_bit_size_1[3 : 0];
    reg [7 : 0] flag_data_bit_size_2[1 : 0];
    reg [8 : 0] data_abs_bit_size_2[1 : 0];
    reg [8 : 0] flag_data_bit_size_3;
    reg [9 : 0] data_abs_bit_size_3;

    reg [5 : 0] flag_data_byte_size;
    reg [6 : 0] data_abs_byte_size;

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
            data_bit_count[0] <= 4'd0;
            data_bit_count[1] <= 4'd0;
            data_bit_count[2] <= 4'd0;
            data_bit_count[3] <= 4'd0;
            data_bit_count[4] <= 4'd0;
            data_bit_count[5] <= 4'd0;
            data_bit_count[6] <= 4'd0;
        end
        else
        begin
            data_bit_count[0] <= 4'd0;
            data_bit_count[1] <= 4'd2;
            data_bit_count[2] <= 4'd2;
            data_bit_count[3] <= 4'd4;
            data_bit_count[4] <= 4'd4;
            data_bit_count[5] <= 4'd8;
            data_bit_count[6] <= 4'd8;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            cnt <= 4'b0;
        end
        else if(cnt > 4'd14)
        begin
            cnt <= 4'b0;
        end
        else if(i_valid && cnt == 4'b0)
        begin
            cnt <= 4'd1;
        end
        else if(cnt > 4'd0)
        begin
            cnt <= cnt +1'b1;
        end
        else
        begin
            cnt <= 4'b0;
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            o_valid <= 1'b0;
        end
        else if(cnt > 4'd14)
        begin
            o_valid <= 1'b1;
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
            for(i = 0;i < 8;i = i + 1)
            begin
                flag_data_bit_size_0[i] <= 6'b0;
            end
        end
        else if(cnt == 4'd1)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                flag_data_bit_size_0[i] <= (judge[i*2  + 1 -: 2] == 2'd0) ? 2'd1 + shift_data[flag_data[i*3*TILE_SIZE + 3 + 2 -: 3]] : 2'd2;
            end
        end
        else if(cnt == 4'd2)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                flag_data_bit_size_0[i] <= flag_data_bit_size_0[i] + ((judge[i*2  + 1 -: 2] == 2'd1) 
                                         ? (3 + shift_data[diff_flag_data[i*3 + 2 -: 3]] + shift_data[same_flag_data[i*3 + 2 -: 3]]) 
                                         : 1'b0);
            end
        end
        else if(cnt > 4'd2 && cnt < 4'd11)
        begin
            flag_data_bit_size_0[0] <= flag_data_bit_size_0[0] + ((judge[1 :0] == 2'd3 && cnt < 4'd10) 
                                     ? (shift_data[flag_data[(cnt - 2)*3 + 2 -: 3]]) 
                                     :1'b0);
            for(i = 1;i < 8;i = i + 1)
            begin
                flag_data_bit_size_0[i] <= flag_data_bit_size_0[i] + ((judge[2*i + 1 -: 2] == 2'd3) 
                                         ? (shift_data[flag_data[i*3*TILE_SIZE + (cnt - 3)*3 + 2 -: 3]]) 
                                         :1'b0);
            end
        end
        else if(!i_valid)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                flag_data_bit_size_0[i] <= 9'b0;
            end
        end
        else 
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                data_abs_bit_size_0[i] <= 7'b0;
            end
        end
        else if(cnt == 4'd1)
        begin
            data_abs_bit_size_0[0] <= 4'd8;
            for(i = 1;i < 8;i = i + 1)
            begin
                data_abs_bit_size_0[i] <= data_bit_count[flag_data[i*3*TILE_SIZE + 2 -: 3]];
            end
        end
        else if(cnt > 4'd1 && cnt < 4'd9)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                data_abs_bit_size_0[i] <= data_abs_bit_size_0[i] + data_bit_count[flag_data[i*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3]];
            end
        end
        else if(!i_valid)
        begin
            for(i = 0;i < 8;i = i + 1)
            begin
                data_abs_bit_size_0[i] <= 7'b0;
            end
        end
        else 
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            for(i = 0;i < 4;i = i + 1)
            begin
                data_abs_bit_size_1[i] <= 8'b0;
            end
        end
        else if(cnt == 4'd9)
        begin
            data_abs_bit_size_1[0] <= data_abs_bit_size_0[0] + data_abs_bit_size_0[1];
            data_abs_bit_size_1[1] <= data_abs_bit_size_0[2] + data_abs_bit_size_0[3];
            data_abs_bit_size_1[2] <= data_abs_bit_size_0[4] + data_abs_bit_size_0[5];
            data_abs_bit_size_1[3] <= data_abs_bit_size_0[6] + data_abs_bit_size_0[7];
        end
        else if(!i_valid)
        begin
            for(i = 0;i < 4;i = i + 1)
            begin
                data_abs_bit_size_1[i] <= 7'b0;
            end
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            data_abs_bit_size_2[0] <= 9'b0;
            data_abs_bit_size_2[1] <= 9'b0;
        end
        else if(cnt == 4'd10)
        begin
            data_abs_bit_size_2[0] <= data_abs_bit_size_1[0] + data_abs_bit_size_1[1];
            data_abs_bit_size_2[1] <= data_abs_bit_size_1[2] + data_abs_bit_size_1[3];
        end
        else if(!i_valid)
        begin
            data_abs_bit_size_2[0] <= 9'b0;
            data_abs_bit_size_2[1] <= 9'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            data_abs_bit_size_3 <= 10'b0;
        end
        else if(cnt == 4'd11)
        begin
            data_abs_bit_size_3 <= data_abs_bit_size_2[0] + data_abs_bit_size_2[1];
        end
        else if(!i_valid)
        begin
            data_abs_bit_size_3 <= 10'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            for(i = 0;i < 4;i = i + 1)
            begin
                flag_data_bit_size_1[i] <= 7'b0;
            end
        end
        else if(cnt == 4'd11)
        begin
            flag_data_bit_size_1[0] <= flag_data_bit_size_0[0] + flag_data_bit_size_0[1];
            flag_data_bit_size_1[1] <= flag_data_bit_size_0[2] + flag_data_bit_size_0[3];
            flag_data_bit_size_1[2] <= flag_data_bit_size_0[4] + flag_data_bit_size_0[5];
            flag_data_bit_size_1[3] <= flag_data_bit_size_0[6] + flag_data_bit_size_0[7];
        end
        else if(!i_valid)
        begin
            for(i = 0;i < 4;i = i + 1)
            begin
                flag_data_bit_size_1[i] <= 7'b0;
            end
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_bit_size_2[0] <= 8'b0;
            flag_data_bit_size_2[1] <= 8'b0;
        end
        else if(cnt == 4'd12)
        begin
            flag_data_bit_size_2[0] <= flag_data_bit_size_1[0] + flag_data_bit_size_1[1];
            flag_data_bit_size_2[1] <= flag_data_bit_size_1[2] + flag_data_bit_size_1[3];
        end
        else if(!i_valid)
        begin
            flag_data_bit_size_2[0] <= 8'b0;
            flag_data_bit_size_2[1] <= 8'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_bit_size_3 <= 9'b0;
        end
        else if(cnt == 4'd13)
        begin
            flag_data_bit_size_3 <= flag_data_bit_size_2[0] + flag_data_bit_size_2[1];
        end
        else if(!i_valid)
        begin
            flag_data_bit_size_3 <= 9'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_byte_size <= 6'b0;
        end
        else if(cnt == 4'd14)
        begin
            flag_data_byte_size <= (flag_data_bit_size_3[2 : 0] == 4'd0) ? (flag_data_bit_size_3[8 : 3]) : (flag_data_bit_size_3[8 : 3] + 1);
        end
        else if(!i_valid)
        begin
            flag_data_byte_size <= 6'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            data_abs_byte_size <= 7'b0;
        end
        else if(cnt == 4'd14)
        begin
            data_abs_byte_size <= (data_abs_bit_size_3[2 : 0] == 4'd0) ? (data_abs_bit_size_3[9 : 3]) : (data_abs_bit_size_3[9 : 3] + 1);
        end
        else if(!i_valid)
        begin
            data_abs_byte_size <= 7'b0;
        end
        else
        begin
            
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            all_data_byte_size <= 7'b0;
        end
        else if(cnt == 4'd15)
        begin
            all_data_byte_size <= flag_data_byte_size + data_abs_byte_size;
        end
        /*else if(o_valid)
        begin
            all_data_byte_size <= all_data_byte_size;
        end*/
        else
        begin
            all_data_byte_size <= 7'b0;
        end
    end

    reg [3 - 1 : 0]     dis_flag_data[63:0];
    reg [2 - 1 : 0]     dis_judge[7:0];           
    reg [3 - 1 : 0]     dis_diff_flag_data[7:0];
    reg [3 - 1 : 0]     dis_same_flag_data[7:0];

    always @(*)
    begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_flag_data[i] <= flag_data[i*3 + 2 -: 3];
    end
    for(i = 0; i <= 7; i = i + 1)
    begin
        dis_judge[i] <= judge[i*2 + 1 -: 2];
        dis_diff_flag_data[i] <= diff_flag_data[i*3 + 2 -: 3];
        dis_same_flag_data[i] <= same_flag_data[i*3 + 2 -: 3];
    end
    end

endmodule
