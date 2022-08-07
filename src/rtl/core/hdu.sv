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

/*
Note for HDU

** lsu_dbus_busy **:
Cause: data bus is busy while we access the data bus.
Stage of the req: MEM
Affect: 1. Stall the whole pipeline since we might have dependence on MEM/WB stage

** load_stall_req **:
Cause: Load instruction followed by a instruction with dependence
Stage of the req: ID
Affect: 1. Stall IF stage for 1 cycle.
        2. Flush ID stage for 1 cycle.

** muldiv_stall_req **
Cause: muliplier/divider
Stage of the req: EX
Affect: 1. Stall IF/ID stage
        2. Flush EX stage

** ex_csr_read/mem_csr_read **:
Cause: instruction depends on CSR instruction
Stage of the req: ID
Affect: 1. Stall IF stage till CSR instruction completes (reach WB stage)
        2. Flush ID stage till CSR instruction completes (reach WB stage)

** branch_take **
Cause: a taken branch
Stage of the req: EX
Affect: 1. Flush IF, ID stage

** trap_take **
Cause: a taken trap
Stage of the req: WB
Affect: 1. Flush IF, ID, EX, MEM stage

*/

module hdu (
    input       lsu_dbus_busy,          // data bus wait request
    input       load_stall_req,         // load denpendence stall request
    input       muldiv_stall_req,
    input       ex_csr_read,
    input       mem_csr_read,
    input       branch_take,
    input       trap_take,

    output      if_flush,
    output      if_stall,
    output      id_flush,
    output      id_stall,
    output      id_bubble,
    output      ex_flush,
    output      ex_stall,
    output      ex_bubble,
    output      mem_flush,
    output      mem_stall,
    output      wb_stall
);

    logic   csr_stall;

    // For simplicity, we just let csr complete before excuting the next instruction
    assign csr_stall = ex_csr_read | mem_csr_read;

    assign if_flush  = branch_take & ~lsu_dbus_busy | trap_take;
    assign id_flush  = branch_take & ~lsu_dbus_busy | trap_take;
    assign ex_flush  = trap_take;
    assign mem_flush = trap_take;

    assign id_bubble = csr_stall | (load_stall_req & ~lsu_dbus_busy);
    assign ex_bubble = muldiv_stall_req;

    assign if_stall  = lsu_dbus_busy | load_stall_req | csr_stall | muldiv_stall_req;
    assign id_stall  = lsu_dbus_busy | muldiv_stall_req;
    assign ex_stall  = lsu_dbus_busy;
    assign mem_stall = lsu_dbus_busy;
    assign wb_stall  = lsu_dbus_busy;

endmodule
