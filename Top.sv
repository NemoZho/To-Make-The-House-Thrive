module Top (
    input      		i_clk,
    input       	i_rst_n,
    inout       	i_ps2_clk,
    inout  [7:0] 	i_ps2_data,
    output [8:0] 	o_ledg,
    output [17:0] 	o_ledr,
    output 				o_vga_clk,
    output 				o_hs,  
    output				o_vs,  
    output		[7:0]		o_red,
    output		[7:0]		o_green,
    output		[7:0]		o_blue,
	 output   	[19:0]   o_address,
	 input     	[15:0]  i_SRAMDATA,
	 output    	[9:0]   nemo_xpos,
	 output    	[9:0]   nemo_ypos,
	 output		[4:0]		gesture,
	 output		[7:0] 	health,
	 output          [9:0]     keycode
);
    logic break_code, long_code, key_state;
    logic [7:0] key_ascii;
	 logic [9:0] key_value;
	 logic [9:0] X_pos,X_pos_kelly;
	 logic [9:0] Y_pos,Y_pos_kelly;
	 logic [2:0] nemostate,kellystate;
	 logic [3:0] o_tblf;
	 logic [1048575:0] ROM;
	 logic [19:0] address;
	 logic [7:0] colorData;
	 logic [7:0] red;
	 logic [7:0] green;
	 logic [7:0] blue;
	 logic [19:0] position;
	 logic flag;
    assign o_ledg[2:0] = nemostate;
	 assign nemo_xpos = X_pos;
	 assign nemo_ypos = Y_pos;
	 assign keycode = key_value;
	 //assign o_ledr[17:9] = Y_pos;
	 //assign o_ledr[15:0] = o_address == 0 ? i_SRAMDATA : o_ledr[15:0];
	 //assign o_address = ;

	 

Keyboard kb0(
    .clk(i_clk),
    .rst_n(i_rst_n),
    .ps2_clk(i_ps2_clk),
    .ps2_data(i_ps2_data),
    .break_code(break_code),
    .long_code(long_code),
    .key_state(key_state),
    .key_ascii(key_ascii),
	 .key_value(key_value)
);


nemo nmsl(
	.clk(i_clk),
   .rst_n(i_rst_n),
	.X_pos(X_pos),
   .Y_pos(Y_pos),
	.state(nemostate),
	.keycode(key_value),
	.gesture(gesture),
	//.health(health)
);

kelly bitch(
	.clk(i_clk),
   .rst_n(i_rst_n),
	.X_pos(X_pos_kelly),
   .Y_pos(Y_pos_kelly),
	.state(kellystate),
	.keycode(key_value),
);



endmodule