// PS2 Keyboard interface
module Keyboard(
    input           clk,
    input           rst_n,
    input           ps2_clk,
    input           ps2_data,
    output          break_code,
    output          long_code,
    output          key_state,
    output  [7:0]   key_ascii,
	 output	[9:0]	  key_value
);

    logic ps2_clk_0, ps2_clk_1, ps2_clk_2, ps2_clk_3;
    logic negedge_ps2_clk, negedge_ps2_clk_shift;
    logic [3:0] counter_11;
    logic [7:0] ascii_tmp;
    logic [9:0] value;
    logic flag;
 
    //assign negedge_ps2_clk = !ps2_clk_0 && !ps2_clk_1 && ps2_clk_2 && ps2_clk_3;
    assign negedge_ps2_clk = !ps2_clk_0 && ps2_clk_1 ;
    //assign key_ascii = flag ? ascii_tmp : key_ascii;
	 assign key_ascii = flag ? ascii_tmp : key_ascii;
	 assign key_value = value;
    assign key_state = flag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ps2_clk_0 <= 1'b0;
            ps2_clk_1 <= 1'b0;
            //ps2_clk_2 <= 1'b0;
            //ps2_clk_3 <= 1'b0;
        end
        else begin                                                                            
            ps2_clk_0 <= ps2_clk;
            ps2_clk_1 <= ps2_clk_0;
            //ps2_clk_2 <= ps2_clk_1;
            //ps2_clk_3 <= ps2_clk_2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_11 <= 4'd0;
        end 
		  else if ( counter_11 == 4'd11) begin
			counter_11 <= 4'd0;
        end
        else if (negedge_ps2_clk) begin
            counter_11 <= counter_11 + 1'b1;
        end
    end

    always @(posedge clk) begin
        negedge_ps2_clk_shift <= negedge_ps2_clk;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ascii_tmp <= 8'd0;
        end
        else if (negedge_ps2_clk_shift) begin
            if (4'd1 < counter_11 < 4'd10) begin
                ascii_tmp[counter_11 - 4'd2] <= ps2_data;
            end
            else begin
                ascii_tmp <= ascii_tmp;
            end
        end
        else begin
            ascii_tmp <= ascii_tmp;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value <= 10'b0;
            break_code <= 1'b0;
            long_code <= 1'b0;
            flag <= 1'b0;
        end
        else if (counter_11 == 4'd11) begin
            if (ascii_tmp == 8'hE0) begin
                long_code <= 1'b1;
            end
            else if (ascii_tmp == 8'hF0) begin
                break_code <= 1'b1;
            end
            else begin
                value <= {break_code, long_code, ascii_tmp};
                break_code <= 1'b0;
                long_code <= 1'b0;
                flag <= 1'b1;
            end
        end
        else begin
            value <= value;
            break_code <= break_code;
            long_code <= long_code;
            flag <= 1'b0;
        end
    end
endmodule