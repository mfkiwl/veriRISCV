// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM ram 1rw
// ------------------------------------------------------------------------------------------------

module avalon_ram_1rw #(
    parameter AW = 10,
    parameter DW = 32   // only support DW = 32 for now
) (
    input               clk,
    input               read,           // not used
    input               write,
    input [AW-1:0]      address,        // this is the word size
    input [DW/8-1:0]    byte_enable,
    input [DW-1:0]      writedata,
    output reg [DW-1:0] readdata,
    output              waitrequest
);

    localparam DEPTH = 2 ** AW;
    localparam BYTE_WIDTH = 8;
    localparam NUM_BYTES = DW / BYTE_WIDTH;

    assign waitrequest = 1'b0;

`ifdef COCOTB_SIM

    reg [DW-1:0] ram[DEPTH-1:0];

    always @(posedge clk) begin
        if(write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(byte_enable[i]) ram[address][i*BYTE_WIDTH +: BYTE_WIDTH] <= writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        readdata <= ram[address];
    end

`else

    reg [NUM_BYTES-1:0][BYTE_WIDTH-1:0] ram[DEPTH-1:0];

    always @(posedge clk) begin
        if(write) begin
            if(byte_enable[0]) ram[address][0] <= writedata[7:0];
            if(byte_enable[1]) ram[address][1] <= writedata[15:8];
            if(byte_enable[2]) ram[address][2] <= writedata[23:16];
            if(byte_enable[3]) ram[address][3] <= writedata[31:24];
        end
        readdata <= ram[address];
    end

`endif

endmodule
