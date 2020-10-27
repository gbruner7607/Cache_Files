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
	#10
	rst = 0;

	#10
	dut.cache_tags[0][0] = 20'hace23; 
end

endmodule