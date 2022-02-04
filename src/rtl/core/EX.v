///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: EX
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// EX (Execution stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module EX (
    input                               clk,
    input                               rst,
    // input from ID/EX stage pipe
    input [`PC_RANGE]                   id2ex_pc,
    input [`DATA_RANGE]                 id2ex_instruction,
    input                               id2ex_reg_wen,
    input [`RF_RANGE]                   id2ex_reg_waddr,
    input [`DATA_RANGE]                 id2ex_op1_data,
    input [`DATA_RANGE]                 id2ex_op2_data,
    input [`DATA_RANGE]                 id2ex_imm_value,
    input [`CORE_ALU_OP_RANGE]          id2ex_alu_op,
    input                               id2ex_mem_rd,
    input                               id2ex_mem_wr,
    input [`CORE_MEM_OP_RANGE]          id2ex_mem_op,
    input [`CORE_BRANCH_OP_RANGE]       id2ex_branch_op,
    input                               id2ex_br_instr,
    input                               id2ex_jal_instr,
    input                               id2ex_jalr_instr,
    input                               id2ex_sel_imm,
    input                               id2ex_op1_sel_pc,
    input                               id2ex_op1_sel_zero,
    input                               id2ex_op2_sel_4,
    input                               id2ex_op1_forward_from_mem,
    input                               id2ex_op1_forward_from_wb,
    input                               id2ex_op2_forward_from_mem,
    input                               id2ex_op2_forward_from_wb,
    input                               id2ex_csr_rd,
    input [`CORE_CSR_OP_RANGE]          id2ex_csr_wr_op,
    input [`CORE_CSR_ADDR_RANGE]        id2ex_csr_addr,
    input                               id2ex_mret,
    input                               id2ex_exc_ill_instr,
    // input from wb stage
    input [`DATA_RANGE]                 wb_reg_wdata,
    // interface to lsu in memory stage
    output                              lsu_mem_rd,
    output                              lsu_mem_wr,
    output [`CORE_MEM_OP_RANGE]         lsu_mem_op,
    output [`DATA_RANGE]                lsu_addr,
    output [`DATA_RANGE]                lsu_wdata,
    // branch control
    output [`PC_RANGE]                  target_pc,
    output                              take_branch,
    // pipeline stage
    output reg [`PC_RANGE]              ex2mem_pc,
    output reg [`DATA_RANGE]            ex2mem_instruction,
    output reg                          ex2mem_csr_rd,
    output reg [`CORE_CSR_OP_RANGE]     ex2mem_csr_wr_op,
    output reg [`DATA_RANGE]            ex2mem_csr_wdata,
    output reg [`CORE_CSR_ADDR_RANGE]   ex2mem_csr_addr,
    output reg                          ex2mem_reg_wen,
    output reg [`RF_RANGE]              ex2mem_reg_waddr,
    output reg [`DATA_RANGE]            ex2mem_alu_out,
    output reg                          ex2mem_mret,
    // exception
    output reg                          ex2mem_exc_ill_instr,
    output reg                          ex2mem_exc_instr_addr_misaligned
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [`DATA_RANGE]  alu_out;                // From alu of alu.v
    wire                exc_instr_addr_misaligned;// From bu of bu.v
    // End of automatics

    /*AUTOREG*/

    wire [`DATA_RANGE]  op1_forwarded;
    wire [`DATA_RANGE]  op2_forwarded;
    wire [`DATA_RANGE]  alu_oprand_0;
    wire [`DATA_RANGE]  alu_oprand_1;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            ex2mem_reg_wen <= 1'b0;
            ex2mem_csr_rd <= 1'b0;
            ex2mem_csr_wr_op <= `CORE_CSR_NOP;
            ex2mem_mret <= 1'b0;
            ex2mem_exc_ill_instr <= 1'b0;
            ex2mem_exc_instr_addr_misaligned <= 1'b0;
        end
        else begin
            ex2mem_reg_wen <= id2ex_reg_wen;
            ex2mem_csr_rd <= id2ex_csr_rd;
            ex2mem_csr_wr_op <= id2ex_csr_wr_op;
            ex2mem_mret <= id2ex_mret;
            ex2mem_exc_ill_instr <= id2ex_exc_ill_instr;
            ex2mem_exc_instr_addr_misaligned <= exc_instr_addr_misaligned;
        end
    end

    always @(posedge clk) begin
        ex2mem_pc <= id2ex_pc;
        ex2mem_instruction <= id2ex_instruction;
        ex2mem_alu_out <= alu_out;
        ex2mem_reg_waddr <= id2ex_reg_waddr;
        ex2mem_csr_addr <= id2ex_csr_addr;
        ex2mem_csr_wdata <= id2ex_sel_imm ? id2ex_imm_value : op1_forwarded;
    end

    //////////////////////////////
    // Logic
    //////////////////////////////

    // Forwarding MUX
    assign op1_forwarded =  (id2ex_op1_forward_from_mem) ? ex2mem_alu_out :
                            (id2ex_op1_forward_from_wb) ?  wb_reg_wdata :
                            id2ex_op1_data;

    assign op2_forwarded =  (id2ex_op2_forward_from_mem) ? ex2mem_alu_out :
                            (id2ex_op2_forward_from_wb) ?  wb_reg_wdata :
                            id2ex_op2_data;

    // immediate select
    assign alu_oprand_0 = id2ex_op1_sel_pc ? id2ex_pc :
                          id2ex_op1_sel_zero ? 'b0 :
                          op1_forwarded;
    assign alu_oprand_1 = id2ex_sel_imm ? id2ex_imm_value :
                          id2ex_op2_sel_4 ? 'd4 :
                          op2_forwarded;

    // Signal to LSU
    assign lsu_addr = op1_forwarded + id2ex_imm_value;  // memory address generation
    assign lsu_wdata = op2_forwarded;
    assign lsu_mem_rd = id2ex_mem_rd;
    assign lsu_mem_wr = id2ex_mem_wr;
    assign lsu_mem_op = id2ex_mem_op;

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // ALU
    /* alu AUTO_TEMPLATE (
        .alu_op        (id2ex_alu_op),
        ); */
    alu
    alu (/*AUTOINST*/
         // Outputs
         .alu_out                       (alu_out[`DATA_RANGE]),
         // Inputs
         .alu_oprand_0                  (alu_oprand_0[`DATA_RANGE]),
         .alu_oprand_1                  (alu_oprand_1[`DATA_RANGE]),
         .alu_op                        (id2ex_alu_op));          // Templated


    // BU
    /* bu AUTO_TEMPLATE (
        .rs1        (op1_forwarded),
        .rs2        (op2_forwarded),
        .br_instr   (id2ex_br_instr),
        .jal_instr  (id2ex_jal_instr),
        .jalr_instr (id2ex_jalr_instr),
        .branch_op  (id2ex_branch_op),
        .pc         (id2ex_pc),
        .imm_value  (id2ex_imm_value),
        ); */
    bu
    bu (/*AUTOINST*/
        // Outputs
        .target_pc                      (target_pc[`PC_RANGE]),
        .take_branch                    (take_branch),
        .exc_instr_addr_misaligned      (exc_instr_addr_misaligned),
        // Inputs
        .br_instr                       (id2ex_br_instr),        // Templated
        .jal_instr                      (id2ex_jal_instr),       // Templated
        .jalr_instr                     (id2ex_jalr_instr),      // Templated
        .branch_op                      (id2ex_branch_op),       // Templated
        .rs1                            (op1_forwarded),         // Templated
        .rs2                            (op2_forwarded),         // Templated
        .imm_value                      (id2ex_imm_value),       // Templated
        .pc                             (id2ex_pc));              // Templated


endmodule
