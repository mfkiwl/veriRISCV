///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: regfile
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// register file
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"

module regfile (
    input                       clk,
    input                       rst,
    input                       wen,
    input [`RF_RANGE]           waddr,
    input [`DATA_RANGE]         din,
    input [`RF_RANGE]           addr_rs1,
    output reg [`DATA_RANGE]    dout_rs1,
    input       [`RF_RANGE]     addr_rs2,
    output reg [`DATA_RANGE]    dout_rs2
);

    reg [`DATA_RANGE]     register[0:`REG_NUM-1];

    // Write port
    always @(posedge clk) begin
        if (wen) begin
            register[waddr] <= din;
        end
    end

    // Note: Register $0 is always pointing to zero.
    // Here we use a mux to select 0 when read address is 0
    // We also formard the data from WB stage if it has
    // the dependence

    // Read port A
    always @(*) begin
        if (addr_rs1 == 0) dout_rs1 = 0;
        else if (addr_rs1 == waddr && wen) dout_rs1 = din;
        else dout_rs1 = register[addr_rs1];
    end


    // Read port B
    always @(*) begin
        if (addr_rs2 == 0) dout_rs2 = 0;
        else if (addr_rs2 == waddr && wen) dout_rs2 = din;
        else dout_rs2 = register[addr_rs2];
    end

endmodule