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


/**

WB stage contains the csr module and the trap control logic

*/

`include "core.svh"

module WB (
    input                           clk,
    input                           rst,
    input                           wb_stall,
    // Interrupt
    input                           software_interrupt,
    input                           timer_interrupt,
    input                           external_interrupt,
    input                           debug_interrupt,
    // input from MEM/WB stage pipe
    input mem2wb_pipeline_ctrl_t    mem2wb_pipeline_ctrl,
    input mem2wb_pipeline_exc_t     mem2wb_pipeline_exc,
    input mem2wb_pipeline_data_t    mem2wb_pipeline_data,
    input [`DATA_RANGE]             mem2wb_pipeline_memory_data,
    // input from MEM stge
    input                           mem_valid,
    input [`DATA_RANGE]             mem_instruction_pc,
    // to register file
    output                          wb_reg_write,
    output [`RF_RANGE]              wb_reg_regid,
    output [`DATA_RANGE]            wb_reg_writedata,
    // to EX forwarding
    output [`DATA_RANGE]            wb_forward_data,
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
    logic                   i_mip_meip_wen;
    logic                   i_mip_msip_wen;
    logic                   i_mip_mtip_wen;
    logic                   i_mip_meip;
    logic                   i_mip_msip;
    logic                   i_mip_mtip;

    logic [31:0]            o_mepc_value;
    logic [31:0]            o_mscratch_value;
    logic                   o_mstatus_mie;
    logic                   o_mstatus_mpie;
    logic [29:0]            o_mtvec_base;
    logic [1:0]             o_mtvec_mode;
    logic                   o_mie_meie;
    logic                   o_mie_msie;
    logic                   o_mie_mtie;

    logic [`DATA_RANGE]     csr_readdata;
    logic                   csr_write;
    logic                   csr_read;

    logic                   next_instruction_valid;
    logic [`DATA_RANGE]     next_instruction_pc;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign wb_reg_write     = mem2wb_pipeline_ctrl.reg_write;
    assign wb_reg_writedata = mem2wb_pipeline_ctrl.csr_read ? csr_readdata :
                              mem2wb_pipeline_ctrl.mem_read ? mem2wb_pipeline_memory_data : mem2wb_pipeline_data.reg_writedata;
    assign wb_reg_regid     = mem2wb_pipeline_data.reg_regid;

    // To improve timing:
    // - For CSR we wait till the CSR is completed in WB stage so we don't forward CSR data to EX stage
    // - We do not forward the memory read data to EX stage because memory data come back at EX stage
    //   and we also need to post process it
    assign wb_forward_data  = mem2wb_pipeline_data.reg_writedata;

    assign csr_read = mem2wb_pipeline_ctrl.csr_read;
    assign csr_write = mem2wb_pipeline_ctrl.csr_write;

    // When we return from interrupt, wshould return to the "next instructions" of the instruction when interrupts is taken
    // In general, people would think that the "next instructions" is pc + 4, however, this is not always true.
    // For example, if the instruction in WB stage is a taken branch, then the next instruction is not pc + 4.
    // One reasonable solution here is to use the instruction in memory stage as the next instruction,
    // and we also need to make sure that the instruction in memory stage is valid.
    // So to take a interrupt, we need to wait till we have a valid instruction in memory stage.
    assign next_instruction_valid = mem_valid;
    assign next_instruction_pc = mem_instruction_pc;

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
     .o_mstatus_mpie                    (o_mstatus_mpie),
     .o_mstatus_mie                     (o_mstatus_mie),
     .o_mtvec_base                      (o_mtvec_base[29:0]),
     .o_mtvec_mode                      (o_mtvec_mode[1:0]),
     .o_mscratch_value                  (o_mscratch_value[31:0]),
     .o_mepc_value                      (o_mepc_value[31:0]),
     .o_mie_msie                        (o_mie_msie),
     .o_mie_mtie                        (o_mie_mtie),
     .o_mie_meie                        (o_mie_meie),
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
     .i_mtval_value                     (i_mtval_value[31:0]),
     .i_mip_msip_wen                    (i_mip_msip_wen),
     .i_mip_msip                        (i_mip_msip),
     .i_mip_mtip_wen                    (i_mip_mtip_wen),
     .i_mip_mtip                        (i_mip_mtip),
     .i_mip_meip_wen                    (i_mip_meip_wen),
     .i_mip_meip                        (i_mip_meip));

    // trap_ctrl
    /* trap_ctrl AUTO_TEMPLATE (
        .exception_instr_addr_misaligned   (mem2wb_pipeline_exc.exception_instr_addr_misaligned),
        .exception_ill_instr               (mem2wb_pipeline_exc.exception_ill_instr),
        .exception_load_addr_misaligned    (mem2wb_pipeline_exc.exception_load_addr_misaligned),
        .exception_store_addr_misaligned   (mem2wb_pipeline_exc.exception_store_addr_misaligned),
        .mret                              (mem2wb_pipeline_ctrl.mret),
        .pc                                (mem2wb_pipeline_data.pc),
        .fault_address                     (mem2wb_pipeline_data.mem_address),
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
     .o_mip_msip_wen                    (i_mip_msip_wen),        // Templated
     .o_mip_msip                        (i_mip_msip),            // Templated
     .o_mip_mtip_wen                    (i_mip_mtip_wen),        // Templated
     .o_mip_mtip                        (i_mip_mtip),            // Templated
     .o_mip_meip_wen                    (i_mip_meip_wen),        // Templated
     .o_mip_meip                        (i_mip_meip),            // Templated
     .trap_take                         (trap_take),
     .trap_pc                           (trap_pc[`PC_RANGE]),
     // Inputs
     .clk                               (clk),
     .rst                               (rst),
     .wb_stall                          (wb_stall),
     .pc                                (mem2wb_pipeline_data.pc), // Templated
     .fault_address                     (mem2wb_pipeline_data.mem_address), // Templated
     .fault_instruction                 (mem2wb_pipeline_data.instruction), // Templated
     .next_instruction_valid            (next_instruction_valid),
     .next_instruction_pc               (next_instruction_pc[`DATA_RANGE]),
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
     .i_mepc_value                      (o_mepc_value),          // Templated
     .i_mie_msie                        (o_mie_msie),            // Templated
     .i_mie_mtie                        (o_mie_mtie),            // Templated
     .i_mie_meie                        (o_mie_meie));            // Templated


endmodule
