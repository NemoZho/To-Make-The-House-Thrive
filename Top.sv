module Top (
    input           i_clk,
    input           i_rst_n,
    inout           i_ps2_clk,
    inout  [7:0]    i_ps2_data,
    output [8:0]    o_ledg,
    output [17:0]   o_ledr,
    output              o_vga_clk,
    output              o_hs,  
    output              o_vs,  
    output  [7:0]       o_red,
    output  [7:0]       o_green,
    output  [7:0]       o_blue
);
    logic break_code, long_code, key_state;
    logic [7:0] key_ascii;
     logic [9:0] key_value;
     logic [9:0] X_pos;
     logic [9:0] Y_pos;
     logic [2:0] nemostate;
     logic [3:0] o_tblf;
    assign o_ledg[7:0] = key_ascii;
     assign o_ledr[17:9] = Y_pos;
     assign o_ledr[8:0] = nemostate;

Keyboard kb0(
    .clk(i_clk),
    .rst_n(i_rst_n),
    .ps2_clk(i_ps2_clk),
    .ps2_data(i_ps2_data),
    .break_code(break_code),
    .long_code(long_code),
    .key_state(key_state),
    .key_ascii(key_ascii),
     .key_value(key_value),
);

VGA vga0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .X_pos(X_pos),
    .Y_pos(Y_pos),
     .o_tblf(o_tblf),
    .o_vga_clk(o_vga_clk),
    .o_hs(o_hs),  
    .o_vs(o_vs),  
    .o_red(o_red),
    .o_green(o_green),
    .o_blue(o_blue)
);

nemo nmsl(
    .clk(i_clk),
   .rst_n(i_rst_n),
    .X_pos(X_pos),
   .Y_pos(Y_pos),
    .state(nemostate),
    .keycode(key_ascii)
);


endmodule