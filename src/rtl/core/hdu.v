///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: hdu.v
//
// Author: Heqing Huang
// Date Created: 01/21/2022
//
// ================== Description ==================
//
// hdu (hazard detect unit)
//
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "decoder.vh"
`include "veririscv_core.vh"

module hdu (
    input       take_branch,
    input       load_dependence,
    input       id2ex_csr_rd,
    input       ex2mem_csr_rd,
    input       mem2wb_csr_rd,
    output      if_flush,
    output      id_flush,
    output      if2id_stall
);

    wire csr_dependence;

    // for simplicity, we just let csr complete before excuting the next instruction
    // FIXME: can be improved later
    assign csr_dependence = id2ex_csr_rd | ex2mem_csr_rd | mem2wb_csr_rd;

    assign if_flush = take_branch;
    assign id_flush = take_branch | load_dependence | csr_dependence;
    assign if2id_stall = (load_dependence | csr_dependence) & ~if_flush;

endmodule
