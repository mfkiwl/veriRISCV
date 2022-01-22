///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: bu.v
//
// Author: Heqing Huang
// Date Created: 01/21/2022
//
// ================== Description ==================
//
// bu (branch unit)
//
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "decoder.vh"
`include "veririscv_core.vh"

module bu (
    input                           br_instr,
    input [`CORE_BRANCH_OP_RANGE]   branch_op,
    input [`DATA_RANGE]             rs1,
    input [`DATA_RANGE]             rs2,
    input [`DATA_RANGE]             imm_value,
    input [`PC_RANGE]               pc,
    output [`PC_RANGE]              target_pc,
    output                          take_branch
);

    wire beq;
    wire blt;
    wire bltu;
    reg branch_result_raw;
    wire branch_result;

    assign beq = rs1 == rs2;
    assign blt = $signed(rs1) < $signed(rs2);
    assign bltu = $unsigned(rs1) < $unsigned(rs2);

    always @(*) begin
        case(branch_op[2:1])
            2'b10: branch_result_raw = blt;
            2'b11: branch_result_raw = bltu;
            default: branch_result_raw = beq;
        endcase
    end

    // From the func3 encoding, if bit 0 is 1, it is
    // BNE, BGE, BGEU so we need to negate the raw result
    assign branch_result = branch_result_raw ^ branch_op[0];

    assign take_branch = branch_result & br_instr;
    assign target_pc = pc + imm_value;

endmodule
