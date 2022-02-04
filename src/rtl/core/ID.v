///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: ID
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// ID (Instruction decode stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module ID (
    input                               clk,
    input                               rst,
    input                               id_flush,
    // input from IF/ID stage pipe
    input                               if2id_valid,
    input [`PC_RANGE]                   if2id_pc,
    input [`DATA_RANGE]                 if2id_instruction,
    // input from MEM stage
    input                               lsu_mem_rd, // this signal is actually from EX stage
    input [`RF_RANGE]                   ex2mem_reg_waddr,
    input                               ex2mem_reg_wen,
    // input from WB stage
    input                               wb_reg_wen,
    input [`RF_RANGE]                   wb_reg_waddr,
    input [`DATA_RANGE]                 wb_reg_wdata,
    // to HDU
    output                              load_dependence,
    // pipeline stage
    output reg [`PC_RANGE]              id2ex_pc,
    output reg [`DATA_RANGE]            id2ex_instruction,
    output reg                          id2ex_br_instr,
    output reg                          id2ex_jal_instr,
    output reg                          id2ex_jalr_instr,
    output reg                          id2ex_sel_imm,
    output reg                          id2ex_op1_sel_pc,
    output reg                          id2ex_op1_sel_zero,
    output reg                          id2ex_op2_sel_4,
    output reg                          id2ex_op1_forward_from_mem,
    output reg                          id2ex_op1_forward_from_wb,
    output reg                          id2ex_op2_forward_from_mem,
    output reg                          id2ex_op2_forward_from_wb,
    output reg                          id2ex_csr_rd,
    output reg [`CORE_CSR_OP_RANGE]     id2ex_csr_wr_op,
    output reg [`CORE_CSR_ADDR_RANGE]   id2ex_csr_addr,
    output reg                          id2ex_reg_wen,
    output reg [`RF_RANGE]              id2ex_reg_waddr,
    output reg [`DATA_RANGE]            id2ex_op1_data,
    output reg [`DATA_RANGE]            id2ex_op2_data,
    output reg [`DATA_RANGE]            id2ex_imm_value,
    output reg [`CORE_ALU_OP_RANGE]     id2ex_alu_op,
    output reg                          id2ex_mem_rd,
    output reg                          id2ex_mem_wr,
    output reg [`CORE_MEM_OP_RANGE]     id2ex_mem_op,
    output reg [`CORE_BRANCH_OP_RANGE]  id2ex_branch_op,
    output reg                          id2ex_mret,
    // exception
    output reg                          id2ex_exc_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [`CORE_ALU_OP_RANGE] alu_op;           // From decoder of decoder.v
    wire                br_instr;               // From decoder of decoder.v
    wire [`CORE_BRANCH_OP_RANGE] branch_op;     // From decoder of decoder.v
    wire [`CORE_CSR_ADDR_RANGE] csr_addr;       // From decoder of decoder.v
    wire                csr_rd;                 // From decoder of decoder.v
    wire [`CORE_CSR_OP_RANGE] csr_wr_op;        // From decoder of decoder.v
    wire                exc_ill_instr;          // From decoder of decoder.v
    wire [`DATA_RANGE]  imm_value;              // From decoder of decoder.v
    wire                jal_instr;              // From decoder of decoder.v
    wire                jalr_instr;             // From decoder of decoder.v
    wire [`CORE_MEM_OP_RANGE] mem_op;           // From decoder of decoder.v
    wire                mem_rd;                 // From decoder of decoder.v
    wire                mem_wr;                 // From decoder of decoder.v
    wire                mret;                   // From decoder of decoder.v
    wire                op1_sel_pc;             // From decoder of decoder.v
    wire                op1_sel_zero;           // From decoder of decoder.v
    wire                op2_sel_4;              // From decoder of decoder.v
    wire [`RF_RANGE]    reg_rs1_addr;           // From decoder of decoder.v
    wire [`DATA_RANGE]  reg_rs1_data;           // From regfile of regfile.v
    wire                reg_rs1_rd;             // From decoder of decoder.v
    wire [`RF_RANGE]    reg_rs2_addr;           // From decoder of decoder.v
    wire [`DATA_RANGE]  reg_rs2_data;           // From regfile of regfile.v
    wire                reg_rs2_rd;             // From decoder of decoder.v
    wire [`RF_RANGE]    reg_waddr;              // From decoder of decoder.v
    wire                reg_wen;                // From decoder of decoder.v
    wire                sel_imm;                // From decoder of decoder.v
    // End of automatics

    /*AUTOREG*/

    // Others
    wire id_stage_valid;
    wire id_stage_valid_raw;
    wire op1_forward_from_mem;
    wire op1_forward_from_wb;
    wire op2_forward_from_mem;
    wire op2_forward_from_wb;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            id2ex_reg_wen  <= 1'b0;
            id2ex_exc_ill_instr <= 1'b0;
            id2ex_mem_rd <= 1'b0;
            id2ex_mem_wr <= 1'b0;
            id2ex_br_instr <= 1'b0;
            id2ex_jal_instr <= 1'b0;
            id2ex_jalr_instr <= 1'b0;
            id2ex_csr_rd <= 1'b0;
            id2ex_csr_wr_op <= `CORE_CSR_NOP;
            id2ex_mret <= 1'b0;
        end
        else begin
            id2ex_reg_wen <= reg_wen & id_stage_valid;
            id2ex_mem_rd <= mem_rd & id_stage_valid;
            id2ex_mem_wr <= mem_wr & id_stage_valid;
            id2ex_br_instr <= br_instr & id_stage_valid;
            id2ex_jal_instr <= jal_instr & id_stage_valid;
            id2ex_jalr_instr <= jalr_instr & id_stage_valid;
            id2ex_mret <= mret & id_stage_valid;
            id2ex_csr_rd <= csr_rd & id_stage_valid;
            id2ex_csr_wr_op <= id_stage_valid ? csr_wr_op : `CORE_CSR_NOP;
            id2ex_exc_ill_instr <= exc_ill_instr & id_stage_valid_raw;
        end
    end

    always @(posedge clk) begin
        id2ex_pc <= if2id_pc;
        id2ex_instruction <= if2id_instruction;
        id2ex_reg_waddr <= reg_waddr;
        id2ex_op1_data <= reg_rs1_data;
        id2ex_op2_data <= reg_rs2_data;
        id2ex_imm_value <= imm_value;
        id2ex_alu_op <= alu_op;
        id2ex_sel_imm <= sel_imm;
        id2ex_op1_sel_pc <= op1_sel_pc;
        id2ex_op1_sel_zero <= op1_sel_zero;
        id2ex_op2_sel_4 <= op2_sel_4;
        id2ex_mem_op <= mem_op;
        id2ex_branch_op <= branch_op;
        id2ex_op1_forward_from_mem <= op1_forward_from_mem;
        id2ex_op1_forward_from_wb <= op1_forward_from_wb;
        id2ex_op2_forward_from_mem <= op2_forward_from_mem;
        id2ex_op2_forward_from_wb <= op2_forward_from_wb;
        id2ex_csr_addr <= csr_addr;
    end

    assign id_stage_valid_raw = if2id_valid & ~id_flush;
    assign id_stage_valid = id_stage_valid_raw & ~exc_ill_instr;

    //////////////////////////////
    // Forward check
    //////////////////////////////
    assign op1_forward_from_mem = (reg_rs1_addr == id2ex_reg_waddr) & id2ex_reg_wen & reg_rs1_rd & (reg_rs1_addr != 0);
    assign op1_forward_from_wb  = (reg_rs1_addr == ex2mem_reg_waddr) & ex2mem_reg_wen & reg_rs1_rd & (reg_rs1_addr != 0);
    assign op2_forward_from_mem = (reg_rs2_addr == id2ex_reg_waddr) & id2ex_reg_wen & reg_rs2_rd & (reg_rs2_addr != 0);
    assign op2_forward_from_wb  = (reg_rs2_addr == ex2mem_reg_waddr) & ex2mem_reg_wen & reg_rs2_rd & (reg_rs2_addr != 0);

    //////////////////////////////
    // Load Dependence check
    //////////////////////////////
    assign load_dependence = id2ex_mem_rd & id2ex_reg_wen &
                             ((reg_rs1_addr == id2ex_reg_waddr) & reg_rs1_rd  |
                              (reg_rs2_addr == id2ex_reg_waddr) & reg_rs2_rd);

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // register file
    /* regfile AUTO_TEMPLATE (
        .clk        (clk),
        .rst        (rst),
        .wen        (wb_reg_wen),
        .waddr      (wb_reg_waddr),
        .din        (wb_reg_wdata),
        .addr_rs1   (reg_rs1_addr[`RF_RANGE]),
        .dout_rs1   (reg_rs1_data[`DATA_RANGE]),
        .addr_rs2   (reg_rs2_addr[`RF_RANGE]),
        .dout_rs2   (reg_rs2_data[`DATA_RANGE]),
        ); */
    regfile
    regfile (/*AUTOINST*/
             // Outputs
             .dout_rs1                  (reg_rs1_data[`DATA_RANGE]), // Templated
             .dout_rs2                  (reg_rs2_data[`DATA_RANGE]), // Templated
             // Inputs
             .clk                       (clk),                   // Templated
             .rst                       (rst),                   // Templated
             .wen                       (wb_reg_wen),            // Templated
             .waddr                     (wb_reg_waddr),          // Templated
             .din                       (wb_reg_wdata),          // Templated
             .addr_rs1                  (reg_rs1_addr[`RF_RANGE]), // Templated
             .addr_rs2                  (reg_rs2_addr[`RF_RANGE])); // Templated

    // decoder
    /* decoder AUTO_TEMPLATE (
        .instruction     (if2id_instruction),
        ); */
    decoder
    decoder (/*AUTOINST*/
             // Outputs
             .reg_wen                   (reg_wen),
             .reg_waddr                 (reg_waddr[`RF_RANGE]),
             .reg_rs1_addr              (reg_rs1_addr[`RF_RANGE]),
             .reg_rs2_addr              (reg_rs2_addr[`RF_RANGE]),
             .reg_rs1_rd                (reg_rs1_rd),
             .reg_rs2_rd                (reg_rs2_rd),
             .br_instr                  (br_instr),
             .jal_instr                 (jal_instr),
             .jalr_instr                (jalr_instr),
             .op1_sel_zero              (op1_sel_zero),
             .op1_sel_pc                (op1_sel_pc),
             .op2_sel_4                 (op2_sel_4),
             .sel_imm                   (sel_imm),
             .csr_rd                    (csr_rd),
             .csr_wr_op                 (csr_wr_op[`CORE_CSR_OP_RANGE]),
             .csr_addr                  (csr_addr[`CORE_CSR_ADDR_RANGE]),
             .imm_value                 (imm_value[`DATA_RANGE]),
             .alu_op                    (alu_op[`CORE_ALU_OP_RANGE]),
             .branch_op                 (branch_op[`CORE_BRANCH_OP_RANGE]),
             .mem_rd                    (mem_rd),
             .mem_wr                    (mem_wr),
             .mem_op                    (mem_op[`CORE_MEM_OP_RANGE]),
             .mret                      (mret),
             .exc_ill_instr             (exc_ill_instr),
             // Inputs
             .instruction               (if2id_instruction));     // Templated

endmodule

// Notes for the forwarding logic and ALU operand1 and ALU operand2 source
// ALU operand 1 source:
//  1. register rs1 data
//  2. 0 (for LUI)
//  3. PC (for AUIPC)
// ALU operand 2 source:
//  1. register rs2 data
//  2. immediate value
//  3. 4 (for JAL/JALR)

// Register wdata source
// 1. ALU result
// 2. Memory read result
// 3. PC + 4 (JAL/JALR)
