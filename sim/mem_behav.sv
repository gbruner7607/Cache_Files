module mem_behav (
	input clk,    // Clock
	input ren, wen, 
	input logic [31:0] din, addr, 
	output logic [31:0] dout
);

logic [31:0] data [65536];

initial begin
	for (int i =0; i < 65536; i++) data[i] = 0; 
end

always_ff @(posedge clk) begin
	if (wen) begin
		data[16'(addr)] <= din;
	end else if (ren) begin
		dout <= data[16'(addr)];
	end
end

endmodule