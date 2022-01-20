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
    input [`PC_RANGE]   if_pc,
    input [`DATA_RANGE] if_instruction,
    // input from WB stage
    input               reg_wen,
    input [`RF_RANGE]   reg_waddr,
    input [`DATA_RANGE] reg_wdata,
    // pipeline stage
    output reg                      id_reg_wen,
    output reg [`RF_RANGE]          id_reg_waddr,
    output reg [`DATA_RANGE]        id_reg_rs1_data,
    output reg [`DATA_RANGE]        id_reg_rs2_data,
    output reg [`CORE_ALU_OP_RANGE] id_alu_op,
    output reg                      id_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    // register file
    wire                dec_reg_wen;
    wire [`RF_RANGE]    dec_reg_waddr;
    wire [`RF_RANGE]    dec_reg_rs1_addr;
    wire [`DATA_RANGE]  dec_reg_rs1_data;
    wire [`RF_RANGE]    dec_reg_rs2_addr;
    wire [`DATA_RANGE]  dec_reg_rs2_data;
    // ALU
    wire [`CORE_ALU_OP_RANGE]   dec_alu_op;
    // Other
    wire dec_ill_instr;

    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            id_reg_wen  <= 1'b0;
            id_ill_instr <= 1'b0;
        end
        else begin
            id_reg_wen <= dec_reg_wen;
            id_ill_instr <= dec_ill_instr;
        end
    end

    always @(posedge clk) begin
        id_reg_waddr <= dec_reg_waddr;
        id_reg_rs1_data <= dec_reg_rs1_data;
        id_reg_rs2_data <= dec_reg_rs2_data;
        id_alu_op <= dec_alu_op;
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////

    // register file
    regfile
    regfile (
        .clk        (clk),
        .rst        (rst),
        .wen        (reg_wen),
        .waddr      (reg_waddr),
        .din        (reg_wdata),
        .addr_rs1   (dec_reg_rs1_addr),
        .dout_rs1   (dec_reg_rs1_data),
        .addr_rs2   (dec_reg_rs2_addr),
        .dout_rs2   (dec_reg_rs2_data)
    );

    // decoder
    decoder
    decoder (
        .instruction     (if_instruction),
        .reg_wen         (dec_reg_wen),
        .reg_waddr       (dec_reg_waddr),
        .reg_rs1_addr    (dec_reg_rs1_addr),
        .reg_rs2_addr    (dec_reg_rs2_addr),
        .alu_op          (dec_alu_op),
        .ill_instr       (dec_ill_instr)
    );

endmodule