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
    input                       id_reg_wen,
    input [`RF_RANGE]           id_reg_waddr,
    input [`DATA_RANGE]         id_reg_rs1_data,
    input [`DATA_RANGE]         id_reg_rs2_data,
    input [`CORE_ALU_OP_RANGE]  id_alu_op,
    input                       id_ill_instr,
    // pipeline stage
    output reg                  ex_reg_wen,
    output reg [`RF_RANGE]      ex_reg_waddr,
    output reg [`DATA_RANGE]    ex_alu_out,
    output reg                  ex_ill_instr
);


    //////////////////////////////
    // Signal Declaration
    //////////////////////////////
    wire [`DATA_RANGE]  alu_out;


    //////////////////////////////

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            ex_reg_wen <= 1'b0;
            ex_ill_instr <= 1'b0;
        end
        else begin
            ex_reg_wen <= id_reg_wen;
            ex_ill_instr <= id_ill_instr;
        end
    end

    always @(posedge clk) begin
        ex_alu_out <= alu_out;
        ex_reg_waddr <= id_reg_waddr;
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////
    alu
    alu (
        .alu_oprand_0       (id_reg_rs1_data),
        .alu_oprand_1       (id_reg_rs2_data),
        .alu_op             (id_alu_op),
        .alu_out            (alu_out)
    );

endmodule