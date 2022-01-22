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
    input   clk,
    input   rst,
    // input from ID/EX stage pipe
    input                       id2ex_reg_wen,
    input [`RF_RANGE]           id2ex_reg_waddr,
    input [`DATA_RANGE]         id2ex_reg_rs1_data,
    input [`DATA_RANGE]         id2ex_reg_rs2_data,
    input [`IMM_RANGE]          id2ex_imm_value,
    input [`CORE_ALU_OP_RANGE]  id2ex_alu_op,
    input [`CORE_MEM_RD_OP_RENGE] id2ex_mem_rd_op,
    input [`CORE_MEM_WR_OP_RENGE] id2ex_mem_wr_op,
    input                       id2ex_sel_imm,
    input                       id2ex_rs1_forward_from_mem,
    input                       id2ex_rs1_forward_from_wb,
    input                       id2ex_rs2_forward_from_mem,
    input                       id2ex_rs2_forward_from_wb,
    input                       id2ex_ill_instr,
    // input from wb stage
    input [`DATA_RANGE]         wb_reg_wdata,
    // interface to lsu
    input                       lsu_mem_rd,
    output [`DATA_RANGE]        lsu_addr,
    output [`DATA_RANGE]        lsu_wdata,
    // pipeline stage
    //output reg [`CORE_MEM_RD_OP_RENGE] ex2mem_mem_rd_op,
    //output reg [`CORE_MEM_WR_OP_RENGE] ex2mem_mem_wr_op,
    output reg                  ex2mem_reg_wen,
    output reg [`RF_RANGE]      ex2mem_reg_waddr,
    output reg [`DATA_RANGE]    ex2mem_alu_out,
    output reg                  ex2mem_mem_rd,
    output reg                  ex2mem_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////
    wire [`DATA_RANGE]  alu_out;
    wire [`DATA_RANGE]  rs1_forwarded;
    wire [`DATA_RANGE]  rs2_forwarded;
    wire [`DATA_RANGE]  alu_oprand_0;
    wire [`DATA_RANGE]  alu_oprand_1;
    wire [`DATA_RANGE]  imm_value;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            ex2mem_reg_wen <= 1'b0;
            ex2mem_ill_instr <= 1'b0;
            ex2mem_mem_rd <= 1'b0;
        end
        else begin
            ex2mem_reg_wen <= id2ex_reg_wen;
            //ex2mem_mem_rd_op <= id2ex_mem_rd_op;
            //ex2mem_mem_wr_op <= id2ex_mem_wr_op;
            ex2mem_mem_rd <= lsu_mem_rd;
            ex2mem_ill_instr <= id2ex_ill_instr;
        end
    end

    always @(posedge clk) begin
        ex2mem_alu_out <= alu_out;
        ex2mem_reg_waddr <= id2ex_reg_waddr;
    end

    //////////////////////////////
    // Logic
    //////////////////////////////

    // Forwarding MUX
    assign rs1_forwarded =  (id2ex_rs1_forward_from_mem) ? ex2mem_alu_out :
                            (id2ex_rs1_forward_from_wb) ?  wb_reg_wdata :
                            id2ex_reg_rs1_data;

    assign rs2_forwarded =  (id2ex_rs2_forward_from_mem) ? ex2mem_alu_out :
                            (id2ex_rs2_forward_from_wb) ?  wb_reg_wdata :
                            id2ex_reg_rs2_data;

    // immediate select
    assign alu_oprand_0 = rs1_forwarded;
    assign imm_value = {{12{id2ex_imm_value[19]}}, id2ex_imm_value};  // sign ext the imm value
    assign alu_oprand_1 = (id2ex_sel_imm) ? imm_value : rs2_forwarded;

    // Address generation for memory
    assign lsu_addr = rs1_forwarded + imm_value;
    assign lsu_wdata = rs2_forwarded;

    //////////////////////////////
    // Module instantiation
    //////////////////////////////
    alu
    alu (
        .alu_oprand_0       (alu_oprand_0),
        .alu_oprand_1       (alu_oprand_1),
        .alu_op             (id2ex_alu_op),
        .alu_out            (alu_out)
    );

endmodule