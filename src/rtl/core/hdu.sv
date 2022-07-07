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
    input       ibus_waitrequest,
    input       branch_take,
    input       load_stall,
    input       ex_csr_read,
    input       mem_csr_read,
    input       trap_take,

    output      if_flush,
    output      if_stall,
    output      id_flush,
    output      id_stall,
    output      ex_flush,
    output      ex_stall,
    output      mem_flush,
    output      mem_stall,
    output      wb_flush
);

    logic   csr_stall;
    logic   ibus_waitrequest_if_flush;

    // For simplicity, we just let csr complete before excuting the next instruction
    assign csr_stall = ex_csr_read | mem_csr_read;

    // we should not flush if stage if we need to stall for load
    assign ibus_waitrequest_if_flush = ibus_waitrequest & ~load_stall;

    assign if_flush = branch_take | trap_take | ibus_waitrequest_if_flush;
    assign id_flush = branch_take | load_stall | csr_stall | trap_take;
    assign ex_flush = trap_take;
    assign mem_flush = trap_take;
    assign wb_flush = 0;

    assign if_stall = load_stall | csr_stall | ibus_waitrequest;
    assign id_stall = 1'b0;
    assign ex_stall = 1'b0;
    assign mem_stall = 1'b0;

endmodule
