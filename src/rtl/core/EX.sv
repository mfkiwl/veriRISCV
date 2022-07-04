// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Execution Stage
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module EX (
    input                               clk,
    input                               rst,
    input                               ex_flush,
    input                               ex_stall,
    // from ID/EX stage pipeline
    input id2ex_pipeline_ctrl_t         id2ex_pipeline_ctrl,
    input id2ex_pipeline_exc_t          id2ex_pipeline_exc,
    input id2ex_pipeline_data_t         id2ex_pipeline_data,
    // from wb stage
    input [`DATA_RANGE]                 wb_reg_writedata,
    // to LSU in memory stage
    output                              lsu_mem_read,
    output                              lsu_mem_write,
    output [`CORE_MEM_OP_RANGE]         lsu_mem_opcode,
    output [`DATA_RANGE]                lsu_address,
    output [`DATA_RANGE]                lsu_writedata,
    // from LSU
    input                               lsu_exception_load_addr_misaligned,
    input                               lsu_exception_store_addr_misaligned,
    // branch control
    output [`PC_RANGE]                  branch_pc,
    output                              branch_take,
    // to EX/MEM stage pipeline
    output ex2mem_pipeline_ctrl_t       ex2mem_pipeline_ctrl,
    output ex2mem_pipeline_exc_t        ex2mem_pipeline_exc,
    output ex2mem_pipeline_data_t       ex2mem_pipeline_data
);


    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    logic [`DATA_RANGE] op1_forwarded;
    logic [`DATA_RANGE] op2_forwarded;
    logic [`DATA_RANGE] alu_op0;
    logic [`DATA_RANGE] alu_op1;

    logic               stage_run;

    ex2mem_pipeline_ctrl_t   ex_stage_ctrl;
    ex2mem_pipeline_exc_t    ex_stage_exc;
    ex2mem_pipeline_data_t   ex_stage_data;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    // Forwarding MUX
    assign op1_forwarded =  (id2ex_pipeline_data.op1_forward_from_mem) ? ex2mem_pipeline_data.alu_out :
                            (id2ex_pipeline_data.op1_forward_from_wb)  ? wb_reg_writedata :
                            id2ex_pipeline_data.rs1_readdata;

    assign op2_forwarded =  (id2ex_pipeline_data.op2_forward_from_mem) ? ex2mem_pipeline_data.alu_out :
                            (id2ex_pipeline_data.op2_forward_from_wb)  ? wb_reg_writedata :
                            id2ex_pipeline_data.rs2_readdata;

    // immediate select
    assign alu_op0 = id2ex_pipeline_data.alu_op1_sel_pc   ? id2ex_pipeline_data.pc :
                     id2ex_pipeline_data.alu_op1_sel_zero ? 'b0 :
                     op1_forwarded;

    assign alu_op1 = id2ex_pipeline_data.alu_op2_sel_imm  ? id2ex_pipeline_data.imm_value :
                     id2ex_pipeline_data.alu_op2_sel_4    ? 'd4 :
                     op2_forwarded;

    // Signal to LSU
    assign lsu_writedata  = op2_forwarded;
    assign lsu_mem_read   = id2ex_pipeline_ctrl.mem_read;
    assign lsu_mem_write  = id2ex_pipeline_ctrl.mem_write;
    assign lsu_mem_opcode = id2ex_pipeline_data.mem_opcode;
    // use a separate memory address generation (AGU) for better performance
    assign lsu_address    = op1_forwarded + id2ex_pipeline_data.imm_value;

    // pipelien stge signal
    assign ex_stage_ctrl.valid = id2ex_pipeline_ctrl.valid;
    assign ex_stage_ctrl.csr_read = id2ex_pipeline_ctrl.csr_read;
    assign ex_stage_ctrl.csr_write = id2ex_pipeline_ctrl.csr_write;
    assign ex_stage_ctrl.reg_write = id2ex_pipeline_ctrl.reg_write & ~lsu_exception_load_addr_misaligned;
    assign ex_stage_ctrl.mret = id2ex_pipeline_ctrl.mret;

    assign ex_stage_exc.exception_ill_instr = id2ex_pipeline_exc.exception_ill_instr;
    assign ex_stage_exc.exception_load_addr_misaligned = lsu_exception_load_addr_misaligned;
    assign ex_stage_exc.exception_store_addr_misaligned = lsu_exception_store_addr_misaligned;

    assign ex_stage_data.pc = id2ex_pipeline_data.pc;
    assign ex_stage_data.instruction = id2ex_pipeline_data.instruction;
    assign ex_stage_data.csr_write_opcode = id2ex_pipeline_data.csr_write_opcode;
    assign ex_stage_data.csr_writedata = id2ex_pipeline_data.alu_op2_sel_imm ? id2ex_pipeline_data.imm_value : op1_forwarded;
    assign ex_stage_data.csr_address = id2ex_pipeline_data.csr_address;
    assign ex_stage_data.reg_regid = id2ex_pipeline_data.reg_regid;
    assign ex_stage_data.lsu_address = lsu_address;

    // pipeline stage
    assign stage_run = ~ex_stall;

    always @(posedge clk) begin
        if (rst) ex2mem_pipeline_ctrl <= 0;
        else if (!id2ex_pipeline_ctrl.valid || ex_flush) ex2mem_pipeline_ctrl <= 0;
        else if (stage_run) ex2mem_pipeline_ctrl <= ex_stage_ctrl;
    end

    always @(posedge clk) begin
        if (rst) ex2mem_pipeline_exc <= 0;
        else if (ex_flush) ex2mem_pipeline_exc <= 0;
        else if (stage_run) ex2mem_pipeline_exc <= ex_stage_exc;
    end

    always @(posedge clk) begin
        if (stage_run) ex2mem_pipeline_data <= ex_stage_data;
    end

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    alu u_alu (
         .alu_out       (ex_stage_data.alu_out[`DATA_RANGE]),
         .alu_op0       (alu_op0[`DATA_RANGE]),
         .alu_op1       (alu_op1[`DATA_RANGE]),
         .alu_opcode    (id2ex_pipeline_data.alu_opcode));


    bu u_bu (
        .branch         (id2ex_pipeline_ctrl.branch),
        .jal            (id2ex_pipeline_ctrl.jal),
        .jalr           (id2ex_pipeline_ctrl.jalr),
        .branch_opcode  (id2ex_pipeline_data.branch_opcode),
        .branch_pc      (branch_pc[`PC_RANGE]),
        .branch_take    (branch_take),
        .op1            (op1_forwarded),
        .op2            (op2_forwarded),
        .imm_value      (id2ex_pipeline_data.imm_value),
        .pc             (id2ex_pipeline_data.pc),
        .exception_instr_addr_misaligned(ex_stage_exc.exception_instr_addr_misaligned));

endmodule
