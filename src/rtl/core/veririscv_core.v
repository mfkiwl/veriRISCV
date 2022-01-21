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
    wire [`DATA_RANGE]    if2id_instruction;
    wire [`PC_RANGE]      if2id_pc;
    wire [`PC_RANGE]      pc_out;

    // ID stage
    wire [`CORE_ALU_OP_RANGE] id2ex_alu_op;
    wire                id2ex_ill_instr;
    wire [`DATA_RANGE]  id2ex_reg_rs1_data;
    wire [`DATA_RANGE]  id2ex_reg_rs2_data;
    wire [`RF_RANGE]    id2ex_reg_waddr;
    wire                id2ex_reg_wen;
    wire [`IMM_RANGE]   id2ex_imm_value;
    wire                id2ex_rs1_forward_from_mem;
    wire                id2ex_rs1_forward_from_wb;
    wire                id2ex_rs2_forward_from_mem;
    wire                id2ex_rs2_forward_from_wb;
    wire                id2ex_sel_imm;

    // EX stage
    wire [`DATA_RANGE]  ex2mem_alu_out;
    wire                ex2mem_ill_instr;
    wire [`RF_RANGE]    ex2mem_reg_waddr;
    wire                ex2mem_reg_wen;

    // MEM stage
    wire [`DATA_RANGE]  mem2wb_alu_out;
    wire                mem2wb_ill_instr;
    wire [`RF_RANGE]    mem2wb_reg_waddr;
    wire                mem2wb_reg_wen;

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
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
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
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_reg_rs1_data             (id2ex_reg_rs1_data[`DATA_RANGE]),
        .id2ex_reg_rs2_data             (id2ex_reg_rs2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`IMM_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_rs1_forward_from_mem     (id2ex_rs1_forward_from_mem),
        .id2ex_rs1_forward_from_wb      (id2ex_rs1_forward_from_wb),
        .id2ex_rs2_forward_from_mem     (id2ex_rs2_forward_from_mem),
        .id2ex_rs2_forward_from_wb      (id2ex_rs2_forward_from_wb),
        .id2ex_ill_instr                (id2ex_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .reg_wen                        (wb_reg_wen),            // Templated
        .reg_waddr                      (wb_reg_waddr),          // Templated
        .reg_wdata                      (wb_reg_wdata));          // Templated


    /////////////////////////////////
    // EX stage
    /////////////////////////////////

    EX
    EX (/*AUTOINST*/
        // Outputs
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_alu_out                 (ex2mem_alu_out[`DATA_RANGE]),
        .ex2mem_ill_instr               (ex2mem_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_reg_rs1_data             (id2ex_reg_rs1_data[`DATA_RANGE]),
        .id2ex_reg_rs2_data             (id2ex_reg_rs2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`IMM_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_rs1_forward_from_mem     (id2ex_rs1_forward_from_mem),
        .id2ex_rs1_forward_from_wb      (id2ex_rs1_forward_from_wb),
        .id2ex_rs2_forward_from_mem     (id2ex_rs2_forward_from_mem),
        .id2ex_rs2_forward_from_wb      (id2ex_rs2_forward_from_wb),
        .id2ex_ill_instr                (id2ex_ill_instr),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]));


    /////////////////////////////////
    // MEM stage
    /////////////////////////////////

    MEM
    MEW (/*AUTOINST*/
         // Outputs
         .mem2wb_reg_wen                (mem2wb_reg_wen),
         .mem2wb_reg_waddr              (mem2wb_reg_waddr[`RF_RANGE]),
         .mem2wb_alu_out                (mem2wb_alu_out[`DATA_RANGE]),
         .mem2wb_ill_instr              (mem2wb_ill_instr),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .ex2mem_reg_wen                (ex2mem_reg_wen),
         .ex2mem_reg_waddr              (ex2mem_reg_waddr[`RF_RANGE]),
         .ex2mem_alu_out                (ex2mem_alu_out[`DATA_RANGE]),
         .ex2mem_ill_instr              (ex2mem_ill_instr));

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
        .mem2wb_reg_wen                 (mem2wb_reg_wen),
        .mem2wb_reg_waddr               (mem2wb_reg_waddr[`RF_RANGE]),
        .mem2wb_alu_out                 (mem2wb_alu_out[`DATA_RANGE]),
        .mem2wb_ill_instr               (mem2wb_ill_instr));


    /////////////////////////////////
    // Simulation Related
    /////////////////////////////////

    `ifdef COCOTB_SIM
        initial begin
        $dumpfile ("veririscv_core.vcd");
        $dumpvars (0, veririscv_core);
        #1;
        end
    `endif

endmodule

