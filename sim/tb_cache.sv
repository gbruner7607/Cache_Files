module tb_cache ();

logic clk, rst, ren, wen;
logic [31:0] din, addr, dout, mem_dout, mem_din, mem_addr; 
logic cache_rdy, mem_ren, mem_wen; 

always #5 clk=~clk; 

cache dut(.*); 

initial begin
	clk = 0; 
	rst = 1; 
	addr = 0; 
	ren = 0;
	wen = 0; 
	#10
	rst = 0;
	#10
	ren = 1; 
	addr = 32'hace12000;
	#10
	ren = 0; 
	addr = 0;
	#10
	ren = 1;
	addr = 32'hace12000;
	#10
	ren = 0;
	#10
	ren = 1;
	addr = 32'hdeadbeef;
	#10
	ren = 0;
	#10
	ren = 1;
	addr = 32'hace12004; 
	#10
	ren = 0; 
	#10
	ren = 1;
	addr = 32'haaaaa000;
	#10
	ren = 0;
	#10
	ren = 1;
	addr = 32'hace12008;
	#10
	ren = 0; 
	
//	#10
//	dut.cache_tags[0][1] = 20'hace23; 
//	dut.cache_empty[0][1] = 0;
//	#10
//	addr = 32'hace12000;
//	#10
//	addr = 32'hace23000;
end

endmodule