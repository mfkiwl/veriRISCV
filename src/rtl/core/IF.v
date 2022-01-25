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
    input                   if_flush,
    input                   if2id_stall,
    // AHBLite Interface to Instruction RAM
    output                  ibus_hwrite,
    output [2:0]            ibus_hsize,
    output [2:0]            ibus_hburst,
    output [3:0]            ibus_hport,
    output [1:0]            ibus_htrans,
    output                  ibus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  ibus_haddr,
    output [`DATA_RANGE]    ibus_hwdata,
    input                   ibus_hready,
    input                   ibus_hresp,
    input  [`DATA_RANGE]    ibus_hrdata,
    // input from other pipeline stage
    input                   take_branch,
    input [`PC_RANGE]       target_pc,
    // pipeline stage
    output reg              if2id_valid,
    output reg [`PC_RANGE]  if2id_pc,
    output [`DATA_RANGE]    if2id_instruction
);

    //////////////////////////////
    // Signal Declaration
    //////////////////////////////

    /*AUTOWIRE*/

    /*AUTOREG*/

    wire [`PC_RANGE]    pc_out;

    reg  [`DATA_RANGE]  prev_instr;
    reg                 use_prev_instr;

    //////////////////////////////

    // AHBlite interface
    assign ibus_hwrite = 1'b0;
    assign ibus_hsize = 3'b010;    // word - 32 bits
    assign ibus_hburst = 3'b0;
    assign ibus_hport  = 4'b0;
    assign ibus_htrans = rst ? 2'b00 : 2'b10; // NONSEQ
    assign ibus_hmastlock = 1'b0;
    assign ibus_haddr = pc_out[`INSTR_RAM_ADDR_RANGE];
    assign ibus_hwdata = 'b0;

    // FIXME:
    // ibus_hready
    // ibus_hresp

    assign if2id_instruction = use_prev_instr ? prev_instr : ibus_hrdata;

    //////////////////////////////
    // Pipeline Stage
    //////////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            if2id_valid <= 1'b0;
        end
        else begin
            if (!if2id_stall) begin
                if2id_valid <= ~if_flush;
            end
        end
    end

    always @(posedge clk) begin
        if (!if2id_stall) begin
            if2id_pc <= pc_out;
        end
    end

    //////////////////////////////
    // logic
    //////////////////////////////
    // store the current instruction if stall
    always @(posedge clk) begin
        if (if2id_stall) begin
            prev_instr <= ibus_hrdata;
        end
    end

    always @(posedge clk) begin
        if (rst) use_prev_instr <= 1'b0;
        else begin
            if (if2id_stall) use_prev_instr <= 1'b1;
            else use_prev_instr <= 1'b0;
        end
    end

    //////////////////////////////
    // Module instantiation
    //////////////////////////////
    // PC
    /* pc AUTO_TEMPLATE (
        ); */
    pc
    pc(/*AUTOINST*/
       // Outputs
       .pc_out                          (pc_out[`PC_RANGE]),
       // Inputs
       .clk                             (clk),
       .rst                             (rst),
       .take_branch                     (take_branch),
       .target_pc                       (target_pc[`PC_RANGE]));

endmodule
