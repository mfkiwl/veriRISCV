// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/12/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Testbench
// ------------------------------------------------------------------------------------------------

module tb_top (
    input                   clk,
    input                   rst,
    inout [31:0]            gpio0,
    inout [31:0]            gpio1,
    input                   uart_debug_en
);
    parameter SRAM_AW   = 19;   // SRAM address width
    parameter SRAM_DW   = 16;   // SRAM data width

    `ifdef SRAM
        // the sram interface
        logic                   sram_ce_n;
        logic                   sram_oe_n;
        logic                   sram_we_n;
        logic [SRAM_DW/8-1:0]   sram_be_n;
        logic [SRAM_AW-1:0]     sram_addr;
        logic [SRAM_DW-1:0]     sram_dq_read;
        /* verilator lint_off UNOPT */
        wire  [SRAM_DW-1:0]     sram_dq;
        /* verilator lint_on UNOPT */
        SRAM SRAM(.*);
    `endif

    logic                       core_en;
    logic                       uart_host_writing;
    logic                       uart_host_reading;
    logic                       uart_txd;
    logic                       uart_rxd;

    veriRISCV_soc #(
    `ifdef SRAM
        .SRAM_AW    (SRAM_AW),
        .SRAM_DW    (SRAM_DW),
    `endif
        .GPIO0_WIDTH    (32),
        .UART_BAUD_RATE (115200),
        .CLK_FREQ_MHZ   (50)
    ) u_veriRISCV_soc (.*);

    assign uart_rxd = uart_txd;
    assign core_en  = 1'b1;

endmodule
