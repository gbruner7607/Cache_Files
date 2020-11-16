module hit_check #(
	parameter N_WAYS=2,
	parameter TAG_BITS=21,
	parameter N_POW=4
	)(
	input logic [TAG_BITS-1:0] tag_in, 
	input logic [TAG_BITS-1:0] line_tags [N_WAYS], 
	input logic line_empty [N_WAYS],
	output logic hit, 
	output logic miss, 
	output logic[N_POW-1:0] hit_way
);

logic [N_WAYS-1:0] hit_encoded; 

function logic [N_POW-1:0] decode(input logic [N_WAYS-1:0] encoded);
	automatic logic [N_POW-1:0] retval = 0; 
	for (int i = 0; i < N_WAYS; i++) begin
		if (encoded[i]) begin
			retval = retval + i; 
		end
	end
	decode = retval;
endfunction

always_comb begin
	for (int i = 0; i < N_WAYS; i++) begin
		hit_encoded[i] = (tag_in == line_tags[i]) & (~line_empty[i]); 
	end

	miss = (hit_encoded == 0);
	hit = ~miss;
	hit_way = decode(hit_encoded);

end	

endmodule