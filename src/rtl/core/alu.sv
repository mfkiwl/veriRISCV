// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// ALU
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module alu (
    input  [`DATA_RANGE]            alu_op0,
    input  [`DATA_RANGE]            alu_op1,
    input  [`CORE_ALU_OP_RANGE]     alu_opcode,
    output logic [`DATA_RANGE]      alu_out
);

    logic slt_result;
    logic sltu_result;

    assign slt_result = ($signed(alu_op0) < $signed(alu_op1)) ? 1'b1 : 1'b0;
    assign sltu_result = ($unsigned(alu_op0) < $unsigned(alu_op1)) ? 1'b1 : 1'b0;

    always @(*) begin
        case(alu_opcode)
            `CORE_ALU_ADD:  alu_out = alu_op0 + alu_op1;
            `CORE_ALU_SUB:  alu_out = alu_op0 - alu_op1;
            `CORE_ALU_SLL:  alu_out = alu_op0 << alu_op1[4:0];
            `CORE_ALU_SLT:  alu_out = {{(`DATA_WIDTH-1){1'b0}},slt_result};
            `CORE_ALU_SLTU: alu_out = {{(`DATA_WIDTH-1){1'b0}},sltu_result};
            `CORE_ALU_XOR:  alu_out = alu_op0 ^ alu_op1;
            `CORE_ALU_SRL:  alu_out = alu_op0 >> alu_op1[4:0];
            `CORE_ALU_SRA:  alu_out = $signed(alu_op0) >>> alu_op1[4:0];
            `CORE_ALU_OR:   alu_out = alu_op0 | alu_op1;
            `CORE_ALU_AND:  alu_out = alu_op0 & alu_op1;
            default:        alu_out = alu_op0 & alu_op1;
        endcase

    end


endmodule