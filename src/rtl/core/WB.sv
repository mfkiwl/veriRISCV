// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/19/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Write Back Stage
// ------------------------------------------------------------------------------------------------


`include "core.svh"

module WB (
    input                           clk,
    input                           rst,
    // Interrupt
    input                           software_interrupt,
    input                           timer_interrupt,
    input                           external_interrupt,
    input                           debug_interrupt,
    // input from MEM/WB stage pipe
    input mem2wb_pipeline_ctrl_t    mem2wb_pipeline_ctrl,
    input mem2wb_pipeline_data_t    mem2wb_pipeline_data,
    // to register file
    output                          wb_reg_write,
    output [`RF_RANGE]              wb_reg_regid,
    output [`DATA_RANGE]            wb_reg_writedata
);


    // ---------------------------------
    // Signal Declaration
    // ---------------------------------


    logic [`DATA_RANGE]  csr_rdata;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign wb_reg_write     = mem2wb_pipeline_ctrl.reg_write;
    assign wb_reg_writedata = mem2wb_pipeline_data.reg_writedata;
    assign wb_reg_regid     = mem2wb_pipeline_data.reg_regid;


    // ---------------------------------
    // Module instantiation
    // ---------------------------------


endmodule
