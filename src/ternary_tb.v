`timescale 1 ns / 100 ps
module ternary_tb();
	reg [1:0] a;
	wire [1:0] b;
	
	test t(a, b);
	
	initial
	begin
	$monitor("%d %d", a, b);
	a = 2'b0;
	#50
	$stop;
	end
	always
	#10 a = a + 1;

endmodule
