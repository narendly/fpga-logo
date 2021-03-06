`timescale 1 ns/ 100 ps
module characterData_tb();

	wire [31:0] out;
	reg [7:0] ps2_info;
	reg ps2_enable, clock, reset;
	
	characterData cd(out, ps2_info,clock, ps2_enable, reset);
	initial
	begin
		$display($time, "<<Starting the simulation>> ");
		$monitor("Reading the values of clock %b, ps2_enable %b, ps2_info %h, and reset %b and output %h ", clock, ps2_enable,ps2_info, reset, out);
		ps2_info = 8'h21;
		ps2_enable = 1'b0;
		reset = 1'b1;
		clock = 1'b0;
		#20
		ps2_enable = 1'b1;
		#50;
		ps2_enable = 1'b0;
		#70
		ps2_enable = 1'b1;
		#50;
		ps2_enable = 1'b0;
		#70
		ps2_enable = 1'b1;
		#50;
		ps2_enable = 1'b0;
		#70
		reset = 1'b0;
		#1000
		$stop;
	end
		always 
			#10 clock = ~clock;
		always
			#20 ps2_info = ps2_info+1;
endmodule