///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: decoder
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// decoder
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"
`include "decoder.vh"

module decoder (

    input [`DATA_RANGE]     instruction,

    // register interface
    output reg              reg_wen,
    output [`RF_RANGE]      reg_waddr,
    output [`RF_RANGE]      reg_rs1_addr,
    output [`RF_RANGE]      reg_rs2_addr,

    // datapath control signal
    output reg              sel_imm,
    output reg [`CORE_ALU_OP_RANGE]     alu_op,
    output reg [`CORE_MEM_RD_OP_RANGE]  mem_rd_op,
    output reg [`CORE_MEM_WR_OP_RANGE]  mem_wr_op,
    output reg [`CORE_BRANCH_OP_RANGE]  branch_op,
    output reg                          br_instr,

    // datapath data signal
    output reg [`IMM_RANGE]     imm_value,

    // exception
    output reg ill_instr         // Illegal instruction
);

    /////////////////////////////////
    // Signal Declaration
    /////////////////////////////////

    wire [`DEC_OPCODE_RANGE] opcode;
    wire [`DEC_FUNC7_RANGE] func7;
    wire [`DEC_FUNC3_RANGE] func3;

    /////////////////////////////////

    /////////////////////////////////
    // Extract instruction field
    /////////////////////////////////
    assign reg_waddr = instruction[`DEC_RD_FIELD];
    assign reg_rs1_addr = instruction[`DEC_RS1_FIELD];
    assign reg_rs2_addr = instruction[`DEC_RS2_FIELD];

    assign opcode = instruction[`DEC_OPCODE_FIELD];
    assign func7 = instruction[`DEC_FUNC7_FIELD];
    assign func3 = instruction[`DEC_FUNC3_FIELD];

    /////////////////////////////////
    // Decode logic
    /////////////////////////////////

    always @(*) begin
        // Default value
        ill_instr = 1'b0;
        alu_op = `CORE_ALU_ADD;
        reg_wen = 1'b0;
        sel_imm = 1'b0;
        mem_rd_op = `CORE_MEM_NO_RD;
        mem_wr_op = `CORE_MEM_NO_WR;
        branch_op = func3;
        br_instr = 1'b0;
        // LEVEL 1 - opcode
        case(opcode)
            `DEC_TYPE_LOGIC: begin  // Logic Type instruction
                reg_wen = 1'b1;
                // To simplifiy the decode logic, here we use the same encoding with the instruction func3 field
                // For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the forth bit to distinguesh them.
                // Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to 1
                alu_op[2:0] = func3;
                alu_op[3] = func7[5];
            end
            `DEC_TYPE_ILOGIC: begin
                // Logic Type instruction with immediate
                // For SRLI/SRAI/SLLI, the format is different then regular immediate instruction.
                // However, shamt field is located at lower 5 bit of the immediate value which is
                // exactly the same field ALU is used for caluculation
                reg_wen = 1'b1;
                sel_imm = 1'b1;
                alu_op[2:0] = func3;
                if (func3 == `DEC_LOGIC_SRA)  alu_op[3] = func7[5];
            end
            `DEC_TYPE_LOAD: begin
                reg_wen = 1'b1;
                sel_imm = 1'b1;
                alu_op = `CORE_ALU_ADD;
                mem_rd_op = func3;
                if (func3[2:1] == 2'b11) ill_instr = 1'b1;
            end
            `DEC_TYPE_STORE: begin
                sel_imm = 1'b1;
                alu_op = `CORE_ALU_ADD;
                mem_wr_op = func3[1:0];
                if (func3[2] == 1'b1 || func3 == 3'b011) ill_instr = 1'b1;
            end
            `DEC_TYPE_BRAHCN: begin
                br_instr = 1'b1;
                if (func3[2:1] == 2'b01) ill_instr = 1'b1;
            end
        default: ill_instr = 1'b1;
        endcase
    end

    always @(*) begin
        case(opcode)
            `DEC_TYPE_ILOGIC, `DEC_TYPE_LOAD: begin
                imm_value = {{8{instruction[31]}}, instruction[31:20]}; // sign ext
            end
            `DEC_TYPE_STORE: begin
                imm_value = {{8{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            `DEC_TYPE_BRAHCN: begin
                imm_value = {{8{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:7]};
            end
        default: imm_value = {{8{instruction[31]}}, instruction[31:20]};
        endcase
    end

endmodule