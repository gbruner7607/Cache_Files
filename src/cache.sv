module cache #(
	parameter DATA_WIDTH=32, 
	parameter ADDR_WIDTH=32, 
	parameter N_WAYS=2,
	parameter BLOCK_SIZE=128,
	parameter NUM_SETS=32, //8KB / 128 = 64 / 2 = 32,
	parameter OFFSET_BITS=7, 
	parameter INDEX_BITS=5, 
	parameter TAG_BITS=20,
	parameter N_POW=4,
	parameter SRAM_ADDR_WIDTH=16, 
	parameter SRAM_LATENCY=7
	)(
	//core to cache interface
	input logic clk, rst, 
	input logic ren, wen,
	input logic [DATA_WIDTH-1:0] din,
	input logic [ADDR_WIDTH-1:0] addr, 
	output logic cache_rdy, 
	output logic [DATA_WIDTH-1:0] dout, 
	
	//cache to cache memory interface
	input logic [7:0] cell_0_dout, cell_1_dout, cell_2_dout, cell_3_dout, 
	output logic [7:0] cell_0_din, cell_1_din, cell_2_din, cell_3_din, 
	output logic [SRAM_ADDR_WIDTH-1:0] cell_0_addr, cell_1_addr, cell_2_addr, cell_3_addr,
	output logic cell_0_sense_en, cell_1_sense_en, cell_2_sense_en, cell_3_sense_en, 
	output logic cell_0_wen, cell_1_wen, cell_2_wen, cell_3_wen,

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
	
	logic [15:0] sram_latency_counter;
	logic [1:0] sram_addr_lsb;

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
							sram_addr_lsb <= addr[1:0]; 
							case (addr[1:0])
								2'b00: begin
									cell_0_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_1_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_2_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_3_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									if (wen) begin
										cell_0_din <= din[7:0];
										cell_1_din <= din[15:8];
										cell_2_din <= din[23:16];
										cell_3_din <= din[31:24];
									end
								end
								2'b01: begin
									cell_0_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_1_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_2_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_3_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									if (wen) begin
										cell_1_din <= din[7:0];
										cell_2_din <= din[15:8];
										cell_3_din <= din[23:16];
										cell_0_din <= din[31:24];
									end
								end
								2'b10: begin
									cell_0_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_1_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_2_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									cell_3_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									if (wen) begin
										cell_2_din <= din[7:0];
										cell_3_din <= din[15:8];
										cell_0_din <= din[23:16];
										cell_1_din <= din[31:24];
									end
								end
								2'b11: begin
									cell_0_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_1_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_2_addr <= addr[SRAM_ADDR_WIDTH+1:2] + 1;
									cell_3_addr <= addr[SRAM_ADDR_WIDTH+1:2];
									if (wen) begin
										cell_3_din <= din[7:0];
										cell_0_din <= din[15:8];
										cell_1_din <= din[23:16];
										cell_2_din <= din[31:24];
									end
								end
							endcase
							cell_0_wen <= wen;
							cell_1_wen <= wen;
							cell_2_wen <= wen;
							cell_3_wen <= wen;
							cell_0_sense_en <= ren;
							cell_1_sense_en <= ren;
							cell_2_sense_en <= ren;
							cell_3_sense_en <= ren;
							state <= cache_rw;
						end
					end
				end
				cache_rw: begin
					if (sram_latency_counter >= SRAM_LATENCY) begin
						sram_latency_counter <= 0; 
						case (sram_addr_lsb) 
							2'b00: begin
								
							end
						endcase
						
						state <= idle;
					end else begin
						sram_latency_counter <= sram_latency_counter + 1;
						cell_0_sense_en <= 1'b0;
						cell_1_sense_en <= 1'b0;
						cell_2_sense_en <= 1'b0;
						cell_3_sense_en <= 1'b0;
						cell_0_wen <= 1'b0; cell_1_wen <= 1'b0; cell_2_wen <= 1'b0; cell_3_wen <= 1'b0;
					end 
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