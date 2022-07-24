// ---------------------------------------------------------------
// Copyright (c) 2022 Heqing Huang
// ---------------------------------------------------------------


module arty_top (
    // Clock Input
    input           clk,
    // Push Button
    input  [3:0]    btn,
    // LEDR
    output [3:0]    led,
    // DPDT Switch
    input  [3:0]    sw,
    // CPU reset
    input           ck_rst,
    // UART
    output          uart_rxd_out,
    input           uart_txd_in
);

    wire [31:0] gpio0;

    logic clk_50;

    assign led[2] = gpio0[0];
    assign led[3] = gpio0[1];

    mmcm mmcm(.clk_out1(clk_50), .clk_in1(clk));

    veriRISCV_soc #(.CLK_FREQ_MHZ(50))
    veriRISCV_soc (
        .clk                (clk_50),
        .rst                (~ck_rst),
        .gpio0              (gpio0),
        .gpio1              (),
        .uart_debug_en      (sw[0]),
        .core_en            (sw[1]),
        .uart_host_writing  (led[0]),
        .uart_host_reading  (led[1]),
        .uart_txd           (uart_rxd_out),
        .uart_rxd           (uart_txd_in)
    );

endmodule
