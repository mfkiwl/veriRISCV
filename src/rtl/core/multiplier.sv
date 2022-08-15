// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/06/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Multiplier for RISCV

/**

This multiplier is mainly targeting FPGA so we use * operator directly.
We have input register and output register so we expect the logic to be mapped into the FPGA DSP logic.

Mul will raise stall to stall the pipeline,

If a req is pending and stall is deasserted, then the data is valid and send to the next stage.

opcode used in opcode signal:
    MUL       2'b00
    MULH      2'b01
    MULHSU    2'b10
    MULHU     2'b11

*/


`include "core.svh"

module multiplier (
    input                   clk,
    input                   rst,
    input                   req,
    input  [1:0]            opcode,
    input  [`DATA_RANGE]    a,      // rs1
    input  [`DATA_RANGE]    b,      // rs2
    output [`DATA_RANGE]    o,      // rd
    output                  stall
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    reg [1:0]                           stage_valid;
    reg                                 busy;
    logic                               new_req;

    // stage 0
    logic [`DATA_WIDTH:0]               a_sign_ext_0;
    logic [`DATA_WIDTH:0]               b_sign_ext_0;
    logic [`DATA_WIDTH:0]               a_unsign_ext_0;
    logic [`DATA_WIDTH:0]               b_unsign_ext_0;

    reg signed [`DATA_WIDTH:0]          a_s1;
    reg signed [`DATA_WIDTH:0]          b_s1;

    // stage 1
    reg signed [(`DATA_WIDTH+1)*2-1:0]  o_s2;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    // stage 0: process the input data and store it in the register

    assign a_sign_ext_0 = {a[`DATA_WIDTH-1], a};
    assign b_sign_ext_0 = {b[`DATA_WIDTH-1], b};
    assign a_unsign_ext_0 = {1'b0, a};
    assign b_unsign_ext_0 = {1'b0, b};

    // a unsigned ext: MULHU => opcode[1:0] == 2'b11
    always @(posedge clk) a_s1 <= (opcode[1:0] == 2'b11) ? a_unsign_ext_0 : a_sign_ext_0;

    // b usigned ext: MULHSU or MULHU => opcode[1] == 1
    always @(posedge clk) b_s1 <= opcode[1] ? b_unsign_ext_0 : b_sign_ext_0;

    // stage 1: calculate the result
    always @(posedge clk) o_s2 <= a_s1 * b_s1;

    // stage 2: process the output data (pipeline register is EX/MEM stage)
    assign o = (opcode[1:0] == 2'b00) ? o_s2[`DATA_WIDTH-1:0] : o_s2[2*`DATA_WIDTH-1:`DATA_WIDTH];

    // flow control
    assign new_req = ~busy & req;
    always @(posedge clk) begin
        if (rst) stage_valid <= 'b0;
        else stage_valid <= {stage_valid[0], new_req};
    end

    always @(posedge clk) begin
        if (rst) busy <= 1'b0;
        else if (new_req) busy <= 1'b1;
        else if (stage_valid[1]) busy <= 1'b0;
    end

    assign stall = new_req | busy & ~stage_valid[1];

endmodule