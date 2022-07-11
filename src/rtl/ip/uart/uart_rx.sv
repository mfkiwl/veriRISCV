/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/07/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * Uart RX
 * ---------------------------------------------------------------
*/

module uart_rx (
    input           clk,
    input           rst,

    input [15:0]    cfg_div,
    input           cfg_rxen,
    input           cfg_nstop,

    output reg       rx_valid,
    output reg [7:0] rx_data,

    input           uart_rxd
);

    // --------------------------------------------
    //  Signal Declaration
    // --------------------------------------------

    logic           baud_tick;
    logic           baud_sample;
    logic           cycle_cnt_fire;
    logic           cycle_cnt_cmpl;
    logic           sample_cnt_fire;
    logic           uart_rxd_synced;

    reg [1:0]       uart_rxd_sync;
    reg             baud_clear;
    reg [2:0]       cycle_cnt;
    reg [3:0]       sample_cnt;

    localparam IDLE  = 0;
    localparam START = 1;
    localparam DATA  = 2;
    localparam STOP  = 3;
    reg [1:0]       state;
    logic [1:0]     state_next;

    // --------------------------------------------
    //  main logic
    // --------------------------------------------

    assign cycle_cnt_fire = (cycle_cnt == 0);
    assign cycle_cnt_cmpl = cycle_cnt_fire & baud_tick;
    assign sample_cnt_fire = (sample_cnt == 0);

    // double flop synchronization for the uart_rxd signal
    always @(posedge clk) begin
        if (rst) uart_rxd_sync <= 2'b11;
        else begin
            uart_rxd_sync[0] <= uart_rxd;
            uart_rxd_sync[1] <= uart_rxd_sync[0];
        end
    end
    assign uart_rxd_synced = uart_rxd_sync[1];

    always @(*) begin
        state_next = state;
        case(state)
            IDLE:  if (!uart_rxd_synced & cfg_rxen) state_next = START;
            START: if (sample_cnt_fire) state_next = DATA; // wait till the middle of the start signal
            DATA:  if (cycle_cnt_cmpl) state_next = STOP;
            STOP:  if (cycle_cnt_cmpl) state_next = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else state <= state_next;
    end

    always @(posedge clk) begin

        baud_clear <= 1'b0;
        rx_valid <= 1'b0;

        if (baud_sample) sample_cnt <= sample_cnt - 1'b1;
        if (baud_tick) cycle_cnt <= cycle_cnt - 1'b1;

        case(state)
            IDLE: begin
                baud_clear <= 1'b1;
                sample_cnt <= 7;
            end
            START: begin
                // clear baud counter when we reach the middle of the bit
                // so we restart the baud counter on the middle of each bit
                if (sample_cnt_fire) baud_clear <= 1'b1;
                cycle_cnt <= 7;
            end
            DATA: begin
                if (baud_tick) rx_data <= {uart_rxd_synced, rx_data[7:1]};
                if (cycle_cnt_cmpl) cycle_cnt <= {2'b0, cfg_nstop};
            end
            STOP: begin
                rx_valid <= cycle_cnt_cmpl;
            end
        endcase
    end

    // --------------------------------------------
    //  Module instantiation
    // --------------------------------------------

    uart_baud u_uart_baud(
        .clk            (clk),
        .rst            (rst),
        .cfg_div        (cfg_div),
        .baud_clear     (baud_clear),
        .baud_tick      (baud_tick),
        .baud_sample    (baud_sample)
    );

endmodule
