module tb_hit_check ();

logic [19:0] tag_in;
logic [19:0] line_tags [2]; 
logic line_empty [2];
logic hit, miss;
logic [3:0] hit_way; 

hit_check dut(.*); 

initial begin
	line_empty = {0, 0};
	tag_in = 20'hace12;
	line_tags[0] = 20'hace23;
	line_tags[1] = 20'h0;
	#10
	line_tags[1] = 20'hace12;
	#10
	line_tags[1] = 20'h0;
	#10
	line_tags[0] = 20'hace12;
end

endmodule