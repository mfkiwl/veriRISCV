// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// program counter
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module pc (
    input                   clk,
    input                   rst,
    input                   stall,
    input                   branch,
    input  [`PC_RANGE]      branch_pc,
    output [`PC_RANGE]      pc_out
);

    reg [`PC_RANGE]         pc_value;

    always @(posedge clk) begin
        if (rst) begin
            pc_value <= 0;
        end
        else begin
            // branch has priority over stall
            if (branch) pc_value <= branch_pc;
            else if (!stall) pc_value <= pc_value + 4;
        end
    end

    assign pc_out = pc_value;

endmodule