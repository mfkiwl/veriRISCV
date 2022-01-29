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
    output [`DATA_RANGE]            csr_rdata
);


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
        ); */
    mcsr
    mcsr (/*AUTOINST*/
          // Outputs
          .csr_rdata                    (csr_rdata[`DATA_RANGE]),
          // Inputs
          .clk                          (clk),
          .rst                          (rst),
          .csr_rd                       (csr_rd),
          .csr_wr                       (csr_wr),
          .csr_addr                     (csr_addr[`CORE_CSR_ADDR_RANGE]),
          .csr_wdata                    (csr_wdata_final[`DATA_RANGE])); // Templated

endmodule
