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
    output reg [`DATA_RANGE]        csr_rdata,

    input                           take_trap,

    output [`DATA_WIDTH-3:0]        mtvec_base,
    output [1:0]                    mtvec_mode
);

    // Machine Information Registers
    wire [`DATA_RANGE]  mvendorid;
    wire [`DATA_RANGE]  marchid;
    wire [`DATA_RANGE]  mimpid;
    wire [`DATA_RANGE]  mhartid;

    assign mvendorid = 0;   // not implemented
    assign marchid = 0;     // not implemented
    assign mimpid = 0;      // not implemented
    assign mhartid = 0;     // only implemented hart 0

    // Machine Trap Setup

    wire [`DATA_RANGE]  misa;
    wire [25:0]         misa_extensions;

    wire [`DATA_RANGE]  mstatus;
    reg                 mstatus_sie;    // *
    reg                 mstatus_mie;    // *
    reg                 mstatus_spie;
    reg                 mstatus_ube;
    reg                 mstatus_mpie;
    reg                 mstatus_spp;
    reg [1:0]           mstatus_vs;
    reg [1:0]           mstatus_mpp;
    reg [1:0]           mstatus_fs;
    reg [1:0]           mstatus_xs;
    reg                 mstatus_mprv;
    reg                 mstatus_sum;
    reg                 mstatus_mxr;
    reg                 mstatus_tvm;
    reg                 mstatus_tw;
    reg                 mstatus_tsr;
    reg                 mstatus_sd;

    wire [`DATA_RANGE]  mie;
    wire [`DATA_RANGE]  mtvec;

    assign misa_extensions = (1'b1 << 8);   // I is bit 8
    assign misa = {2'd1, {`DATA_WIDTH-28{1'b0}}, misa_extensions};

    assign mstatus = {mstatus_sd, 8'b0, mstatus_tsr, mstatus_tw, mstatus_tvm, mstatus_mxr, mstatus_sum,
                      mstatus_mprv, mstatus_xs, mstatus_fs, mstatus_mpp, mstatus_vs, mstatus_spp,
                      mstatus_mpie, mstatus_ube, mstatus_spie, 1'b0,  mstatus_mie, 1'b0, mstatus_sie, 1'b0};

    // Machine Trap Handling
    wire [`DATA_RANGE]  mscratch;
    wire [`DATA_RANGE]  mepc;
    wire [`DATA_RANGE]  mcause;
    wire [`DATA_RANGE]  mtval;

    // General Read logic
    always @(*) begin
        case(csr_addr)
            // Machine Information Registers
            12'hF11: csr_rdata = mvendorid;
            12'hF12: csr_rdata = marchid;
            12'hF13: csr_rdata = mimpid;
            12'hF14: csr_rdata = mhartid;
            // Machine Trap Setup
            12'h301: csr_rdata = misa;
            default: csr_rdata = 0;
        endcase
    end

endmodule