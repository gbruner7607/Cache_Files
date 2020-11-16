module cache #(
	parameter DATA_WIDTH=32, 
	parameter ADDR_WIDTH=32, 
	parameter N_WAYS=2,
	parameter BLOCK_SIZE=128,
	parameter NUM_SETS=16, //4KB / 128 = 64 / 2 = 32,
	parameter OFFSET_BITS=7, 
	parameter INDEX_BITS=4, 
	parameter TAG_BITS=21,
	parameter N_POW=4,
	parameter SRAM_ADDR_WIDTH=10, 
	parameter SRAM_LATENCY=1
	)(
	//core to cache interface
	input logic clk, rst, 
	input logic ren, wen,
	input logic [DATA_WIDTH-1:0] din,
	input logic [ADDR_WIDTH-1:0] addr, 
	input logic [2:0] storecntrl,
	input logic [4:0] loadcntrl,
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
	enum {setup, idle, cache_rw, sram_to_buffer, buffer_to_mem, mem_to_buffer, buffer_to_sram} state;
	logic read_flag, write_flag;

	//Cache block data and information
	logic [TAG_BITS-1:0] cache_tags [NUM_SETS][N_WAYS];
	logic [DATA_WIDTH-1:0] cache_data [NUM_SETS][N_WAYS]; 
	logic cache_dirty [NUM_SETS][N_WAYS];
	logic cache_empty [NUM_SETS][N_WAYS];
	logic [31:0] cache_age [NUM_SETS][N_WAYS];

	//Interface w/ address translator
	logic [TAG_BITS-1:0] tag_out;
	logic [INDEX_BITS-1:0] index_out;
	logic [OFFSET_BITS-1:0] offset_out; 

	//Line pointed to by address translator
	logic [TAG_BITS-1:0] line_tags [N_WAYS];
	logic line_dirty [N_WAYS];
	logic line_empty [N_WAYS];
	logic [31:0] line_age [N_WAYS];
	
	//Outputs from hit check module
	logic cache_hit, cache_miss;
	logic [N_POW-1:0] hit_way; 
	
	//Outputs from replacement scheme module
	logic [N_POW-1:0] evict_way;
	
	//SRAM stuff
	logic [15:0] sram_latency_counter;
	logic [1:0] sram_addr_lsb;
	logic [3:0] cell_sense_en, cell_wen;
	logic [4:0] sram_loadcntrl;
	logic [2:0] sram_storecntrl;
	logic [31:0] sram_dout; 
	
	//Block buffer for exchanging blocks with higher level memory
	logic [31:0] block_buf [32]; 
	logic [15:0] block_counter; 
	logic [SRAM_ADDR_WIDTH-1:0] block_addr;
	logic [OFFSET_BITS-1:0] block_offset;
	logic [31:0] mem_addr_tmp;

        // buffer parameters
        logic buff_en, buff_wr_en, buff_rd_en, buff_rst, EMPTY, FULL; //added by Nishith
	logic [DATA_WIDTH-1:0] buff_din, buff_dout;

        // buffer
	buffer  b0 ( clk, buff_din, buff_rd_en, buff_wr_en, buff_en, buff_dout, buff_rst, EMPTY, FULL ); //added by Nishith

	//Instantiate Address Translator 
	address_translator a0(.*);
	
	//Instantiate hit check module
	hit_check ht0(.tag_in(tag_out), .line_tags(line_tags), .line_empty(line_empty), .hit(cache_hit), .miss(cache_miss), .hit_way(hit_way));
	
	//Instantiate replacement scheme module
	replacement_scheme rs0(.*); 
	
	function logic[3:0] RSL(input logic[3:0] A, input logic[1:0] B);
		automatic logic [7:0] C = {A, A};
		C = C << B; 
		RSL = C[7:4];
	endfunction
	
	function logic[31:0] RSR_32(input logic [31:0] A, input logic [1:0] B);
		automatic logic [63:0] C = {A, A}; 
		C = C >> (B * 8); 
		RSR_32 = C[31:0];
	endfunction

	always_comb begin
		line_tags = cache_tags[index_out];
		line_dirty = cache_dirty[index_out];
		line_empty = cache_empty[index_out];
		line_age = cache_age[index_out];
		
		cell_0_sense_en = cell_sense_en[0];
		cell_1_sense_en = cell_sense_en[1];
		cell_2_sense_en = cell_sense_en[2];
		cell_3_sense_en = cell_sense_en[3];
		cell_0_wen = cell_wen[0];
		cell_1_wen = cell_wen[1];
		cell_2_wen = cell_wen[2];
		cell_3_wen = cell_wen[3];
		sram_dout = RSR_32({cell_3_dout, cell_2_dout, cell_1_dout, cell_0_dout}, sram_addr_lsb);
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
			sram_latency_counter <= 0;
			cell_sense_en <= 4'b0000;
			cell_wen <= 4'b0000;
			block_counter <= 0;
			buff_din <= 0;
			buff_rd_en <= 0;
			buff_wr_en <= 0;
			buff_en <= 0;
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
					for (int i = 0; i < 32; i++) begin
						block_buf[i] = 0;
					end
					state <= idle;
					cache_rdy <= 1; 
				end
				idle: begin
					//Are we reading or writing when the cache is ready? 
					if ((ren | wen) & cache_rdy) begin
						cache_rdy <= 0;
						//Cache Miss
						if (cache_miss) begin
							
//							cache_rdy <= 1;
							//TODO: Transition to next state
							//Need to writeback dirty block. Load it into the block buffer
							if (cache_dirty[index_out][evict_way]) begin
                                mem_addr <= {cache_tags[index_out][evict_way], index_out, 7'h00};
                                mem_addr_tmp <= {tag_out, index_out, 7'h00};
                                block_addr <= {evict_way[0], index_out, 5'b00000}; 
                                cell_0_addr <= {evict_way[0], index_out, 5'b00000}; 
                                cell_1_addr <= {evict_way[0], index_out, 5'b00000};
                                cell_2_addr <= {evict_way[0], index_out, 5'b00000}; 
                                cell_3_addr <= {evict_way[0], index_out, 5'b00000};
                                cell_sense_en = 4'b1111;
                                sram_latency_counter <= 0;
                                state <= sram_to_buffer; 
                                block_counter <= 0;
                                buff_en <= 1;  //added by Nishith
                            end 
							//Block isn't dirty, we can replace it now
							else begin
								mem_addr <= {tag_out, index_out, 7'h00};
								mem_addr_tmp <= {tag_out, index_out, 7'h00};
								mem_ren <= 1; 
								state <= mem_to_buffer;
								block_addr <= {evict_way[0], index_out, 5'b00000};
								block_offset = offset_out[6:2]; 
								sram_loadcntrl <= loadcntrl;
								sram_storecntrl <= storecntrl;
								sram_addr_lsb = addr[1:0];
								read_flag <= ren;
								write_flag <= wen;
								cache_rdy <= 0;
							end
							cache_tags[index_out][evict_way] = tag_out;
							cache_age[index_out][evict_way] = 0;
							cache_empty[index_out][evict_way] = 0; 
							if (wen) cache_dirty[index_out][evict_way] = 1; 
						//Cache Hit
						end else if (cache_hit) begin
							cache_age[index_out][hit_way] = 0; 
							sram_addr_lsb <= addr[1:0]; 
							case (addr[1:0])
								2'b00: begin
									cell_0_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_1_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_2_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_3_addr <= {hit_way[0], index_out, offset_out[6:2]};
									if (wen) begin
										cell_0_din <= din[7:0];
										cell_1_din <= din[15:8];
										cell_2_din <= din[23:16];
										cell_3_din <= din[31:24];
									end
								end
								2'b01: begin
									cell_0_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_1_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_2_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_3_addr <= {hit_way[0], index_out, offset_out[6:2]};
									if (wen) begin
										cell_1_din <= din[7:0];
										cell_2_din <= din[15:8];
										cell_3_din <= din[23:16];
										cell_0_din <= din[31:24];
									end
								end
								2'b10: begin
									cell_0_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_1_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_2_addr <= {hit_way[0], index_out, offset_out[6:2]};
									cell_3_addr <= {hit_way[0], index_out, offset_out[6:2]};
									if (wen) begin
										cell_2_din <= din[7:0];
										cell_3_din <= din[15:8];
										cell_0_din <= din[23:16];
										cell_1_din <= din[31:24];
									end
								end
								2'b11: begin
									cell_0_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_1_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_2_addr <= {hit_way[0], index_out, offset_out[6:2]} + 1;
									cell_3_addr <= {hit_way[0], index_out, offset_out[6:2]};
									if (wen) begin
										cell_3_din <= din[7:0];
										cell_0_din <= din[15:8];
										cell_1_din <= din[23:16];
										cell_2_din <= din[31:24];
									end
								end
							endcase
							if (ren) 
								case (loadcntrl)
									5'b00001: cell_sense_en = RSL(4'b0001, addr[1:0]);
									5'b00010: cell_sense_en = RSL(4'b0011, addr[1:0]); 
									5'b00100: cell_sense_en = 4'b1111; 
									5'b01000: cell_sense_en = RSL(4'b0001, addr[1:0]);
									5'b10000: cell_sense_en = RSL(4'b0011, addr[1:0]);
									default: cell_sense_en = 4'b0000;
								endcase
							else cell_sense_en = 0;
							if (wen)
								case (storecntrl)
									3'b001: cell_wen = RSL(4'b0001, addr[1:0]);
									3'b010: cell_wen = RSL(4'b0011, addr[1:0]);
									3'b100: cell_wen = 4'b1111;
									default: cell_wen = 4'b0000;
								endcase
							else cell_wen = 0;
							read_flag <= ren;
							sram_storecntrl <= storecntrl;
							sram_loadcntrl <= loadcntrl;
							write_flag <= wen;
							sram_latency_counter <= 0;
							state <= cache_rw;
						end
					end
				end
				cache_rw: begin
					if (sram_latency_counter >= SRAM_LATENCY) begin
						sram_latency_counter <= 0; 
						if (read_flag) begin
							case (sram_loadcntrl) 
								5'b00001: dout <= {{24{sram_dout[7]}},sram_dout[7:0]};
								5'b00010: dout <= {{16{sram_dout[15]}},sram_dout[15:0]};
								5'b00100: dout <= sram_dout; 
								5'b01000: dout <= {{24{1'b0}}, sram_dout[7:0]};
								5'b10000: dout <= {{16{1'b0}}, sram_dout[15:0]}; 
								default: dout <= 32'h0;
							endcase
						end
						read_flag <= 0; 
						write_flag <= 0;
						state <= idle;
						cache_rdy <= 1;
					end else begin
						sram_latency_counter <= sram_latency_counter + 1;
						cell_sense_en <= 4'b0000;
						cell_wen <= 4'b0000;
					end 
				end
				sram_to_buffer: begin  // added by Nishith
				    if (FULL | block_counter >= 32) begin
				        block_counter <= 0;
				        buff_wr_en <= 0;
				        buff_rd_en <= 1;
				        state <= buffer_to_mem; 
				        cell_sense_en <= 4'b0000;
				    end else begin
				        if (sram_latency_counter >= SRAM_LATENCY) begin
				            buff_wr_en <= 1;
				            buff_din <= {cell_3_dout, cell_2_dout, cell_1_dout, cell_0_dout}; 
				            sram_latency_counter <= 0; 
				            cell_0_addr <= cell_0_addr + 1; 
				            cell_1_addr <= cell_1_addr + 1; 
				            cell_2_addr <= cell_2_addr + 1; 
				            cell_3_addr <= cell_3_addr + 1; 
				            cell_sense_en <= 4'b1111;
				            block_counter <= block_counter + 1;
				        end else begin
				            sram_latency_counter <= sram_latency_counter + 1; 
				            cell_sense_en <= 4'b0000;
				            buff_wr_en <= 0;
				        end
				    end
