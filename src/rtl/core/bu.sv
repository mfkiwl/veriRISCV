// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/21/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Barnch Unit
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module bu (
    input                           branch,
    input                           jal,
    input                           jalr,
    input [`CORE_BRANCH_OP_RANGE]   branch_opcode,
    input [`DATA_RANGE]             op1,
    input [`DATA_RANGE]             op2,
    input [`DATA_RANGE]             imm_value,
    input [`PC_RANGE]               pc,
    output [`PC_RANGE]              branch_pc,
    output                          branch_take,
    output                          exception_instr_addr_misaligned
);

    logic eq_result;
    logic lt_result;
    logic ltu_result;
    logic branch_result_raw;
    logic branch_result;

    logic [`DATA_RANGE] branch_addr_op1;
    logic [`DATA_RANGE] branch_addr_op2;
    logic [`DATA_RANGE] branch_addr_result;

    // ---------------------------------
    // Check branch result
    // ---------------------------------
    assign eq_result = op1 == op2;
    assign lt_result = $signed(op1) < $signed(op2);
    assign ltu_result = $unsigned(op1) < $unsigned(op2);

    // Branch opcode encoding is the same as func3 field.
    // FUNC3    INST
    // 000      BEQ *
    // 001      BNE
    // 100      BLT *
    // 101      BGE
    // 110      BLTU *
    // 111      BGEU
    // opcode[2:1] is used to distinguesh BEQ/BLT/BLTU
    // opcode[1] is used to distinguesh EQ/LT with NE/GE (0 - EQ/LT, 1 - NE/GE)
    always @(*) begin
        case(branch_opcode[2:1])
            2'b10: branch_result_raw = lt_result;
            2'b11: branch_result_raw = ltu_result;
            default: branch_result_raw = eq_result;
        endcase
    end
    // if opcode[0] is 1 we need to invert the result. An XOR operation will do this for us
    assign branch_result = branch_result_raw ^ branch_opcode[0];
    assign branch_take = branch_result & branch | jal | jalr;

    // ---------------------------------
    // calcualate the target pc address
    // ---------------------------------
    // for branch instruction: PC = current pc + immediate
    // for jal instruction:    PC = current pc + immediate value
    // for jalr instruction:   PC = op1 + immediate value
    assign branch_addr_op1 = jalr ? op1 : pc;
    assign branch_addr_op2 = imm_value;
    assign branch_addr_result = branch_addr_op1 + branch_addr_op2;
    // Based on the RISCV Spec, bit zero of the target pc is always zero.
    assign branch_pc = {branch_addr_result[31:1], 1'b0};

    // ---------------------------------
    // Exception
    // ---------------------------------
    assign exception_instr_addr_misaligned = branch_take & branch_pc[1];  // address should be 4 byte aligned, branch_pc[0] is already 0

endmodule
