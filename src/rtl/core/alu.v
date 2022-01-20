///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: alu.vv
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// ALU
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module alu (
    input  [`DATA_RANGE]            alu_oprand_0,
    input  [`DATA_RANGE]            alu_oprand_1,
    input  [`CORE_ALU_OP_RANGE]     alu_op,
    output reg [`DATA_RANGE]        alu_out
);

    wire    slt_result;
    wire    sltu_result;

    assign slt_result = ($signed(alu_oprand_0) < $signed(alu_oprand_1)) ? 1'b1 : 1'b0;
    assign sltu_result = ($unsigned(alu_oprand_0) < $unsigned(alu_oprand_1)) ? 1'b1 : 1'b0;

    always @(*) begin
        case(alu_op)
            `CORE_ALU_ADD:  alu_out = alu_oprand_0 + alu_oprand_1;
            `CORE_ALU_SUB:  alu_out = alu_oprand_0 - alu_oprand_1;
            `CORE_ALU_SLL:  alu_out = alu_oprand_0 << alu_oprand_1[4:0];
            `CORE_ALU_SLT:  alu_out = {{(`DATA_WIDTH-1){1'b0}},slt_result};
            `CORE_ALU_SLTU: alu_out = {{(`DATA_WIDTH-1){1'b0}},sltu_result};
            `CORE_ALU_XOR:  alu_out = alu_oprand_0 ^ alu_oprand_1;
            `CORE_ALU_SRL:  alu_out = alu_oprand_0 >> alu_oprand_1[4:0];
            `CORE_ALU_SRA:  alu_out = alu_oprand_0 >>> alu_oprand_1[4:0];
            `CORE_ALU_OR:   alu_out = alu_oprand_0 | alu_oprand_1;
            `CORE_ALU_AND:  alu_out = alu_oprand_0 & alu_oprand_1;
            default:        alu_out = alu_oprand_0 & alu_oprand_1;
        endcase

    end


endmodule