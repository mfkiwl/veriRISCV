/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/07/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * Uart TX
 * ---------------------------------------------------------------
*/

module uart_tx (
    input           clk,
    input           rst,

    input [15:0]    cfg_div,
    input           cfg_txen,
    input           cfg_nstop,

    input           tx_valid,
    input [7:0]     tx_data,
    output reg      tx_ready,

    output reg      uart_txd
);

    // --------------------------------------------
    //  Signal Declaration
    // --------------------------------------------

    logic           req;
    logic           baud_tick;
    logic           cycle_cnt_cmpl;
    logic           cycle_cnt_fire;

    reg             baud_clear;
    reg [7:0]       buffer;
    reg [2:0]       cycle_cnt;

    localparam IDLE  = 0;
    localparam START = 1;
    localparam DATA  = 2;
    localparam STOP  = 3;
    reg [1:0]       state;
    logic [1:0]     state_next;

    // --------------------------------------------
    //  main logic
    // --------------------------------------------

    assign          req = tx_valid & tx_ready & cfg_txen;
    assign          cycle_cnt_fire = (cycle_cnt == 0);
    assign          cycle_cnt_cmpl = cycle_cnt_fire & baud_tick;

    always @(*) begin
        state_next = state;
        case(state)
            IDLE:  if (req) state_next = START;
            START: if (baud_tick) state_next = DATA;
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
        tx_ready <= 1'b0;

        if (baud_tick) cycle_cnt <= cycle_cnt - 1'b1;

        case(state)
            IDLE: begin
                buffer <= tx_data;
                tx_ready <= ~req;
                uart_txd <= 1'b1;
                baud_clear <= 1'b1;
            end
            START: begin
                uart_txd <= 1'b0;
                cycle_cnt <= 7;
            end
            DATA: begin
                uart_txd <= buffer[0];
                if (baud_tick) buffer <= (buffer >> 1);
                if (cycle_cnt_cmpl) cycle_cnt <= {2'b0, cfg_nstop};
            end
            STOP: begin
                uart_txd <= 1'b1;
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
        .baud_sample    ()
    );

endmodule
