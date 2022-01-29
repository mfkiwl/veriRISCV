///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: mcsr
//
// Author: Heqing Huang
// Date Created: 01/29/2022
//
// ================== Description ==================
//
// Machine level CSR  module
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "veririscv_core.vh"

module mcsr (
    input                           clk,
    input                           rst,
    input                           csr_rd,
    input                           csr_wr,
    input [`CORE_CSR_ADDR_RANGE]    csr_addr,
    input [`DATA_RANGE]             csr_wdata,
    output [`DATA_RANGE]            csr_rdata
);





endmodule