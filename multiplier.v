module multiplier(out, clk, a, b);

	output [15:0] out;
	input clk;
	input [7:0] a; //removed signed here
	input signed [7:0] b;

	reg	[7:0] a_reg; //not signed here
	reg	signed [7:0] b_reg;
	reg	signed [15:0] out;

	wire signed	[15:0] mult_out;

	assign mult_out = a_reg * b_reg;

	always@(posedge clk)
	begin
		a_reg <= a;
		b_reg <= b;
		out <= mult_out;
	end

endmodule


