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

    input [`DATA_RANGE]                 instruction,

    // datapath signal
    output reg                          reg_wen,
    output [`RF_RANGE]                  reg_waddr,
    output [`RF_RANGE]                  reg_rs1_addr,
    output [`RF_RANGE]                  reg_rs2_addr,
    output reg                          reg_rs1_rd,
    output reg                          reg_rs2_rd,


    output reg                          br_instr,       // indicating branch instruction
    output reg                          jal_instr,      // indicating jal instruction
    output reg                          jalr_instr,     // indicating jalr instruction
    output reg                          op1_sel_zero,   // for LUI
    output reg                          op1_sel_pc,     // for AUIPC, JAL, JALR
    output reg                          op2_sel_4,      // for JAL, JALR
    output reg                          sel_imm,

    output reg                          csr_rd,         // indicating read csr
    output reg [`CORE_CSR_OP_RANGE]     csr_wr_op,
    output [`CORE_CSR_ADDR_RANGE]       csr_addr,
    output reg                          sel_csr,        // select csr data as rd data at WB stage


    output reg [`DATA_RANGE]            imm_value,
    output reg [`CORE_ALU_OP_RANGE]     alu_op,
    output reg [`CORE_BRANCH_OP_RANGE]  branch_op,
    output reg [`CORE_MEM_RD_OP_RANGE]  mem_rd_op,
    output reg [`CORE_MEM_WR_OP_RANGE]  mem_wr_op,

    // exception
    output reg                          exc_ill_instr   // Illegal instruction
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
    assign csr_addr = instruction[`DEC_CSR_ADDR_FIELD];

    /////////////////////////////////
    // Decode logic
    /////////////////////////////////

    always @(*) begin
        // Default value
        exc_ill_instr = 1'b0;
        alu_op = `CORE_ALU_ADD;
        csr_wr_op = `CORE_CSR_NOP;
        reg_wen = 1'b0;
        reg_rs1_rd = 1'b0;
        reg_rs2_rd = 1'b0;
        sel_imm = 1'b0;
        mem_rd_op = `CORE_MEM_NO_RD;
        mem_wr_op = `CORE_MEM_NO_WR;
        branch_op = func3;
        csr_rd = 1'b0;
        br_instr = 1'b0;
        jal_instr = 1'b0;
        jalr_instr = 1'b0;
        op1_sel_zero = 1'b0;
        op1_sel_pc = 1'b0;
        op2_sel_4 = 1'b0;
        sel_csr = 1'b0;
        // LEVEL 1 - opcode
        case(opcode)
            `DEC_TYPE_LOGIC: begin  // Logic Type instruction
                reg_rs1_rd = 1'b1;
                reg_rs2_rd = 1'b1;
                reg_wen = 1'b1;
                // To simplifiy the decode logic, here we use the same encoding with the instruction func3 field
                // For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the forth bit to distinguesh them.
                // Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to 1
                alu_op[2:0] = func3;
                alu_op[3] = func7[5];
            end
            `DEC_TYPE_ILOGIC: begin // Immediate Type instruction
                // Logic Type instruction with immediate
                // For SRLI/SRAI/SLLI, the format is different then regular immediate instruction.
                // However, shamt field is located at lower 5 bit of the immediate value which is
                // exactly the same field ALU is used for caluculation
                reg_rs1_rd = 1'b1;
                reg_wen = 1'b1;
                sel_imm = 1'b1;
                alu_op[2:0] = func3;
                if (func3 == `DEC_LOGIC_SRA)  alu_op[3] = func7[5];
            end
            `DEC_TYPE_LOAD: begin   // Load instruction
                reg_rs1_rd = 1'b1;
                reg_wen = 1'b1;
                sel_imm = 1'b1;
                alu_op = `CORE_ALU_ADD;
                mem_rd_op = func3;
                if (func3[2:1] == 2'b11) exc_ill_instr = 1'b1;
            end
            `DEC_TYPE_STORE: begin  // Store instruction
                reg_rs1_rd = 1'b1;
                reg_rs2_rd = 1'b1;
                sel_imm = 1'b1;
                alu_op = `CORE_ALU_ADD;
                mem_wr_op = func3[1:0];
                if (func3[2] == 1'b1 || func3 == 3'b011) exc_ill_instr = 1'b1;
            end
            `DEC_TYPE_BRAHCN: begin // Branch instruction
                reg_rs1_rd = 1'b1;
                reg_rs2_rd = 1'b1;
                br_instr = 1'b1;
                if (func3[2:1] == 2'b01) exc_ill_instr = 1'b1;
            end
            `DEC_TYPE_LUI: begin    // LUI
                sel_imm = 1'b1;
                op1_sel_zero = 1'b1;
                alu_op = `CORE_ALU_ADD;
                reg_wen = 1'b1;
            end
            `DEC_TYPE_AUIPC: begin    // AUIPC
                sel_imm = 1'b1;
                op1_sel_pc = 1'b1;
                alu_op = `CORE_ALU_ADD;
                reg_wen = 1'b1;
            end
            `DEC_TYPE_JAL: begin    // JAL
                jal_instr = 1'b1;
                op1_sel_pc = 1'b1;
                op2_sel_4 = 1'b1;
                alu_op = `CORE_ALU_ADD;
                reg_wen = 1'b1;
            end
            `DEC_TYPE_JALR: begin    // JALR
                reg_rs1_rd = 1'b1;
                jalr_instr = 1'b1;
                op1_sel_pc = 1'b1;
                op2_sel_4 = 1'b1;
                alu_op = `CORE_ALU_ADD;
                reg_wen = 1'b1;
            end
            `DEC_TYPE_CSR: begin    // CSR
                // for CSRRW/CSRRWI, if rd=x0, then the instruction should not read the CSR
                csr_rd = (func3[1:0] != `CORE_CSR_RW) | (reg_waddr != 0);
                // for CSRRS, CSRRC, if rs1=x0, then the instruction should notwrite to the CSR
                csr_wr_op = (func3[1] && (reg_rs1_addr == 0)) ? `CORE_CSR_NOP : func3[1:0];
                sel_imm = 1'b1;
                exc_ill_instr = (func3[1:0] == 0);
            end
        default: exc_ill_instr = 1'b1;
        endcase
    end

    always @(*) begin
        case(opcode)
            // In the default section
            //`DEC_TYPE_ILOGIC, `DEC_TYPE_LOAD: begin
            //    imm_value = {{20{instruction[31]}}, instruction[31:20]};
            //end
            `DEC_TYPE_STORE: begin
                imm_value = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            `DEC_TYPE_BRAHCN: begin
                imm_value = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:7]};
            end
            `DEC_TYPE_LUI, `DEC_TYPE_AUIPC: begin
                imm_value = {instruction[31:12], 12'b0};
            end
            `DEC_TYPE_CSR: begin
                imm_value = {27'b0, reg_rs1_addr}; // rs1 addr field is the same field as uimm for CSR
            end
        default: imm_value = {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end

endmodule