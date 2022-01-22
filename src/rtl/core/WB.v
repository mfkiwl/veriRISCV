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
    input   clk,
    input   rst,
    // input from MEM/WB stage pipe
    input                       mem2wb_reg_wen,
    input [`RF_RANGE]           mem2wb_reg_waddr,
    input [`DATA_RANGE]         mem2wb_reg_wdata,
    input                       mem2wb_ill_instr,
    // to register file
    output                      wb_reg_wen,
    output [`RF_RANGE]          wb_reg_waddr,
    output [`DATA_RANGE]        wb_reg_wdata
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    //////////////////////////////

    assign wb_reg_wen = mem2wb_reg_wen;
    assign wb_reg_wdata = mem2wb_reg_wdata;
    assign wb_reg_waddr = mem2wb_reg_waddr;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    //////////////////////////////
    // Module instantiation
    //////////////////////////////


endmodule