//				  buff_en <= 1;
//                                  buff_wr_en <= 1;
//                                  buff_rd_en <= 0;
////                                  buff_din <= ; // need to correct, dirty block here
//                                  state <= buffer_to_mem;
				end
				buffer_to_mem: begin //added by Nishith
				    if (FULL) begin
				       buff_rd_en <= 1;
				       mem_din <= buff_dout;
				       mem_wen <= 0; 
//				       block_counter <= block_counter + 1;
				    end else if ( block_counter >= 32) begin
				        buff_rd_en <= 0;
				        mem_wen <= 0; 
				        mem_addr <= mem_addr_tmp;
				        mem_ren <= 1;
				        state <= mem_to_buffer;
				        block_counter <= 0;
				    end else begin
//				        mem_addr <= mem_addr + 1;
				        mem_din <= buff_dout; 
				        mem_wen <= 1;
				        if (mem_wen) mem_addr <= mem_addr + 1;
				        block_counter <= block_counter + 1;
				    end
//				    buff_en <= 1;
//                                    buff_wr_en <= 0;
//                                    buff_rd_en <= 1;
//                                    mem_din <= buff_dout; // maybe correction here too
//                                    state <= idle;
				end
				mem_to_buffer: begin
				    if (block_counter >= 31) begin
				        mem_ren <= 0; 
				        block_counter <= 0; 
				        sram_latency_counter <= 0;
				        cell_0_din <= block_buf[0][7:0]; 
						cell_1_din <= block_buf[0][15:8]; 
						cell_2_din <= block_buf[0][23:16]; 
						cell_3_din <= block_buf[0][32:24]; 
						cell_0_addr <= block_addr;
						cell_1_addr <= block_addr;
						cell_2_addr <= block_addr;
						cell_3_addr <= block_addr;
						cell_wen <= 4'b1111;
						state <= buffer_to_sram;
				    end else begin
				        block_buf[block_counter] <= mem_dout;
				        block_counter <= block_counter + 1;
				        mem_addr <= mem_addr + 1;
				    end
