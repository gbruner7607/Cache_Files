module cache_top (
	input logic clk, rst,
	input logic ren, wen, 
	input logic [31:0] din, 
	input logic [31:0] addr, 
	input logic [2:0] storecntrl,
	input logic [4:0] loadcntrl,
	output logic cache_rdy,
	output logic [31:0] dout, 

	input logic [31:0] mem_dout,
	output logic mem_ren, mem_wen, 
	output logic [31:0] mem_din,
	output logic [31:0] mem_addr
	);


	logic [7:0] cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout;
	logic [7:0] cell_0_din, cell_1_din, cell_2_din, cell_3_din;
	logic [9:0] cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr;
	logic cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en;
	logic cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen; 

	cache c0(.*); 

	sram_compiled_array cell0(
		cell_0_addr[0],cell_0_addr[1],
		cell_0_addr[2],cell_0_addr[3],
		cell_0_addr[4],cell_0_addr[5],
		cell_0_addr[6],cell_0_addr[7],
		cell_0_addr[8],cell_0_addr[9],
		cell_0_din[0],cell_0_din[1],
		cell_0_din[2],cell_0_din[3],
		cell_0_din[4],cell_0_din[5],
		cell_0_din[6],cell_0_din[7],
		cell_0_dout[0], cell_0_dout[1],
		cell_0_dout[2], cell_0_dout[3],
		cell_0_dout[4], cell_0_dout[5],
		cell_0_dout[6], cell_0_dout[7],
		clk, cell_0_wen, cell_0_sense_en
		);

	sram_compiled_array cell1(
		cell_1_addr[0],cell_0_addr[1],
		cell_1_addr[2],cell_1_addr[3],
		cell_1_addr[4],cell_1_addr[5],
		cell_1_addr[6],cell_1_addr[7],
		cell_1_addr[8],cell_1_addr[9],
		cell_1_din[1],cell_1_din[1],
		cell_1_din[2],cell_1_din[3],
		cell_1_din[4],cell_1_din[5],
		cell_1_din[6],cell_1_din[7],
		cell_1_dout[0], cell_1_dout[1],
		cell_1_dout[2], cell_1_dout[3],
		cell_1_dout[4], cell_1_dout[5],
		cell_1_dout[6], cell_1_dout[7],
		clk, cell_1_wen, cell_1_sense_en
		);

	sram_compiled_array cell2(
		cell_2_addr[0],cell_2_addr[1],
		cell_2_addr[2],cell_2_addr[3],
		cell_2_addr[4],cell_2_addr[5],
		cell_2_addr[6],cell_2_addr[7],
		cell_2_addr[8],cell_2_addr[9],
		cell_2_din[0],cell_2_din[1],
		cell_2_din[2],cell_2_din[3],
		cell_2_din[4],cell_2_din[5],
		cell_2_din[6],cell_2_din[7],
		cell_2_dout[0], cell_2_dout[1],
		cell_2_dout[2], cell_2_dout[3],
		cell_2_dout[4], cell_2_dout[5],
		cell_2_dout[6], cell_2_dout[7],
		clk, cell_2_wen, cell_2_sense_en
		);

	sram_compiled_array cell3(
		cell_3_addr[0],cell_3_addr[1],
		cell_3_addr[2],cell_3_addr[3],
		cell_3_addr[4],cell_3_addr[5],
		cell_3_addr[6],cell_3_addr[7],
		cell_3_addr[8],cell_3_addr[9],
		cell_3_din[0],cell_3_din[1],
		cell_3_din[2],cell_3_din[3],
		cell_3_din[4],cell_3_din[5],
		cell_3_din[6],cell_3_din[7],
		cell_3_dout[0], cell_3_dout[1],
		cell_3_dout[2], cell_3_dout[3],
		cell_3_dout[4], cell_3_dout[5],
		cell_3_dout[6], cell_3_dout[7],
		clk, cell_3_wen, cell_3_sense_en
		);

endmodule