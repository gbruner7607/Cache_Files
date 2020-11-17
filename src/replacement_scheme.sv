module replacement_scheme #(
	parameter N_WAYS=2, 
	parameter N_POW=4
)(
	input logic line_empty [N_WAYS],
	input logic [31:0] line_age [N_WAYS], 
	output logic [N_POW-1:0] evict_way
);

logic [N_WAYS-1:0] way_encoded; 

function automatic logic [N_POW-1:0] decode(input logic [N_WAYS-1:0] encoded);
	automatic logic [N_POW-1:0] retval = 0; 
	for (int i = 0; i < N_WAYS; i++) begin
		if (encoded[i]) retval = retval + i; 
	end
	decode = retval;
endfunction

function automatic logic [N_POW-1:0] replace(input logic line_empty [N_WAYS], input logic [31:0] line_age [N_WAYS]);
	automatic int retval = 0; 
	automatic int ret_age = line_age[0];
	for (int i = 0; i < N_WAYS; i++) begin
		if (line_empty[i]) return i; 
		if (line_age[i] > ret_age) begin
			ret_age = line_age[i];
			retval = i;
		end
//		replace = i; 
	end
	replace = retval;
endfunction

always_comb begin
	evict_way = replace(line_empty, line_age);
end

endmodule
