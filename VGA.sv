// VGA interface 1920x1080@60Hz 148.5MHz
module  VGA(
    input           i_clk,
    input           i_rst_n,
     input    [9:0]  X_pos,
    input    [9:0]  Y_pos,
     input    [9:0]  X_pos_kelly,
    input    [9:0]  Y_pos_kelly,
     output      [3:0]  o_tblf,
     output           o_vga_clk,        // vga_clk
    output          o_hs,           // horizontal sync
    output          o_vs,           // vertical sync
    output   [5:0]  o_red,
    output   [5:0]  o_green,
    output   [5:0]  o_blue
);
    //for 640x480@60Hz 25.175MHz
    parameter C_H_SYNC_PULSE    =   96;
    parameter C_H_BACK_PORCH    =   48;
    parameter C_H_ACTIVE_TIME   =   640;
    parameter C_H_FRONT_PORCH   =   16;
    parameter C_H_LINE_PERIOD   =   800;

    parameter C_V_SYNC_PULSE    =   2;
    parameter C_V_BACK_PORCH    =   33;
    parameter C_V_ACTIVE_TIME   =   480;
    parameter C_V_FRONT_PORCH   =   10;
    parameter C_V_FRAME_PERIOD  =   525;

    parameter C_COLOR_BAR_WIDTH =   80;
     parameter default_x =   0;
     parameter default_y =   0;

    logic   [11:0]  R_h_cnt;    // horizontal counter
    logic   [11:0]  R_v_cnt;    // vertical counter
    logic           R_clk_25M;    
     
    logic           W_active_flag;  // display enable

    logic [9:0] top,top_kelly;
    logic [9:0] bottom,bottom_kelly;
    logic [9:0] left,left_kelly;
    logic [9:0] right,right_kelly;
    parameter C_IMAGE_HEIGHT = 5;
    parameter C_IMAGE_WIDTH = 5;

    assign o_hs = (R_h_cnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1;
    assign o_vs = (R_v_cnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1;
    assign W_active_flag =  ((C_H_SYNC_PULSE + C_H_BACK_PORCH) <= R_h_cnt 
                            <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME)) 
                            &&
                            ((C_V_SYNC_PULSE + C_V_BACK_PORCH) <= R_v_cnt 
                            <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME)); 
                                     
    assign o_vga_clk = R_clk_25M;
     assign o_tblf[3] = R_v_cnt >= top;
     assign o_tblf[2] = R_v_cnt <= bottom;
     assign o_tblf[1] = R_h_cnt >= left;
     assign o_tblf[0] = R_h_cnt <= right;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            R_clk_25M  <=  1'b0;
        end
        else begin
            R_clk_25M  <=  ~R_clk_25M;
        end
    end

    always @(posedge R_clk_25M or negedge i_rst_n) begin
        if (!i_rst_n) begin
            R_h_cnt  <=  12'd0;
        end
          else if (R_h_cnt == C_H_LINE_PERIOD - 1'b1) begin
            R_h_cnt  <=  12'd0;
        end
        else begin
            R_h_cnt  <=  R_h_cnt + 1'b1;
        end
    end

    always @(posedge R_clk_25M or negedge i_rst_n) begin
        if (!i_rst_n) begin
            R_v_cnt  <=  12'd0;
        end
          else if (R_v_cnt == C_V_FRAME_PERIOD - 1'b1) begin
            R_v_cnt  <=  12'd0;
        end
        else if (R_h_cnt == C_H_LINE_PERIOD - 1'b1) begin
            R_v_cnt  <=  R_v_cnt + 1'b1;
        end
        else begin
            R_v_cnt  <=  R_v_cnt;
        end
    end

    /*
    always @(posedge R_clk_25M or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_red   <=  6'b000000;
            o_green <=  6'b000000;
            o_blue  <=  6'b000000;
        end
        else if (W_active_flag) begin
            if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH)) begin
                o_red   <=  6'b111111;
                o_green <=  6'b000000;
                o_blue  <=  6'b000000;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 2)) begin
                o_red   <=  6'b000000;
                o_green <=  6'b111111;
                o_blue  <=  6'b000000;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 3)) begin
                o_red   <=  6'b000000;
                o_green <=  6'b000000;
                o_blue  <=  6'b111111;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 4)) begin
                o_red   <=  6'b111111;
                o_green <=  6'b111111;
                o_blue  <=  6'b111111;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 5)) begin
                o_red   <=  6'b000000;
                o_green <=  6'b000000;
                o_blue  <=  6'b000000;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 6)) begin
                o_red   <=  6'b111111;
                o_green <=  6'b111111;
                o_blue  <=  6'b000000;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_COLOR_BAR_WIDTH * 7)) begin
                o_red   <=  6'b111111;
                o_green <=  6'b000000;
                o_blue  <=  6'b111111;
            end
            else begin
                o_red   <=  6'b000000;
                o_green <=  6'b111111;
                o_blue  <=  6'b111111;
            end
        end
        else begin
            o_red   <=  6'b000000;
            o_green <=  6'b000000;
            o_blue  <=  6'b000000;
        end
    end
    
*/
    always @(posedge R_clk_25M or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_red   <=  6'b000000;
            o_green <=  6'b000000;
            o_blue  <=  6'b000000;
        end
        else if (W_active_flag) begin
            if(R_h_cnt >= left  && R_h_cnt <= right  && R_v_cnt >= top && R_v_cnt <= bottom) begin
                //if(R_v_cnt >= top && R_v_cnt <= bottom) begin
                o_red       <= 6'b111111;
                o_green     <= 6'b111111;
                o_blue      <= 6'b111111;     
            end else if(R_h_cnt >= left_kelly  && R_h_cnt <= right_kelly  && R_v_cnt >= top_kelly && R_v_cnt <= bottom_kelly) begin
                o_red   <=  6'b010101;
                o_green <=  6'b010101;
                o_blue  <=  6'b010101;
                end
            else begin
                o_red   <=  6'b000000;
                o_green <=  6'b000000;
                o_blue  <=  6'b000000;
            end                          
        end
        else begin
            o_red   <=  6'b000000;
            o_green <=  6'b000000;
            o_blue  <=  6'b000000;
        end          
    end

    always @(posedge R_clk_25M or negedge i_rst_n) begin
        if (!i_rst_n) begin
            top     <= C_V_SYNC_PULSE + C_V_BACK_PORCH + default_y;
            bottom  <= C_V_SYNC_PULSE + C_V_BACK_PORCH + default_y + C_IMAGE_HEIGHT - 1'b1;
            left     <= C_H_SYNC_PULSE + C_H_BACK_PORCH + default_x;
            right   <= C_H_SYNC_PULSE + C_H_BACK_PORCH + default_x + C_IMAGE_WIDTH  - 1'b1;
                top_kelly     <= C_V_SYNC_PULSE + C_V_BACK_PORCH + default_y;
            bottom_kelly  <= C_V_SYNC_PULSE + C_V_BACK_PORCH + default_y + C_IMAGE_HEIGHT - 1'b1;
            left_kelly     <= C_H_SYNC_PULSE + C_H_BACK_PORCH + default_x;
            right_kelly   <= C_H_SYNC_PULSE + C_H_BACK_PORCH + default_x + C_IMAGE_WIDTH  - 1'b1;
        end
        else begin
                if (0 < top < C_V_ACTIVE_TIME && 0 < bottom < C_V_ACTIVE_TIME) begin
                    top     <= C_V_SYNC_PULSE + C_V_BACK_PORCH + Y_pos + default_y;
                    bottom  <= C_V_SYNC_PULSE + C_V_BACK_PORCH + Y_pos + default_y + C_IMAGE_HEIGHT - 1'b1;
                end
                else begin
                    top         <= top;
                    bottom   <= bottom;
                end
                if (0 < top < C_H_ACTIVE_TIME && 0 < bottom < C_H_ACTIVE_TIME) begin
                    left     <= C_H_SYNC_PULSE + C_H_BACK_PORCH + X_pos + default_x;
                    right   <= C_H_SYNC_PULSE + C_H_BACK_PORCH + X_pos + default_x + C_IMAGE_WIDTH  - 1'b1;
                end
                else begin
                    left    <= left;
                    right   <= right;
                end
                if (0 < top_kelly < C_V_ACTIVE_TIME && 0 < bottom_kelly < C_V_ACTIVE_TIME) begin
                    top_kelly     <= C_V_SYNC_PULSE + C_V_BACK_PORCH + Y_pos_kelly + default_y;
                    bottom_kelly  <= C_V_SYNC_PULSE + C_V_BACK_PORCH + Y_pos_kelly + default_y + C_IMAGE_HEIGHT - 1'b1;
                end
                else begin
                    top_kelly       <= top_kelly;
                    bottom_kelly   <= bottom_kelly;
                end
                if (0 < top_kelly < C_H_ACTIVE_TIME && 0 < bottom_kelly < C_H_ACTIVE_TIME) begin
                    left_kelly     <= C_H_SYNC_PULSE + C_H_BACK_PORCH + X_pos_kelly + default_x;
                    right_kelly   <= C_H_SYNC_PULSE + C_H_BACK_PORCH + X_pos_kelly + default_x + C_IMAGE_WIDTH  - 1'b1;
                end
                else begin
                    left_kelly    <= left_kelly;
                    right_kelly   <= right_kelly;
                end
        end
    end
    
endmodule