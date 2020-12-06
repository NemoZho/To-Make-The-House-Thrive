module nemo (
	input clk,	
	input rst_n,
	output [9:0]  X_pos, Y_pos,
	output [2:0] state,
	input [7:0]	  keycode
);

	logic clk_50hz;
	logic [21:0] clk_50hz_counter;
	//generate 50hz singnal 
	always_ff @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			clk_50hz_counter <= 0;
			clk_50hz <= 0;
		end else begin
			clk_50hz_counter = clk_50hz_counter + 1;
			if (clk_50hz_counter > 1000000) begin
				clk_50hz <= ~clk_50hz;
				clk_50hz_counter <= 0;
			end
		end
	end	

	parameter GROUND_LEVEL = 10'd300;
	parameter GRAVITY = 2;
	parameter SPEED = 4;
	parameter IDLE = 3'b000;
	parameter RIGHT = 3'b001;
	parameter LEFT = 3'b010;
	parameter JUMP = 3'b011;
	parameter DOWN = 3'b100;
	parameter KEY_UP = 8'b01110101;
	parameter KEY_DOWN = 8'b01110010;
	parameter KEY_LEFT = 8'b01101011;
	parameter KEY_RIGHT = 8'b01110100;
	logic [9:0] vertic_speed_w,vertic_speed_r;
	logic [9:0] posx_w,posy_w,posx_r,posy_r;
	logic [2:0] state_w,state_r; 
	logic on_the_ground_w,on_the_ground_r,attacking_w,attacking_r;
	assign X_pos = posx_r;
	assign Y_pos = posy_r;
	assign state = state_w;

	//單純處理state	
	always_comb begin
		state_w = state_r;
		case(state_r)
			IDLE:begin
				state_w = state_r;
				case(keycode)
					KEY_UP:begin
						state_w = JUMP;
					end
					KEY_DOWN:begin
						state_w = DOWN;
					end
					KEY_RIGHT:begin
						state_w = RIGHT;
					end
					KEY_LEFT:begin
						state_w = LEFT;
					end
				endcase
			end
			JUMP:begin
				if (posy_r >= GROUND_LEVEL) begin
					state_w = IDLE;
				end
			end
			DOWN:begin
				if (keycode != KEY_DOWN) begin
					state_w = IDLE;
				end
			end
			RIGHT:begin
				if (keycode != KEY_RIGHT) begin
					state_w = IDLE;
				end
			end
			LEFT:begin
				if (keycode != KEY_LEFT) begin
					state_w = IDLE;
				end
			end
		endcase
	end



	//以50hz處理位置+速度
	always_ff @(posedge clk_50hz or negedge rst_n)begin
		if(!rst_n) begin
			posx_w <= 10'd300;
			posy_w <= GROUND_LEVEL;
		end else begin
			posy_w <= posy_r;
			posx_w <= posx_r;
			vertic_speed_w = vertic_speed_r;
			case(state_r)
				IDLE:begin
					posy_w <= GROUND_LEVEL;
					posx_w <= posx_r;
					vertic_speed_w <= 15;
				end
				JUMP:begin
					posy_w <= ((posy_r - vertic_speed_r) >= GROUND_LEVEL) ? GROUND_LEVEL : posy_r - vertic_speed_r;
					vertic_speed_w <= vertic_speed_w - GRAVITY;
				end
				DOWN:begin
					posy_w <= posy_r - SPEED;
				end
				RIGHT:begin
					posx_w <= posx_r + SPEED;
				end
				LEFT:begin
					posx_w <= posx_r - SPEED;
				end
			endcase
		end
	end


	always_ff @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			posy_r <= GROUND_LEVEL;
			posx_r <= 10'd300;
			state_r <= IDLE;
		end else begin
			vertic_speed_r <= vertic_speed_w;
			state_r <= state_w;
			posy_r <= posy_w;
			posx_r <= posx_w;
		end
	end
endmodule