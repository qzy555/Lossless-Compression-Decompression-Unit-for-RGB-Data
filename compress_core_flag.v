`timescale 1ns / 1ps

module compress_core_flag
#(parameter TILE_SIZE = 4'd8
 )
(
    input                                               clk,
    input                                               rst_n,
    input                                               i_valid,

    input   [3*TILE_SIZE*TILE_SIZE - 1 : 0]             flag_data,
    input   [2*TILE_SIZE - 1 : 0]                       judge,
    input   [3*TILE_SIZE - 1 : 0]                       diff_position,
    input   [3*TILE_SIZE - 1 : 0]                       diff_flag_data,
    input   [3*TILE_SIZE - 1 : 0]                       same_flag_data,
    
    output reg  [(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]   flag_data_compressed,
    output reg  [5 : 0]                                 flag_data_compressed_bytesize,
    output reg                                          o_valid
    );
    
    reg [2 : 0]                     shift_data [6 : 0];
    reg [4 : 0]                     add_data [6 : 0];

    reg [3 : 0]                     cnt;

    reg [(5*TILE_SIZE+2) - 1 : 0]   temp_flag_data_compressed_0[7 : 0];
    reg [(5*TILE_SIZE+2)*2 - 1 : 0] temp_flag_data_compressed_1[3 : 0];
    reg [(5*TILE_SIZE+2)*4 - 1 : 0] temp_flag_data_compressed_2[1 : 0];
    reg [5 : 0]                     temp_flag_data_compressed_bitsize_0 [7 : 0];
    reg [7 : 0]                     temp_flag_data_compressed_bitsize_1 [3 : 0];
    reg [8 : 0]                     temp_flag_data_compressed_bitsize_2;
    reg                             stage0_valid;
    reg                             stage1_valid;
    reg                             stage2_valid;

    reg                             judge_valid;
    reg                             diff_position_valid;
    
    
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
           cnt <= 4'd0;
           stage0_valid <= 1'd0;
        end
        else
        begin
            if(i_valid && judge_valid && cnt > 4'd7)
            begin
                cnt <= 4'd0;
                stage0_valid <= 1'd1;
            end
            else if(i_valid && cnt > 4'd0 && judge_valid && cnt < 4'd8)
            begin
                cnt <= cnt + 1;
            end
            else if(i_valid && judge_valid && (cnt == 4'd0) && !diff_position_valid)
            begin
                cnt <= 1'd1;
                stage0_valid <= 1'd0;
            end
            else 
            begin
                cnt <= 4'd0;
                stage0_valid <= 1'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            judge_valid <= 1'd0;
        end
        else
        begin
            if(i_valid)
            begin
                judge_valid <= 1'd1;
            end
            else 
            begin
                judge_valid <= 1'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            diff_position_valid <= 1'd0;
        end
        else
        begin
            if(i_valid && judge_valid && (cnt == 4'd3))
            begin
                diff_position_valid <= 1'd1;
            end
            else if(!i_valid)
            begin
                diff_position_valid <= 1'd0;
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
            temp_flag_data_compressed_0[0] <= 42'd0;
            temp_flag_data_compressed_bitsize_0[0] <= 6'd0;
        end
        else if(i_valid)
        begin
            if(cnt > 1'd0 && cnt < 4'd8)
            begin
                if(judge[1 : 0] == 2'd3)
                begin
                    temp_flag_data_compressed_0[0] <= temp_flag_data_compressed_0[0] | (add_data[flag_data[cnt*3 + 2 -: 3]] << (temp_flag_data_compressed_bitsize_0[0]));
                    temp_flag_data_compressed_bitsize_0[0] <= temp_flag_data_compressed_bitsize_0[0] + shift_data[flag_data[cnt*3 + 2 -: 3]];
                end
                else 
                begin
                    
                end
            end
            else if(judge_valid  && !diff_position_valid)
            begin
                if(judge[1 : 0] == 2'd1)
                begin
                    temp_flag_data_compressed_0[0] <= temp_flag_data_compressed_0[0] | ({add_data[diff_flag_data[2 : 0]],diff_position[2 : 0]} << temp_flag_data_compressed_bitsize_0[0]) | (add_data[same_flag_data[2 : 0]] << (2'd2 + shift_data[diff_flag_data[2 : 0]] + 3));//temp_flag_data_compressed_bitsize_0[0]
                    temp_flag_data_compressed_bitsize_0[0] <= temp_flag_data_compressed_bitsize_0[0] + shift_data[same_flag_data[2 : 0]] + shift_data[diff_flag_data[2 : 0]] + 3;
                end
            end
             else if(i_valid && !diff_position_valid)
            begin
                if(judge[1 : 0] == 1'd0)
                begin
                    temp_flag_data_compressed_0[0] <= {add_data[flag_data[5 : 3]],1'd0};//temp_flag_data_compressed_0[0] | (1'd0 << temp_flag_data_compressed_bitsize_0[0]);
                    temp_flag_data_compressed_bitsize_0[0] <= temp_flag_data_compressed_bitsize_0[0] + 1'd1 + shift_data[flag_data[5 : 3]];
                end
                else if(judge[1 : 0] == 2'd1)
                begin
                    temp_flag_data_compressed_0[0] <= 2'd1;//temp_flag_data_compressed_0[0] | (2'd1 << temp_flag_data_compressed_bitsize_0[0]);
                    temp_flag_data_compressed_bitsize_0[0] <= temp_flag_data_compressed_bitsize_0[0] + 2'd2;
                end
                else if(judge[1 : 0] == 2'd3)
                begin
                    temp_flag_data_compressed_0[0] <= 2'd3;//temp_flag_data_compressed_0[0] | (2'd3 << temp_flag_data_compressed_bitsize_0[0]);
                    temp_flag_data_compressed_bitsize_0[0] <= temp_flag_data_compressed_bitsize_0[0] + 2'd2;
                end
                else 
                begin
                    
                end
            end
            else 
            begin
                
            end
        end
        else 
        begin
            temp_flag_data_compressed_0[0] <= 42'd0;
            temp_flag_data_compressed_bitsize_0[0] <= 6'd0;    
        end
    end

    always @(negedge rst_n or posedge clk)
    begin:exist_frame
        integer i;
        for(i=1;i<8;i=i + 1)
        begin
            if(!rst_n)
            begin
                temp_flag_data_compressed_0[i] <= 42'd0;
                temp_flag_data_compressed_bitsize_0[i] <= 6'd0;
            end
            else if(i_valid)
            begin
                if(cnt > 1'd0)
                begin
                    if(judge[i*2 +1 -: 2] == 2'd3)
                    begin
                    temp_flag_data_compressed_0[i] <= temp_flag_data_compressed_0[i] | (add_data[flag_data[i*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3]] << (temp_flag_data_compressed_bitsize_0[i]));
                    temp_flag_data_compressed_bitsize_0[i] <= temp_flag_data_compressed_bitsize_0[i] + shift_data[flag_data[i*3*TILE_SIZE + (cnt - 1)*3 + 2 -: 3]];
                    end
                end
                else if(judge_valid && !diff_position_valid)
                begin
                    if(judge[i*2 +1 -: 2] == 2'd1)
                    begin
                        temp_flag_data_compressed_0[i] <= temp_flag_data_compressed_0[i] | ({add_data[diff_flag_data[i*3 + 2 -: 3]],diff_position[i*3 + 2 -: 3]} << temp_flag_data_compressed_bitsize_0[i]) | (add_data[same_flag_data[i*3 + 2 -: 3]] << (2'd2)+ shift_data[diff_flag_data[i*3 + 2 -: 3]] + 3);//temp_flag_data_compressed_bitsize_0[i]
                        temp_flag_data_compressed_bitsize_0[i] <= temp_flag_data_compressed_bitsize_0[i] + shift_data[same_flag_data[i*3 + 2 -: 3]] + shift_data[diff_flag_data[i*3 + 2 -: 3]] + 3;
                    end
                    else 
                    begin
                        
                    end
                end
                else if(i_valid && !diff_position_valid)
                begin
                    if(judge[i*2 +1 -: 2] == 1'd0)
                    begin
                        temp_flag_data_compressed_0[i] <= {add_data[flag_data[i*3*TILE_SIZE + 2 -: 3]],1'd0};//temp_flag_data_compressed_0[i] | (1'd0 << temp_flag_data_compressed_bitsize_0[i]);
                        temp_flag_data_compressed_bitsize_0[i] <= temp_flag_data_compressed_bitsize_0[i] + 1'd1 + shift_data[flag_data[i*3*TILE_SIZE + 2 -: 3]];
                    end
                    else if(judge[i*2 +1 -: 2] == 2'd1)
                    begin
                        temp_flag_data_compressed_0[i] <= 2'd1;//temp_flag_data_compressed_0[i] | (2'd1 << temp_flag_data_compressed_bitsize_0[i]);
                        temp_flag_data_compressed_bitsize_0[i] <= temp_flag_data_compressed_bitsize_0[i] + 2'd2;
                    end
                    else if(judge[i*2 +1 -: 2] == 2'd3)
                    begin
                        temp_flag_data_compressed_0[i] <= 2'd3;//temp_flag_data_compressed_0[i] | (2'd3 << temp_flag_data_compressed_bitsize_0[i]);
                        temp_flag_data_compressed_bitsize_0[i] <= temp_flag_data_compressed_bitsize_0[i] + 2'd2;
                    end
                    else 
                    begin
                        
                    end
                end
            end
            else 
            begin
                temp_flag_data_compressed_0[i] <= 42'd0;
                temp_flag_data_compressed_bitsize_0[i] <= 6'd0;
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
            if(i_valid && stage0_valid)
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
            temp_flag_data_compressed_1[0] <= 84'd0;
            temp_flag_data_compressed_1[1] <= 84'd0;
            temp_flag_data_compressed_1[2] <= 84'd0;
            temp_flag_data_compressed_1[3] <= 84'd0;
            temp_flag_data_compressed_bitsize_1[0] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[1] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[2] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[3] <= 7'd0;
        end
        else if(i_valid && stage0_valid)
        begin
            temp_flag_data_compressed_1[0] <= temp_flag_data_compressed_0[0] | (temp_flag_data_compressed_0[1] << temp_flag_data_compressed_bitsize_0[0]);
            temp_flag_data_compressed_1[1] <= temp_flag_data_compressed_0[2] | (temp_flag_data_compressed_0[3] << temp_flag_data_compressed_bitsize_0[2]);
            temp_flag_data_compressed_1[2] <= temp_flag_data_compressed_0[4] | (temp_flag_data_compressed_0[5] << temp_flag_data_compressed_bitsize_0[4]);
            temp_flag_data_compressed_1[3] <= temp_flag_data_compressed_0[6] | (temp_flag_data_compressed_0[7] << temp_flag_data_compressed_bitsize_0[6]);
            temp_flag_data_compressed_bitsize_1[0] = temp_flag_data_compressed_bitsize_0[0] + temp_flag_data_compressed_bitsize_0[1];
            temp_flag_data_compressed_bitsize_1[1] = temp_flag_data_compressed_bitsize_0[2] + temp_flag_data_compressed_bitsize_0[3];
            temp_flag_data_compressed_bitsize_1[2] = temp_flag_data_compressed_bitsize_0[4] + temp_flag_data_compressed_bitsize_0[5];
            temp_flag_data_compressed_bitsize_1[3] = temp_flag_data_compressed_bitsize_0[6] + temp_flag_data_compressed_bitsize_0[7];
        end
        else if(!i_valid)
        begin
            temp_flag_data_compressed_1[0] <= 84'd0;
            temp_flag_data_compressed_1[1] <= 84'd0;
            temp_flag_data_compressed_1[2] <= 84'd0;
            temp_flag_data_compressed_1[3] <= 84'd0;
            temp_flag_data_compressed_bitsize_1[0] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[1] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[2] <= 7'd0;
            temp_flag_data_compressed_bitsize_1[3] <= 7'd0;
        end
        else 
        begin
            
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
            if(i_valid && stage1_valid)
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
            temp_flag_data_compressed_2[0] <= 168'd0;
            temp_flag_data_compressed_2[1] <= 168'd0;
            temp_flag_data_compressed_bitsize_2 <= 9'd0;
        end
        else
        begin
            if(i_valid && stage1_valid)
            begin
                temp_flag_data_compressed_2[0] <= temp_flag_data_compressed_1[0] | (temp_flag_data_compressed_1[1] << temp_flag_data_compressed_bitsize_1[0]);
                temp_flag_data_compressed_2[1] <= temp_flag_data_compressed_1[2] | (temp_flag_data_compressed_1[3] << temp_flag_data_compressed_bitsize_1[2]);
                temp_flag_data_compressed_bitsize_2 <= temp_flag_data_compressed_bitsize_1[0] + temp_flag_data_compressed_bitsize_1[1] + temp_flag_data_compressed_bitsize_1[2] + temp_flag_data_compressed_bitsize_1[3];
            end
            else if(!i_valid)
            begin
                temp_flag_data_compressed_2[0] <= 168'd0;
                temp_flag_data_compressed_2[1] <= 168'd0;
                temp_flag_data_compressed_bitsize_2 <= 9'd0;
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
            if(stage2_valid)
            begin
                o_valid <= 1'd1;
            end
            else 
            begin
                o_valid <= 1'd0; 
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_compressed <= 336'd0;
        end
        else
        begin
            /*if(o_valid)
            begin
                flag_data_compressed <= flag_data_compressed;
            end*/
            if(i_valid && stage2_valid)
            begin
                flag_data_compressed <= temp_flag_data_compressed_2[0] | (temp_flag_data_compressed_2[1] << temp_flag_data_compressed_bitsize_1[0] + temp_flag_data_compressed_bitsize_1[1]);
            end
            else 
            begin
                flag_data_compressed <= 336'd0;
            end
        end
    end

    always @(negedge rst_n or posedge clk)
    begin
        if(!rst_n)
        begin
            flag_data_compressed_bytesize <= 6'd0;
        end
        else
        begin
            /*if(o_valid)
            begin
                flag_data_compressed_bytesize <= flag_data_compressed_bytesize;
            end*/
            if(i_valid && stage2_valid)
            begin
                flag_data_compressed_bytesize <= (temp_flag_data_compressed_bitsize_2[2 : 0] == 3'd0) 
                                                ? temp_flag_data_compressed_bitsize_2[8 : 3] 
                                                : temp_flag_data_compressed_bitsize_2[8 : 3] + 1;
            end
            else 
            begin
                flag_data_compressed_bytesize <= 6'd0;
            end
        end
    end

    reg [3 - 1 : 0] dis_flag_data[63:0];
    reg [2 - 1 : 0] dis_judge[7:0];
    reg [3 - 1 : 0] dis_diff_position[7:0];
    reg [3 - 1 : 0] dis_diff_flag_data[7:0];
    reg [3 - 1 : 0] dis_same_flag_data[7:0];

    reg [7 : 0] dis_flag_data_compressed[41:0];

integer i;
always @(*)
begin
    for(i = 0; i <= 63; i = i + 1)
    begin
        dis_flag_data[i] <= flag_data[i*3 + 2 -: 3];
    end

    for(i = 0; i <= 41; i = i + 1)
    begin
        dis_flag_data_compressed[i] <= flag_data_compressed[i*8 + 7 -: 8];
    end

    for(i = 0; i <= 7; i = i + 1)
    begin
        dis_judge           [i] <= judge         [2*i + 1 -: 2];
        dis_diff_position   [i] <= diff_position [3*i + 2 -: 3];
        dis_diff_flag_data  [i] <= diff_flag_data[3*i + 2 -: 3];
        dis_same_flag_data  [i] <= same_flag_data[3*i + 2 -: 3];
    end

end
endmodule
