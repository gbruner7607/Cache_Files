module tb_buffer ();

logic Clk, RD, WR, EN, Rst; 
logic EMPTY, FULL;
logic [31:0] dataIn, dataOut;

buffer dut(.*);

always #5 Clk=!Clk; 

initial begin
	Clk = 0;
	Rst = 1;
	RD = 0;
	WR = 0;
	EN = 0; 
	dataIn = 0; 
	#10 
	Rst = 0;
	EN = 1;

	for (int i = 0; i < 32; i++) begin
		WR = 1;
		dataIn = i + 1;
		#10;
		WR = 0; 
		#10;
	end

	for (int i = 0; i < 32; i++) begin
		RD = 1;
		#10;
	end
end

endmodule