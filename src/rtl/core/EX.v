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
    input                               id2ex_reg_wen,
    input [`RF_RANGE]                   id2ex_reg_waddr,
    input [`DATA_RANGE]                 id2ex_op1_data,
    input [`DATA_RANGE]                 id2ex_op2_data,
    input [`DATA_RANGE]                 id2ex_imm_value,
    input [`CORE_ALU_OP_RANGE]          id2ex_alu_op,
    input [`CORE_MEM_RD_OP_RANGE]       id2ex_mem_rd_op,
    input [`CORE_MEM_WR_OP_RANGE]       id2ex_mem_wr_op,
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
    input                               id2ex_sel_csr,
    input [`CORE_CSR_OP_RANGE]          id2ex_csr_wr_op,
    input [`CORE_CSR_ADDR_RANGE]        id2ex_csr_addr,
    input                               id2ex_ill_instr,
    // input from wb stage
    input [`DATA_RANGE]                 wb_reg_wdata,
    // interface to lsu
    input                               lsu_mem_rd,
    output [`DATA_RANGE]                lsu_addr,
    output [`DATA_RANGE]                lsu_wdata,
    // branch control
    output [`PC_RANGE]                  target_pc,
    output                              take_branch,
    // pipeline stage
    output reg                          ex2mem_csr_rd,
    output reg [`CORE_CSR_OP_RANGE]     ex2mem_csr_wr_op,
    output reg [`DATA_RANGE]            ex2mem_csr_wdata,
    output reg [`CORE_CSR_ADDR_RANGE]   ex2mem_csr_addr,
    output reg                          ex2mem_sel_csr,
    output reg                          ex2mem_reg_wen,
    output reg [`RF_RANGE]              ex2mem_reg_waddr,
    output reg [`DATA_RANGE]            ex2mem_alu_out,
    output reg                          ex2mem_mem_rd,
    output reg                          ex2mem_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////
    wire [`DATA_RANGE]  alu_out;
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
            ex2mem_mem_rd <= 1'b0;
            ex2mem_csr_rd <= 1'b0;
            ex2mem_csr_wr_op <= `CORE_CSR_NOP;
            ex2mem_ill_instr <= 1'b0;
        end
        else begin
            ex2mem_reg_wen <= id2ex_reg_wen;
            ex2mem_mem_rd <= lsu_mem_rd;
            ex2mem_csr_rd <= id2ex_csr_rd;
            ex2mem_csr_wr_op <= id2ex_csr_wr_op;
            ex2mem_csr_addr <= id2ex_csr_addr;
            ex2mem_ill_instr <= id2ex_ill_instr;
        end
    end

    always @(posedge clk) begin
        ex2mem_alu_out <= alu_out;
        ex2mem_reg_waddr <= id2ex_reg_waddr;
        ex2mem_sel_csr <= id2ex_sel_csr;
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

    // Address generation for memory
    assign lsu_addr = op1_forwarded + id2ex_imm_value;
    assign lsu_wdata = op2_forwarded;

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
        .exc_addr_misaligned            (exc_addr_misaligned),
        // Inputs
        .br_instr                       (id2ex_br_instr),        // Templated
        .jal_instr                      (id2ex_jal_instr),      // Templated
        .jalr_instr                     (id2ex_jalr_instr),     // Templated
        .branch_op                      (id2ex_branch_op),       // Templated
        .rs1                            (op1_forwarded),         // Templated
        .rs2                            (op2_forwarded),         // Templated
        .imm_value                      (id2ex_imm_value),       // Templated
        .pc                             (id2ex_pc));              // Templated


endmodule
