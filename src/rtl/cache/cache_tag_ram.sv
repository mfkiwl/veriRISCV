// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Memory for cache tag
// ------------------------------------------------------------------------------------------------

/**

Cache tag ram is a 1 rw ports memory.

! The read latency is 0.

*/

module cache_tag_ram #(
    parameter AW = 10,
    parameter DW = 32
) (
    input               clk,
    // port 1
    input [AW-1:0]      core_address,        // this is the word size
    output [DW-1:0]     core_readdata,
    // port 2
    input               fill_write,
    input [AW-1:0]      fill_address,        // this is the word size
    input [DW-1:0]      fill_writedata
);

    localparam RAM_DEPTH = 2 ** AW;

    reg [DW-1:0] ram[RAM_DEPTH-1:0];
    reg [DW-1:0] data;

    always @(posedge clk) begin
        if(fill_write) ram[fill_address]<= fill_writedata;
    end

    assign core_readdata = ram[core_address];

endmodule
