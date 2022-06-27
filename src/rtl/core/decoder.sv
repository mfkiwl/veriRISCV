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

`include "core.svh"

module decoder (

    input [`DATA_RANGE]                     instruction,

    // datapath signal
    output logic                            regfile_write,
    output logic [`RF_RANGE]                regfile_regid,
    output logic [`RF_RANGE]                regfile_rs1_regid,
    output logic [`RF_RANGE]                regfile_rs2_regid,
    output logic                            regfile_rs1_read,
    output logic                            regfile_rs2_read,

    output logic                            br_instr,           // indicating branch instruction
    output logic                            jal_instr,          // indicating jal instruction
    output logic                            jalr_instr,         // indicating jalr instruction
    output logic                            alu_op1_sel_zero,   // for LUI
    output logic                            alu_op1_sel_pc,     // for AUIPC, JAL, JALR
    output logic                            alu_op2_sel_4,      // for JAL, JALR
    output logic                            alu_op2_sel_imm,

    output logic                            csr_rd,             // indicating read csr
    output logic [`CORE_CSR_OP_RANGE]       csr_wr_opcode,
    output logic [`CORE_CSR_ADDR_RANGE]     csr_addr,

    output logic [`DATA_RANGE]              imm_value,
    output logic [`CORE_ALU_OP_RANGE]       alu_opcode,
    output logic [`CORE_BRANCH_OP_RANGE]    branch_opcode,
    output logic                            mem_read,
    output logic                            mem_write,
    output logic [`CORE_MEM_OP_RANGE]       mem_opcode,

    output logic                            mret,

    // exception
    output logic                            exception_ill_instr   // Illegal instruction
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    wire [`DEC_OPCODE_RANGE]    opcode;
    wire [`DEC_FUNC7_RANGE]     func7;
    wire [`DEC_FUNC3_RANGE]     func3;
    wire [`DEC_SYSTEM_31_7]     instr_31_7;


    // ---------------------------------
    //  main logic
    // ---------------------------------

    // Extract instruction field

    assign regfile_regid = instruction[`DEC_RD_FIELD];
    assign regfile_rs1_regid = instruction[`DEC_RS1_FIELD];
    assign regfile_rs2_regid = instruction[`DEC_RS2_FIELD];

    assign opcode = instruction[`DEC_OPCODE_FIELD];
    assign func7 = instruction[`DEC_FUNC7_FIELD];
    assign func3 = instruction[`DEC_FUNC3_FIELD];
    assign csr_addr = instruction[`DEC_CSR_ADDR_FIELD];


    // Decode logic
    always @* begin

        // Default value
        exception_ill_instr = 1'b0;
        alu_opcode = 0;
        csr_wr_opcode = `CORE_CSR_NOP;
        regfile_write = 1'b0;
        regfile_rs1_read = 1'b0;
        regfile_rs2_read = 1'b0;
        alu_op2_sel_imm = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_opcode = func3;
        branch_opcode = func3;
        csr_rd = 1'b0;
        br_instr = 1'b0;
        jal_instr = 1'b0;
        jalr_instr = 1'b0;
        alu_op1_sel_zero = 1'b0;
        alu_op1_sel_pc = 1'b0;
        alu_op2_sel_4 = 1'b0;
        mret = 1'b0;

        // LEVEL 1 - opcode
        case(opcode)

            // Logic Type instruction
            `DEC_TYPE_LOGIC: begin
                regfile_rs1_read = 1'b1;
                regfile_rs2_read = 1'b1;
                regfile_write = 1'b1;
                // To simplifiy the decode logic, we use the same encoding as the instruction func3 field in ALU.
                // For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the 4th bit to distinguesh them.
                // Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to fcun7[5]
                alu_opcode[2:0] = func3;
                alu_opcode[3] = func7[5];
            end

            // Immediate Type instruction
            `DEC_TYPE_ILOGIC: begin
                // Logic Type instruction with immediate
                // For SRLI/SRAI/SLLI, the format is different then regular immediate instruction.
                // However, shamt field is located at lower 5 bit of the immediate value which is the same field ALU used for caluculation
                regfile_rs1_read = 1'b1;
                regfile_write = 1'b1;
                alu_op2_sel_imm = 1'b1;
                alu_opcode[2:0] = func3;
                alu_opcode[3] = func7[5];
            end

            // Load instruction
            `DEC_TYPE_LOAD: begin
                regfile_rs1_read = 1'b1;
                regfile_write = 1'b1;
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
                br_instr = 1'b1;
                if (func3[2:1] == 2'b01) exception_ill_instr = 1'b1;
            end

            // LUI
            `DEC_TYPE_LUI: begin
                alu_op2_sel_imm = 1'b1;
                alu_op1_sel_zero = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_write = 1'b1;
            end

            // AUIPC
            `DEC_TYPE_AUIPC: begin
                alu_op2_sel_imm = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_write = 1'b1;
            end

            // JAL
            `DEC_TYPE_JAL: begin
                jal_instr = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_op2_sel_4 = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_write = 1'b1;
            end

            // JALR
            `DEC_TYPE_JALR: begin
                regfile_rs1_read = 1'b1;
                jalr_instr = 1'b1;
                alu_op1_sel_pc = 1'b1;
                alu_op2_sel_4 = 1'b1;
                alu_opcode = `CORE_ALU_ADD;
                regfile_write = 1'b1;
            end

            // SYSTEM - CHECK ME
            `DEC_TYPE_SYSTEM: begin

                // CSR
                if (func3 != 3'b000) begin
                    // for CSRRW/CSRRWI, if rd=x0, then the instruction should not read the CSR
                    csr_rd = (func3[1:0] != `CORE_CSR_RW) | (regfile_regid != 0);
                    // for CSRRS, CSRRC, if rs1=x0, then the instruction should notwrite to the CSR
                    csr_wr_opcode = (func3[1] && (regfile_rs1_regid == 0)) ? `CORE_CSR_NOP : func3[1:0];
                    regfile_write = csr_rd;
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