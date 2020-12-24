module rs232 (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_GET_DATA = 0;
localparam S_SEND_DATA = 1;

reg [7:0] data_rd_r, data_rd_w;
reg      state_r, state_w;
reg [4:0] avm_address_r, avm_address_w;
reg avm_read_r, avm_read_w, avm_write_r, avm_write_w;


assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = data_rd_r[7:0];

always @(*) begin
    case(state_r)

    S_GET_DATA: begin
        avm_read_w = 1 ;
        avm_write_w = 0;
        if (!avm_waitrequest) begin 
        //read request
            if (avm_readdata[RX_OK_BIT] == 1'b1 && avm_address_r==STATUS_BASE) begin
                data_rd_w = data_rd_r;
                state_w = state_r;
                avm_address_w = RX_BASE;
            end
            else if (avm_address_r==RX_BASE) begin 
            //read data(a)
                data_rd_w = avm_readdata[7:0];
                state_w = S_SEND_DATA;
                avm_address_w = STATUS_BASE;
            end
            else begin
                data_rd_w = data_rd_r;
                state_w = state_r;
                avm_address_w = avm_address_r;
            end
        end
        else begin
            data_rd_w = data_rd_r;
            state_w = state_r ;
            avm_address_w = avm_address_r ;    
        end
    end

    S_SEND_DATA: begin
        data_rd_w = data_rd_r;
        avm_read_w = 1 ;
        avm_write_w = 0;
        if (!avm_waitrequest) begin 
        //read request to write request
            if (avm_readdata[TX_OK_BIT] == 1'b1 && avm_address_r==STATUS_BASE) begin
                state_w = state_r;
                avm_address_w = TX_BASE;
                avm_write_w = 1;
                avm_read_w = 0;
            end
            else if (avm_address_r==TX_BASE) begin 
            //send data
                state_w = S_GET_DATA;
                avm_address_w = STATUS_BASE;
                avm_read_w = 1;
                avm_write_w = 0;
            end
            else begin
                state_w = state_r;
                avm_read_w = avm_read_r;
                avm_write_w = avm_write_r;
                avm_address_w = avm_address_r;
            end
        end
        else begin
            state_w = state_r ;
            avm_read_w = avm_read_r;
            avm_write_w = avm_write_r;
            avm_address_w = avm_address_r ;    
        end
    end

    endcase
end

always @(posedge avm_clk or negedge avm_rst) begin
    if (!avm_rst) begin
        data_rd_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_GET_DATA;
    end 
    else begin
        data_rd_r <= data_rd_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
    end
end

endmodule
