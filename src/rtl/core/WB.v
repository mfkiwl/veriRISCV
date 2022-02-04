///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: MEM
//
// Author: Heqing Huang
// Date Created: 01/19/2022
//
// ================== Description ==================
//
// WB (Write back stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module WB (
    input                           clk,
    input                           rst,
    // Interrupt
    input                           software_interrupt,
    input                           timer_interrupt,
    input                           external_interrupt,
    input                           debug_interrupt,
    // input from MEM/WB stage pipe
    input [`PC_RANGE]               mem2wb_pc,
    input [`DATA_RANGE]             mem2wb_instruction,
    input                           mem2wb_mret,
    input                           mem2wb_reg_wen,
    input [`RF_RANGE]               mem2wb_reg_waddr,
    input [`DATA_RANGE]             mem2wb_reg_wdata,
    input                           mem2wb_csr_rd,
    input [`CORE_CSR_OP_RANGE]      mem2wb_csr_wr_op,
    input [`DATA_RANGE]             mem2wb_csr_wdata,
    input [`CORE_CSR_ADDR_RANGE]    mem2wb_csr_addr,
    input [`DATA_RANGE]             mem2wb_lsu_addr,
    input                           mem2wb_exc_ill_instr,
    input                           mem2wb_exc_instr_addr_misaligned,
    input                           mem2wb_exc_load_addr_misaligned,
    input                           mem2wb_exc_store_addr_misaligned,
    // to register file
    output                          wb_reg_wen,
    output [`RF_RANGE]              wb_reg_waddr,
    output [`DATA_RANGE]            wb_reg_wdata
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [30:0]         i_mcause_exception_code;// From trap_ctrl of trap_ctrl.v
    wire                i_mcause_interrupt;     // From trap_ctrl of trap_ctrl.v
    wire [`DATA_RANGE]  i_mepc_value;           // From trap_ctrl of trap_ctrl.v
    wire                i_mstatus_mie;          // From trap_ctrl of trap_ctrl.v
    wire                i_mstatus_mpie;         // From trap_ctrl of trap_ctrl.v
    wire [1:0]          i_mstatus_mpp;          // From trap_ctrl of trap_ctrl.v
    wire [`DATA_RANGE]  i_mtval_value;          // From trap_ctrl of trap_ctrl.v
    wire [31:0]         o_mepc_value;           // From csr of csr.v
    wire [31:0]         o_mscratch_value;       // From csr of csr.v
    wire                o_mstatus_mie;          // From csr of csr.v
    wire                o_mstatus_mpie;         // From csr of csr.v
    wire [29:0]         o_mtvec_base;           // From csr of csr.v
    wire [1:0]          o_mtvec_mode;           // From csr of csr.v
    wire                take_trap;              // From trap_ctrl of trap_ctrl.v
    wire [`PC_RANGE]    target_pc;              // From trap_ctrl of trap_ctrl.v
    // End of automatics

    /*AUTOREG*/

    wire [`DATA_RANGE]  csr_rdata;

    //////////////////////////////

    assign wb_reg_wen = mem2wb_reg_wen;
    assign wb_reg_wdata = mem2wb_csr_rd ? csr_rdata : mem2wb_reg_wdata;
    assign wb_reg_waddr = mem2wb_reg_waddr;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // trap_ctrl
    // the i_ and o_ are inverted here, so the signal can be connected to
    // csr module by the name. Not ideal and error prone...
    /* trap_ctrl AUTO_TEMPLATE (
         .pc                        (mem2wb_pc),
         .fault_instruction         (mem2wb_instruction),
         .fault_address             (mem2wb_lsu_addr),
         .exc_instr_addr_misaligned (mem2wb_exc_instr_addr_misaligned),
         .exc_ill_instr             (mem2wb_exc_ill_instr),
         .exc_load_addr_misaligned  (mem2wb_exc_load_addr_misaligned),
         .exc_store_addr_misaligned (mem2wb_exc_store_addr_misaligned),
         .mret                      (mem2wb_mret),
         .i_\(.*\)                  (o_\1[]),
         .o_\(.*\)                  (i_\1[]),
        ); */
    trap_ctrl
    trap_ctrl(/*AUTOINST*/
              // Outputs
              .o_mcause_exception_code  (i_mcause_exception_code[30:0]), // Templated
              .o_mcause_interrupt       (i_mcause_interrupt),    // Templated
              .o_mepc_value             (i_mepc_value[`DATA_RANGE]), // Templated
              .o_mtval_value            (i_mtval_value[`DATA_RANGE]), // Templated
              .o_mstatus_mie            (i_mstatus_mie),         // Templated
              .o_mstatus_mpie           (i_mstatus_mpie),        // Templated
              .o_mstatus_mpp            (i_mstatus_mpp[1:0]),    // Templated
              .take_trap                (take_trap),
              .target_pc                (target_pc[`PC_RANGE]),
              // Inputs
              .clk                      (clk),
              .rst                      (rst),
              .pc                       (mem2wb_pc),             // Templated
              .fault_address            (mem2wb_lsu_addr),       // Templated
              .fault_instruction        (mem2wb_instruction),    // Templated
              .software_interrupt       (software_interrupt),
              .timer_interrupt          (timer_interrupt),
              .external_interrupt       (external_interrupt),
              .debug_interrupt          (debug_interrupt),
              .exc_instr_addr_misaligned(mem2wb_exc_instr_addr_misaligned), // Templated
              .exc_ill_instr            (mem2wb_exc_ill_instr),  // Templated
              .exc_load_addr_misaligned (mem2wb_exc_load_addr_misaligned), // Templated
              .exc_store_addr_misaligned(mem2wb_exc_store_addr_misaligned), // Templated
              .mret                     (mem2wb_mret),           // Templated
              .i_mtvec_base             (o_mtvec_base[`DATA_WIDTH-3:0]), // Templated
              .i_mtvec_mode             (o_mtvec_mode[1:0]),     // Templated
              .i_mstatus_mie            (o_mstatus_mie),         // Templated
              .i_mstatus_mpie           (o_mstatus_mpie),        // Templated
              .i_mepc_value             (o_mepc_value[`PC_RANGE])); // Templated


    // msr
    /* csr AUTO_TEMPLATE (
        .\(.*\)_wen     (take_trap),
        .csr_rd         (mem2wb_csr_rd),
        .csr_wr_op      (mem2wb_csr_wr_op[]),
        .csr_addr       (mem2wb_csr_addr[]),
        .csr_wdata      (mem2wb_csr_wdata[]),
        ); */
    csr
    csr(/*AUTOINST*/
        // Outputs
        .csr_rdata                      (csr_rdata[`DATA_RANGE]),
        .o_mepc_value                   (o_mepc_value[31:0]),
        .o_mscratch_value               (o_mscratch_value[31:0]),
        .o_mstatus_mie                  (o_mstatus_mie),
        .o_mstatus_mpie                 (o_mstatus_mpie),
        .o_mtvec_base                   (o_mtvec_base[29:0]),
        .o_mtvec_mode                   (o_mtvec_mode[1:0]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .csr_rd                         (mem2wb_csr_rd),         // Templated
        .csr_wr_op                      (mem2wb_csr_wr_op[`CORE_CSR_OP_RANGE]), // Templated
        .csr_addr                       (mem2wb_csr_addr[`CORE_CSR_ADDR_RANGE]), // Templated
        .csr_wdata                      (mem2wb_csr_wdata[`DATA_RANGE]), // Templated
        .take_trap                      (take_trap),
        .i_mcause_exception_code        (i_mcause_exception_code[30:0]),
        .i_mcause_interrupt             (i_mcause_interrupt),
        .i_mepc_value                   (i_mepc_value[31:0]),
        .i_mstatus_mie                  (i_mstatus_mie),
        .i_mstatus_mpie                 (i_mstatus_mpie),
        .i_mstatus_mpp                  (i_mstatus_mpp[1:0]),
        .i_mtval_value                  (i_mtval_value[31:0]));

endmodule
