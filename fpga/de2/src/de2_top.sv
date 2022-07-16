// ---------------------------------------------------------------
// Copyright (c) 2022 Heqing Huang
//
// Template taken from ECE5760
// https://people.ece.cornell.edu/land/courses/ece5760/DE2/DDS_Example/sine_wave.v
//
// ---------------------------------------------------------------


module de2_top (
    // Clock Input
    input         CLOCK_50,
    // Push Button
    input  [3:0]  KEY,
    // LEDR
    output [17:0] LEDR,
    // DPDT Switch
    input  [17:0] SW,
    // SRAM Interface
    inout  [15:0] SRAM_DQ,
    output [17:0] SRAM_ADDR,
    output        SRAM_UB_N,
    output        SRAM_LB_N,
    output        SRAM_WE_N,
    output        SRAM_CE_N,
    output        SRAM_OE_N,
    // UART
    output        UART_TXD,
    input         UART_RXD
);

    wire [31:0] gpio0;

    logic       clk;

    assign LEDR = gpio0[17:0];

    `ifndef SRAM
        //Disable SRAM.
        assign SRAM_ADDR = 18'h0;
        assign SRAM_CE_N = 1'b1;
        assign SRAM_DQ   = 16'hzzzz;
        assign SRAM_LB_N = 1'b1;
        assign SRAM_OE_N = 1'b1;
        assign SRAM_UB_N = 1'b1;
        assign SRAM_WE_N = 1'b1;
    `endif

    pll
    pll (
        .inclk0 (CLOCK_50),
        .c0     (clk)
    );

    veriRISCV_soc #(.CLK_FREQ_MHZ(25))
    veriRISCV_soc (
        .clk            (clk),
        .rst            (~KEY[0]),
        .gpio0          (gpio0),
        .gpio1          (),
        .uart_debug_en  (SW[0]),
    `ifdef SRAM
        .sram_ce_n      (SRAM_CE_N),
        .sram_oe_n      (SRAM_OE_N),
        .sram_we_n      (SRAM_WE_N),
        .sram_be_n      ({SRAM_UB_N, SRAM_LB_N}),
        .sram_addr      (SRAM_ADDR),
        .sram_dq        (SRAM_DQ),
    `endif
        .uart_txd       (UART_TXD),
        .uart_rxd       (UART_RXD)
    );

endmodule
