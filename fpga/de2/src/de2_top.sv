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
    // UART
    output        UART_TXD,
    input         UART_RXD
);

    wire [31:0] gpio0;

    assign LEDR = gpio0[17:0];

    veriRISCV_soc
    veriRISCV_soc (
        .clk            (CLOCK_50),
        .rst            (~KEY[0]),
        .gpio0          (gpio0),
        .gpio1          (),
        .uart_debug_en  (SW[0]),
        .uart_txd       (UART_TXD),
        .uart_rxd       (UART_RXD)
    );

endmodule
