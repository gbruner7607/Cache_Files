module cache_top (
	clk, rst,
	ren, wen, 
	din, 
	addr, 
	storecntrl,
	loadcntrl,
	cache_rdy,
	dout, 

	mem_dout,
	mem_ren, mem_wen, 
	mem_din,
	mem_addr
	);

	output clk;
	output rst;
	output ren;
	output wen;
	output [31:0] din;
	output [31:0] addr;
	output [2:0] storecntrl;
	output [4:0] loadcntrl;
	output cache_rdy;
	output [31:0] dout;
	output [31:0] mem_dout;
	output mem_ren;
	output mem_wen;
	output [31:0] mem_din;
	output [31:0] mem_addr;


	wire [7:0] cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout;
	wire [7:0] cell_0_din, cell_1_din, cell_2_din, cell_3_din;
	wire [8:0] cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr;
	wire cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en;
	wire cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen; 

	//cache c0(.*); 
	
cache cache_inst(clk, rst, ren, wen, din, addr, storecntrl, loadcntrl, cache_rdy, dout,
cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout,
cell_0_din, cell_1_din, cell_2_din, cell_3_din, 
cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr, 
cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en,
cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen,
mem_dout, mem_ren, mem_wen, mem_din, mem_addr);

	sram_compiled_array cell0(
		.addr0(cell_0_addr[0]), .addr1(cell_0_addr[1]),
		.addr2(cell_0_addr[2]), .addr3(cell_0_addr[3]),
		.addr4(cell_0_addr[4]), .addr5(cell_0_addr[5]),
		.addr6(cell_0_addr[6]), .addr7(cell_0_addr[7]),
		.addr8(cell_0_addr[8]),
		.din0(cell_0_din[0]), .din1(cell_0_din[1]),
		.din2(cell_0_din[2]),.din3(cell_0_din[3]),
		.din4(cell_0_din[4]),.din5(cell_0_din[5]),
		.din6(cell_0_din[6]),.din7(cell_0_din[7]),
		.dout0(cell_0_dout[0]), .dout1(cell_0_dout[1]),
		.dout2(cell_0_dout[2]), .dout3(cell_0_dout[3]),
		.dout4(cell_0_dout[4]), .dout5(cell_0_dout[5]),
		.dout6(cell_0_dout[6]), .dout7(cell_0_dout[7]),
		.clk(clk), .write_en(cell_0_wen), .sense_en(cell_0_sense_en)
		);

	sram_compiled_array cell1(
		.addr0(cell_1_addr[0]), .addr1(cell_1_addr[1]),
		.addr2(cell_1_addr[2]), .addr3(cell_1_addr[3]),
		.addr4(cell_1_addr[4]), .addr5(cell_1_addr[5]),
		.addr6(cell_1_addr[6]), .addr7(cell_1_addr[7]),
		.addr8(cell_1_addr[8]),
		.din0(cell_1_din[0]), .din1(cell_1_din[1]),
		.din2(cell_1_din[2]),.din3(cell_1_din[3]),
		.din4(cell_1_din[4]),.din5(cell_1_din[5]),
		.din6(cell_1_din[6]),.din7(cell_1_din[7]),
		.dout0(cell_1_dout[0]), .dout1(cell_1_dout[1]),
		.dout2(cell_1_dout[2]), .dout3(cell_1_dout[3]),
		.dout4(cell_1_dout[4]), .dout5(cell_1_dout[5]),
		.dout6(cell_1_dout[6]), .dout7(cell_1_dout[7]),
		.clk(clk), .write_en(cell_1_wen), .sense_en(cell_1_sense_en)
		);

	sram_compiled_array cell2(
		.addr0(cell_2_addr[0]), .addr1(cell_2_addr[1]),
		.addr2(cell_2_addr[2]), .addr3(cell_2_addr[3]),
		.addr4(cell_2_addr[4]), .addr5(cell_2_addr[5]),
		.addr6(cell_2_addr[6]), .addr7(cell_2_addr[7]),
		.addr8(cell_2_addr[8]),
		.din0(cell_2_din[0]), .din1(cell_2_din[1]),
		.din2(cell_2_din[2]),.din3(cell_2_din[3]),
		.din4(cell_2_din[4]),.din5(cell_2_din[5]),
		.din6(cell_2_din[6]),.din7(cell_2_din[7]),
		.dout0(cell_2_dout[0]), .dout1(cell_2_dout[1]),
		.dout2(cell_2_dout[2]), .dout3(cell_2_dout[3]),
		.dout4(cell_2_dout[4]), .dout5(cell_2_dout[5]),
		.dout6(cell_2_dout[6]), .dout7(cell_2_dout[7]),
		.clk(clk), .write_en(cell_2_wen), .sense_en(cell_2_sense_en)
		);

	sram_compiled_array cell3(
		.addr0(cell_3_addr[0]), .addr1(cell_3_addr[1]),
		.addr2(cell_3_addr[2]), .addr3(cell_3_addr[3]),
		.addr4(cell_3_addr[4]), .addr5(cell_3_addr[5]),
		.addr6(cell_3_addr[6]), .addr7(cell_3_addr[7]),
		.addr8(cell_3_addr[8]),
		.din0(cell_3_din[0]), .din1(cell_3_din[1]),
		.din2(cell_3_din[2]),.din3(cell_3_din[3]),
		.din4(cell_3_din[4]),.din5(cell_3_din[5]),
		.din6(cell_3_din[6]),.din7(cell_3_din[7]),
		.dout0(cell_3_dout[0]), .dout1(cell_3_dout[1]),
		.dout2(cell_3_dout[2]), .dout3(cell_3_dout[3]),
		.dout4(cell_3_dout[4]), .dout5(cell_3_dout[5]),
		.dout6(cell_3_dout[6]), .dout7(cell_3_dout[7]),
		.clk(clk), .write_en(cell_3_wen), .sense_en(cell_3_sense_en)
		);

endmodule
