///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: csr
//
// Author: Heqing Huang
// Date Created: 01/29/2022
//
// ================== Description ==================
//
// CSR R/W module
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "veririscv_core.vh"

module csr (
    input                           clk,
    input                           rst,
    input                           csr_rd,
    input [`CORE_CSR_OP_RANGE]      csr_wr_op,
    input [`CORE_CSR_ADDR_RANGE]    csr_addr,
    input [`DATA_RANGE]             csr_wdata,
    output [`DATA_RANGE]            csr_rdata,
    input                           take_trap,

    /*AUTOINPUT*/
    // Beginning of automatic inputs (from unused autoinst inputs)
    input [30:0]        i_mcause_exception_code,// To mcsr of mcsr.v
    input               i_mcause_interrupt,     // To mcsr of mcsr.v
    input [31:0]        i_mepc_value,           // To mcsr of mcsr.v
    input               i_mstatus_mie,          // To mcsr of mcsr.v
    input               i_mstatus_mpie,         // To mcsr of mcsr.v
    input [1:0]         i_mstatus_mpp,          // To mcsr of mcsr.v
    input [31:0]        i_mtval_value,          // To mcsr of mcsr.v
    // End of automatics

    /*AUTOOUTPUT*/
    // Beginning of automatic outputs (from unused autoinst outputs)
    output [31:0]       o_mepc_value,           // From mcsr of mcsr.v
    output [31:0]       o_mscratch_value,       // From mcsr of mcsr.v
    output              o_mstatus_mie,          // From mcsr of mcsr.v
    output              o_mstatus_mpie,         // From mcsr of mcsr.v
    output [29:0]       o_mtvec_base,           // From mcsr of mcsr.v
    output [1:0]        o_mtvec_mode           // From mcsr of mcsr.v
    // End of automatics

    );

    /*AUTOWIRE*/

    /*AUTOREG*/

    reg [`DATA_RANGE]       csr_wdata_final;
    wire                    csr_wr;

    assign csr_wr = csr_wr_op != `CORE_CSR_NOP;

    always @(*) begin
        case(csr_wr_op)
            `CORE_CSR_RS: csr_wdata_final = csr_rdata | csr_wdata;      // set
            `CORE_CSR_RC: csr_wdata_final = csr_rdata & ~csr_wdata;     // clear
            default: csr_wdata_final = csr_wdata;
        endcase
    end

    // mcsr
    /* mcsr AUTO_TEMPLATE (
        .csr_wdata  (csr_wdata_final[`DATA_RANGE]),
        .\(.*\)_wen (take_trap),
        ); */
    mcsr
    mcsr (/*AUTOINST*/
          // Outputs
          .csr_rdata                    (csr_rdata[31:0]),
          .o_mstatus_mpie               (o_mstatus_mpie),
          .o_mstatus_mie                (o_mstatus_mie),
          .o_mtvec_base                 (o_mtvec_base[29:0]),
          .o_mtvec_mode                 (o_mtvec_mode[1:0]),
          .o_mscratch_value             (o_mscratch_value[31:0]),
          .o_mepc_value                 (o_mepc_value[31:0]),
          // Inputs
          .clk                          (clk),
          .rst                          (rst),
          .csr_rd                       (csr_rd),
          .csr_wr                       (csr_wr),
          .csr_addr                     (csr_addr[11:0]),
          .csr_wdata                    (csr_wdata_final[`DATA_RANGE]), // Templated
          .i_mstatus_mpp                (i_mstatus_mpp[1:0]),
          .i_mstatus_mpp_wen            (take_trap),             // Templated
          .i_mstatus_mpie               (i_mstatus_mpie),
          .i_mstatus_mpie_wen           (take_trap),             // Templated
          .i_mstatus_mie                (i_mstatus_mie),
          .i_mstatus_mie_wen            (take_trap),             // Templated
          .i_misa_mxl_wen               (take_trap),             // Templated
          .i_misa_extensions_wen        (take_trap),             // Templated
          .i_mtvec_base_wen             (take_trap),             // Templated
          .i_mtvec_mode_wen             (take_trap),             // Templated
          .i_mscratch_value_wen         (take_trap),             // Templated
          .i_mepc_value                 (i_mepc_value[31:0]),
          .i_mepc_value_wen             (take_trap),             // Templated
          .i_mcause_interrupt           (i_mcause_interrupt),
          .i_mcause_interrupt_wen       (take_trap),             // Templated
          .i_mcause_exception_code      (i_mcause_exception_code[30:0]),
          .i_mcause_exception_code_wen  (take_trap),             // Templated
          .i_mtval_value                (i_mtval_value[31:0]),
          .i_mtval_value_wen            (take_trap),             // Templated
          .i_mvendorid_value_wen        (take_trap),             // Templated
          .i_marchid_value_wen          (take_trap),             // Templated
          .i_mimpid_value_wen           (take_trap),             // Templated
          .i_mhartid_value_wen          (take_trap));             // Templated

endmodule
