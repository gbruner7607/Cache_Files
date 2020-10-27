module tb_address_translator ();

logic [31:0] addr;
logic [19:0] tag_out;
logic [4:0] index_out;
logic [6:0] offset_out; 

address_translator dut(.*); 

initial begin
	addr = 32'habcdef01;
	#10
	addr = 32'h01234567;
	#10
	addr = 32'hace1ace2;
end

endmodule