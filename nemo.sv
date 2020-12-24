module nemo (
	input clk,	
	input rst_n,
	output [9:0]  X_pos, Y_pos,
	output [4:0] state,
	input [9:0]	  keycode,
	output [4:0]  gesture,
	output [7:0]  health
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

	parameter GROUND_LEVEL = 10'd230;
	parameter GRAVITY = 5;
	parameter SPEED = 12;
	parameter JUMPSPEED = 45;

	parameter IDLE 	   = 5'b00000;
	parameter RIGHT    = 5'b00001;
	parameter LEFT 	   = 5'b00010;
	parameter JUMP 	   = 5'b00011;
	parameter DOWN 	   = 5'b00100;
	parameter L_JUMP   = 5'b00101;
	parameter R_JUMP   = 5'b00110;
	parameter PUNCH    = 5'b00111;
	parameter DEFENCE  = 5'b01000;
	parameter FIREBALL = 5'b01001;
	parameter KICK     = 5'b01010;

	parameter KEY_UP 				= 10'b0101110101;
	parameter KEY_DOWN 			= 10'b0101110010;
	parameter KEY_LEFT 			= 10'b0101101011;
	parameter KEY_RIGHT 		   = 10'b0101110100;
	parameter KEY_UP_BREAK 		= 10'b1101110101;
	parameter KEY_DOWN_BREAK 	= 10'b1101110010;
	parameter KEY_LEFT_BREAK 	= 10'b1101101011;
	parameter KEY_LEFT_FIX     = 10'b0001101011;
	parameter KEY_RIGHT_BREAK 	= 10'b1101110100;
	parameter KEY_1 				= 10'b0001101001;
	parameter KEY_2 				= 10'b0001110010;
	parameter KEY_3 				= 10'b0001111010;
	parameter KEY_4 				= 10'b0001101011;
	parameter KEY_5 				= 10'b0001110011;
	parameter KEY_6 				= 10'b0001110100;
	
	
	logic [9:0] vertic_speed_w,vertic_speed_r;
	logic [4:0] o_gesture;
	logic [7:0] o_health;
	logic [9:0] posx_w,posy_w,posx_r,posy_r;
	logic [4:0] state_w,state_r; 
	logic on_the_ground_w,on_the_ground_r,attacking_w,attacking_r,jumped_w,jumped_r,rightjumpfix_w,rightjumpfix_r,leftjumpfix_w,leftjumpfix_r;
	assign X_pos = posx_r;
	assign Y_pos = posy_r;
	assign state = state_w;

	logic [4:0] punch_counter;//0.5sec
	logic [4:0] defence_counter;//0.5sec
	logic [5:0] kick_counter;//1.0sec
	logic [6:0] down_counter;//2.0sec 
	logic [5:0] defence_cooldown;//1.0sec
	assign gesture = o_gesture;
	
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
					KEY_RIGHT:begin
						state_w = RIGHT;
					end
					KEY_LEFT:begin
						state_w = LEFT;
					end
					KEY_1:begin
						state_w = PUNCH;
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
				end else if(keycode == KEY_RIGHT_BREAK || keycode == KEY_LEFT || keycode == KEY_UP || keycode == KEY_LEFT_FIX) begin
					state_w = IDLE;
				end else if(keycode == KEY_1)begin
					state_w = PUNCH;
				end
			end
			LEFT:begin
				if (keycode == KEY_UP) begin
					state_w = L_JUMP;
				end else if(keycode == KEY_LEFT_BREAK || keycode == KEY_RIGHT || keycode == KEY_UP || keycode == KEY_LEFT_FIX) begin
					state_w = IDLE;
				end else if(keycode == KEY_1)begin
					state_w = PUNCH;
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
			PUNCH:begin
				if (punch_counter > 6) begin
					state_w = IDLE;
				end
			end
			DEFENCE:begin
				
			end
			FIREBALL:begin
				
			end
			KICK:begin
				
			end
		endcase
	end

	always_ff @(posedge clk_50hz or negedge rst_n)begin
		if(!rst_n) begin
			punch_counter <= 0;
			defence_counter <= 0;
			kick_counter <= 0;
			down_counter <= 0;
			defence_cooldown <= 0;
			//fireball_counter <= 0;
		end else begin
			case(state_r)
				IDLE:begin
					punch_counter <= 0;
					defence_counter <= 0;
					kick_counter <= 0;
					down_counter <= 0;
					defence_cooldown <= 0;
					o_gesture <= 0;
				end
				PUNCH:begin
					punch_counter <= punch_counter + 1;
					if(punch_counter < 3)begin
						o_gesture <= 1;
					end else begin
						o_gesture <= 2;
					end
				end
				KICK:begin
					kick_counter <= kick_counter + 1;
				end
				DEFENCE:begin
					defence_counter <= defence_counter + 1;
				end
				DOWN:begin
					down_counter <= down_counter + 1;
				end
			endcase
		end
	end

	//以50hz處理位置+速度
	always_ff @(posedge clk_50hz or negedge rst_n)begin
		if(!rst_n) begin
			posx_w <= 10'd0;
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