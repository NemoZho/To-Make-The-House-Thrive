module flash_control(
	 input           clk,
    input           rst_n,
	 output	[31:0]  flash_address
);

logic [31:0] f_addr;
logic [10:0] counter;
assign flash_address = f_addr;

always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            f_addr <= 1'b0;
				counter <= 0;
        end
		  else if (f_addr == 125*250 -1) begin
				f_addr <= 1'b0;
		  end
        else if(counter == 2047) begin                                                                            
				f_addr <= f_addr + 1;
				counter <= 0; 
        end
		  else begin
		      counter <= counter + 1;
		  end
    end
endmodule
