// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Instruction decoder
// ------------------------------------------------------------------------------------------------

// Notes for the forwarding logic and ALU operand 1 and ALU operand 2 source

// ALU operand 1 source:
//  1. register rs1 data
//  2. 0 (for LUI)
//  3. pc (for AUIPC)
// ALU operand 2 source:
//  1. register rs2 data
//  2. immediate value
//  3. 4 (for JAL/JALR)

// Register writedata source
// 1. ALU result
// 2. Memory read result
// 3. PC + 4 (JAL/JALR)

// FIXME:
// Need logic for exception_ill_instr in Logic type and I type

`include "core.svh"

module decoder (

    input [`DATA_RANGE]                     instruction,

    // register file
    output logic                            regfile_reg_write,
    output logic [`RF_RANGE]                regfile_reg_regid,
    output logic [`RF_RANGE]                regfile_rs1_regid,
    output logic [`RF_RANGE]                regfile_rs2_regid,
    output logic                            regfile_rs1_read,
    output logic                            regfile_rs2_read,

    // branch and jump
    output logic                            branch,             // indicating branch instruction
    output logic [`CORE_BRANCH_OP_RANGE]    branch_opcode,
    output logic                            jal,                // indicating jal instruction
    output logic                            jalr,               // indicating jalr instruction

    // alu
    output logic                            alu_op1_sel_zero,   // for LUI
    output logic                            alu_op1_sel_pc,     // for AUIPC, JAL, JALR
    output logic                            alu_op2_sel_4,      // for JAL, JALR
    output logic                            alu_op2_sel_imm,
    output logic [`CORE_ALU_OP_RANGE]       alu_opcode,
    output logic [`DATA_RANGE]              imm_value,

    // csr
    output logic                            csr_read,             // indicating read csr
    output logic                            csr_write,
    output logic [`CORE_CSR_OP_RANGE]       csr_write_opcode,
    output logic [`CORE_CSR_ADDR_RANGE]     csr_address,

    // memory
    output logic                            mem_read,
    output logic                            mem_write,
    output logic [`CORE_MEM_OP_RANGE]       mem_opcode,

`ifdef ISA_RV32M
    // mul and div
    output logic                            mul,
    output logic                            div,
    output logic [1:0]                      muldiv_opcode,
`endif

    // other instruction
    output logic                            mret,

    // exception
    output logic                            exception_ill_instr   // Illegal instruction
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    logic [`DEC_OPCODE_RANGE]    opcode;
    logic [`DEC_FUNC7_RANGE]     func7;
    logic [`DEC_FUNC3_RANGE]     func3;
    logic [`DEC_SYSTEM_31_7_FIELD] instr_31_7;

    //logic                        func7_equal_00x;
    logic                        func7_equal_01x;
    //logic                        func7_equal_20x;

    // ---------------------------------
    //  main logic
    // ---------------------------------

    // Extract instruction field

    assign regfile_reg_regid = instruction[`DEC_RD_FIELD];
    assign regfile_rs1_regid = instruction[`DEC_RS1_FIELD];
    assign regfile_rs2_regid = instruction[`DEC_RS2_FIELD];

    assign opcode = instruction[`DEC_OPCODE_FIELD];
    assign func7 = instruction[`DEC_FUNC7_FIELD];
    assign func3 = instruction[`DEC_FUNC3_FIELD];
    assign csr_address = instruction[`DEC_CSR_ADDR_FIELD];
    assign instr_31_7 = instruction[`DEC_SYSTEM_31_7_FIELD];

    //assign func7_equal_00x = func7 == 7'b0000000;   // For most of the logic type
    assign func7_equal_01x = func7 == 7'b0000001;   // For MUL/DIV
    //assign func7_equal_20x = func7 == 7'b0100000;   // For SLLI/SRLI/SRAI, SRA, SUB

    // Decode logic
    always @* begin

        // Default value
        exception_ill_instr = 1'b0;
        alu_opcode = 0;
        csr_write_opcode = `CORE_CSR_NOP;
        regfile_reg_write = 1'b0;
        regfile_rs1_read = 1'b0;
        regfile_rs2_read = 1'b0;
        alu_op2_sel_imm = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_opcode = func3;
        branch_opcode = func3;
        csr_read = 1'b0;
        csr_write = 1'b0;
        branch = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        alu_op1_sel_zero = 1'b0;
        alu_op1_sel_pc = 1'b0;
        alu_op2_sel_4 = 1'b0;
        mret = 1'b0;

    `ifdef ISA_RV32M
        mul = 0;
        div = 0;
        muldiv_opcode = 0;
    `endif

        // LEVEL 1 - opcode
        case(opcode)

            // Logic Type instruction
            `DEC_TYPE_LOGIC: begin
                regfile_rs1_read = 1'b1;
                regfile_rs2_read = 1'b1;
                regfile_reg_write = 1'b1;
                // To simplifiy the decode logic, we use the same encoding as the instruction func3 field in ALU.
                // For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the 4th bit to distinguesh them.
                // Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to fcun7[5]
                alu_opcode[2:0] = func3;
                alu_opcode[3] = func7[5];

                // For RV32M extension
            `ifdef ISA_RV32M
                mul = ~func3[2] & func7_equal_01x;
                div = func3[2] & func7_equal_01x;
                muldiv_opcode = func3[1:0];
            `endif

            end

            // Immediate Type instruction
            `DEC_TYPE_ILOGIC: begin
                // Logic Type instruction with immediate
                // For SRLI/SRAI/SLLI, the format is different then regular immediate instruction.
                // However, shamt field is located at lower 5 bit of the immediate value which is the same field ALU used for caluculation
                regfile_rs1_read = 1'b1;
                regfile_reg_write = 1'b1;
                alu_op2_sel_imm = 1'b1;
                alu_opcode[2:0] = func3;
                alu_opcode[3] = (func3 == `DEC_LOGIC_SRA) & func7[5];   // for SRAI, we need to use alu_opcode[3] to distinguesh between SRLI/SRAI
            end

            // Load instruction
            `DEC_TYPE_LOAD: begin
                regfile_rs1_read = 1'b1;
                regfile_reg_write = 1'b1;
                alu_op2_sel_imm = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                mem_read = 1'b1;
                if (func3[2:1] == 2'b11) exception_ill_instr = 1'b1;
            end

            // Store instruction
            `DEC_TYPE_STORE: begin
                regfile_rs1_read = 1'b1;
                regfile_rs2_read = 1'b1;
                alu_op2_sel_imm = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                mem_write = 1'b1;
                if (func3[2] == 1'b1 || func3[1:0] == 2'b11) exception_ill_instr = 1'b1;
            end

            // Branch instruction
            `DEC_TYPE_BRAHCN: begin
                regfile_rs1_read = 1'b1;
                regfile_rs2_read = 1'b1;
                branch = 1'b1;
                if (func3[2:1] == 2'b01) exception_ill_instr = 1'b1;
            end

            // LUI
            `DEC_TYPE_LUI: begin
                alu_op2_sel_imm = 1'b1;
                alu_op1_sel_zero = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_reg_write = 1'b1;
            end

            // AUIPC
            `DEC_TYPE_AUIPC: begin
                alu_op2_sel_imm = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_reg_write = 1'b1;
            end

            // JAL
            `DEC_TYPE_JAL: begin
                jal = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_op2_sel_4 = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_reg_write = 1'b1;
            end

            // JALR
            `DEC_TYPE_JALR: begin
                regfile_rs1_read = 1'b1;
                jalr = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_op2_sel_4 = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_reg_write = 1'b1;
            end

            // SYSTEM - CHECK ME - FIXME
            `DEC_TYPE_SYSTEM: begin

                // CSR
                if (func3 != 3'b000) begin
                    // From SPEC: for CSRRW/CSRRWI, if rd=x0, then the instruction should not read the CSR
                    csr_read = (func3[1:0] != `CORE_CSR_RW) | (regfile_reg_regid != 0);
                    // From SPEC: for CSRRS/CSRRC, if rs1=x0, then the instruction will not write to the CSR at all, and
                    // so shall not cause any of the side effects that might otherwise occur on a CSR write
                    csr_write = (func3[1:0] == `CORE_CSR_RW) | ((func3[1:0] != `CORE_CSR_NOP) & (regfile_rs1_regid != 0));
                    csr_write_opcode = func3[1:0];
                    regfile_reg_write = csr_read;
                    regfile_rs1_read = ~func3[2];
                    alu_op2_sel_imm = func3[2];
                end
                else begin  // other
                    if (instr_31_7 == `DEC_SYSTEM_MRET) mret = 1'b1;    // MRET
                    else exception_ill_instr = 1'b1;
                end
            end
        default: exception_ill_instr = 1'b1;
        endcase
    end

    //  - CHECK ME
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
            `DEC_TYPE_JAL: begin
                imm_value = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            `DEC_TYPE_LUI, `DEC_TYPE_AUIPC: begin
                imm_value = {instruction[31:12], 12'b0};
            end
            `DEC_TYPE_CSR: begin
                imm_value = {27'b0, regfile_rs1_regid}; // rs1 addr field is the same field as uimm for CSR
            end
        default: imm_value = {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end

endmodule