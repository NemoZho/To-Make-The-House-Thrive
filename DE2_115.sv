module DE2_115(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,

	//////////// LED //////////
	output		     [8:0]		LEDG,
	output		    [17:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// PS2 for Keyboard and Mouse //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// VGA //////////
	output		     [7:0]		VGA_B,
	output		          		VGA_BLANK_N,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  VGA setting
//=======================================================
assign VGA_BLANK_N = VGA_HS & VGA_VS;
assign VGA_SYNC_N = 1'b0;

Top top0(

	.i_rst_n(KEY[0]),
	.i_clk(CLOCK_50),
	
	// PS2
   .i_ps2_clk(PS2_CLK),
   .i_ps2_data(PS2_DAT),
   .o_ledg(LEDG), // [8:0]
	.o_ledr(LEDR), // [17:0]
	// VGA
	.o_vga_clk(VGA_CLK),
	.o_hs(VGA_HS),  
   .o_vs(VGA_VS),  
   .o_red(VGA_R),
   .o_green(VGA_G),
   .o_blue(VGA_B)
	
	
	//.i_key_0(key0down),
	//.i_key_1(key1down),
	//.i_key_2(key2down),
	//.i_speed(SW[5:0]), // design how user can decide mode on your own
	
	// AudDSP and SRAM
	//.o_SRAM_ADDR(SRAM_ADDR), // [19:0]
	//.io_SRAM_DQ(SRAM_DQ), // [15:0]
	// .o_SRAM_WE_N(SRAM_WE_N),
	// .o_SRAM_CE_N(SRAM_CE_N),
	// .o_SRAM_OE_N(SRAM_OE_N),
	// .o_SRAM_LB_N(SRAM_LB_N),
	// .o_SRAM_UB_N(SRAM_UB_N),
	
	// I2C
	// .i_clk_100k(CLK_100K),
	// .o_I2C_SCLK(I2C_SCLK),
	// .io_I2C_SDAT(I2C_SDAT),
	
	// AudPlayer
	// .i_AUD_ADCDAT(AUD_ADCDAT),
	// .i_AUD_ADCLRCK(AUD_ADCLRCK),
	// .i_AUD_BCLK(AUD_BCLK),
	// .i_AUD_DACLRCK(AUD_DACLRCK),
	// .o_AUD_DACDAT(AUD_DACDAT),

	// SEVENDECODER (optional display)
	//.o_record_time(recd_time),
	//.o_play_time(play_time),
    //.o_key_state(key_state),
    //.o_key_data(key_data),

	// LCD (optional display)
	// .i_clk_800k(CLK_800K),
	// .o_LCD_DATA(LCD_DATA), // [7:0]
	// .o_LCD_EN(LCD_EN),
	// .o_LCD_RS(LCD_RS),
	// .o_LCD_RW(LCD_RW),
	// .o_LCD_ON(LCD_ON),
	// .o_LCD_BLON(LCD_BLON),

	// LED
	//.o_ledr(LEDR) // [17:0]
);

// SevenHexDecoder seven_dec(
// 	.i_num(play_time),
//  	.o_seven_ten(HEX1),
// 	.o_seven_one(HEX0)
// );

// SevenHexDecoder seven_dec1(
//  	.i_num(recd_time),
//  	.o_seven_ten(HEX5),
//   	.o_seven_one(HEX4)
// );

// comment those are use for display
assign HEX0 = 0;
assign HEX1 = '1;
assign HEX2 = '1;
assign HEX3 = '1;
assign HEX4 = '1;
assign HEX5 = '1;
assign HEX6 = '1;
assign HEX7 = '1;

endmodule