//				    if (EMPTY) begin 
//				        buff_wr_en <= 1;
//				        buff_din <= mem_dout; 
//				        mem_addr <= mem_addr + 1;
//				    end else if (block_counter >= 32) begin
//				        block_counter <= 0;
//				        buff_wr_en <= 0;
//				        mem_ren <= 0;
				        
//				        state <= buffer_to_sram;
//				    end else begin
//				        buff_din <= mem_dout;
//				        mem_addr <= mem_addr + 1;
//				    end
				end
				buffer_to_sram: begin
						if (sram_latency_counter >= SRAM_LATENCY) begin
							if (block_counter >= 31) begin
								block_counter <= 0;
								sram_latency_counter <= 0;
								if (read_flag) begin
									case (sram_loadcntrl) 
										5'b00001: begin
											case(sram_addr_lsb)
												2'b00: dout <= {{24{block_buf[block_offset][7]}}, block_buf[block_offset][7:0]};
												2'b01: dout <= {{24{block_buf[block_offset][15]}}, block_buf[block_offset][15:8]};
												2'b10: dout <= {{24{block_buf[block_offset][23]}}, block_buf[block_offset][23:16]};
												2'b11: dout <= {{24{block_buf[block_offset][31]}}, block_buf[block_offset][31:24]};
											endcase
										end
										5'b00010: begin
											case(sram_addr_lsb)
												2'b00: dout <= {{16{block_buf[block_offset][15]}}, block_buf[block_offset][15:0]};
												2'b01: dout <= {{16{block_buf[block_offset][23]}}, block_buf[block_offset][23:8]};
												2'b10: dout <= {{16{block_buf[block_offset][31]}}, block_buf[block_offset][31:16]};
												2'b11: dout <= {{16{block_buf[block_offset + 1][7]}}, block_buf[block_offset + 1][7:0], block_buf[block_offset][31:24]};
											endcase
										end 
										5'b00100: begin
											case(sram_addr_lsb)
											2'b00: dout <= block_buf[block_offset];
											2'b01: dout <= {block_buf[block_offset+1][7:0], block_buf[block_offset][31:8]};
											2'b10: dout <= {block_buf[block_offset+1][15:0], block_buf[block_offset][31:16]};
											2'b11: dout <= {block_buf[block_offset+1][23:0], block_buf[block_offset][31:24]};
											endcase
										end 
										5'b01000: begin
											case(sram_addr_lsb)
												2'b00: dout <= {{24{1'b0}}, block_buf[block_offset][7:0]};
												2'b01: dout <= {{24{1'b0}}, block_buf[block_offset][15:8]};
												2'b10: dout <= {{24{1'b0}}, block_buf[block_offset][23:16]};
												2'b11: dout <= {{24{1'b0}}, block_buf[block_offset][31:24]};
											endcase
										end 
										5'b10000: begin
											case(sram_addr_lsb)
												2'b00: dout <= {{16{1'b0}}, block_buf[block_offset][15:0]};
												2'b01: dout <= {{16{1'b0}}, block_buf[block_offset][23:8]};
												2'b10: dout <= {{16{1'b0}}, block_buf[block_offset][31:16]};
												2'b11: dout <= {{16{1'b0}}, block_buf[block_offset + 1][7:0], block_buf[block_offset][31:24]};
											endcase
										end 
										default: begin
											dout <= 0;
										end
									endcase
								end else if (write_flag) begin
								
								end
								read_flag <= 0;
								write_flag <= 0;
								state <= idle;
								cache_rdy <= 1;
							end else begin
								sram_latency_counter <= 0;
								cell_0_din <= block_buf[block_counter + 1][7:0]; 
								cell_1_din <= block_buf[block_counter + 1][15:8]; 
								cell_2_din <= block_buf[block_counter + 1][23:16]; 
								cell_3_din <= block_buf[block_counter + 1][32:24]; 
								cell_0_addr <= block_addr + block_counter + 1;
								cell_1_addr <= block_addr + block_counter + 1;
								cell_2_addr <= block_addr + block_counter + 1;
								cell_3_addr <= block_addr + block_counter + 1;
								cell_wen <= 4'b1111;
								block_counter <= block_counter + 1;
								
							end
						end else begin
							sram_latency_counter <= sram_latency_counter + 1; 
							cell_wen <= 4'b0000;
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
