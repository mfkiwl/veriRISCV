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

** ibus_waitrequest **:
Cause: instruction bus is busy and need to wait.
Stage of the req: IF
Affect: 1. Stall IF/ID/EX stage and let other stage goes.
        1. flush the IF stage since the instruction is not ready and let other stage go

** lsu_stall_req **:
Cause: data bus is busy while we access the data bus.
Stage of the req: MEM
Affect: 1. Stall the whole pipeline since we might have dependence on MEM/WB stage

** load_stall_req **:
Cause: Load instruction followed by a instruction with dependence
Stage of the req: ID
Affect: 1. Stall IF stage for 1 cycle.
        2. Flush ID stage for 1 cycle.

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
    input       ibus_waitrequest,   // instruction bus wait request
    input       lsu_stall_req,      // lsu stall request
    input       load_stall_req,     // load denpendence stall request

    input       ex_csr_read,
    input       mem_csr_read,
    input       branch_take,
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

    // For simplicity, we just let csr complete before excuting the next instruction
    assign csr_stall = ex_csr_read | mem_csr_read;

    // NOTE: In our pipeline logic, flush has priority over stall.
    // So if a signal casuse a stall that should not be flushed while at the same time other signals cause flush
    // we should disable those signals from flushing the pipeline.

    // Why: (ibus_waitrequest) & ~(load_stall_req | lsu_stall_req) ?
    // - If we have load dependence or lsu is requesting stall then we should not flush if stage
    assign if_flush = branch_take | trap_take | (ibus_waitrequest) & ~(load_stall_req | lsu_stall_req);

    // Why: load_stall_req & ~lsu_stall_req ?
    // - If lsu is requesting for stall, then we should not flush id stage for load dependence, since EX stage need to wait
    assign id_flush  = branch_take | csr_stall | trap_take | (load_stall_req & ~lsu_stall_req);

    assign ex_flush  = trap_take;
    assign mem_flush = trap_take;
    assign wb_flush  = 0;

    assign if_stall  = load_stall_req | csr_stall | ibus_waitrequest | lsu_stall_req;
    assign id_stall  = lsu_stall_req;
    assign ex_stall  = lsu_stall_req;
    assign mem_stall = lsu_stall_req;

endmodule
