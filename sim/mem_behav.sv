module mem_behav (
	input clk,    // Clock
	input ren, wen, 
	input logic [31:0] din, addr, 
	output logic [31:0] dout
);

logic [31:0] data [65536];

int fd;
int i;
string a;

initial begin
//	for (int i =0; i < 65536; i++) data[i] = 0;
	i = 0; 
	fd = $fopen("C:/Users/grayb/Projects/Cache_Files/mem_files/test.hex", "r"); 
	$display("%0d", fd);
	while (!$feof(fd)) begin
		$fscanf(fd, "%s", a);
		$display("%s", a);
		data[i] = a.atohex();
		i = i + 1;
	end 
end

always_ff @(posedge clk) begin
	if (wen) begin
		data[16'(addr)] <= din;
	end else if (ren) begin
		dout <= data[16'(addr)];
	end
end

endmodule