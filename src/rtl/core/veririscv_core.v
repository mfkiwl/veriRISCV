///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: veririscv_core
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// veririscv core top level
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module veririscv_core (
    input   clk,
    input   rst,

    // Instruction RAM port
    output                          instr_ram_rd,
    output [`INSTR_RAM_ADDR_RANGE]  instr_ram_addr,
    input  [`DATA_RANGE]            instr_ram_din
);

    /////////////////////////////////
    // Signal Declaration
    /////////////////////////////////

    /*AUTOREG*/

    /*AUTOWIRE*/

    // IF stage
    wire [`DATA_RANGE]    if_instruction;
    wire [`PC_RANGE]      if_pc;
    wire [`PC_RANGE]      pc_out;

    // ID stage
    wire [`CORE_ALU_OP_RANGE] id_alu_op;
    wire                id_ill_instr;
    wire [`DATA_RANGE]  id_reg_rs1_data;
    wire [`DATA_RANGE]  id_reg_rs2_data;
    wire [`RF_RANGE]    id_reg_waddr;
    wire                id_reg_wen;

    // EX stage
    wire [`DATA_RANGE]  ex_alu_out;
    wire                ex_ill_instr;
    wire [`RF_RANGE]    ex_reg_waddr;
    wire                ex_reg_wen;

    // MEM stage
    wire [`DATA_RANGE]  mem_alu_out;
    wire                mem_ill_instr;
    wire [`RF_RANGE]    mem_reg_waddr;
    wire                mem_reg_wen;

    // WB stage
    wire [`RF_RANGE]    wb_reg_waddr;
    wire [`DATA_RANGE]  wb_reg_wdata;
    wire                wb_reg_wen;

    /////////////////////////////////

    /////////////////////////////////
    // IF stage
    /////////////////////////////////
    IF
    IF (/*AUTOINST*/
        // Outputs
        .instr_ram_addr                 (instr_ram_addr[`INSTR_RAM_ADDR_RANGE]),
        .instr_ram_rd                   (instr_ram_rd),
        .if_pc                          (if_pc[`PC_RANGE]),
        .if_instruction                 (if_instruction[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .instr_ram_din                  (instr_ram_din[`DATA_RANGE]));


    /////////////////////////////////
    // ID stage
    /////////////////////////////////

    /* ID AUTO_TEMPLATE (
        .reg_\(.*\)     (wb_reg_\1),
        ); */
    ID
    ID (/*AUTOINST*/
        // Outputs
        .id_reg_wen                     (id_reg_wen),
        .id_reg_waddr                   (id_reg_waddr[`RF_RANGE]),
        .id_reg_rs1_data                (id_reg_rs1_data[`DATA_RANGE]),
        .id_reg_rs2_data                (id_reg_rs2_data[`DATA_RANGE]),
        .id_alu_op                      (id_alu_op[`CORE_ALU_OP_RANGE]),
        .id_ill_instr                   (id_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .if_pc                          (if_pc[`PC_RANGE]),
        .if_instruction                 (if_instruction[`DATA_RANGE]),
        .reg_wen                        (wb_reg_wen),            // Templated
        .reg_waddr                      (wb_reg_waddr),          // Templated
        .reg_wdata                      (wb_reg_wdata));          // Templated


    /////////////////////////////////
    // EX stage
    /////////////////////////////////

    EX
    EX (/*AUTOINST*/
        // Outputs
        .ex_reg_wen                     (ex_reg_wen),
        .ex_reg_waddr                   (ex_reg_waddr[`RF_RANGE]),
        .ex_alu_out                     (ex_alu_out[`DATA_RANGE]),
        .ex_ill_instr                   (ex_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .id_reg_wen                     (id_reg_wen),
        .id_reg_waddr                   (id_reg_waddr[`RF_RANGE]),
        .id_reg_rs1_data                (id_reg_rs1_data[`DATA_RANGE]),
        .id_reg_rs2_data                (id_reg_rs2_data[`DATA_RANGE]),
        .id_alu_op                      (id_alu_op[`CORE_ALU_OP_RANGE]),
        .id_ill_instr                   (id_ill_instr));


    /////////////////////////////////
    // MEM stage
    /////////////////////////////////

    MEM
    MEW (/*AUTOINST*/
         // Outputs
         .mem_reg_wen                   (mem_reg_wen),
         .mem_reg_waddr                 (mem_reg_waddr[`RF_RANGE]),
         .mem_alu_out                   (mem_alu_out[`DATA_RANGE]),
         .mem_ill_instr                 (mem_ill_instr),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .ex_reg_wen                    (ex_reg_wen),
         .ex_reg_waddr                  (ex_reg_waddr[`RF_RANGE]),
         .ex_alu_out                    (ex_alu_out[`DATA_RANGE]),
         .ex_ill_instr                  (ex_ill_instr));

    /////////////////////////////////
    // WB stage
    /////////////////////////////////

    WB
    WB (/*AUTOINST*/
        // Outputs
        .wb_reg_wen                     (wb_reg_wen),
        .wb_reg_waddr                   (wb_reg_waddr[`RF_RANGE]),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .mem_reg_wen                    (mem_reg_wen),
        .mem_reg_waddr                  (mem_reg_waddr[`RF_RANGE]),
        .mem_alu_out                    (mem_alu_out[`DATA_RANGE]),
        .mem_ill_instr                  (mem_ill_instr));

endmodule

