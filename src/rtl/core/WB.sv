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

    /*AUTOWIRE*/

    /*AUTOREG*/

    /*AUTOREGINPUT*/


    logic  [30:0]           i_mcause_exception_code;
    logic                   i_mcause_interrupt;
    logic  [31:0]           i_mepc_value;
    logic                   i_mstatus_mie;
    logic                   i_mstatus_mpie;
    logic  [1:0]            i_mstatus_mpp;
    logic  [31:0]           i_mtval_value;
    logic                   trap;

    logic [`DATA_RANGE]     csr_readdata;
    logic [31:0]            o_mepc_value;
    logic [31:0]            o_mscratch_value;
    logic                   o_mstatus_mie;
    logic                   o_mstatus_mpie;
    logic [29:0]            o_mtvec_base;
    logic [1:0]             o_mtvec_mode;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign wb_reg_write     = mem2wb_pipeline_ctrl.reg_write;
    assign wb_reg_writedata = mem2wb_pipeline_ctrl.csr_read ? csr_readdata : mem2wb_pipeline_data.reg_writedata;
    assign wb_reg_regid     = mem2wb_pipeline_data.reg_regid;

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    // csr
    /* csr AUTO_TEMPLATE (
        .csr_read           (mem2wb_pipeline_ctrl.csr_read),
        .csr_write          (mem2wb_pipeline_ctrl.csr_write),
        .csr_write_opcode   (mem2wb_pipeline_data.csr_write_opcode),
        .csr_address        (mem2wb_pipeline_data.csr_address),
        .csr_writedata      (mem2wb_pipeline_data.csr_writedata),
        .csr_readdata       (csr_readdata[`DATA_RANGE]),
    ); */
    csr
    u_csr
    (/*AUTOINST*/
     // Outputs
     .csr_readdata                      (csr_readdata[`DATA_RANGE]), // Templated
     .o_mepc_value                      (o_mepc_value[31:0]),
     .o_mscratch_value                  (o_mscratch_value[31:0]),
     .o_mstatus_mie                     (o_mstatus_mie),
     .o_mstatus_mpie                    (o_mstatus_mpie),
     .o_mtvec_base                      (o_mtvec_base[29:0]),
     .o_mtvec_mode                      (o_mtvec_mode[1:0]),
     // Inputs
     .clk                               (clk),
     .rst                               (rst),
     .csr_read                          (mem2wb_pipeline_ctrl.csr_read), // Templated
     .csr_write                         (mem2wb_pipeline_ctrl.csr_write), // Templated
     .csr_write_opcode                  (mem2wb_pipeline_data.csr_write_opcode), // Templated
     .csr_address                       (mem2wb_pipeline_data.csr_address), // Templated
     .csr_writedata                     (mem2wb_pipeline_data.csr_writedata), // Templated
     .trap                              (trap),
     .i_mcause_exception_code           (i_mcause_exception_code[30:0]),
     .i_mcause_interrupt                (i_mcause_interrupt),
     .i_mepc_value                      (i_mepc_value[31:0]),
     .i_mstatus_mie                     (i_mstatus_mie),
     .i_mstatus_mpie                    (i_mstatus_mpie),
     .i_mstatus_mpp                     (i_mstatus_mpp[1:0]),
     .i_mtval_value                     (i_mtval_value[31:0]));

endmodule
