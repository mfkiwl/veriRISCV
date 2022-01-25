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
    output      if_flush,
    output      id_flush,
    output      if2id_stall
);

    assign if_flush = take_branch;
    assign id_flush = take_branch | load_dependence;
    assign if2id_stall = load_dependence & ~if_flush;

endmodule
