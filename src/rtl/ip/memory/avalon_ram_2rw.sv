// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/04/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM ram 2rw
// ------------------------------------------------------------------------------------------------

module avalon_ram_2rw #(
    parameter AW = 10,
    parameter DW = 32
) (
    input               clk,

    // port 1
    input               p1_read,
    input               p1_write,
    input [AW-1:0]      p1_address,        // this is the word size
    input [DW/8-1:0]    p1_byte_enable,
    input [DW-1:0]      p1_writedata,
    output reg [DW-1:0] p1_readdata,
    output              p1_waitrequest,
    // port 2
    input               p2_read,
    input               p2_write,
    input [AW-1:0]      p2_address,        // this is the word size
    input [DW/8-1:0]    p2_byte_enable,
    input [DW-1:0]      p2_writedata,
    output reg [DW-1:0] p2_readdata,
    output              p2_waitrequest
);

    localparam BYTE_WIDTH = 8;
    localparam NUM_BYTES = DW / BYTE_WIDTH;

`ifdef QUARTUS_RAM


 `else

    reg [DW-1:0] ram[0:(1<<AW)-1];

    always @(posedge clk) begin
        if(p1_write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(p1_byte_enable[i]) ram[p1_address][i*BYTE_WIDTH +: BYTE_WIDTH] <= p1_writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        if (p1_read) p1_readdata <= ram[p1_address];
    end

    always @(posedge clk) begin
        if(p2_write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(p2_byte_enable[i]) ram[p2_address][i*BYTE_WIDTH +: BYTE_WIDTH] <= p2_writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        if (p2_read) p2_readdata <= ram[p2_address];
    end

`endif

endmodule
