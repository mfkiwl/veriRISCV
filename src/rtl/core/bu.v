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
    input                           jal_instr,
    input                           jalr_instr,
    input [`CORE_BRANCH_OP_RANGE]   branch_op,
    input [`DATA_RANGE]             rs1,
    input [`DATA_RANGE]             rs2,
    input [`DATA_RANGE]             imm_value,
    input [`PC_RANGE]               pc,
    output [`PC_RANGE]              target_pc,
    output                          take_branch,
    output                          exc_instr_addr_misaligned
);

    wire    beq;
    wire    blt;
    wire    bltu;
    wire    branch_result;
    reg     branch_result_raw;

    wire [`DATA_RANGE] tgt_addr_operand1;
    wire [`DATA_RANGE] tgt_addr_operand2;
    wire [`DATA_RANGE] tgt_addr_calc_result;

    ////////////////////////////
    // Check branch result
    ////////////////////////////
    assign beq = rs1 == rs2;
    assign blt = $signed(rs1) < $signed(rs2);
    assign bltu = $unsigned(rs1) < $unsigned(rs2);

    always @(*) begin
        // bit[2:1] is good enough for beq/blt/bltu
        case(branch_op[2:1])
            2'b10: branch_result_raw = blt;
            2'b11: branch_result_raw = bltu;
            default: branch_result_raw = beq;
        endcase
    end

    // From the func3 encoding, if bit[0] is 1, it is
    // BNE, BGE, BGEU so we need to invert the raw result
    // in those cases
    assign branch_result = branch_result_raw ^ branch_op[0];
    assign take_branch = branch_result & br_instr | jal_instr | jalr_instr;

    ////////////////////////////
    // target pc address calc
    ////////////////////////////
    // for branch instruction, PC = current pc + immediate
    // for jal instruction, PC = current pc + immediate value
    // for jalr instruction, PC = rs1 + immediate value
    assign tgt_addr_operand1 = jalr_instr ? rs1 : pc;
    assign tgt_addr_operand2 = imm_value;
    assign tgt_addr_calc_result = tgt_addr_operand1 + tgt_addr_operand2;
    assign target_pc = {tgt_addr_calc_result[31:1], 1'b0};

    ////////////////////////////
    // Exception
    ////////////////////////////
    assign exc_instr_addr_misaligned = take_branch & (target_pc[1] != 0);  // address should be 4 byte aligned, target_pc[0] is already 0

endmodule
