module POS_FLASH(
    input       i_clk,
    input       i_rst_n,
    input       [9:0]   p1_x,
    input       [9:0]   p1_y,
    input       [9:0]   p2_x,
    input       [9:0]   p2_y,
    input       [12:0]  h_cnt,
    input       [12:0]  v_cnt,
    input       [7:0]   flash_data,
    input       [15:0]  sdram_data_1,
    input       [15:0]  sdram_data_2,
    input       [4:0]   gesture,
	 input       [7:0]   health,
    output      [9:0]   o_red,
    output      [9:0]   o_green,
    output      [9:0]   o_blue,
    output      [22:0]  flash_address
);

parameter height        = 250;
parameter green_bg      = 8'b00011100;

parameter h_max        	= 637;

parameter blood_w_start			= 18;
parameter blood_h_start			= 30;
parameter blood_h_length		= 19;

parameter gusture0 = 0;
parameter gusture1 = 1;
parameter gusture2 = 2;
parameter gusture3 = 3;
parameter gusture4 = 4;
parameter gusture5 = 5;
parameter gusture6 = 6;
parameter gusture7 = 7;
parameter gusture8 = 8;
parameter gusture9 = 9;
parameter gusture10 = 10;

parameter base0 	= 0;
parameter base1 	= base0 + 125*250;
parameter base2 	= base1 + 150*250;
parameter base3 	= base2;
parameter base4 	= base3;
parameter base5 	= base4;
parameter base6 	= base5;
parameter base7 	= base6;
parameter base8 	= base7;
parameter base9 	= base8;
parameter base10 	= base9;

logic [9:0] red, green, blue;
logic [22:0] fl_add, base;
logic p1_en, p2_en;
logic	[7:0] width;
logic blood_1_en, blood_2_en;

assign o_red 		= red;
assign o_green 	= green;
assign o_blue 		= blue;
assign p1_en 		= p1_x < h_cnt && h_cnt < width + p1_x && p1_y < v_cnt && v_cnt < height + p1_y;
assign p2_en 		= p2_x < h_cnt && h_cnt < width + p2_x && p2_y < v_cnt && v_cnt < height + p2_y;
assign blood_1_en = blood_w_start < h_cnt && h_cnt < blood_w_start + health && blood_h_start < v_cnt && v_cnt < blood_h_start + blood_h_length;
assign blood_2_en = h_max - blood_w_start - health < h_cnt && h_cnt < h_max - blood_w_start && blood_h_start < v_cnt && v_cnt < blood_h_start + blood_h_length;

assign flash_address = fl_add + base;

always@(*) begin
    case (gesture)
		  gusture0: begin
            base = base0;
				width = 125;
        end
        gusture1: begin
            base = base1;
				width = 150;
        end
        gusture2: begin
            base = base2;
				width = 200;
        end
        gusture3: begin
            base = base3;
        end
        gusture4: begin
            base = base4;
        end
        gusture5: begin
            base = base5;
        end
		  gusture6: begin
            base = base6;
        end
        gusture7: begin
            base = base7;
        end
        gusture8: begin
            base = base8;
        end
        gusture9: begin
            base = base9;
        end
        gusture10: begin
            base = base10;
        end
    endcase
	 if (!blood_1_en && !blood_2_en) begin
		 if (p1_en) begin  
			  fl_add  <= (h_cnt - p1_x) + (v_cnt - p1_y) * width;
			  if (flash_data == green_bg) begin
					red     <= sdram_data_2[9:0];
					green   <= {sdram_data_1[14:10],sdram_data_2[14:10]};
					blue    <= sdram_data_1[9:0];
			  end
			  else begin
					red     <= {flash_data[7:5],7'b1};
					green   <= {flash_data[4:2],7'b1};
					blue    <= {flash_data[1:0],8'b1};
			  end
		 end
		 else if (p2_en) begin
			  fl_add  <= (h_cnt - p2_x) + (v_cnt - p2_y) * width;
			  if (flash_data == green_bg) begin
					red     <= sdram_data_2[9:0];
					green   <= {sdram_data_1[14:10],sdram_data_2[14:10]};
					blue    <= sdram_data_1[9:0];
			  end
			  else begin
					red     <= {flash_data[7:5],7'b1};
					green   <= {flash_data[4:2],7'b1};
					blue    <= {flash_data[1:0],8'b1};
			  end
		 end
		 else begin
			  fl_add  <= 0;
			  red     <= sdram_data_2[9:0];
			  green   <= {sdram_data_1[14:10],sdram_data_2[14:10]};
			  blue    <= sdram_data_1[9:0];
		 end
	end
	else begin
		fl_add  <= 0;
		red     <= 10'b1111111111;
		green   <= 10'b1111111111;
		blue    <= 10'b1111111111;
	end
end

endmodule