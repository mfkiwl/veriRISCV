///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: pc
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// program counter
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"

module pc (
    input                   clk,
    input                   rst,
    input                   take_branch,
    input [`PC_RANGE]       target_pc,
    output [`PC_RANGE]      pc_out
);

    reg [`PC_RANGE]         pc_value;

    always @(posedge clk) begin
        if (rst) begin
            pc_value <= 0;
        end
        else begin
            if (take_branch) pc_value <= target_pc;
            else pc_value <= pc_value + 4;
        end
    end

    assign pc_out = pc_value;

endmodule