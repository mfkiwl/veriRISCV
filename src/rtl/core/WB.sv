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
    input                           wb_flush,
    // Interrupt
    input                           software_interrupt,
    input                           timer_interrupt,
    input                           external_interrupt,
    input                           debug_interrupt,
    // input from MEM/WB stage pipe
    input mem2wb_pipeline_ctrl_t    mem2wb_pipeline_ctrl,
    input mem2wb_pipeline_exc_t     mem2wb_pipeline_exc,
    input mem2wb_pipeline_data_t    mem2wb_pipeline_data,
    // to register file
    output                          wb_reg_write,
    output [`RF_RANGE]              wb_reg_regid,
    output [`DATA_RANGE]            wb_reg_writedata,
    // to IF
    output [`PC_RANGE]              trap_pc,
    output                          trap_take
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

    logic [`DATA_RANGE]     csr_readdata;
    logic [31:0]            o_mepc_value;
    logic [31:0]            o_mscratch_value;
    logic                   o_mstatus_mie;
    logic                   o_mstatus_mpie;
    logic [29:0]            o_mtvec_base;
    logic [1:0]             o_mtvec_mode;

    logic                   csr_write;
    logic                   csr_read;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign wb_reg_write     = mem2wb_pipeline_ctrl.reg_write & ~wb_flush;
    assign wb_reg_writedata = mem2wb_pipeline_ctrl.csr_read ? csr_readdata : mem2wb_pipeline_data.reg_writedata;
    assign wb_reg_regid     = mem2wb_pipeline_data.reg_regid;

    assign csr_read = mem2wb_pipeline_ctrl.csr_read & ~wb_flush;
    assign csr_write = mem2wb_pipeline_ctrl.csr_write & ~wb_flush;

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    // csr
    /* csr AUTO_TEMPLATE (
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
     .csr_read                          (csr_read),
     .csr_write                         (csr_write),
     .csr_write_opcode                  (mem2wb_pipeline_data.csr_write_opcode), // Templated
     .csr_address                       (mem2wb_pipeline_data.csr_address), // Templated
     .csr_writedata                     (mem2wb_pipeline_data.csr_writedata), // Templated
     .trap_take                         (trap_take),
     .i_mcause_exception_code           (i_mcause_exception_code[30:0]),
     .i_mcause_interrupt                (i_mcause_interrupt),
     .i_mepc_value                      (i_mepc_value[31:0]),
     .i_mstatus_mie                     (i_mstatus_mie),
     .i_mstatus_mpie                    (i_mstatus_mpie),
     .i_mstatus_mpp                     (i_mstatus_mpp[1:0]),
     .i_mtval_value                     (i_mtval_value[31:0]));

    // trap_ctrl
    /* trap_ctrl AUTO_TEMPLATE (
        .exception_instr_addr_misaligned   (mem2wb_pipeline_exc.exception_instr_addr_misaligned),
        .exception_ill_instr               (mem2wb_pipeline_exc.exception_ill_instr),
        .exception_load_addr_misaligned    (mem2wb_pipeline_exc.exception_load_addr_misaligned),
        .exception_store_addr_misaligned   (mem2wb_pipeline_exc.exception_store_addr_misaligned),
        .mret                              (mem2wb_pipeline_ctrl.mret),
        .pc                                (mem2wb_pipeline_data.pc),
        .fault_address                     (mem2wb_pipeline_data.lsu_address),
        .fault_instruction                 (mem2wb_pipeline_data.instruction),

        .i_\(.*\)                          (o_\1),
        .o_\(.*\)                          (i_\1),
    ); */
    trap_ctrl
    u_trap_ctrl
    (/*AUTOINST*/
     // Outputs
     .o_mcause_exception_code           (i_mcause_exception_code), // Templated
     .o_mcause_interrupt                (i_mcause_interrupt),    // Templated
     .o_mepc_value                      (i_mepc_value),          // Templated
     .o_mtval_value                     (i_mtval_value),         // Templated
     .o_mstatus_mie                     (i_mstatus_mie),         // Templated
     .o_mstatus_mpie                    (i_mstatus_mpie),        // Templated
     .o_mstatus_mpp                     (i_mstatus_mpp),         // Templated
     .trap_take                         (trap_take),
     .trap_pc                           (trap_pc[`PC_RANGE]),
     // Inputs
     .clk                               (clk),
     .rst                               (rst),
     .pc                                (mem2wb_pipeline_data.pc), // Templated
     .fault_address                     (mem2wb_pipeline_data.lsu_address), // Templated
     .fault_instruction                 (mem2wb_pipeline_data.instruction), // Templated
     .software_interrupt                (software_interrupt),
     .timer_interrupt                   (timer_interrupt),
     .external_interrupt                (external_interrupt),
     .debug_interrupt                   (debug_interrupt),
     .exception_instr_addr_misaligned   (mem2wb_pipeline_exc.exception_instr_addr_misaligned), // Templated
     .exception_ill_instr               (mem2wb_pipeline_exc.exception_ill_instr), // Templated
     .exception_load_addr_misaligned    (mem2wb_pipeline_exc.exception_load_addr_misaligned), // Templated
     .exception_store_addr_misaligned   (mem2wb_pipeline_exc.exception_store_addr_misaligned), // Templated
     .mret                              (mem2wb_pipeline_ctrl.mret), // Templated
     .i_mtvec_base                      (o_mtvec_base),          // Templated
     .i_mtvec_mode                      (o_mtvec_mode),          // Templated
     .i_mstatus_mie                     (o_mstatus_mie),         // Templated
     .i_mstatus_mpie                    (o_mstatus_mpie),        // Templated
     .i_mepc_value                      (o_mepc_value));          // Templated


endmodule
