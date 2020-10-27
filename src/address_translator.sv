module address_translator #(
	parameter ADDR_WIDTH=32,
	parameter N_WAYS=2,
	parameter BLOCK_SIZE=128,
	parameter NUM_SETS=32, 
	parameter OFFSET_BITS=7,
	parameter INDEX_BITS=5,
	parameter TAG_BITS=20
	)(
	input logic [ADDR_WIDTH-1:0] addr, 
	output logic [TAG_BITS-1:0] tag_out, 
	output logic [INDEX_BITS-1:0] index_out,
	output logic [OFFSET_BITS-1:0] offset_out
	
);


	assign tag_out = addr[ADDR_WIDTH-1:ADDR_WIDTH-TAG_BITS];
	assign index_out = addr[(ADDR_WIDTH-TAG_BITS)-1:(ADDR_WIDTH-TAG_BITS)-INDEX_BITS];
	assign offset_out = addr[(ADDR_WIDTH-TAG_BITS-INDEX_BITS)-1:0];

endmodule