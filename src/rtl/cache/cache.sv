// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/16/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Top level for cache
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module cache #(
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

generate
if (CACHE_WAYS == 1) begin:_dir_cache
    cache_dirmap #(
        .CACHE_LINE_SIZE    (CACHE_LINE_SIZE),
        .CACHE_SET_DEPTH    (CACHE_SET_DEPTH))
    u_instruction_cache (
        .clk                (clk),
        .rst                (rst),
        .core_avn_req       (core_avn_req),
        .core_avn_resp      (core_avn_resp),
        .mem_avn_req        (mem_avn_req),
        .mem_avn_resp       (mem_avn_resp)
    );
end
else begin:_sa_cache
    cache_samap #(
        .CACHE_LINE_SIZE    (CACHE_LINE_SIZE),
        .CACHE_SET_DEPTH    (CACHE_SET_DEPTH),
        .CACHE_WAYS         (CACHE_WAYS))
    u_instruction_cache (
        .clk                (clk),
        .rst                (rst),
        .core_avn_req       (core_avn_req),
        .core_avn_resp      (core_avn_resp),
        .mem_avn_req        (mem_avn_req),
        .mem_avn_resp       (mem_avn_resp)
    );
end
endgenerate

endmodule