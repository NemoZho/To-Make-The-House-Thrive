module kelly (
	input clk,	
	input rst_n,
	output [9:0]  X_pos, Y_pos,
	output [2:0] state,
	input [9:0]	  keycode
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

	parameter GROUND_LEVEL = 10'd400;
	parameter GRAVITY = 4;
	parameter SPEED = 6;
	parameter JUMPSPEED = 24;
	parameter IDLE 	= 3'b000;
	parameter RIGHT 	= 3'b001;
	parameter LEFT 	= 3'b010;
	parameter JUMP 	= 3'b011;
	parameter DOWN 	= 3'b100;
	parameter L_JUMP 	= 3'b101;
	parameter R_JUMP 	= 3'b110;
	parameter KEY_UP 			   = 10'b0000011101;
	parameter KEY_DOWN 			= 10'b0000011011;
	parameter KEY_LEFT 			= 10'b0000011100;
	parameter KEY_RIGHT 		   = 10'b0000100011;
	parameter KEY_UP_BREAK 		= 10'b1000011101;
	parameter KEY_DOWN_BREAK 	= 10'b1000011011;
	parameter KEY_LEFT_BREAK 	= 10'b1000011100;
	parameter KEY_RIGHT_BREAK 	= 10'b1000100011;
	logic [9:0] vertic_speed_w,vertic_speed_r;
	logic [9:0] posx_w,posy_w,posx_r,posy_r;
	logic [2:0] state_w,state_r; 
	logic on_the_ground_w,on_the_ground_r,attacking_w,attacking_r,jumped_w,jumped_r,rightjumpfix_w,rightjumpfix_r,leftjumpfix_w,leftjumpfix_r;
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
				if (posy_r >= GROUND_LEVEL && jumped_r == 1) begin

					state_w = IDLE;
				end
			end
			DOWN:begin
				if (keycode == KEY_DOWN_BREAK) begin
					state_w = IDLE;
				end
			end
			RIGHT:begin
				if (keycode == KEY_UP) begin
					state_w = R_JUMP;
				end else if(keycode == KEY_RIGHT_BREAK) begin
					state_w = IDLE;
				end
			end
			LEFT:begin
				if (keycode == KEY_UP) begin
					state_w = L_JUMP;
				end else if(keycode == KEY_LEFT_BREAK) begin
					state_w = IDLE;
				end
			end
			R_JUMP:begin
				if (posy_r >= GROUND_LEVEL && jumped_r == 1 && rightjumpfix_r == 1) begin
					state_w = IDLE;
				end else if (posy_r >= GROUND_LEVEL && jumped_r == 1 && rightjumpfix_r == 0)begin
					state_w = RIGHT;
				end
			end
			L_JUMP:begin
				if (posy_r >= GROUND_LEVEL && jumped_r == 1 && leftjumpfix_r == 1) begin
					state_w = IDLE;
				end else if (posy_r >= GROUND_LEVEL && jumped_r == 1 && leftjumpfix_r == 0)begin
					state_w = LEFT;
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
			vertic_speed_w <= vertic_speed_r;
			jumped_w <= jumped_r;
			rightjumpfix_w <= rightjumpfix_r;
			leftjumpfix_w <= leftjumpfix_r;
			case(state_r)
				IDLE:begin
					posy_w <= GROUND_LEVEL;
					posx_w <= posx_r;
					vertic_speed_w <= JUMPSPEED;
					jumped_w <= 0;
				end
				JUMP:begin
					posy_w <= ((posy_r - vertic_speed_r) >= GROUND_LEVEL) ? GROUND_LEVEL : posy_r - vertic_speed_r;
					vertic_speed_w <= vertic_speed_w - GRAVITY;
					if(posy_r == GROUND_LEVEL)begin
						jumped_w <= 1;
					end
				end
				DOWN:begin
					posy_w <= posy_r - SPEED;
				end
				RIGHT:begin
					rightjumpfix_w <= 0;
					vertic_speed_w <= JUMPSPEED;
					posx_w <= posx_r + SPEED;
				end
				LEFT:begin
					leftjumpfix_w <= 0;
					vertic_speed_w <= JUMPSPEED;
					posx_w <= posx_r - SPEED;
				end
				R_JUMP:begin
					if (keycode == KEY_RIGHT_BREAK) begin
						rightjumpfix_w <= 1;
					end
					posx_w <= posx_r + SPEED;
					posy_w <= ((posy_r - vertic_speed_r) >= GROUND_LEVEL) ? GROUND_LEVEL : posy_r - vertic_speed_r;
					vertic_speed_w <= vertic_speed_w - GRAVITY;
					if(posy_r == GROUND_LEVEL)begin
						jumped_w <= 1;
					end
				end
				L_JUMP:begin
					if (keycode == KEY_LEFT_BREAK) begin
						leftjumpfix_w <= 1;
					end
					posx_w <= posx_r - SPEED;
					posy_w <= ((posy_r - vertic_speed_r) >= GROUND_LEVEL) ? GROUND_LEVEL : posy_r - vertic_speed_r;
					vertic_speed_w <= vertic_speed_w - GRAVITY;
					if(posy_r == GROUND_LEVEL)begin
						jumped_w <= 1;
					end
				end
			endcase
		end
	end


	always_ff @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			posy_r <= GROUND_LEVEL;
			posx_r <= 10'd300;
			state_r <= IDLE;
			jumped_r <= 0;
			rightjumpfix_r <= 0;
			leftjumpfix_r <= 0;
		end else begin
			vertic_speed_r <= vertic_speed_w;
			state_r <= state_w;
			posy_r <= posy_w;
			posx_r <= posx_w;
			jumped_r <= jumped_w;
			rightjumpfix_r <= rightjumpfix_w;
			leftjumpfix_r <= leftjumpfix_w;
		end
	end
endmodule