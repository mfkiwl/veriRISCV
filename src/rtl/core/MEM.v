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
    input [`PC_RANGE]                   ex2mem_pc,
    input [`DATA_RANGE]                 ex2mem_isntruction,
    input                               ex2mem_reg_wen,
    input [`RF_RANGE]                   ex2mem_reg_waddr,
    input [`DATA_RANGE]                 ex2mem_alu_out,
    input                               ex2mem_csr_rd,
    input [`CORE_CSR_OP_RANGE]          ex2mem_csr_wr_op,
    input [`DATA_RANGE]                 ex2mem_csr_wdata,
    input [`CORE_CSR_ADDR_RANGE]        ex2mem_csr_addr,
    input                               ex2mem_sel_csr,
    input                               ex2mem_ill_instr,
    input                               ex2mem_exc_instr_addr_misaligned,
    // input from EX stage for lsu, without pipeline
    input                               lsu_mem_rd,
    input                               lsu_mem_wr,
    input [`CORE_MEM_OP_RANGE]          lsu_mem_op,
    input [`DATA_RANGE]                 lsu_addr,
    input [`DATA_RANGE]                 lsu_wdata,
    // AHBLite Interface to memory/data bus
    output                              dbus_hwrite,
    output [2:0]                        dbus_hsize,
    output [2:0]                        dbus_hburst,
    output [3:0]                        dbus_hport,
    output [1:0]                        dbus_htrans,
    output                              dbus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]      dbus_haddr,
    output [`DATA_RANGE]                dbus_hwdata,
    input                               dbus_hready,
    input                               dbus_hresp,
    input  [`DATA_RANGE]                dbus_hrdata,

    // pipeline stage
    output reg [`PC_RANGE]              mem2wb_pc,
    output reg [`DATA_RANGE]            mem2wb_isntruction,
    output reg                          mem2wb_reg_wen,
    output reg [`RF_RANGE]              mem2wb_reg_waddr,
    output reg [`DATA_RANGE]            mem2wb_reg_wdata,
    output reg                          mem2wb_csr_rd,
    output reg [`CORE_CSR_OP_RANGE]     mem2wb_csr_wr_op,
    output reg [`DATA_RANGE]            mem2wb_csr_wdata,
    output reg [`CORE_CSR_ADDR_RANGE]   mem2wb_csr_addr,
    output reg                          mem2wb_sel_csr,
    output reg                          mem2wb_ill_instr,
    output reg                          mem2wb_exc_instr_addr_misaligned
);

    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire                exc_load_addr_misaligned;// From lsu of lsu.v
    wire                exc_store_addr_misaligned;// From lsu of lsu.v
    wire [`DATA_RANGE]  lsu_rdata;              // From lsu of lsu.v
    wire                lsu_rvld;               // From lsu of lsu.v
    // End of automatics

    /*AUTOREG*/

    wire [`DATA_RANGE]  reg_wdata;

    //////////////////////////////

    assign reg_wdata = lsu_rvld ? lsu_rdata : ex2mem_alu_out;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            mem2wb_reg_wen <= 1'b0;
            mem2wb_csr_rd <= 1'b0;
            mem2wb_csr_wr_op <= `CORE_CSR_NOP;
            mem2wb_ill_instr <= 1'b0;
            mem2wb_exc_instr_addr_misaligned <= 1'b0;
        end
        else begin
            mem2wb_reg_wen <= ex2mem_reg_wen;
            mem2wb_csr_rd <= ex2mem_csr_rd;
            mem2wb_csr_wr_op <= ex2mem_csr_wr_op;
            mem2wb_ill_instr <= ex2mem_ill_instr;
            mem2wb_exc_instr_addr_misaligned <= ex2mem_exc_instr_addr_misaligned;
        end
    end

    always @(posedge clk) begin
        mem2wb_pc <= ex2mem_pc;
        mem2wb_isntruction <= ex2mem_isntruction;
        mem2wb_reg_wdata <= reg_wdata;
        mem2wb_reg_waddr <= ex2mem_reg_waddr;
        mem2wb_csr_wdata <= ex2mem_csr_wdata;
        mem2wb_csr_addr <= ex2mem_csr_addr;
        mem2wb_sel_csr <= ex2mem_sel_csr;
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

        /* lsu AUTO_TEMPLATE (
        ); */
        lsu
        lsu (/*AUTOINST*/
             // Outputs
             .dbus_hwrite               (dbus_hwrite),
             .dbus_hsize                (dbus_hsize[2:0]),
             .dbus_hburst               (dbus_hburst[2:0]),
             .dbus_hport                (dbus_hport[3:0]),
             .dbus_htrans               (dbus_htrans[1:0]),
             .dbus_hmastlock            (dbus_hmastlock),
             .dbus_haddr                (dbus_haddr[`INSTR_RAM_ADDR_RANGE]),
             .dbus_hwdata               (dbus_hwdata[`DATA_RANGE]),
             .lsu_rvld                  (lsu_rvld),
             .lsu_rdata                 (lsu_rdata[`DATA_RANGE]),
             .exc_load_addr_misaligned  (exc_load_addr_misaligned),
             .exc_store_addr_misaligned (exc_store_addr_misaligned),
             // Inputs
             .clk                       (clk),
             .rst                       (rst),
             .lsu_mem_rd                (lsu_mem_rd),
             .lsu_mem_wr                (lsu_mem_wr),
             .lsu_mem_op                (lsu_mem_op[`CORE_MEM_OP_RANGE]),
             .lsu_addr                  (lsu_addr[`DATA_RANGE]),
             .lsu_wdata                 (lsu_wdata[`DATA_RANGE]),
             .dbus_hready               (dbus_hready),
             .dbus_hresp                (dbus_hresp),
             .dbus_hrdata               (dbus_hrdata[`DATA_RANGE]));

endmodule
