// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/29/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// CSR R/W module
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module csr (
    input                           clk,
    input                           rst,
    input                           csr_read,
    input                           csr_write,
    input [`CORE_CSR_OP_RANGE]      csr_write_opcode,
    input [`CORE_CSR_ADDR_RANGE]    csr_address,
    input [`DATA_RANGE]             csr_writedata,
    output [`DATA_RANGE]            csr_readdata,

    input           trap_take,

    input [30:0]    i_mcause_exception_code,
    input           i_mcause_interrupt,
    input [31:0]    i_mepc_value,
    input           i_mstatus_mie,
    input           i_mstatus_mpie,
    input [1:0]     i_mstatus_mpp,
    input [31:0]    i_mtval_value,
    input           i_mip_msip_wen,
    input           i_mip_msip,
    input           i_mip_mtip_wen,
    input           i_mip_mtip,
    input           i_mip_meip_wen,
    input           i_mip_meip,

    output          o_mstatus_mpie,
    output          o_mstatus_mie,
    output [29:0]   o_mtvec_base,
    output [1:0]    o_mtvec_mode,
    output [31:0]   o_mscratch_value,
    output [31:0]   o_mepc_value,
    output          o_mie_msie,
    output          o_mie_mtie,
    output          o_mie_meie

    /*AUTOINPUT*/

    /*AUTOOUTPUT*/

);

    /*AUTOWIRE*/

    /*AUTOREG*/

    logic [`DATA_RANGE] csr_writedata_final;

    always @(*) begin
        case(csr_write_opcode)
            `CORE_CSR_RS: csr_writedata_final = csr_readdata | csr_writedata;      // set
            `CORE_CSR_RC: csr_writedata_final = csr_readdata & ~csr_writedata;     // clear
            default:      csr_writedata_final = csr_writedata;
        endcase
    end

    // mcsr
    /* mcsr AUTO_TEMPLATE (
        .csr_writedata  (csr_writedata_final[`DATA_RANGE]),
        .i_mip_msip_wen (i_mip_msip_wen),
        .i_mip_mtip_wen (i_mip_mtip_wen),
        .i_mip_meip_wen (i_mip_meip_wen),
        .\(.*\)_wen     (trap_take),
        ); */
    mcsr
    mcsr (/*AUTOINST*/
          // Outputs
          .csr_readdata                 (csr_readdata[31:0]),
          .o_mstatus_mpie               (o_mstatus_mpie),
          .o_mstatus_mie                (o_mstatus_mie),
          .o_mtvec_base                 (o_mtvec_base[29:0]),
          .o_mtvec_mode                 (o_mtvec_mode[1:0]),
          .o_mscratch_value             (o_mscratch_value[31:0]),
          .o_mepc_value                 (o_mepc_value[31:0]),
          .o_mie_msie                   (o_mie_msie),
          .o_mie_mtie                   (o_mie_mtie),
          .o_mie_meie                   (o_mie_meie),
          // Inputs
          .clk                          (clk),
          .rst                          (rst),
          .csr_read                     (csr_read),
          .csr_write                    (csr_write),
          .csr_address                  (csr_address[11:0]),
          .csr_writedata                (csr_writedata_final[`DATA_RANGE]), // Templated
          .i_mstatus_mpp                (i_mstatus_mpp[1:0]),
          .i_mstatus_mpp_wen            (trap_take),             // Templated
          .i_mstatus_mpie               (i_mstatus_mpie),
          .i_mstatus_mpie_wen           (trap_take),             // Templated
          .i_mstatus_mie                (i_mstatus_mie),
          .i_mstatus_mie_wen            (trap_take),             // Templated
          .i_misa_mxl_wen               (trap_take),             // Templated
          .i_misa_extensions_wen        (trap_take),             // Templated
          .i_mtvec_base_wen             (trap_take),             // Templated
          .i_mtvec_mode_wen             (trap_take),             // Templated
          .i_mscratch_value_wen         (trap_take),             // Templated
          .i_mepc_value                 (i_mepc_value[31:0]),
          .i_mepc_value_wen             (trap_take),             // Templated
          .i_mcause_interrupt           (i_mcause_interrupt),
          .i_mcause_interrupt_wen       (trap_take),             // Templated
          .i_mcause_exception_code      (i_mcause_exception_code[30:0]),
          .i_mcause_exception_code_wen  (trap_take),             // Templated
          .i_mtval_value                (i_mtval_value[31:0]),
          .i_mtval_value_wen            (trap_take),             // Templated
          .i_mvendorid_value_wen        (trap_take),             // Templated
          .i_marchid_value_wen          (trap_take),             // Templated
          .i_mimpid_value_wen           (trap_take),             // Templated
          .i_mhartid_value_wen          (trap_take),             // Templated
          .i_mip_msip_wen               (i_mip_msip_wen),        // Templated
          .i_mip_msip                   (i_mip_msip),
          .i_mip_mtip_wen               (i_mip_mtip_wen),        // Templated
          .i_mip_mtip                   (i_mip_mtip),
          .i_mip_meip_wen               (i_mip_meip_wen),        // Templated
          .i_mip_meip                   (i_mip_meip));

endmodule
