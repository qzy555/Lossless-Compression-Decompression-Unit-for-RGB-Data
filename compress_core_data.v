`timescale 1ns / 1ps

module compress_core_data
#(parameter TILE_SIZE = 4'd8
 )
(
input                                       clk,                 
input                                       rst_n,                 
input                                       i_valid,                                                                                

input   [8*TILE_SIZE*TILE_SIZE - 1 : 0]     data_abs,
input   [3*TILE_SIZE*TILE_SIZE - 1 : 0]     flag_data,
                                                                                              
output reg  [8*TILE_SIZE*TILE_SIZE - 1 : 0] data_abs_compressed,                          
output reg  [5 : 0]                         data_abs_compressed_bytesize,                                               
output reg                                  o_valid                                                                           
);
    
    reg [3:0]                   data_bit_count [6:0];

    reg [3 : 0]                 cnt;

    reg [6 : 0]                 data_abs_compressed_bitsize_0 [7 : 0];
    reg [7 : 0]                 data_abs_compressed_bitsize_1 [3 : 0];
    reg [9 : 0]                 data_abs_compressed_bitsize_2;
    reg [8*TILE_SIZE - 1 : 0]   data_abs_compressed_0 [7 : 0];
    reg [8*TILE_SIZE*2 - 1 : 0] data_abs_compressed_1 [3 : 0];
    reg [8*TILE_SIZE*4 - 1 : 0] data_abs_compressed_2 [1 : 0];
    reg                         stage0_valid;
    reg                         stage1_valid;
    reg                         stage2_valid;

    reg                         end_cnt_valid;

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

    always @(negedge rst_n or posedge clk)//1-8
    begin
        if(!rst_n)
        begin
           cnt <= 4'd0;
        end
        else
        begin
            if(i_valid && cnt == 4'd0 && !end_cnt_valid)
            begin
                cnt <= 4'd1;
            end
            else if(cnt > 4'd0 && cnt < 4'd8)
            begin
                cnt <= cnt +1'b1;
            end
            else if(cnt > 4'd7)
            begin
                cnt <= 4'd0;
            end
            else 
            begin
                cnt <= 4'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            end_cnt_valid <= 1'b0;
        end
        else
        begin
            if(i_valid && cnt > 4'd7)
            begin
                end_cnt_valid <= 4'd1;
            end
            else if(!i_valid)
            begin
                end_cnt_valid <= 4'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            stage0_valid <= 1'd0;
        end
        else
        begin
            if(cnt > 4'd7)
            begin
                stage0_valid <= 1'd1;
            end
            else 
            begin
                stage0_valid <= 1'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            stage1_valid <= 1'd0;
        end
        else
        begin
            if(stage0_valid && !stage1_valid)
            begin
                stage1_valid <= 1'd1;
            end
            else 
            begin
                stage1_valid <= 1'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            stage2_valid <= 1'd0;
        end
        else
        begin
            if(stage1_valid && !stage2_valid)
            begin
                stage2_valid <= 1'd1;
            end
            else 
            begin
                stage2_valid <= 1'd0;
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
            if(stage2_valid && !o_valid)
            begin
                o_valid <= 1'b1;
            end
            else 
            begin
                o_valid <= 1'b0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)//处理第一�?
    begin
        if(!rst_n)
        begin
            data_abs_compressed_bitsize_0[0] <= 7'd0;
            data_abs_compressed_0[0] <= 64'd0;
        end
        else
        begin
            if(i_valid && !stage0_valid && cnt == 1'd1)
            begin
                data_abs_compressed_0[0] <= data_abs_compressed_0[0] | (data_abs[(cnt - 1)*8 + 7 -: 8]);
                data_abs_compressed_bitsize_0[0] <= data_abs_compressed_bitsize_0[0] + 8;
            end
            else if(i_valid && !stage0_valid && cnt > 1'd1)
            begin
                data_abs_compressed_0[0] <= data_abs_compressed_0[0] | (data_abs[(cnt - 1)*8 + 7 -: 8] << data_abs_compressed_bitsize_0[0]);
                data_abs_compressed_bitsize_0[0] <= data_abs_compressed_bitsize_0[0] + data_bit_count[flag_data[(cnt - 1)*3 + 2 -: 3]];
            end
            else if(!i_valid)
            begin
                data_abs_compressed_bitsize_0[0] <= 7'd0;
                data_abs_compressed_0[0] <= 64'd0;
            end
            else 
            begin
                
            end
        end
    end

    always @(negedge rst_n or posedge clk)//其余�?
    begin:exist_frame
        integer i;
        for(i=1;i<8;i=i + 1)
        begin
            if(!rst_n)
            begin
                data_abs_compressed_bitsize_0[i] <= 7'd0;
                data_abs_compressed_0[i] <= 64'd0;
            end
            else
            begin
                if(i_valid && !stage0_valid && cnt > 1'd0)
                begin
                    data_abs_compressed_0[i] <= data_abs_compressed_0[i] | (data_abs[i*8*TILE_SIZE + (cnt - 1)*8 + 7 -: 8] << data_abs_compressed_bitsize_0[i]);
                    data_abs_compressed_bitsize_0[i] <= data_abs_compressed_bitsize_0[i] + data_bit_count[flag_data[i*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3]];
                end
                else if(!i_valid)
                begin
                    data_abs_compressed_bitsize_0[i] <= 7'd0;
                    data_abs_compressed_0[i] <= 64'd0;
                end
                else 
                begin
                    
                end
            end
        end
    end

    always @(negedge rst_n or posedge clk)//8---4
    begin
        if(!rst_n)
        begin
            data_abs_compressed_bitsize_1[0] <= 8'd0;
            data_abs_compressed_bitsize_1[1] <= 8'd0;
            data_abs_compressed_bitsize_1[2] <= 8'd0;
            data_abs_compressed_bitsize_1[3] <= 8'd0;
            data_abs_compressed_1[0] <= 128'd0;
            data_abs_compressed_1[1] <= 128'd0;
            data_abs_compressed_1[2] <= 128'd0;
            data_abs_compressed_1[3] <= 128'd0;
        end
        else
        begin
            if(stage0_valid && !stage1_valid)
            begin
                data_abs_compressed_1[0] <= data_abs_compressed_0[0] | (data_abs_compressed_0[1] << data_abs_compressed_bitsize_0[0]);
                data_abs_compressed_1[1] <= data_abs_compressed_0[2] | (data_abs_compressed_0[3] << data_abs_compressed_bitsize_0[2]);
                data_abs_compressed_1[2] <= data_abs_compressed_0[4] | (data_abs_compressed_0[5] << data_abs_compressed_bitsize_0[4]);
                data_abs_compressed_1[3] <= data_abs_compressed_0[6] | (data_abs_compressed_0[7] << data_abs_compressed_bitsize_0[6]);
                data_abs_compressed_bitsize_1[0] <= data_abs_compressed_bitsize_0[0] + data_abs_compressed_bitsize_0[1];
                data_abs_compressed_bitsize_1[1] <= data_abs_compressed_bitsize_0[2] + data_abs_compressed_bitsize_0[3];
                data_abs_compressed_bitsize_1[2] <= data_abs_compressed_bitsize_0[4] + data_abs_compressed_bitsize_0[5];
                data_abs_compressed_bitsize_1[3] <= data_abs_compressed_bitsize_0[6] + data_abs_compressed_bitsize_0[7];
            end
            else if(!i_valid)
            begin
                data_abs_compressed_bitsize_1[0] <= 8'd0;
                data_abs_compressed_bitsize_1[1] <= 8'd0;
                data_abs_compressed_bitsize_1[2] <= 8'd0;
                data_abs_compressed_bitsize_1[3] <= 8'd0;
                data_abs_compressed_1[0] <= 128'd0;
                data_abs_compressed_1[1] <= 128'd0;
                data_abs_compressed_1[2] <= 128'd0;
                data_abs_compressed_1[3] <= 128'd0;
            end
            else 
            begin
                
            end
        end
    end

    always @(negedge rst_n or posedge clk)//4---2
    begin
        if(!rst_n)
        begin
            data_abs_compressed_bitsize_2 <= 10'd0;
            data_abs_compressed_2[0] <= 256'd0;
            data_abs_compressed_2[1] <= 256'd0;
        end
        else
        begin
            if(stage1_valid && !stage2_valid)
            begin
                data_abs_compressed_2[0] <= data_abs_compressed_1[0] | (data_abs_compressed_1[1] << data_abs_compressed_bitsize_1[0]);
                data_abs_compressed_2[1] <= data_abs_compressed_1[2] | (data_abs_compressed_1[3] << data_abs_compressed_bitsize_1[2]);
                data_abs_compressed_bitsize_2 <= data_abs_compressed_bitsize_1[0] + data_abs_compressed_bitsize_1[1] + data_abs_compressed_bitsize_1[2] + data_abs_compressed_bitsize_1[3];
            end
            else if(!i_valid)
            begin
                data_abs_compressed_bitsize_2 <= 10'd0;
                data_abs_compressed_2[0] <= 256'd0;
                data_abs_compressed_2[1] <= 256'd0;
            end
            else
            begin

            end
        end
    end

    always @(negedge rst_n or posedge clk)//2---1
    begin
        if(!rst_n)
        begin
            data_abs_compressed_bytesize <= 6'd0;
            data_abs_compressed <= 512'd0;
        end
        else
        begin
            if(stage2_valid && !o_valid)
            begin
                data_abs_compressed <= data_abs_compressed_2[0] | (data_abs_compressed_2[1] << data_abs_compressed_bitsize_1[0] + data_abs_compressed_bitsize_1[1]);
                if(data_abs_compressed_bitsize_2[2 : 0] != 1'd0)
                begin
                    data_abs_compressed_bytesize <= data_abs_compressed_bitsize_2[9 : 3] + 1;
                end
                else if(data_abs_compressed_bitsize_2[2 : 0] == 1'd0)
                begin
                    data_abs_compressed_bytesize <= data_abs_compressed_bitsize_2[9 : 3];
                end
            end
            /*else if(o_valid)
            begin
                data_abs_compressed_bytesize <= data_abs_compressed_bytesize;
                data_abs_compressed <= data_abs_compressed;
            end*/
            else if(!i_valid)
            begin
                data_abs_compressed_bytesize <= 6'd0;
                data_abs_compressed <= 512'd0;
            end
            else 
            begin
                
            end
        end
    end

reg  [8- 1 : 0]     dis_data_abs[63:0];
reg  [3 - 1 : 0]     dis_flag_data[63:0];
reg [7:0] dis_data_abs_compressed[63:0];

integer i;
always @(*)
begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_flag_data[i] <= flag_data[i*3 + 2 -: 3];
        dis_data_abs [i] <= data_abs[i*8 + 7 -: 8];
        dis_data_abs_compressed[i] <= data_abs_compressed[i*8 + 7 -: 8];
    end
end

endmodule
