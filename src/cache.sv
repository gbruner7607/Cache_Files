module cache #(
	parameter DATA_WIDTH=32, 
	parameter ADDR_WIDTH=32, 
	parameter N_WAYS=2,
	parameter BLOCK_SIZE=128,
	parameter NUM_SETS=32, //8KB / 128 = 64 / 2 = 32,
	parameter OFFSET_BITS=7, 
	parameter INDEX_BITS=5, 
	parameter TAG_BITS=20
	)(
	//core to cache interface
	input logic clk, rst, 
	input logic ren, wen,
	input logic [DATA_WIDTH-1:0] din,
	input logic [ADDR_WIDTH-1:0] addr, 
	output logic cache_rdy, 
	output logic [DATA_WIDTH-1:0] dout, 

	//cache to mem interface 
	input logic [DATA_WIDTH-1:0] mem_dout, 
	output logic mem_ren, mem_wen, 
	output logic [DATA_WIDTH-1:0] mem_din, 
	output logic [ADDR_WIDTH-1:0] mem_addr
	);


	logic [TAG_BITS-1:0] cache_tags [NUM_SETS][N_WAYS];
	logic [DATA_WIDTH-1:0] cache_data [NUM_SETS][N_WAYS]; 
	logic cache_dirty [NUM_SETS][N_WAYS];
	logic cache_empty [NUM_SETS][N_WAYS];


endmodule : cache