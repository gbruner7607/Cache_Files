`timescale 1ns/1ps

module sram_behav #(
	parameter SRAM_LATENCY = 1
	)(
	input logic clk, rst,
	input logic[7:0] din,
	input logic sense_en, wen,
	input logic [8:0] addr, 
	output logic [7:0] dout
);

	logic [7:0] data [512];
	logic [7:0] sram_dout;
	
//	sequence s_dout;
//		@(posedge clk) dout ##1 sram_dout;
//	endsequence
	
	always @(sram_dout) #10 dout = sram_dout;
	
/*	initial begin
		for (int i = 0; i < 1024; i++)
			data[i] = 8'(i);
	end */

	always_ff @(posedge clk) begin
		if (rst) begin
			for (int i = 0; i < 1024; i++) data[i] = 0;
		end else begin
			if (wen) begin
				data[addr] <= din; 
			end else if (sense_en) begin
				sram_dout <= data[addr];
			end
		end
	end

endmodule
