`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 11:52:30
// Design Name: 
// Module Name: TOP_compress
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


module TOP_compress#
(parameter TILE_SIZE = 4'd8
)
(
	input									clk,
	input									rst_n,
	input	[512 - 1 : 0]					i_data,
	input									i_valid,
	input	[32 - 1 : 0]					data_width,

	output	[TILE_SIZE*TILE_SIZE*4 - 1 : 0]	o_all_data_compressed,
	output	[8 : 0]							o_all_data_bytesize,

	output									o_valid
    );

//compress_receive
wire											receive_o_valid;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			receive_b_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			receive_g_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			receive_r_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			receive_a_data;

//generate_data_abs
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_data;
wire											generate_i_valid;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_data_row_abs;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_data_col_abs;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_flag_row_data_abs;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_flag_row;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			generate_flag_col;
wire											generate_o_valid;

//compare_judge
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_judge_flag_data;
wire											cp_judge_i_valid;
wire	[2*TILE_SIZE - 1 : 0]					cp_judge_judge;
wire	[3*TILE_SIZE - 1 : 0]					cp_judge_diff_position;
wire	[3*TILE_SIZE - 1 : 0]					cp_judge_diff_flag_data;
wire	[3*TILE_SIZE - 1 : 0]					cp_judge_same_flag_data;
wire											cp_judge_o_valid;

//calculate_size
wire											calculate_i_valid;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			calculate_flag_data;
wire	[2*TILE_SIZE - 1 : 0]					calculate_judge;
wire	[3*TILE_SIZE - 1 : 0]					calculate_diff_flag_data;
wire	[3*TILE_SIZE - 1 : 0]					calculate_same_flag_data;
wire											calculate_o_valid;
wire	[6 : 0]									calculate_all_data_byte_size;

//compress_core_data
wire											compress_core_data_i_valid;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_data_data_abs;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_data_flag_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_data_data_abs_compressed;
wire	[5 : 0]									compress_core_data_data_abs_compressed_bytesize;
wire											compress_core_data_o_valid;

//compress_core_flag
wire											compress_core_flag_i_valid;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			compress_core_flag_data;
wire	[2*TILE_SIZE - 1 : 0]					compress_core_judge;
wire	[3*TILE_SIZE - 1 : 0]					compress_core_diff_position;
wire	[3*TILE_SIZE - 1 : 0]					compress_core_diff_flag_data;
wire	[3*TILE_SIZE - 1 : 0]					compress_core_same_flag_data;
wire	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	compress_core_flag_data_compressed;
wire	[5 : 0]									compress_core_flag_data_compressed_bytesize;
wire											compress_core_flag_o_valid;

//compare_bgr
wire											cp_bgr_i_valid;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_b_flag;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_g_flag;
wire	[3*TILE_SIZE*TILE_SIZE - 1 : 0]			cp_bgr_r_flag;
wire	[6*7 - 1 : 0]							cp_bgr_diff_g_position;
wire	[3*7 - 1 : 0]							cp_bgr_diff_g_flag;
wire	[6*7 - 1 : 0]							cp_bgr_diff_r_position;
wire	[3*7 - 1 : 0]							cp_bgr_diff_r_flag;
wire	[2 : 0]									cp_bgr_g_diff_num;
wire	[2 : 0]									cp_bgr_r_diff_num;
wire											cp_bgr_similar_g;
wire											cp_bgr_similar_r;
wire											cp_bgr_o_valid;

//compress_core_flag_bgr_same
wire											compress_bgr_same_i_valid;
wire	[6*7 - 1 : 0]							compress_bgr_same_diff_position;
wire	[3*7 - 1 : 0]							compress_bgr_same_diff_flag;
wire	[2 : 0]									compress_bgr_same_diff_num;
wire	[76 : 0]								compress_bgr_flag_data_compressed;
wire	[3 : 0]									compress_bgr_flag_data_compressed_bytesize;
wire											compress_bgr_o_valid;

//tidy_data
wire											tidy_i_valid;
wire											tidy_similar_g;
wire											tidy_similar_r;
wire											tidy_row_col;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_b_data_abs_compressed;
wire	[5 : 0]									tidy_b_data_abs_compressed_bytesize;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_g_data_abs_compressed;
wire	[5 : 0]									tidy_g_data_abs_compressed_bytesize;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_r_data_abs_compressed;
wire	[5 : 0]									tidy_r_data_abs_compressed_bytesize;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_a_data_abs_compressed;
wire	[5 : 0]									tidy_a_data_abs_compressed_bytesize;
wire	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_b_flag_data_compressed;
wire	[5 : 0]									tidy_b_flag_data_compressed_bytesize;
wire	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_g_flag_data_compressed;
wire	[5 : 0]									tidy_g_flag_data_compressed_bytesize;
wire	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_r_flag_data_compressed;
wire	[5 : 0]									tidy_r_flag_data_compressed_bytesize;
wire	[(5*TILE_SIZE + 2)*TILE_SIZE - 1 : 0]	tidy_a_flag_data_compressed;
wire	[5 : 0]									tidy_a_flag_data_compressed_bytesize;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_b_data;//Receive-data
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_g_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_r_data;
wire	[8*TILE_SIZE*TILE_SIZE - 1 : 0]			tidy_a_data;

	compress_control #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compress_control (
			.clk                                             (clk),
			.rst_n                                           (rst_n),
			.receive_o_valid                                 (receive_o_valid),
			.receive_b_data                                  (receive_b_data),
			.receive_g_data                                  (receive_g_data),
			.receive_r_data                                  (receive_r_data),
			.receive_a_data                                  (receive_a_data),
			.generate_data                                   (generate_data),
			.generate_i_valid                                (generate_i_valid),
			.generate_data_row_abs                           (generate_data_row_abs),
			.generate_data_col_abs                           (generate_data_col_abs),
			.generate_flag_row_data_abs                      (generate_flag_row_data_abs),
			.generate_flag_row                               (generate_flag_row),
			.generate_flag_col                               (generate_flag_col),
			.generate_o_valid                                (generate_o_valid),
			.cp_judge_flag_data                              (cp_judge_flag_data),
			.cp_judge_i_valid                                (cp_judge_i_valid),
			.cp_judge_judge                                  (cp_judge_judge),
			.cp_judge_diff_position                          (cp_judge_diff_position),
			.cp_judge_diff_flag_data                         (cp_judge_diff_flag_data),
			.cp_judge_same_flag_data                         (cp_judge_same_flag_data),
			.cp_judge_o_valid                                (cp_judge_o_valid),
			.calculate_i_valid                               (calculate_i_valid),
			.calculate_flag_data                             (calculate_flag_data),
			.calculate_judge                                 (calculate_judge),
			.calculate_diff_flag_data                        (calculate_diff_flag_data),
			.calculate_same_flag_data                        (calculate_same_flag_data),
			.calculate_o_valid                               (calculate_o_valid),
			.calculate_all_data_byte_size                    (calculate_all_data_byte_size),
			.compress_core_data_i_valid                      (compress_core_data_i_valid),
			.compress_core_data_data_abs                     (compress_core_data_data_abs),
			.compress_core_data_flag_data                    (compress_core_data_flag_data),
			.compress_core_data_data_abs_compressed          (compress_core_data_data_abs_compressed),
			.compress_core_data_data_abs_compressed_bytesize (compress_core_data_data_abs_compressed_bytesize),
			.compress_core_data_o_valid                      (compress_core_data_o_valid),
			.compress_core_flag_i_valid                      (compress_core_flag_i_valid),
			.compress_core_flag_data                         (compress_core_flag_data),
			.compress_core_judge                             (compress_core_judge),
			.compress_core_diff_position                     (compress_core_diff_position),
			.compress_core_diff_flag_data                    (compress_core_diff_flag_data),
			.compress_core_same_flag_data                    (compress_core_same_flag_data),
			.compress_core_flag_data_compressed              (compress_core_flag_data_compressed),
			.compress_core_flag_data_compressed_bytesize     (compress_core_flag_data_compressed_bytesize),
			.compress_core_flag_o_valid                      (compress_core_flag_o_valid),
			.cp_bgr_i_valid                                  (cp_bgr_i_valid),
			.cp_bgr_b_flag                                   (cp_bgr_b_flag),
			.cp_bgr_g_flag                                   (cp_bgr_g_flag),
			.cp_bgr_r_flag                                   (cp_bgr_r_flag),
			.cp_bgr_diff_g_position                          (cp_bgr_diff_g_position),
			.cp_bgr_diff_g_flag                              (cp_bgr_diff_g_flag),
			.cp_bgr_diff_r_position                          (cp_bgr_diff_r_position),
			.cp_bgr_diff_r_flag                              (cp_bgr_diff_r_flag),
			.cp_bgr_g_diff_num                               (cp_bgr_g_diff_num),
			.cp_bgr_r_diff_num                               (cp_bgr_r_diff_num),
			.cp_bgr_similar_g                                (cp_bgr_similar_g),
			.cp_bgr_similar_r                                (cp_bgr_similar_r),
			.cp_bgr_o_valid                                  (cp_bgr_o_valid),
			.compress_bgr_same_i_valid                       (compress_bgr_same_i_valid),
			.compress_bgr_same_diff_position                 (compress_bgr_same_diff_position),
			.compress_bgr_same_diff_flag                     (compress_bgr_same_diff_flag),
			.compress_bgr_same_diff_num                      (compress_bgr_same_diff_num),
			.compress_bgr_flag_data_compressed               (compress_bgr_flag_data_compressed),
			.compress_bgr_flag_data_compressed_bytesize      (compress_bgr_flag_data_compressed_bytesize),
			.compress_bgr_o_valid                            (compress_bgr_o_valid),
			.tidy_i_valid                                    (tidy_i_valid),
			.tidy_similar_g                                  (tidy_similar_g),
			.tidy_similar_r                                  (tidy_similar_r),
			.tidy_row_col                                    (tidy_row_col),
			.tidy_b_data_abs_compressed                      (tidy_b_data_abs_compressed),
			.tidy_b_data_abs_compressed_bytesize             (tidy_b_data_abs_compressed_bytesize),
			.tidy_g_data_abs_compressed                      (tidy_g_data_abs_compressed),
			.tidy_g_data_abs_compressed_bytesize             (tidy_g_data_abs_compressed_bytesize),
			.tidy_r_data_abs_compressed                      (tidy_r_data_abs_compressed),
			.tidy_r_data_abs_compressed_bytesize             (tidy_r_data_abs_compressed_bytesize),
			.tidy_a_data_abs_compressed                      (tidy_a_data_abs_compressed),
			.tidy_a_data_abs_compressed_bytesize             (tidy_a_data_abs_compressed_bytesize),
			.tidy_b_flag_data_compressed                     (tidy_b_flag_data_compressed),
			.tidy_b_flag_data_compressed_bytesize            (tidy_b_flag_data_compressed_bytesize),
			.tidy_g_flag_data_compressed                     (tidy_g_flag_data_compressed),
			.tidy_g_flag_data_compressed_bytesize            (tidy_g_flag_data_compressed_bytesize),
			.tidy_r_flag_data_compressed                     (tidy_r_flag_data_compressed),
			.tidy_r_flag_data_compressed_bytesize            (tidy_r_flag_data_compressed_bytesize),
			.tidy_a_flag_data_compressed                     (tidy_a_flag_data_compressed),
			.tidy_a_flag_data_compressed_bytesize            (tidy_a_flag_data_compressed_bytesize),
			.tidy_b_data                                     (tidy_b_data),
			.tidy_g_data                                     (tidy_g_data),
			.tidy_r_data                                     (tidy_r_data),
			.tidy_a_data                                     (tidy_a_data)
		);
	
	compress_receive_data #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compress_receive_data (
			.clk        (clk),
			.rst_n      (rst_n),
			.data_width (32'd256),
			.i_valid    (i_valid),
			.i_data     (i_data),
			.b_data     (receive_b_data),
			.g_data     (receive_g_data),
			.r_data     (receive_r_data),
			.a_data     (receive_a_data),
			.o_valid    (receive_o_valid)
		);
        
	generate_data_abs #(
			.TILE_SIZE(TILE_SIZE)
		) inst_generate_data_abs (
			.clk               (clk),
			.rst_n             (rst_n),
			.i_valid           (generate_i_valid),
			.data              (generate_data),
			.data_row_abs      (generate_data_row_abs),
			.data_col_abs      (generate_data_col_abs),
			.flag_row_data_abs (generate_flag_row_data_abs),
			.flag_row          (generate_flag_row),
			.flag_col          (generate_flag_col),
			.o_valid           (generate_o_valid)
		);
    
	compare_judge #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compare_judge (
			.clk            (clk),
			.rst_n          (rst_n),
			.i_valid        (cp_judge_i_valid),
			.flag_data      (cp_judge_flag_data),
			.judge          (cp_judge_judge),
			.diff_position  (cp_judge_diff_position),
			.diff_flag_data (cp_judge_diff_flag_data),
			.same_flag_data (cp_judge_same_flag_data),
			.o_valid        (cp_judge_o_valid)
		);

	calculate_size_core #(
			.TILE_SIZE(TILE_SIZE)
		) inst_calculate_size_core (
			.clk                (clk),
			.rst_n              (rst_n),
			.i_valid            (calculate_i_valid),
			.flag_data          (calculate_flag_data),
			.judge              (calculate_judge),
			.diff_flag_data     (calculate_diff_flag_data),
			.same_flag_data     (calculate_same_flag_data),
			.o_valid            (calculate_o_valid),
			.all_data_byte_size (calculate_all_data_byte_size)
		);

	compress_core_data #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compress_core_data (
			.clk                          (clk),
			.rst_n                        (rst_n),
			.i_valid                      (compress_core_data_i_valid),
			.data_abs                     (compress_core_data_data_abs),
			.flag_data                    (compress_core_data_flag_data),
			.data_abs_compressed          (compress_core_data_data_abs_compressed),
			.data_abs_compressed_bytesize (compress_core_data_data_abs_compressed_bytesize),
			.o_valid                      (compress_core_data_o_valid)
		);

	compress_core_flag #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compress_core_flag (
			.clk                           (clk),
			.rst_n                         (rst_n),
			.i_valid                       (compress_core_flag_i_valid),
			.flag_data                     (compress_core_flag_data),
			.judge                         (compress_core_judge),
			.diff_position                 (compress_core_diff_position),
			.diff_flag_data                (compress_core_diff_flag_data),
			.same_flag_data                (compress_core_same_flag_data),
			.flag_data_compressed          (compress_core_flag_data_compressed),
			.flag_data_compressed_bytesize (compress_core_flag_data_compressed_bytesize),
			.o_valid                       (compress_core_flag_o_valid)
		);
           
	compare_bgr #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compare_bgr (
			.clk             (clk),
			.rst_n           (rst_n),
			.i_valid         (cp_bgr_i_valid),
			.b_flag          (cp_bgr_b_flag),
			.g_flag          (cp_bgr_g_flag),
			.r_flag          (cp_bgr_r_flag),
			.diff_g_position (cp_bgr_diff_g_position),
			.diff_g_flag     (cp_bgr_diff_g_flag),
			.diff_r_position (cp_bgr_diff_r_position),
			.diff_r_flag     (cp_bgr_diff_r_flag),
			.g_diff_num      (cp_bgr_g_diff_num),
			.r_diff_num      (cp_bgr_r_diff_num),
			.similar_g       (cp_bgr_similar_g),
			.similar_r       (cp_bgr_similar_r),
			.o_valid         (cp_bgr_o_valid)
		);

	compress_core_flag_bgr_same #(
			.TILE_SIZE(TILE_SIZE)
		) inst_compress_core_flag_bgr_same (
			.clk                           (clk),
			.rst_n                         (rst_n),
			.i_valid                       (compress_bgr_same_i_valid),
			.diff_position                 (compress_bgr_same_diff_position),
			.diff_flag                     (compress_bgr_same_diff_flag),
			.diff_num                      (compress_bgr_same_diff_num),
			.flag_data_compressed          (compress_bgr_flag_data_compressed),
			.flag_data_compressed_bytesize (compress_bgr_flag_data_compressed_bytesize),
			.o_valid                       (compress_bgr_o_valid)
		);
                         
	tidy_data #(
			.TILE_SIZE(TILE_SIZE)
		) inst_tidy_data (
			.clk                               (clk),
			.rst_n                             (rst_n),
			.i_valid                           (tidy_i_valid),
			.similar_g                         (tidy_similar_g),
			.similar_r                         (tidy_similar_r),
			.row_col                           (tidy_row_col),
			.i_b_data_abs_compressed           (tidy_b_data_abs_compressed),
			.i_b_data_abs_compressed_bytesize  (tidy_b_data_abs_compressed_bytesize),
			.i_g_data_abs_compressed           (tidy_g_data_abs_compressed),
			.i_g_data_abs_compressed_bytesize  (tidy_g_data_abs_compressed_bytesize),
			.i_r_data_abs_compressed           (tidy_r_data_abs_compressed),
			.i_r_data_abs_compressed_bytesize  (tidy_r_data_abs_compressed_bytesize),
			.i_a_data_abs_compressed           (tidy_a_data_abs_compressed),
			.i_a_data_abs_compressed_bytesize  (tidy_a_data_abs_compressed_bytesize),
			.i_b_flag_data_compressed          (tidy_b_flag_data_compressed),
			.i_b_flag_data_compressed_bytesize (tidy_b_flag_data_compressed_bytesize),
			.i_g_flag_data_compressed          (tidy_g_flag_data_compressed),
			.i_g_flag_data_compressed_bytesize (tidy_g_flag_data_compressed_bytesize),
			.i_r_flag_data_compressed          (tidy_r_flag_data_compressed),
			.i_r_flag_data_compressed_bytesize (tidy_r_flag_data_compressed_bytesize),
			.i_a_flag_data_compressed          (tidy_a_flag_data_compressed),
			.i_a_flag_data_compressed_bytesize (tidy_a_flag_data_compressed_bytesize),
			.i_b_data                          (tidy_b_data),
			.i_g_data                          (tidy_g_data),
			.i_r_data                          (tidy_r_data),
			.i_a_data                          (tidy_a_data),
			.o_all_data_compressed             (o_all_data_compressed),
			.o_all_data_bytesize               (o_all_data_bytesize),
			.o_valid                           (o_valid)
		);

endmodule
