// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/15/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// A direct mapped cache
// ------------------------------------------------------------------------------------------------

/**

The cache contains a single cache set and the control logic to access the cache set

For simplicity we use Address bit 31 (MSB) to deternmins whether the address is cache-able or not.
Bit 31 = 1: Non-cacheable address
Bit 31 = 0: Cacheable address

*/

`include "core.svh"

module cache_dirmap #(
    parameter CACHE_LINE_SIZE = 4,      // cache line size in bytes, support 4 byte only for now
    parameter CACHE_SET_DEPTH = 32      // depth of the cache set. Must be power of 2
) (
    input                   clk,
    input                   rst,

    input  avalon_req_t     core_avn_req,
    output avalon_resp_t    core_avn_resp,

    output avalon_req_t     mem_avn_req,
    input  avalon_resp_t    mem_avn_resp
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    logic                       set_read;
    logic                       set_write;
    logic [`DATA_RANGE]         set_address;
    logic [`DATA_RANGE]         set_writedata;
    logic [`DATA_WIDTH/8-1:0]   set_byteenable;
    logic [`DATA_RANGE]         set_readdata;
    logic                       set_hit;
    logic                       set_dirty;
    logic [`DATA_RANGE]         set_dirty_data;
    logic                       set_fill;
    logic [`DATA_RANGE]         set_fill_address;
    logic [`DATA_RANGE]         set_fill_data;

    // state machine
    typedef enum logic[1:0] {IDLE, FLUSH, RETRIVE} state_t;
    state_t state, state_next;

    logic                       cache_access;
    logic                       cache_miss;
    logic                       non_cacheable;

    reg                         read_from_memory;
    reg [`DATA_RANGE]           set_address_s1;    // need to store the address for cache update


    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign cache_access = core_avn_req.read | core_avn_req.write;
    assign cache_miss = cache_access & ~set_hit;
    assign non_cacheable = core_avn_req.address[`DATA_WIDTH-1];

    assign set_address = core_avn_req.address;
    assign set_byteenable = core_avn_req.byte_enable;

    always @(posedge clk) set_address_s1 <= core_avn_req.address;
    always @(posedge clk) read_from_memory <= mem_avn_req.read & ~mem_avn_resp.waitrequest;

    assign core_avn_resp.readdata = read_from_memory ? mem_avn_resp.readdata
                                                     : set_readdata;   // the read data already has 1 read latency

    assign set_fill = read_from_memory;
    assign set_fill_data  = mem_avn_resp.readdata;
    assign set_fill_address = set_address_s1;

    // state machine
    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else state <= state_next;
    end

    always @* begin

        set_read = 0;
        set_write = 0;

        core_avn_resp.waitrequest = 0;

        mem_avn_req.read = 0;
        mem_avn_req.write = 0;
        mem_avn_req.address = core_avn_req.address;
        mem_avn_req.byte_enable = core_avn_req.byte_enable;
        mem_avn_req.writedata = non_cacheable ? core_avn_req.writedata : set_dirty_data;

        state_next = state;

        case(state)

            // IDLE state: take new cache read/write request from CPU core.
            // If the address is non-cacheable, we go to RETRIVE state to get the data from memory
            // If we have a cache hit, we take the request, and we are done. Stay at IDLE state
            // If we have a cache miss, we need to check if the replaced line is dirty or not.
            // => if the line is dirty, we go to FLUSH state to flush that line back to memory
            // => if the line is not dirty, we go to RETRIVE state to read the new data from memory.
            IDLE: begin

                set_read = core_avn_req.read;
                set_write = core_avn_req.write;

                core_avn_resp.waitrequest = non_cacheable & mem_avn_resp.waitrequest
                                          | ~non_cacheable & cache_miss & mem_avn_resp.waitrequest;

                // if the address is non cachable, we access the memory directly
                if (non_cacheable) begin
                    mem_avn_req.read = core_avn_req.read;
                    mem_avn_req.write = core_avn_req.write;
                end
                // if cache miss, we start to flush/retrive data from memory
                else if (cache_miss) begin
                    mem_avn_req.write = set_dirty;
                    mem_avn_req.read = ~set_dirty;
                end

                // for noncachable situlation, we just need to stay at IDLE state
                // the pipeline stall logic will take care of it
                if (!non_cacheable && cache_miss) begin
                    // if set is dirty, we need to flush the data back to the memory.
                    if (set_dirty)  begin
                        // if the bus transfer can't be done in one cycle,
                        // we go to FLUSh state to wait for the transfer to complete
                        if (mem_avn_resp.waitrequest)   state_next = FLUSH;
                        // if the bus transfer completes in one cycle, we go to retrive state
                        else                            state_next = RETRIVE;
                    end
                    // set is clean, we go to RETRIVE state if the bus transfer can't be done in one cycle.
                    else begin
                        if (mem_avn_resp.waitrequest)  state_next = RETRIVE;
                    end
                end
            end

            FLUSH: begin
                core_avn_resp.waitrequest = 1'b1;
                mem_avn_req.write = 1;
                if (!mem_avn_resp.waitrequest) state_next = RETRIVE;
            end

            RETRIVE: begin
                core_avn_resp.waitrequest = mem_avn_resp.waitrequest;
                mem_avn_req.read = 1;
                if (!mem_avn_resp.waitrequest) state_next = IDLE;
            end

            default: ;
        endcase
    end

    // ---------------------------------
    // Module Instantiation
    // ---------------------------------

    cache_set #(
        .CACHE_LINE_SIZE    (CACHE_LINE_SIZE),
        .CACHE_SET_DEPTH    (CACHE_SET_DEPTH),
        .NRU_LOGIC          (0))
    u_cache_set (
        .clk                (clk),
        .rst                (rst),
        .read               (set_read),
        .write              (set_write),
        .address            (set_address),
        .writedata          (set_writedata),
        .byteenable         (set_byteenable),
        .readdata           (set_readdata),
        .hit                (set_hit),
        .dirty              (set_dirty),
        .dirty_data         (set_dirty_data),
        .valid              (),
        .fill               (set_fill),
        .fill_address       (set_fill_address),
        .fill_data          (set_fill_data),
        .set_nru            (1'b0),
        .clr_nru            (1'b0),
        .nru                ()
    );

endmodule
