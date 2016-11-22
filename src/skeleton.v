module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50);  													// 50 MHz clock
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	
	
	
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	wire [31:0] logo_command;
	wire [1:0] position;
	
	position_counter pos_count(position, 1'b1, ps2_key_pressed, ~resetn);
	
	
	
	// your processor
	processor myprocessor(clock, ~resetn, /*ps2_key_pressed, ps2_out, lcd_write_en, lcd_write_data,*/ debug_data_in, debug_addr);
	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, ps2_out, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(ps2_out[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(ps2_out[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted
	assign leds = 8'b00101011;
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	vga_controller vga_ins(.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R));
	
	
endmodule

module position_counter(out,enable,clk,reset);
	output [1:0] out;	 //potentially change								
	input enable, clk, reset;
	reg [1:0] out;		//potentially change	initial out = 6'b0;
	initial 
	begin
		out = 2'b00;
	end
	always @(posedge clk)
	if (reset) begin
	  out <= 6'b0;
	end else if (enable) begin
		case(out)
			2'd0: out <= 2'd1;
			2'd1: out <= 2'd2;
			2'd2: out <= 2'd3;
			2'd3: out <= 2'd0;		
		endcase
	end
endmodule

// 8-BIT SHIFTER (verified)
//
// PARAMS:
//      * 32-BIT INPUT
//    * 1-BIT DIRECTION (0 = left, 1 = right)


module characterData(register_Out, ps2_info, clock, ps2_enable, reset);
	input [7:0] ps2_info;
	input ps2_enable, clock, reset;
	
	output [31:0] register_Out;
	
	wire [31:0] out_temp, out_register_input;
	
	wire [7:0] mappedResult;
	
	mapping m(ps2_info, mappedResult);
	
	
	shift8bitena s8be(register_Out, 1'b0, ps2_enable, out_temp);   // SHIFT WHENEVER ENABLE IS TRUE.
	
	assign out_register_input[31:8] = out_temp[31:8];
	assign out_register_input[7:0] = mappedResult;
	
	// HERE YOU"RE CHOOSING BETWEEN RESETING AND WRITING THE INITIAL DATA vs THE DATA RESULTING FROM PS2.
	
	register r1(clock, ps2_enable, reset, out_register_input,register_Out);   
	
endmodule
	
	
module shift8bitena(data_input, ctrl_shiftdirection, ena, data_output);
    input [31:0] data_input;
    input ctrl_shiftdirection, ena;
    output [31:0] data_output;

    wire [31:0] intermediate1, intermediate2;

    shift4bit s4(data_input, ctrl_shiftdirection, intermediate1);
    shift4bit s8(intermediate1, ctrl_shiftdirection, intermediate2);
	 
	 assign data_output = (ena) ? intermediate2 : data_input;
endmodule



module mapping(in, out);

	input [7:0] in;
	output [7:0] out;
	reg [7:0] out1;
	always@(in)
	begin
	if(in==8'h1c)		//A
		 out1<=8'h41;
	else if (in==8'h32) //B
		 out1<=8'h42;
	else if(in==8'h21) 	//C
		 out1<=8'h43;
	 else if(in==8'h23)	//D
		 out1<=8'h44;
	 else if(in==8'h24)	//E
		 out1<=8'h45; 
	 else if(in==8'h26)	//F
		 out1<=8'h46;
	 else if(in==8'h34)	//G
		 out1<=8'h47;
	 else if(in==8'h33)	//H
		 out1<=8'h48;
	else if (in==8'h43)	//I
		 out1<=8'h49;
	else if(in==8'h3B)	//J
		 out1<=8'h4A;
	 else if(in==8'h42)	//K
		 out1<=8'h4B;
	 else if(in==8'h4B)	//L
		 out1<=8'h4C; 
	 else if(in==8'h3A)	//M
		 out1<=8'h4D;
	 else if(in==8'h31)	//N
		 out1<=8'h4E;
	 else if(in==8'h44)	//O
		 out1<=8'h4F;	 
	else if (in==8'h4D)	//P
		 out1<=8'h50;
	else if(in==8'h15)	//Q
		 out1<=8'h51;
	 else if(in==8'h2D)	//R
		 out1<=8'h52;
	 else if(in==8'h1B)	//S
		 out1<=8'h53; 
	 else if(in==8'h2C)	//T
		 out1<=8'h54;
	 else if(in==8'h3C)	//U
		 out1<=8'h55;
	 else if(in==8'h2A)	//V
		 out1<=8'h56;
	else if(in==8'h1D)	//W
		 out1<=8'h57;
	 else if(in==8'h22)	//X
		 out1<=8'h58;
	 else if(in==8'h35)	//Y
		 out1<=8'h59;
	else if(in==8'h1A)	//Z
		 out1<=8'h5A;
	else if(in==8'h45)	//0
		out1<=8'h30;
	else if(in==8'h16)	//1
		 out1<=8'h31;
	 else if(in==8'h1E)	//2
		 out1<=8'h32;
	 else if(in==8'h26)	//3
		 out1<=8'h33; 
	 else if(in==8'h25)	//4
		 out1<=8'h34;
	 else if(in==8'h2E)	//5
		 out1<=8'h35;
	 else if(in==8'h36)	//6
		 out1<=8'h36;
	else if(in==8'h3D)	//7
		 out1<=8'h37;
	 else if(in==8'h3E)	//8
		 out1<=8'h38;
	 else if(in==8'h46)	//9
		 out1<=8'h39;
	else //begin
		 out1<=8'h00;
	end
	assign out=out1;
endmodule