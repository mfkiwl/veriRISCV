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
    input   clk,
    input   rst,
    input   id_flush,
    // input from IF/ID stage pipe
    input               if2id_valid,
    input [`PC_RANGE]   if2id_pc,
    input [`DATA_RANGE] if2id_instruction,
    // input from EX stage
    input               lsu_mem_rd,
    // input from MEM stage
    input [`RF_RANGE]   ex2mem_reg_waddr,
    input               ex2mem_reg_wen,
    // input from WB stage
    input               reg_wen,
    input [`RF_RANGE]   reg_waddr,
    input [`DATA_RANGE] reg_wdata,
    // to HDU
    output              load_dependence,
    // pipeline stage
    output reg [`PC_RANGE]          id2ex_pc,
    output reg                      id2ex_reg_wen,
    output reg [`RF_RANGE]          id2ex_reg_waddr,
    output reg [`DATA_RANGE]        id2ex_op1_data,
    output reg [`DATA_RANGE]        id2ex_op2_data,
    output reg [`DATA_RANGE]        id2ex_imm_value,
    output reg [`CORE_ALU_OP_RANGE] id2ex_alu_op,
    output reg [`CORE_MEM_RD_OP_RANGE] id2ex_mem_rd_op,
    output reg [`CORE_MEM_WR_OP_RANGE] id2ex_mem_wr_op,
    output reg [`CORE_BRANCH_OP_RANGE] id2ex_branch_op,
    output reg                         id2ex_br_instr,
    output reg                      id2ex_jal_instr,
    output reg                      id2ex_jalr_instr,
    output reg                      id2ex_sel_imm,
    output reg                      id2ex_op1_sel_pc,
    output reg                      id2ex_op1_sel_zero,
    output reg                      id2ex_op2_sel_4,
    output reg                      id2ex_op1_forward_from_mem,
    output reg                      id2ex_op1_forward_from_wb,
    output reg                      id2ex_op2_forward_from_mem,
    output reg                      id2ex_op2_forward_from_wb,
    output reg                      id2ex_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/

    /*AUTOREG*/

    // register file
    wire                dec_reg_wen;
    wire [`RF_RANGE]    dec_reg_waddr;
    wire                dec_reg_rs1_rd;
    wire                dec_reg_rs2_rd;
    wire [`RF_RANGE]    dec_reg_rs1_addr;
    wire [`DATA_RANGE]  dec_reg_rs1_data;
    wire [`RF_RANGE]    dec_reg_rs2_addr;
    wire [`DATA_RANGE]  dec_reg_rs2_data;
    // datapath
    wire    dec_op1_sel_pc;
    wire    dec_op1_sel_zero;
    wire    dec_sel_imm;
    wire    op1_forward_from_mem;
    wire    op1_forward_from_wb;
    wire    op2_forward_from_mem;
    wire    op2_forward_from_wb;
    wire    dec_forwarding;
    wire    dec_special_rs1_sel;
    wire    dec_ja_instr;
    wire    dec_op2_sel_4;
    wire    dec_br_instr;
    wire    dec_jal_instr;
    wire    dec_jalr_instr;

    wire [`DATA_RANGE]  dec_special_rs1_value;
    wire [`DATA_RANGE]  dec_imm_value;
    wire [`CORE_ALU_OP_RANGE]   dec_alu_op;
    wire [`CORE_MEM_RD_OP_RANGE] dec_mem_rd_op;
    wire [`CORE_MEM_WR_OP_RANGE] dec_mem_wr_op;
    wire [`CORE_BRANCH_OP_RANGE] dec_branch_op;


    // exception
    wire dec_ill_instr;
    wire dec_exc_ill_instr;
    // Others
    wire id_stage_valid;
    wire id_stage_valid_raw;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            id2ex_reg_wen  <= 1'b0;
            id2ex_ill_instr <= 1'b0;
            id2ex_mem_rd_op <= `CORE_MEM_NO_RD;
            id2ex_mem_wr_op <= `CORE_MEM_NO_WR;
            id2ex_br_instr <= 1'b0;
            id2ex_jal_instr <= 1'b0;
            id2ex_jalr_instr <= 1'b0;
        end
        else begin
            id2ex_reg_wen <= dec_reg_wen & id_stage_valid;
            id2ex_mem_rd_op <= id_stage_valid ? dec_mem_rd_op : `CORE_MEM_NO_RD;
            id2ex_mem_wr_op <= id_stage_valid ? dec_mem_wr_op : `CORE_MEM_NO_WR;
            id2ex_br_instr <= dec_br_instr & id_stage_valid;
            id2ex_jal_instr <= dec_jal_instr & id_stage_valid;
            id2ex_jalr_instr <= dec_jalr_instr & id_stage_valid;
            id2ex_ill_instr <= dec_ill_instr & id_stage_valid_raw;
        end
    end

    always @(posedge clk) begin
        id2ex_pc <= if2id_pc;
        id2ex_reg_waddr <= dec_reg_waddr;
        id2ex_op1_data <= dec_reg_rs1_data;
        id2ex_op2_data <= dec_reg_rs2_data;
        id2ex_imm_value <= dec_imm_value;
        id2ex_alu_op <= dec_alu_op;
        id2ex_sel_imm <= dec_sel_imm;
        id2ex_op1_sel_pc <= dec_op1_sel_pc;
        id2ex_op1_sel_zero <= dec_op1_sel_zero;
        id2ex_op2_sel_4 <= dec_op2_sel_4;
        id2ex_branch_op <= dec_branch_op;
        id2ex_op1_forward_from_mem <= op1_forward_from_mem;
        id2ex_op1_forward_from_wb <= op1_forward_from_wb;
        id2ex_op2_forward_from_mem <= op2_forward_from_mem;
        id2ex_op2_forward_from_wb <= op2_forward_from_wb;
    end

    assign id_stage_valid_raw = if2id_valid & ~id_flush;
    assign id_stage_valid = id_stage_valid_raw & ~dec_exc_ill_instr;

    //////////////////////////////
    // Forward check
    //////////////////////////////
    assign op1_forward_from_mem = (dec_reg_rs1_addr == id2ex_reg_waddr) & id2ex_reg_wen & dec_reg_rs1_rd & (dec_reg_rs1_addr != 0);
    assign op1_forward_from_wb  = (dec_reg_rs1_addr == ex2mem_reg_waddr) & ex2mem_reg_wen & dec_reg_rs1_rd & (dec_reg_rs1_addr != 0);
    assign op2_forward_from_mem = (dec_reg_rs2_addr == id2ex_reg_waddr) & id2ex_reg_wen & dec_reg_rs2_rd & (dec_reg_rs2_addr != 0);
    assign op2_forward_from_wb  = (dec_reg_rs2_addr == ex2mem_reg_waddr) & ex2mem_reg_wen & dec_reg_rs2_rd & (dec_reg_rs2_addr != 0);

    //////////////////////////////
    // Load Dependence check
    //////////////////////////////
    assign load_dependence = lsu_mem_rd & id2ex_reg_wen &
                             ((dec_reg_rs1_addr == id2ex_reg_waddr) & dec_reg_rs1_rd  |
                              (dec_reg_rs2_addr == id2ex_reg_waddr) & dec_reg_rs2_rd);

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // register file
    /* regfile AUTO_TEMPLATE (
        .clk        (clk),
        .rst        (rst),
        .wen        (reg_wen),
        .waddr      (reg_waddr),
        .din        (reg_wdata),
        .addr_rs1   (dec_reg_rs1_addr),
        .dout_rs1   (dec_reg_rs1_data),
        .addr_rs2   (dec_reg_rs2_addr),
        .dout_rs2   (dec_reg_rs2_data),
        ); */
    regfile
    regfile (/*AUTOINST*/
             // Outputs
             .dout_rs1                  (dec_reg_rs1_data),      // Templated
             .dout_rs2                  (dec_reg_rs2_data),      // Templated
             // Inputs
             .clk                       (clk),                   // Templated
             .rst                       (rst),                   // Templated
             .wen                       (reg_wen),               // Templated
             .waddr                     (reg_waddr),             // Templated
             .din                       (reg_wdata),             // Templated
             .addr_rs1                  (dec_reg_rs1_addr),      // Templated
             .addr_rs2                  (dec_reg_rs2_addr));      // Templated

    // decoder
    /* decoder AUTO_TEMPLATE (
        .instruction     (if2id_instruction),
        .\(.*\)          (dec_\1),
        ); */
    decoder
    decoder (/*AUTOINST*/
             // Outputs
             .reg_wen                   (dec_reg_wen),           // Templated
             .reg_waddr                 (dec_reg_waddr),         // Templated
             .reg_rs1_addr              (dec_reg_rs1_addr),      // Templated
             .reg_rs2_addr              (dec_reg_rs2_addr),      // Templated
             .reg_rs1_rd                (dec_reg_rs1_rd),        // Templated
             .reg_rs2_rd                (dec_reg_rs2_rd),        // Templated
             .sel_imm                   (dec_sel_imm),           // Templated
             .imm_value                 (dec_imm_value),         // Templated
             .alu_op                    (dec_alu_op),            // Templated
             .mem_rd_op                 (dec_mem_rd_op),         // Templated
             .mem_wr_op                 (dec_mem_wr_op),         // Templated
             .branch_op                 (dec_branch_op),         // Templated
             .br_instr                  (dec_br_instr),          // Templated
             .jal_instr                 (dec_jal_instr),         // Templated
             .jalr_instr                (dec_jalr_instr),        // Templated
             .op1_sel_zero              (dec_op1_sel_zero),      // Templated
             .op1_sel_pc                (dec_op1_sel_pc),        // Templated
             .op2_sel_4                 (dec_op2_sel_4),         // Templated
             .exc_ill_instr             (dec_exc_ill_instr),     // Templated
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
