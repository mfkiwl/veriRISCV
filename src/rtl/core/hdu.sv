// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/19/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Hazard Detection Unit (HDU)
// ------------------------------------------------------------------------------------------------

`include "core.svh"


module hdu (
    input       branch_take,
    input       load_stall,
    output      if_flush,
    output      if_stall,
    output      id_flush,
    output      id_stall,
    output      ex_flush,
    output      ex_stall,
    output      mem_flush,
    output      mem_stall
);

    //logic   csr_dependence;
    // for simplicity, we just let csr complete before excuting the next instruction
    // FIXME: can be improved later
    //assign csr_dependence = id2ex_csr_rd | ex2mem_csr_rd | mem2wb_csr_rd;

    assign if_flush = branch_take;
    assign id_flush = branch_take | load_stall;
    assign ex_flush = 1'b0;
    assign mem_flush = 1'b0;

    assign if_stall = load_stall;
    assign id_stall = 1'b0;
    assign ex_stall = 1'b0;
    assign mem_stall = 1'b0;

endmodule
