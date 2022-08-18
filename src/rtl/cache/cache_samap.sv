// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/15/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// A Set-associative cache
// ------------------------------------------------------------------------------------------------

/**

The cache contains multiple cache set and the control logic to access the cache set

For simplicity we use Address bit 31 (MSB) to deternmins whether the address is cache-able or not.
Bit 31 = 1: Non-cacheable address
Bit 31 = 0: Cacheable address

Replacement Policy:

We use NRU (Not Recently Used) algorithm for repleacment instead of LRU.
LRU is better then NRU but it is hard for hardware implementations.
NRU use similar idea of LRU. We keep track of whether the cell has been recently used or not.
When replacement is needed, we choose those cells that have not been recently used.

Here is how nru is implemented:

- For each set in a cacheline, we use a nru indicator to  keep track of whether the cell is recently access or not.
- The nru bit is initially set to 1 after reset indicating that it is not recently used.
- When we have a cache hit on a cell or a fill in a cell, we clear the nru bit indicating that we have recently use.
- If all the nru bits will become zero after the above actions, we reset the nru bit for OTHER cells to 1.

*/

`include "core.svh"

module cache_samap #(
    parameter CACHE_LINE_SIZE = 4,      // cache line size in bytes, support 4 byte only for now
    parameter CACHE_SET_DEPTH = 32,     // depth of the cache set. Must be power of 2
    parameter CACHE_WAYS = 2            // cache ways
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

    localparam LRU_WIDTH = $clog2(CACHE_WAYS);

    logic [CACHE_WAYS-1:0]                      set_read;
    logic [CACHE_WAYS-1:0]                      set_write;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_address;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_writedata;
    logic [CACHE_WAYS-1:0][`DATA_WIDTH/8-1:0]   set_byteenable;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_readdata;
    logic [CACHE_WAYS-1:0]                      set_hit;
    logic [CACHE_WAYS-1:0]                      set_dirty;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_dirty_data;
    logic [CACHE_WAYS-1:0]                      set_valid;
    logic [CACHE_WAYS-1:0]                      set_fill;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_fill_address;
    logic [CACHE_WAYS-1:0][`DATA_RANGE]         set_fill_data;
    logic [CACHE_WAYS-1:0]                      set_set_nru;
    logic [CACHE_WAYS-1:0]                      set_clr_nru;
    logic [CACHE_WAYS-1:0]                      set_nru;

    logic                                       set_hit_agg;
    logic                                       set_dirty_agg;

    logic                                       all_ru_hit;     // all recently used after hit
    logic                                       all_ru_miss;    // all recently used after miss
    logic [$clog2(CACHE_WAYS)-1:0]              hit_set_id;
    logic [CACHE_WAYS-1:0]                      victim_set;
    logic [$clog2(CACHE_WAYS)-1:0]              victim_set_id;



    // state machine
    typedef enum logic[1:0] {IDLE, FLUSH, RETRIVE} state_t;
    state_t state, state_next;

    logic                           cache_access;
    logic                           cache_miss;
    logic                           cache_hit;
    logic                           non_cacheable;

    reg                             read_from_memory;
    reg [`DATA_RANGE]               set_address_s1;    // need to store the address for cache update
    reg [$clog2(CACHE_WAYS)-1:0]    hit_set_id_s1;
    reg [$clog2(CACHE_WAYS)-1:0]    victim_set_id_s1;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign cache_access = core_avn_req.read | core_avn_req.write;
    assign cache_miss = cache_access & ~set_hit_agg;
    assign cache_hit = cache_access & set_hit_agg;
    assign non_cacheable = core_avn_req.address[`DATA_WIDTH-1];

    assign set_hit_agg = |set_hit;
    assign set_dirty_agg = |(victim_set & set_dirty); // only when the victim set is dirty we need to flush the victim.

    assign hit_set_id = onehot2binary(set_hit);

    assign victim_set = bit_scan(set_nru);
    assign victim_set_id = onehot2binary(victim_set);

    // both set_nru and set_hit/victim_set are one hot. so if they are equal
    // then after this access all the sets are recently used.
    assign all_ru_hit = (set_nru == set_hit);
    assign all_ru_miss = (set_nru == victim_set);

    genvar i;
    generate
    for (i = 0; i < CACHE_WAYS; i++) begin: _set
        assign set_address[i] = core_avn_req.address;
        assign set_writedata[i] = core_avn_req.writedata;
        assign set_byteenable[i] = core_avn_req.byte_enable;
        assign set_fill_data[i]  = mem_avn_resp.readdata;
        assign set_fill_address[i] = set_address_s1;
    end
    endgenerate

    always @(posedge clk) set_address_s1 <= core_avn_req.address;
    always @(posedge clk) read_from_memory <= mem_avn_req.read & ~mem_avn_resp.waitrequest;
    always @(posedge clk) hit_set_id_s1 <= hit_set_id;
    always @(posedge clk) victim_set_id_s1 <= victim_set_id;

    assign core_avn_resp.readdata = read_from_memory ? mem_avn_resp.readdata
                                                     : set_readdata[hit_set_id_s1];   // the read data already has 1 read latency

    always @* begin
        set_fill = 0;
        set_fill[victim_set_id_s1] = read_from_memory;
    end

    // state machine
    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else state <= state_next;
    end

    always @* begin

        set_read = 0;
        set_write = 0;

        set_clr_nru = 0;
        set_set_nru = 0;

        core_avn_resp.waitrequest = 0;

        mem_avn_req.read = 0;
        mem_avn_req.write = 0;
        mem_avn_req.address = core_avn_req.address;
        mem_avn_req.byte_enable = core_avn_req.byte_enable;
        mem_avn_req.writedata = non_cacheable ? core_avn_req.writedata : set_dirty_data[hit_set_id];

        state_next = state;

        case(state)

            // IDLE state: take new cache read/write request from CPU core.
            // If the address is non-cacheable, we go to RETRIVE state to get the data from memory
            // If we have a cache hit, we take the request, and we are done. Stay at IDLE state
            // If we have a cache miss, we need to check if the replaced line is dirty or not.
            // => if the line is dirty, we go to FLUSH state to flush that line back to memory
            // => if the line is not dirty, we go to RETRIVE state to read the new data from memory.
            IDLE: begin

                for (int i = 0; i < CACHE_WAYS; i++) begin
                    set_read[i] = core_avn_req.read;
                    set_write[i] = core_avn_req.write;
                end
                core_avn_resp.waitrequest = non_cacheable & mem_avn_resp.waitrequest
                                          | ~non_cacheable & cache_miss & mem_avn_resp.waitrequest;

                // if the address is non cachable, we access the memory directly
                if (non_cacheable) begin
                    mem_avn_req.read = core_avn_req.read;
                    mem_avn_req.write = core_avn_req.write;
                end
                // if cache miss, we start to flush/retrive data from memory
                else if (cache_miss) begin
                    mem_avn_req.write = set_dirty_agg;
                    mem_avn_req.read = ~set_dirty_agg;
                end

                // if cache hit, clear the NLU bit for the hitting set since we just access this set.
                if (cache_hit) set_clr_nru = set_hit;
                if (cache_hit && all_ru_hit) set_set_nru = ~set_hit;

                // for noncachable situlation, we just need to stay at IDLE state
                // the pipeline stall logic will take care of it
                if (!non_cacheable && cache_miss) begin
                    // if set is dirty, we need to flush the data back to the memory.
                    if (set_dirty_agg)  begin
                        // if the bus transfer can't be done in one cycle,
                        // we go to FLUSh state to wait for the transfer to complete
                        if (mem_avn_resp.waitrequest)   state_next = FLUSH;
                        // if the bus transfer completes in one cycle, we go to retrive state
                        else                            state_next = RETRIVE;
                    end
                    // set is clean, we go to RETRIVE state if the bus transfer can't be done in one cycle.
                    else begin
                        if (mem_avn_resp.waitrequest)   state_next = RETRIVE;
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
                if (!mem_avn_resp.waitrequest) set_clr_nru = victim_set;
                if (!mem_avn_resp.waitrequest && all_ru_miss) set_set_nru = ~victim_set;
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
        .NRU_LOGIC          (1))
    u_cache_set[CACHE_WAYS-1:0] (
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
        .valid              (set_valid),
        .fill               (set_fill),
        .fill_address       (set_fill_address),
        .fill_data          (set_fill_data),
        .set_nru            (set_set_nru),
        .clr_nru            (set_clr_nru),
        .nru                (set_nru)
    );

    // ---------------------------------
    // Functions
    // ---------------------------------
    function automatic [CACHE_WAYS-1:0] bit_scan();
        input [CACHE_WAYS-1:0] in;
        bit_scan = in & (~in + 1);
    endfunction

    function automatic [$clog2(CACHE_WAYS)-1:0] onehot2binary();
        input [CACHE_WAYS-1:0] oh;
        onehot2binary = 0;
        for (int i = 0; i < CACHE_WAYS; i++) begin
            if (oh[i]) onehot2binary = i[$clog2(CACHE_WAYS)-1:0];
        end
    endfunction

endmodule
