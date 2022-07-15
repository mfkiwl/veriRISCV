// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/12/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// SRAM model for simulation
// ------------------------------------------------------------------------------------------------

module SRAM #(
    parameter AW   = 19,   // SRAM address width
    parameter DW   = 16    // SRAM data width
) (
    // the sram interface
    input               sram_ce_n,
    input               sram_oe_n,
    input               sram_we_n,
    input [DW/8-1:0]    sram_be_n,
    input [AW-1:0]      sram_addr,
    inout [DW-1:0]      sram_dq
);


    logic sram_write;
    logic sram_read;
    logic [DW/8-1:0] sram_write_byte;

    reg [DW-1:0] sram_mem[(1<<AW)-1:0];

    assign sram_write = ~sram_ce_n & ~sram_we_n;
    assign sram_write_byte = {(DW/8){sram_write}} & ~sram_be_n;
    assign sram_read = ~sram_ce_n & ~sram_oe_n;

    assign sram_dq = sram_read ? sram_mem[sram_addr] : 'z;

    genvar i;
    generate
        for (i = 0; i < DW/8; i++ ) begin
            always @* begin
                if (sram_write_byte[i]) begin
                    sram_mem[sram_addr][i*8+8-1:i*8] = sram_dq[i*8+8-1:i*8];
                end
            end
        end
    endgenerate



endmodule