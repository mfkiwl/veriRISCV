/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/07/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * Baud Rate generation
 * - baud_tick: regular baud tick signal
 * - baud_sample: 16x Rx oversampling
 * ---------------------------------------------------------------
*/

module uart_baud #(
    parameter SAMPLE = 1
) (
    input           clk,
    input           rst,
    input [15:0]    cfg_div,
    input           baud_clear,
    output reg      baud_tick,
    output reg      baud_sample
);

    reg [15:0]      baud_cnt;
    logic           baud_cnt_fire;
    logic [15:0]    div;

    assign baud_cnt_fire = baud_cnt == 0;
    assign div = cfg_div + 1'b1;

    always @(posedge clk) begin
        if (rst) baud_cnt <= 0;
        else begin
            if (baud_cnt_fire || baud_clear) baud_cnt <= div;
            else baud_cnt <= baud_cnt - 1'b1;
        end
    end

    always @(posedge clk) begin
        if (rst) baud_tick <= 0;
        else baud_tick <= baud_cnt_fire;
    end

    generate
        if (SAMPLE) begin: sample_logic
            reg [11:0]  sample_cnt;
            logic       sample_cnt_fire;

            assign sample_cnt_fire = sample_cnt == 0;

            always @(posedge clk) begin
                if (rst) sample_cnt <= 0;
                else begin
                    if (sample_cnt_fire || baud_clear) sample_cnt <= div[15:4];
                    else sample_cnt <= sample_cnt - 1'b1;
                end
            end

            always @(posedge clk) begin
                if (rst) baud_sample <= 0;
                else baud_sample <= sample_cnt_fire;
            end
        end
        else begin: no_sample_logic
            always baud_sample = 0;
        end
    endgenerate

endmodule
