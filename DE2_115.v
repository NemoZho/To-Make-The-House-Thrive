module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

wire    [31:0]  rs232_data;
wire	[15:0]	Read_DATA1;
wire	[15:0]	Read_DATA2;

wire  [19:0]   sraM_ADDR;
wire	[11:0]	rs232_R;
wire	[11:0]	rs232_G;
wire	[11:0]	rs232_B;

reg         sram_clk;
wire            write_en;
reg            write;
wire			Read; // VGA read enable

wire			sdram_ctrl_clk;
wire	[9:0]	oVGA_R;   				//	VGA Red[9:0]
wire	[9:0]	oVGA_G;	 				//	VGA Green[9:0]
wire	[9:0]	oVGA_B;   				//	VGA Blue[9:0]

wire			DLY_RST_0;
wire			DLY_RST_1;
wire			DLY_RST_2;
wire			DLY_RST_3;
wire			DLY_RST_4;

wire NOUSE_CLK1;
wire NOUSE_CLK2;

reg [31:0] count_pix;
reg [1:0] counter_w, counter_r;
reg [11:0] R,G,B;
reg [19:0] sram_clk_counter;

assign  rs232_R = R;
assign  rs232_G = G;
assign  rs232_B = B;
assign  SRAM_WE_N = 1;


assign  VGA_CTRL_CLK = ~VGA_CLK;
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

always@(posedge write_en) 
begin
	count_pix <= count_pix + 1;
	case (count_pix % 3)
		0:begin
			write <= 0;
			B <= {rs232_data[7:0],2'b00};
		end
		
		1:begin
			write <= 0;
			G <= {rs232_data[7:0],2'b00};
		end
		
		2:begin
			write <= 1;
			R <= {rs232_data[7:0],2'b00};
		end
	endcase
	
end


//Reset module
Reset_Delay			u4	(	.iCLK(CLOCK2_50),
								.iRST(KEY[0]),
								.oRST_0(DLY_RST_0),
								.oRST_1(DLY_RST_1),
								.oRST_2(DLY_RST_2),
								.oRST_3(DLY_RST_3),
								.oRST_4(DLY_RST_4)
							);

sdram_pll 			u1	(
								.inclk0(CLOCK2_50),
								.c0(sdram_ctrl_clk),
								.c1(DRAM_CLK),
								.c2(NOUSE_CLK1), //25M
								.c3(VGA_CLK),     //25M 
								.c4(NOUSE_CLK2)     //125M 	

							);

//SDRam Read and Write as Frame Buffer
SDRAM_Control	u2	(	//	HOST Side						
						    .RESET_N(KEY[0]),
							.CLK(sdram_ctrl_clk),

							//	FIFO Write Side 1
							//.WR1_DATA(16'b0111110000000000),
							.WR1_DATA({1'b0, rs232_G[9:5], rs232_B[9:0]}),
							.WR1(write && write_en),
							.WR1_ADDR(0),
							.WR1_MAX_ADDR(640*480/2),
							.WR1_LENGTH(8'h50),
							.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(NOUSE_CLK1),

							//	FIFO Write Side 2
							//.WR2_DATA(16'b0111110000000000),
							.WR2_DATA({1'b0, rs232_G[4:0], rs232_R[9:0]}),
							.WR2(write && write_en),
							.WR2_ADDR(23'h100000),
							.WR2_MAX_ADDR(23'h100000+640*480/2),
							.WR2_LENGTH(8'h50),
							.WR2_LOAD(!DLY_RST_0),
							.WR2_CLK(NOUSE_CLK1),
				
							//	FIFO Read Side 1
						   .RD1_DATA(Read_DATA1),
				        	.RD1(Read),
				        	.RD1_ADDR(0),
						   .RD1_MAX_ADDR(640*480/2),
							.RD1_LENGTH(8'h50),
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							
							//	FIFO Read Side 2
						   .RD2_DATA(Read_DATA2),
							.RD2(Read),
							.RD2_ADDR(23'h100000),
						   .RD2_MAX_ADDR(23'h100000+640*480/2),
							.RD2_LENGTH(8'h50),
				        	.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~VGA_CTRL_CLK),
							
							//	SDRAM Side
						   .SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM(DRAM_DQM)
						);

//VGA DISPLAY
VGA_Controller		u3	(	//	Host Side
							.oRequest(Read),
							.iRed(Read_DATA2[9:0]),
							.iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
							.iBlue(Read_DATA1[9:0]),
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(SW[16])
						);
SEG7_LUT_8 			u5	(	
							.oSEG0(HEX0),
							.oSEG1(HEX1),
							.oSEG2(HEX2),
							.oSEG3(HEX3),
							.oSEG4(HEX4),
							.oSEG5(HEX5),
							.oSEG6(HEX6),
							.oSEG7(HEX7),
							.iDIG(count_pix)//Frame_Cont
						);

rs232_qsys my_qsys(
							.clk_clk(CLOCK2_50),
							.reset_reset_n(KEY[0]),
							.uart_0_external_connection_rxd(UART_RXD),
							.uart_0_external_connection_txd(UART_TXD),
							.data(rs232_data),
							.write(write_en)
);

/*sram_controller sramcontroller(
	.clk(sram_clk),
	.rst_n(KEY[0]),
	.addr(sraM_ADDR),
	.sdram_data(SRAM_DQ),
	.rgb_data(rs232_data),
	.writeen(write_en)
);*/

endmodule
