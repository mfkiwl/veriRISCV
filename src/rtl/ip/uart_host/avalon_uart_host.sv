/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/10/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * Uart Host to access memory mapped address using avalon interface
 *
 * It receives data from the Uart RX port.

 * The expected data format is 4 byte address + 4 byte data.
 * Received Byte: 0 1 2 3 4 5 6 7 8
 * content: AB0, AB1, AB2, AB3, DB0, DB1, DB2, DB3
 * AB0 ~ AB3: Address byte 0 ~ byte 3. DB0 ~ DB1: Data byte 0 ~ byte 3
 * Currently only memory write (memWr) access is supported
 * ---------------------------------------------------------------
 */


module avalon_uart_host (
    input               clk,
    input               rst,

    output              avn_read,
    output              avn_write,
    output [31:0]       avn_address,
    output [31:0]       avn_writedata,
    output [3:0]        avn_byte_enable,
    input  [31:0]       avn_readdata,
    input               avn_waitrequest,

    input [15:0]        cfg_div,
    input               cfg_rxen,
    input               uart_rxd
);

    // --------------------------------------------
    //  Sginal Declaration
    // --------------------------------------------

    localparam WIDTH = 64;

    logic               cfg_nstop;

    logic               rx_valid;
    logic [7:0]         rx_data;

    logic               fifo_push;
    logic               fifo_pop;
    logic               fifo_full;
    logic               fifo_empty;
    logic [WIDTH-1:0]   fifo_din;
    logic [WIDTH-1:0]   fifo_dout;

    reg [WIDTH-1:0]     cmd;
    reg [3:0]           data_count;
    reg                 cmd_cmpl;

    logic               data_count_fire;

    // --------------------------------------------
    //  Glue logic
    // --------------------------------------------

    // Uart configuration
    assign cfg_nstop = 0;

    assign data_count_fire = data_count == 7;

    always @(posedge clk) begin
        if (rst) data_count <= 0;
        else begin
            if (rx_valid) begin
                if (data_count_fire) data_count <= 0;
                else data_count <= data_count + 1;
            end
        end
    end

    always @(posedge clk) begin
        cmd_cmpl <= 0;
        if (rx_valid) begin
            cmd <= {rx_data, cmd[WIDTH-1:8]};
            if (data_count_fire) cmd_cmpl <= 1;
        end
    end

    assign fifo_push = cmd_cmpl & ~fifo_full;
    assign fifo_din = cmd;
    assign fifo_pop = avn_write & ~avn_waitrequest;

    assign avn_write = ~fifo_empty;
    assign avn_address = fifo_dout[31:0];
    assign avn_writedata = fifo_dout[63:32];
    assign avn_byte_enable = 4'b1111;

    // --------------------------------------------
    //  Module instantiation
    // --------------------------------------------

    uart_rx u_uart_rx(.*);

    uart_fifo #( .WIDTH (64), .DEPTH (2))
    u_fifo (
        .rst    (rst),
        .clk    (clk),
        .push   (fifo_push),
        .pop    (fifo_pop),
        .din    (fifo_din),
        .dout   (fifo_dout),
        .full   (fifo_full),
        .empty  (fifo_empty),
        .entry  ()
    );

endmodule
