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
    // input from MEM/WB stage pipe
    input [`PC_RANGE]               mem2wb_pc,
    input [`DATA_RANGE]             mem2wb_isntruction,
    input                           mem2wb_reg_wen,
    input [`RF_RANGE]               mem2wb_reg_waddr,
    input [`DATA_RANGE]             mem2wb_reg_wdata,
    input                           mem2wb_csr_rd,
    input [`CORE_CSR_OP_RANGE]      mem2wb_csr_wr_op,
    input [`DATA_RANGE]             mem2wb_csr_wdata,
    input [`CORE_CSR_ADDR_RANGE]    mem2wb_csr_addr,
    input                           mem2wb_sel_csr,
    input                           mem2wb_ill_instr,
    input                           mem2wb_exc_instr_addr_misaligned,
    // to register file
    output                          wb_reg_wen,
    output [`RF_RANGE]              wb_reg_waddr,
    output [`DATA_RANGE]            wb_reg_wdata
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/

    /*AUTOREG*/

    wire [`DATA_RANGE]  csr_rdata;

    wire [`DATA_RANGE]  mcause_o;
    wire [`DATA_RANGE]  mepc_o;
    wire                mstatus_mie_o;
    wire                mstatus_mpie_o;
    wire [1:0]          mstatus_mpp_o;
    wire [`DATA_RANGE]  mtval_o;
    wire [`PC_RANGE]    target_pc;
    wire                take_trap;

    //////////////////////////////

    assign wb_reg_wen = mem2wb_reg_wen;
    assign wb_reg_wdata = mem2wb_sel_csr ? csr_rdata : mem2wb_reg_wdata;
    assign wb_reg_waddr = mem2wb_reg_waddr;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // csr
    /* csr AUTO_TEMPLATE (
         .csr_rd                        (mem2wb_csr_rd),
         .csr_wr_op                     (mem2wb_csr_wr_op[`CORE_CSR_OP_RANGE]),
         .csr_addr                      (mem2wb_csr_addr[`CORE_CSR_ADDR_RANGE]),
         .csr_wdata                     (mem2wb_csr_wdata[`DATA_RANGE]),
        ); */
    csr
    csr (/*AUTOINST*/
         // Outputs
         .csr_rdata                     (csr_rdata[`DATA_RANGE]),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .csr_rd                        (mem2wb_csr_rd),         // Templated
         .csr_wr_op                     (mem2wb_csr_wr_op[`CORE_CSR_OP_RANGE]), // Templated
         .csr_addr                      (mem2wb_csr_addr[`CORE_CSR_ADDR_RANGE]), // Templated
         .csr_wdata                     (mem2wb_csr_wdata[`DATA_RANGE])); // Templated

    // trap_ctrl
    /* trap_ctrl AUTO_TEMPLATE (
         .pc                        (mem2wb_pc),
         .fault_instruction         (mem2wb_isntruction),
        ); */
    //trap_ctrl
    //trap_ctrl(/*AUTOINST*/);

endmodule
