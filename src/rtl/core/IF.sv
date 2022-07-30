// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Instruction Fetch stage
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module IF (
    input                   clk,
    input                   rst,
    // stage control
    input                   if_flush,
    input                   if_stall,
    // instruction bus
    output avalon_req_t     ibus_avalon_req,
    input  avalon_resp_t    ibus_avalon_resp,
    // branch control
    input                   branch_take,
    input [`PC_RANGE]       branch_pc,
    // trap control
    input                   trap_take,
    input [`PC_RANGE]       trap_pc,
    // pipelineline stage
    output if2id_pipeline_ctrl_t if2id_pipeline_ctrl,
    output if2id_pipeline_data_t if2id_pipeline_data
);

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    ifu u_ifu (
        .clk                (clk),
        .rst                (rst),
        .ifu_flush          (if_flush),
        .ifu_stall          (if_stall),
        .branch_take        (branch_take),
        .branch_pc          (branch_pc),
        .trap_take          (trap_take),
        .trap_pc            (trap_pc),
        .instruction        (if2id_pipeline_data.instruction),
        .instruction_pc     (if2id_pipeline_data.pc),
        .instruction_valid  (if2id_pipeline_ctrl.valid),
        .ibus_avalon_req    (ibus_avalon_req),
        .ibus_avalon_resp   (ibus_avalon_resp)
    );

endmodule
