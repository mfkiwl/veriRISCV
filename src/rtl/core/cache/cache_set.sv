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

Cache Set logic

- The readdata has a one read latency.
- The cache use NRU replacemnent policy

*/

`include "core.svh"

module cache_set #(
    parameter CACHE_LINE_SIZE = 4,  // cache line size in bytes, support 4 byte only for now
    parameter CACHE_SET_DEPTH = 32,       // CACHE_SET_DEPTH of the cache set. Must be power of 2
    parameter NRU_LOGIC = 0         // Use NRU logic
) (
    input                       clk,
    input                       rst,

    // input request from cpu core
    input                       read,
    input                       write,
    input [`DATA_RANGE]         address,
    input [`DATA_RANGE]         writedata,
    input [`DATA_WIDTH/8-1:0]   byteenable,
    output [`DATA_RANGE]        readdata,      // the read data has a latency of 1

    // cache line information
    output                      hit,
    output                      valid,
    output                      dirty,
    output [`DATA_RANGE]        dirty_data,

    // cache update from memory
    input                       fill,
    input [`DATA_RANGE]         fill_address,
    input [`DATA_RANGE]         fill_data,

    // NRU
    input                       set_nru,
    input                       clr_nru,
    output                      nru
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    localparam LINE_WIDTH = CACHE_LINE_SIZE*8;          // cache line CACHE_LINE_SIZE
    localparam BYTE_WIDTH = $clog2(CACHE_LINE_SIZE);
    localparam SET_WIDTH  = $clog2(CACHE_SET_DEPTH);
    localparam TAG_WIDTH  = `DATA_WIDTH - BYTE_WIDTH - SET_WIDTH;

    logic [BYTE_WIDTH-1:0]  cache_byte_addr;
    logic [SET_WIDTH-1:0]   cache_set_addr;
    logic [TAG_WIDTH-1:0]   cache_tag;

    logic                   cache_line_valid;
    logic                   cache_line_dirty;
    logic [`DATA_RANGE]     cache_line_data;
    logic [TAG_WIDTH-1:0]   cache_line_tag;

    logic                   tag_match;
    logic                   cache_write;

    reg [LINE_WIDTH-1:0]    cache_mem_data[CACHE_SET_DEPTH-1:0];
    reg [TAG_WIDTH-1:0]     cache_mem_tag[CACHE_SET_DEPTH-1:0];
    reg [CACHE_SET_DEPTH-1:0] cache_mem_valid;
    reg [CACHE_SET_DEPTH-1:0] cache_mem_dirty;

    logic [BYTE_WIDTH-1:0]  fill_byte_addr;
    logic [SET_WIDTH-1:0]   fill_set_addr;
    logic [TAG_WIDTH-1:0]   fill_tag;

    // ---------------------------------
    // main logic
    // ---------------------------------

    // extract different field from address
    assign {cache_tag, cache_set_addr, cache_byte_addr} = address;
    assign {fill_tag, fill_set_addr, fill_byte_addr} = fill_address;

    // check if we have a cache hit or a cache miss
    assign cache_line_tag = cache_mem_tag[cache_set_addr];
    assign cache_line_valid = cache_mem_valid[cache_set_addr];
    assign cache_line_dirty = cache_mem_dirty[cache_set_addr];
    always @(posedge clk) cache_line_data <= cache_mem_data[cache_set_addr];

    assign tag_match = cache_line_tag == cache_tag;
    assign hit = cache_line_valid & tag_match;
    assign dirty = cache_line_dirty;
    assign dirty_data = cache_line_data;
    assign valid = cache_line_valid;
    assign readdata = cache_line_data;

    // cache hit and write
    assign cache_write = hit & write;
    always @(posedge clk) if (cache_write) cache_mem_data[cache_set_addr] <= writedata; // FIXME: byte enable logic

    // cache miss update
    always @(posedge clk) if (fill) cache_mem_tag[fill_set_addr] <= fill_tag;
    always @(posedge clk) if (fill) cache_mem_data[fill_set_addr] <= fill_data;

    // cache line valid
    always @(posedge clk) begin
        if (rst) cache_mem_valid <= 0;
        else if (fill) cache_mem_valid[fill_set_addr] <= 1'b1;
    end

    // cache line dirty
    always @(posedge clk) begin
        if (rst) cache_mem_dirty <= 0;
        else if (fill) cache_mem_dirty[fill_set_addr] <= 1'b0;
        else if (cache_write) cache_mem_dirty[cache_set_addr] <= 1'b1;
    end

    // nru logic for Set associative cache
    generate
    if (NRU_LOGIC) begin

    reg [CACHE_SET_DEPTH-1:0] cache_mem_nru;

    always @(posedge clk) begin
        if (rst) cache_mem_nru <= -1;   // set default NRU to 1 (Important!)
        else begin
            if (clr_nru) cache_mem_nru[cache_set_addr] <= 0;
            else if (set_nru) cache_mem_nru[cache_set_addr] <= 1'b1;
        end
    end

    end
    endgenerate

endmodule
