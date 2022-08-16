// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/15/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Cache Set
// ------------------------------------------------------------------------------------------------

/**

Single set for a cache

*/

`include "core.svh"

module cache_set #(
    parameter SIZE = 4,     // cache line size in bytes, support 4 byte only for now
    parameter DEPTH = 32    // depth of the cache set. Must be power of 2
) (
    input                       clk,
    input                       rst,

    // input request from cpu core
    input                       core_read,
    input                       core_write,
    input [`DATA_RANGE]         core_address,
    input [`DATA_RANGE]         core_writedata,
    input [`DATA_WIDTH/8-1:0]   core_byteenable,
    output [`DATA_RANGE]        core_readdata,      // the read data has a latency of 1

    // cache line information
    output                      set_hit,
    output                      set_dirty,
    output [`DATA_RANGE]        set_dirty_data,

    // cache update from memory
    input                       update_write,
    input [`DATA_RANGE]         update_address,
    input [`DATA_RANGE]         update_data
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    localparam LINE_SIZE  = SIZE*8;          // cache line size
    localparam BYTE_WIDTH = $clog2(SIZE);
    localparam SET_WIDTH  = $clog2(DEPTH);
    localparam TAG_WIDTH  = `DATA_WIDTH - BYTE_WIDTH - SET_WIDTH;

    logic [BYTE_WIDTH-1:0]  cache_byte_addr;
    logic [SET_WIDTH-1:0]   cache_set_addr;
    logic [TAG_WIDTH-1:0]   cache_tag;

    logic                   cache_line_valid;
    logic                   cache_line_dirty;
    logic [`DATA_RANGE]     cache_line_data;
    logic [TAG_WIDTH-1:0]   cache_line_tag;

    logic                   tag_match;
    logic                   core_cache_write;

    reg [LINE_SIZE-1:0]     cache_mem_data[DEPTH-1:0];
    reg [TAG_WIDTH-1:0]     cache_mem_tag[DEPTH-1:0];
    reg [DEPTH-1:0]         cache_mem_valid;
    reg [DEPTH-1:0]         cache_mem_dirty;

    logic [BYTE_WIDTH-1:0]  update_byte_addr;
    logic [SET_WIDTH-1:0]   update_set_addr;
    logic [TAG_WIDTH-1:0]   update_tag;

    // ---------------------------------
    // main logic
    // ---------------------------------

    // CPU core access logic
    assign {cache_tag, cache_set_addr, cache_byte_addr} = core_address;

    // check if we have a cache hit or a cache miss
    assign cache_line_tag = cache_mem_tag[cache_set_addr];
    assign cache_line_valid = cache_mem_valid[cache_set_addr];
    assign cache_line_dirty = cache_mem_dirty[cache_set_addr];
    always @(posedge clk) cache_line_data <= cache_mem_data[cache_set_addr];

    assign tag_match = cache_line_tag == cache_tag;
    assign set_hit = cache_line_valid & tag_match;
    assign set_dirty = cache_line_dirty;
    assign set_dirty_data = cache_line_data;
    assign core_readdata = cache_line_data;

    // cache hit and write
    assign core_cache_write = set_hit & core_write;
    always @(posedge clk) if (core_cache_write) cache_mem_data[cache_set_addr] <= core_writedata; // FIXME: byte enable

    // cache miss update
    assign {update_tag, update_set_addr, update_byte_addr} = update_address;
    always @(posedge clk) if (update_write) cache_mem_tag[update_set_addr] <= update_tag;
    always @(posedge clk) if (update_write) cache_mem_data[update_set_addr] <= update_data;

    // cache line valid
    always @(posedge clk) begin
        if (rst) cache_mem_valid <= 0;
        else begin
            if (update_write) cache_mem_valid[update_set_addr] <= 1'b1;
        end
    end

    // cache line set_dirty
    always @(posedge clk) begin
        if (rst) cache_mem_dirty <= 0;
        else begin
            if (update_write) cache_mem_dirty[update_set_addr] <= 1'b0;
            else if (core_cache_write) cache_mem_dirty[cache_set_addr] <= 1'b1;
        end
    end

endmodule
