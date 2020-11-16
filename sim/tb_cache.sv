module tb_cache ();

logic clk, rst, ren, wen;
logic [31:0] din, addr, dout, mem_dout, mem_din, mem_addr; 
logic cache_rdy, mem_ren, mem_wen; 
logic [4:0] loadcntrl;
logic [2:0] storecntrl;

logic [7:0] cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout;
logic [7:0] cell_0_din, cell_1_din, cell_2_din, cell_3_din;
logic [11:0] cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr;
logic cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en;
logic cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen;

always #5 clk=~clk; 

cache dut(.*); 

sram_behav sram_cell_0(clk, cell_0_din, cell_0_sense_en, cell_0_wen, cell_0_addr, cell_0_dout);
sram_behav sram_cell_1(clk, cell_1_din, cell_1_sense_en, cell_1_wen, cell_1_addr, cell_1_dout);
sram_behav sram_cell_2(clk, cell_2_din, cell_2_sense_en, cell_2_wen, cell_2_addr, cell_2_dout);
sram_behav sram_cell_3(clk, cell_3_din, cell_3_sense_en, cell_3_wen, cell_3_addr, cell_3_dout);

initial begin
	clk = 0;
	rst = 1;
	addr = 0;
	din = 0; 
	ren = 0;
	wen = 0;
	loadcntrl = 0;
	storecntrl = 0; 
	#10
	rst = 0; 
	#10 
	ren = 1;
	addr = 32'hace12000; 
	loadcntrl = 5'b00100; 
	#10
	ren = 0; 
//	@(posedge cache_rdy);
	#10 
	storecntrl = 3'b100;
	din = 32'hdeadbeef; 
	wen = 1;
	#10
	wen = 0; 
	@(posedge cache_rdy);
	ren = 1;
	@(negedge cache_rdy);
	ren = 0;
end

//initial begin
//	clk = 0; 
//	rst = 1; 
//	addr = 0; 
//	ren = 0;
//	wen = 0; 
//	#10
//	rst = 0;
//	#10
//	ren = 1; 
//	addr = 32'hace12000;
//	#10
//	ren = 0; 
//	addr = 0;
//	#20
//	ren = 1;
//	addr = 32'hace12000;
//	#10
//	ren = 0;
//	#20
//	ren = 1;
//	addr = 32'hdeadbeef;
//	#10
//	ren = 0;
//	#20
//	ren = 1;
//	addr = 32'hace12004; 
//	#10
//	ren = 0; 
//	#20
//	ren = 1;
//	addr = 32'haaaaa000;
//	#10
//	ren = 0;
//	#20
//	ren = 1;
//	addr = 32'hace12008;
//	#10
//	ren = 0; 
	
////	#10
////	dut.cache_tags[0][1] = 20'hace23; 
////	dut.cache_empty[0][1] = 0;
////	#10
////	addr = 32'hace12000;
////	#10
////	addr = 32'hace23000;
//end

endmodule