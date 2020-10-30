module cache #(
	parameter DATA_WIDTH=32, 
	parameter ADDR_WIDTH=32, 
	parameter N_WAYS=2,
	parameter BLOCK_SIZE=128,
	parameter NUM_SETS=32, //8KB / 128 = 64 / 2 = 32,
	parameter OFFSET_BITS=7, 
	parameter INDEX_BITS=5, 
	parameter TAG_BITS=20,
	parameter N_POW=4
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

	//State Machine
	enum {setup, idle, cache_rw, cache_replace} state;
	logic read_flag, write_flag;

	//Cache block data and information
	logic [TAG_BITS-1:0] cache_tags [NUM_SETS][N_WAYS];
	logic [DATA_WIDTH-1:0] cache_data [NUM_SETS][N_WAYS]; 
	logic cache_dirty [NUM_SETS][N_WAYS];
	logic cache_empty [NUM_SETS][N_WAYS];
	logic [15:0] cache_age [NUM_SETS][N_WAYS];

	//Interface w/ address translator
	logic [TAG_BITS-1:0] tag_out;
	logic [INDEX_BITS-1:0] index_out;
	logic [OFFSET_BITS-1:0] offset_out; 

	//Line pointed to by address translator
	logic [TAG_BITS-1:0] line_tags [N_WAYS];
	logic line_dirty [N_WAYS];
	logic line_empty [N_WAYS];
	logic [15:0] line_age [N_WAYS];
	
	//Outputs from hit check module
	logic cache_hit, cache_miss;
	logic [N_POW-1:0] hit_way; 
	
	//Outputs from replacement scheme module
	logic [N_POW-1:0] evict_way;

	//Instantiate Address Translator 
	address_translator a0(.*);
	
	//Instantiate hit check module
	hit_check ht0(.tag_in(tag_out), .line_tags(line_tags), .line_empty(line_empty), .hit(cache_hit), .miss(cache_miss), .hit_way(hit_way));
	
	//Instantiate replacement scheme module
	replacement_scheme rs0(.*); 

	always_comb begin
		line_tags = cache_tags[index_out];
		line_dirty = cache_dirty[index_out];
		line_empty = cache_empty[index_out];
		line_age = cache_age[index_out];
	end

	always_ff @(posedge clk) begin
		if (rst) begin
			state <= setup;
			read_flag <= 0;
			write_flag <= 0; 
			cache_rdy <= 0;
			dout <= 32'h0;
			mem_ren <= 0;
			mem_wen <= 0;
			mem_din <= 32'h0;
			mem_addr <= 32'h0;
		end else begin
			case (state) 
				setup: begin
					for (int i = 0; i < NUM_SETS; i++) begin
						for (int j = 0; j < N_WAYS; j++) begin
							cache_tags[i][j] = 0;
							cache_data[i][j] = 0;
							cache_dirty[i][j] = 0;
							cache_empty[i][j] = 1;
							cache_age[i][j] = 0; 
						end
					end
					state <= idle;
					cache_rdy <= 1; 
				end
				idle: begin
					if ((ren | wen) & cache_rdy) begin
						if (cache_miss) begin
							cache_tags[index_out][evict_way] = tag_out;
							cache_age[index_out][evict_way] = 0;
							cache_empty[index_out][evict_way] = 0; 
							if (wen) cache_dirty[index_out][evict_way] = 1; 
						end else if (cache_hit) begin
							cache_age[index_out][hit_way] = 0; 
						end
					end
//					if (ren) begin
//						read_flag <= 1;
//						state <= cache_rw; 
//					end else if (wen) begin
//						write_flag <= 1;
//						state <= cache_rw; 
//					end
				end
				default: begin
					state <= idle;
				end
			endcase

			for (int i = 0; i < NUM_SETS; i++) begin
				for (int j = 0; j < N_WAYS; j++) begin
					if (cache_empty[i][j] == 0) begin
						cache_age[i][j]++; 
					end
				end
			end
		end
	end

endmodule : cache