// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/15/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// A Direct cache
// ------------------------------------------------------------------------------------------------

/**

The cache contains a single cache set and the control logic to access the cache set

For simplicity we use Address bit 31 (MSB) to deternmins whether the address is cache-able or not.
Bit 31 = 1: Non-cacheable address
Bit 31 = 0: Cacheable address

*/

`include "core.svh"

module direct_cache #(
    parameter CACHE_LINE_SIZE = 4,      // cache line size in bytes, support 4 byte only for now
    parameter CACHE_DEPTH = 32          // depth of the cache set. Must be power of 2
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

    logic                       core_read;
    logic                       core_write;
    logic [`DATA_RANGE]         core_address;
    logic [`DATA_RANGE]         core_writedata;
    logic [`DATA_WIDTH/8-1:0]   core_byteenable;
    logic [`DATA_RANGE]         core_readdata;
    logic                       set_hit;
    logic                       set_dirty;
    logic [`DATA_RANGE]         set_dirty_data;
    logic                       update_write;
    logic [`DATA_RANGE]         update_address;
    logic [`DATA_RANGE]         update_data;

    // state machine
    typedef enum logic[1:0] {IDLE, FLUSH, RETRIVE} state_t;
    state_t state, state_next;

    logic                       cache_access;
    logic                       cache_miss;
    logic                       non_cacheable;

    reg                         read_from_memory;
    reg [`DATA_RANGE]           core_address_s1;    // need to store the address for cache update


    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign cache_access = core_avn_req.read | core_avn_req.write;
    assign cache_miss = cache_access & ~set_hit;
    assign non_cacheable = core_avn_req.address[`DATA_WIDTH-1];

    assign core_address = core_avn_req.address;
    assign core_byteenable = core_avn_req.byte_enable;

    always @(posedge clk) core_address_s1 <= core_address;
    always @(posedge clk) read_from_memory <= mem_avn_req.read & ~mem_avn_resp.waitrequest;

    assign core_avn_resp.readdata = read_from_memory ? mem_avn_resp.readdata
                                                     : core_readdata;   // the read data already has 1 read latency

    assign update_write = read_from_memory;
    assign update_data  = mem_avn_resp.readdata;
    assign update_address = core_address_s1;

    // state machine
    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else state <= state_next;
    end

    always @* begin

        core_read = 0;
        core_write = 0;

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

                core_read = core_avn_req.read;
                core_write = core_avn_req.write;

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
        .SIZE   (CACHE_LINE_SIZE),
        .DEPTH  (CACHE_DEPTH))
    u_cache_set (
        .clk                (clk),
        .rst                (rst),
        .core_read          (core_read),
        .core_write         (core_write),
        .core_address       (core_address),
        .core_writedata     (core_writedata),
        .core_byteenable    (core_byteenable),
        .core_readdata      (core_readdata),
        .set_hit            (set_hit),
        .set_dirty          (set_dirty),
        .set_dirty_data     (set_dirty_data),
        .update_write       (update_write),
        .update_address     (update_address),
        .update_data        (update_data)
    );

endmodule
