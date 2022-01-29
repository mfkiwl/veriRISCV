///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: MEM
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// MEM (Memory stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module MEM (
    input                               clk,
    input                               rst,
    // input from EX/MEM stage pipe
    input                               ex2mem_reg_wen,
    input [`RF_RANGE]                   ex2mem_reg_waddr,
    input [`DATA_RANGE]                 ex2mem_alu_out,
    input                               ex2mem_mem_rd,
    input                               ex2mem_csr_rd,
    input [`CORE_CSR_OP_RANGE]          ex2mem_csr_wr_op,
    input [`DATA_RANGE]                 ex2mem_csr_wdata,
    input [`CORE_CSR_ADDR_RANGE]        ex2mem_csr_addr,
    input                               ex2mem_sel_csr,
    input                               ex2mem_ill_instr,
    // input from lsu
    input [`DATA_RANGE]                 lsu_rdata,
    // pipeline stage
    output reg                          mem2wb_reg_wen,
    output reg [`RF_RANGE]              mem2wb_reg_waddr,
    output reg [`DATA_RANGE]            mem2wb_reg_wdata,
    output reg                          mem2wb_csr_rd,
    output reg [`CORE_CSR_OP_RANGE]     mem2wb_csr_wr_op,
    output reg [`DATA_RANGE]            mem2wb_csr_wdata,
    output reg [`CORE_CSR_ADDR_RANGE]   mem2wb_csr_addr,
    output reg                          mem2wb_sel_csr,
    output reg                          mem2wb_ill_instr
);

    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    wire [`DATA_RANGE]          reg_wdata;

    //////////////////////////////

    assign reg_wdata = ex2mem_mem_rd ? lsu_rdata : ex2mem_alu_out;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            mem2wb_reg_wen <= 1'b0;
            mem2wb_csr_rd <= 1'b0;
            mem2wb_csr_wr_op <= `CORE_CSR_NOP;
            mem2wb_ill_instr <= 1'b0;
        end
        else begin
            mem2wb_reg_wen <= ex2mem_reg_wen;
            mem2wb_csr_rd <= ex2mem_csr_rd;
            mem2wb_csr_wr_op <= ex2mem_csr_wr_op;
            mem2wb_ill_instr <= ex2mem_ill_instr;
        end
    end

    always @(posedge clk) begin
        mem2wb_reg_wdata <= reg_wdata;
        mem2wb_reg_waddr <= ex2mem_reg_waddr;
        mem2wb_csr_wdata <= ex2mem_csr_wdata;
        mem2wb_csr_addr <= ex2mem_csr_addr;
        mem2wb_sel_csr <= ex2mem_sel_csr;
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////


endmodule