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
    // input from IF/ID stage pipe
    input [`PC_RANGE]   if2id_pc,
    input [`DATA_RANGE] if2id_instruction,
    // input from MEM stage
    input [`RF_RANGE]   ex2mem_reg_waddr,
    input               ex2mem_reg_wen,
    // input from WB stage
    input               reg_wen,
    input [`RF_RANGE]   reg_waddr,
    input [`DATA_RANGE] reg_wdata,
    // pipeline stage
    output reg                      id2ex_reg_wen,
    output reg [`RF_RANGE]          id2ex_reg_waddr,
    output reg [`DATA_RANGE]        id2ex_reg_rs1_data,
    output reg [`DATA_RANGE]        id2ex_reg_rs2_data,
    output reg [`IMM_RANGE]         id2ex_imm_value,
    output reg [`CORE_ALU_OP_RANGE] id2ex_alu_op,
    output reg                      id2ex_sel_imm,
    output reg                      id2ex_rs1_forward_from_mem,
    output reg                      id2ex_rs1_forward_from_wb,
    output reg                      id2ex_rs2_forward_from_mem,
    output reg                      id2ex_rs2_forward_from_wb,
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
    wire [`RF_RANGE]    dec_reg_rs1_addr;
    wire [`DATA_RANGE]  dec_reg_rs1_data;
    wire [`RF_RANGE]    dec_reg_rs2_addr;
    wire [`DATA_RANGE]  dec_reg_rs2_data;
    // datapath control
    wire [`CORE_ALU_OP_RANGE]   dec_alu_op;
    wire                        dec_sel_imm;
    wire                        rs1_forward_from_mem;
    wire                        rs1_forward_from_wb;
    wire                        rs2_forward_from_mem;
    wire                        rs2_forward_from_wb;
    // datapath data
    wire [`IMM_RANGE]           dec_imm_value;
    // Other
    wire dec_ill_instr;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            id2ex_reg_wen  <= 1'b0;
            id2ex_ill_instr <= 1'b0;
        end
        else begin
            id2ex_reg_wen <= dec_reg_wen;
            id2ex_ill_instr <= dec_ill_instr;
        end
    end

    always @(posedge clk) begin
        id2ex_reg_waddr <= dec_reg_waddr;
        id2ex_reg_rs1_data <= dec_reg_rs1_data;
        id2ex_reg_rs2_data <= dec_reg_rs2_data;
        id2ex_imm_value <= dec_imm_value;
        id2ex_alu_op <= dec_alu_op;
        id2ex_sel_imm <= dec_sel_imm;
        id2ex_rs1_forward_from_mem <= rs1_forward_from_mem;
        id2ex_rs1_forward_from_wb <= rs1_forward_from_wb;
        id2ex_rs2_forward_from_mem <= rs2_forward_from_mem;
        id2ex_rs2_forward_from_wb <= rs2_forward_from_wb;
    end

    //////////////////////////////
    // Forward check
    //////////////////////////////
    assign rs1_forward_from_mem = (dec_reg_rs1_addr == id2ex_reg_waddr) & id2ex_reg_wen;
    assign rs1_forward_from_wb  = (dec_reg_rs1_addr == ex2mem_reg_waddr) & ex2mem_reg_wen;
    assign rs2_forward_from_mem = (dec_reg_rs2_addr == id2ex_reg_waddr) & id2ex_reg_wen;
    assign rs2_forward_from_wb  = (dec_reg_rs2_addr == ex2mem_reg_waddr) & ex2mem_reg_wen;

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
        .\(.*\)           (dec_\1),
        ); */
    decoder
    decoder (/*AUTOINST*/
             // Outputs
             .reg_wen                   (dec_reg_wen),           // Templated
             .reg_waddr                 (dec_reg_waddr),         // Templated
             .reg_rs1_addr              (dec_reg_rs1_addr),      // Templated
             .reg_rs2_addr              (dec_reg_rs2_addr),      // Templated
             .alu_op                    (dec_alu_op),            // Templated
             .sel_imm                   (dec_sel_imm),           // Templated
             .imm_value                 (dec_imm_value),         // Templated
             .ill_instr                 (dec_ill_instr),         // Templated
             // Inputs
             .instruction               (if2id_instruction));        // Templated

endmodule
