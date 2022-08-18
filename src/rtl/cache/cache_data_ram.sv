// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Memory for cache data
// ------------------------------------------------------------------------------------------------

/**

Cache data ram is a 2 rw ports memory.

! The read latency is 1.

*/

module cache_data_ram #(
    parameter AW = 10,
    parameter DW = 32
) (
    input               clk,
    // port 1
    input               core_write,
    input [AW-1:0]      core_address,        // this is the word size
    input [DW/8-1:0]    core_byte_enable,
    input [DW-1:0]      core_writedata,
    output logic [DW-1:0] core_readdata,
    // port 2
    input               fill_write,
    input [AW-1:0]      fill_address,        // this is the word size
    input [DW/8-1:0]    fill_byte_enable,
    input [DW-1:0]      fill_writedata
);

    localparam RAM_DEPTH    = 2 ** AW;
    localparam BYTE_WIDTH   = 8;
    localparam NUM_BYTES    = DW / BYTE_WIDTH;

`ifndef XILINX

    reg [DW-1:0] ram[0:(1<<AW)-1];

    logic [DW-1:0] fill_readdata;

    always @(posedge clk) begin

        // port 1
        if(core_write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(core_byte_enable[i]) ram[core_address][i*BYTE_WIDTH +: BYTE_WIDTH] <= core_writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        core_readdata <= ram[core_address];

        // port 2
        if(fill_write) begin
            for (int j = 0; j < NUM_BYTES; j = j + 1) begin
                if(fill_byte_enable[j]) ram[fill_address][j*BYTE_WIDTH +: BYTE_WIDTH] <= fill_writedata[j*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        fill_readdata <= ram[core_address];
    end

`else

    // use seperate ram for each byte
    // Only this style works for vivado

    reg [BYTE_WIDTH-1:0] ram0[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram1[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram2[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram3[RAM_DEPTH-1:0];

    reg [BYTE_WIDTH-1:0] core_data0;
    reg [BYTE_WIDTH-1:0] core_data1;
    reg [BYTE_WIDTH-1:0] core_data2;
    reg [BYTE_WIDTH-1:0] core_data3;

    // port 1

    always @(posedge clk) begin
        if(core_write) begin
            if(core_byte_enable[0]) ram0[core_address] <= core_writedata[7:0];
            if(core_byte_enable[1]) ram1[core_address] <= core_writedata[15:8];
            if(core_byte_enable[2]) ram2[core_address] <= core_writedata[23:16];
            if(core_byte_enable[3]) ram3[core_address] <= core_writedata[31:24];
        end
        core_data0 <= ram0[core_address];
        core_data1 <= ram1[core_address];
        core_data2 <= ram2[core_address];
        core_data3 <= ram3[core_address];
    end

    assign core_readdata = {core_data3, core_data2, core_data1, core_data0};

    // port 2

    always @(posedge clk) begin
        if(fill_write) begin
            if(fill_byte_enable[0]) ram0[fill_address] <= fill_writedata[7:0];
            if(fill_byte_enable[1]) ram1[fill_address] <= fill_writedata[15:8];
            if(fill_byte_enable[2]) ram2[fill_address] <= fill_writedata[23:16];
            if(fill_byte_enable[3]) ram3[fill_address] <= fill_writedata[31:24];
        end
    end

`endif

endmodule
