///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: IF
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// IF (Instruction Fetch stage)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"

module IF (
    input                   clk,
    input                   rst,
    // to instruction ram
    output [`INSTR_RAM_ADDR_RANGE]  instr_ram_addr,
    output                  instr_ram_rd,
    input [`DATA_RANGE]     instr_ram_din,
    // pipeline stage
    output reg [`PC_RANGE]  if2id_pc,
    output [`DATA_RANGE]    if2id_instruction
);

    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    wire [`PC_RANGE]    pc_out;

    //////////////////////////////

    assign instr_ram_addr = pc_out[`INSTR_RAM_ADDR_RANGE];   // Select part of the PC as instruction ram address
    assign instr_ram_rd = ~rst; // for now, we always read the instruction ram
    assign if2id_instruction = instr_ram_din;  // for now, assume that the instrunction ram hold the data in the output reigster

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            if2id_pc <= 'b0;
        end
        else begin
            if2id_pc <= pc_out;
        end
    end


    //////////////////////////////
    // Module instantiation
    //////////////////////////////
    pc
    pc(
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

endmodule