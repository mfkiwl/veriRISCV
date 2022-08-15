// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// register_file File
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module regfile (
    input                   clk,
    input                   rst,

    input                   reg_write,
    input [`RF_RANGE]       reg_regid,
    input [`DATA_RANGE]     reg_writedata,

    input  [`RF_RANGE]      rs1_regid,
    output [`DATA_RANGE]    rs1_readdata,

    input  [`RF_RANGE]      rs2_regid,
    output [`DATA_RANGE]    rs2_readdata
);

    reg [`DATA_RANGE] register_file[`REG_NUM-1:0];

    logic rs1_regid_eq_zero;
    logic rs2_regid_eq_zero;

    logic rs1_forward;
    logic rs2_forward;

    // Write back port
    always @(posedge clk) begin
        if (reg_write) register_file[reg_regid] <= reg_writedata;
    end

    // Register_file $0 is always read zero. Here we use a mux to select 0 when read reg_regid is 0
    // We formard the data from WB stage if there is a dependence here.

    // Read port A
    assign rs1_regid_eq_zero = (rs1_regid == 0);
    assign rs1_forward = (rs1_regid == reg_regid) & reg_write;
    assign rs1_readdata = rs1_regid_eq_zero ? 0 : (rs1_forward ? reg_writedata : register_file[rs1_regid]);

    // Read port B
    assign rs2_regid_eq_zero = (rs2_regid == 0);
    assign rs2_forward = (rs2_regid == reg_regid) & reg_write;
    assign rs2_readdata = rs2_regid_eq_zero ? 0 : (rs2_forward ? reg_writedata : register_file[rs2_regid]);

endmodule
