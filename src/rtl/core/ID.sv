// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Instruction Decode Stage
// ------------------------------------------------------------------------------------------------


/**

ID stage contains the instruction decoder and the register file.

ID stage also detects if the instruction in ID stage depends on a load instruction in the pipeline.
Unlike the typcial 5 stage pipeline model touch in Computer architecture class,
here we do not forward the read data from the load instruction to EX stage at all so we need to stall the
pipelines for 2 clocks.

Here are the reasons:
- In our micro-architecture, the memory read/write requests are sent to the bus at MEM stage.
  Most of FPGA BRAM has an input register, so the actual read/write happens at the next clock cycle which is WB stage
  so the timing cricital path is at the WB stage.
- If we forward the read data from WB stage to EX stage, then the timing critical path will be:
  input_register clk to q + internal FPGA BRAM read delay + post process the read data + forwarding logic
  + ALU delay + setup time
  The delay is too high which almost slow down the clock speed by half in FPGA


To Improve timing in EX stage, we check if we need to foward in EX stage, and store the information in
pipeline registers. (pipeline retiming technique)

*/

`include "core.svh"

module ID (
    input                               clk,
    input                               rst,
    input                               id_flush,
    input                               id_stall,
    input                               id_bubble,

    // from IF/ID stage pipeline
    input if2id_pipeline_ctrl_t         if2id_pipeline_ctrl,
    input if2id_pipeline_data_t         if2id_pipeline_data,

    // from EX stage
    input                               ex_mem_read,

    // from MEM stage
    input [`RF_RANGE]                   mem_reg_regid,
    input                               mem_reg_write,
    input                               mem_mem_read,

    // from WB stage
    input                               wb_reg_write,
    input [`RF_RANGE]                   wb_reg_regid,
    input [`DATA_RANGE]                 wb_reg_writedata,

    // to HDU
    output                              hdu_load_stall_req,
    // to ID/EX pipelineline stage
    output id2ex_pipeline_ctrl_t        id2ex_pipeline_ctrl,
    output id2ex_pipeline_exc_t         id2ex_pipeline_exc,
    output id2ex_pipeline_data_t        id2ex_pipeline_data
);


    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    logic                   regfile_rs1_read;
    logic [`RF_RANGE]       regfile_rs1_regid;

    logic                   regfile_rs2_read;
    logic [`RF_RANGE]       regfile_rs2_regid;

    logic                   rs1_match_ex;
    logic                   rs1_match_mem;
    logic                   rs1_non_zero;
    logic                   rs2_match_ex;
    logic                   rs2_match_mem;
    logic                   rs2_non_zero;

    id2ex_pipeline_ctrl_t   id_stage_ctrl;
    id2ex_pipeline_exc_t    id_stage_exc;
    id2ex_pipeline_data_t   id_stage_data;
    logic                   stage_run;
    logic                   stage_flush;

    logic                   load_match_ex;
    logic                   load_match_mem;

    logic                   exception_ill_instr;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign id_stage_ctrl.valid       = if2id_pipeline_ctrl.valid;
    assign id_stage_data.instruction = if2id_pipeline_data.instruction;
    assign id_stage_data.pc          = if2id_pipeline_data.pc;

    assign id_stage_exc.exception_ill_instr = if2id_pipeline_ctrl.valid & exception_ill_instr;

    // Forward check on ID stage for better timing performance
    assign rs1_match_ex  = regfile_rs1_regid == id2ex_pipeline_data.reg_regid;
    assign rs1_match_mem = regfile_rs1_regid == mem_reg_regid;
    assign rs1_non_zero  = regfile_rs1_regid != 0;
    assign id_stage_data.op1_forward_from_mem = rs1_match_ex  & regfile_rs1_read & id2ex_pipeline_ctrl.reg_write & rs1_non_zero;
    assign id_stage_data.op1_forward_from_wb  = rs1_match_mem & regfile_rs1_read & mem_reg_write & rs1_non_zero;

    assign rs2_match_ex  = regfile_rs2_regid == id2ex_pipeline_data.reg_regid;
    assign rs2_match_mem = regfile_rs2_regid == mem_reg_regid;
    assign rs2_non_zero  = regfile_rs2_regid != 0;
    assign id_stage_data.op2_forward_from_mem = rs2_match_ex  & regfile_rs2_read & id2ex_pipeline_ctrl.reg_write & rs2_non_zero;
    assign id_stage_data.op2_forward_from_wb  = rs2_match_mem & regfile_rs2_read & mem_reg_write & rs2_non_zero;

    // Load dependence check
    // To improve timing, we do not forward the load data to EX stage, so we need to stall 2 cycles
    assign load_match_ex  = ex_mem_read & (rs1_match_ex & regfile_rs1_read | rs2_match_ex & regfile_rs2_read);
    assign load_match_mem = mem_mem_read & (rs1_match_mem & regfile_rs1_read | rs2_match_mem & regfile_rs2_read);
    assign hdu_load_stall_req = if2id_pipeline_ctrl.valid           // the instruction itself is valid
                              & ~id_stage_exc.exception_ill_instr   // instruction is not a illegal instruction
                              & ~id_flush                           // If ID stage is flushed, then we should not stall
                              & (load_match_ex | load_match_mem);

    // pipeline stage
    assign stage_run = ~id_stall;
    assign stage_flush = id_flush | (~if2id_pipeline_ctrl.valid | id_stage_exc.exception_ill_instr) & stage_run;

    always @(posedge clk) begin
        if (rst) id2ex_pipeline_ctrl <= 0;
        else if (stage_flush || id_bubble) id2ex_pipeline_ctrl <= 0;
        else if (stage_run) id2ex_pipeline_ctrl <= id_stage_ctrl;
    end

    always @(posedge clk) begin
        if (rst) id2ex_pipeline_exc <= 0;
        else if (id_flush || id_bubble) id2ex_pipeline_exc <= 0;
        else if (stage_run) id2ex_pipeline_exc <= id_stage_exc;
    end

    always @(posedge clk) begin
        if (stage_run) id2ex_pipeline_data <= id_stage_data;
    end

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    regfile u_regfile(
        .clk            (clk),
        .rst            (rst),
        .reg_write      (wb_reg_write),
        .reg_regid      (wb_reg_regid),
        .reg_writedata  (wb_reg_writedata),
        .rs1_regid      (regfile_rs1_regid),
        .rs1_readdata   (id_stage_data.rs1_readdata),
        .rs2_regid      (regfile_rs2_regid),
        .rs2_readdata   (id_stage_data.rs2_readdata)
    );

    decoder u_decoder (
    `ifdef ISA_RV32M
        .mul                    (id_stage_ctrl.mul),
        .div                    (id_stage_ctrl.div),
        .muldiv_opcode          (id_stage_data.muldiv_opcode),
    `endif
        .instruction            (if2id_pipeline_data.instruction),
        .regfile_reg_write      (id_stage_ctrl.reg_write),
        .regfile_reg_regid      (id_stage_data.reg_regid),
        .regfile_rs1_regid      (regfile_rs1_regid),
        .regfile_rs2_regid      (regfile_rs2_regid),
        .regfile_rs1_read       (regfile_rs1_read),
        .regfile_rs2_read       (regfile_rs2_read),
        .branch                 (id_stage_ctrl.branch),
        .branch_opcode          (id_stage_data.branch_opcode),
        .jal                    (id_stage_ctrl.jal),
        .jalr                   (id_stage_ctrl.jalr),
        .alu_op1_sel_zero       (id_stage_data.alu_op1_sel_zero),
        .alu_op1_sel_pc         (id_stage_data.alu_op1_sel_pc),
        .alu_op2_sel_4          (id_stage_data.alu_op2_sel_4),
        .alu_op2_sel_imm        (id_stage_data.alu_op2_sel_imm),
        .alu_opcode             (id_stage_data.alu_opcode),
        .imm_value              (id_stage_data.imm_value),
        .csr_read               (id_stage_ctrl.csr_read),
        .csr_write              (id_stage_ctrl.csr_write),
        .csr_write_opcode       (id_stage_data.csr_write_opcode),
        .csr_address            (id_stage_data.csr_address),
        .mem_read               (id_stage_ctrl.mem_read),
        .mem_write              (id_stage_ctrl.mem_write),
        .mem_opcode             (id_stage_data.mem_opcode),
        .mret                   (id_stage_ctrl.mret),
        .exception_ill_instr    (exception_ill_instr)
    );


endmodule
