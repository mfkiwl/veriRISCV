/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/07/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * Avalon Memory Mapped Uart Core
 * ---------------------------------------------------------------
 */


module avalon_uart (
    input               clk,
    input               rst,

    input               avn_read,
    input               avn_write,
    input [4:0]         avn_address,
    input [31:0]        avn_writedata,
    output reg [31:0]   avn_readdata,
    output              avn_waitrequest,

    output              int_txwm,
    output              int_rxwm,

    output              uart_txd,
    input               uart_rxd
);

    // --------------------------------------------
    //  Sginal Declaration
    // --------------------------------------------

    logic [15:0]    cfg_div;
    logic           cfg_txen;
    logic           cfg_rxen;
    logic           cfg_nstop;

    logic           tx_valid;
    logic [7:0]     tx_data;
    logic           tx_ready;
    logic           rx_valid;
    logic [7:0]     rx_data;

    logic           txfifo_push;
    logic           txfifo_pop;
    logic [7:0]     txfifo_din;
    logic [7:0]     txfifo_dout;
    logic           txfifo_full;
    logic           txfifo_empty;
    logic [3:0]     txfifo_entry;

    logic           rxfifo_push;
    logic           rxfifo_pop;
    logic [7:0]     rxfifo_din;
    logic [7:0]     rxfifo_dout;
    logic           rxfifo_full;
    logic           rxfifo_empty;
    logic [3:0]     rxfifo_entry;

    logic           txwm;
    logic           rxwm;

    reg             txdata_valid;

    // --------------------------------------------
    //  Register logic
    // --------------------------------------------

    // -- register definations -- //

    // txdata 0x0
    logic [31:0]    txdata;
    reg             txdata_full;
    reg [7:0]       txdata_data;
    logic           txdata_write;
    assign txdata = {txdata_full, 23'b0, txdata_data};

    // rxdata 0x4
    logic [31:0]    rxdata;
    reg             rxdata_empty;
    reg [7:0]       rxdata_data;
    logic           rxdata_read;
    assign rxdata = {rxdata_empty, 23'b0, rxdata_data};

    // txctrl 0x8
    logic [31:0]    txctrl;
    reg [2:0]       txctrl_txcnt;
    reg             txctrl_nstop;   // 0 for 1 stop bit and 1 for 2 stop bit
    reg             txctrl_txen;
    logic           txctrl_write;
    assign txctrl = {13'b0, txctrl_txcnt, 14'b0, txctrl_nstop, txctrl_txen};

    // rxctrl 0xC
    logic [31:0]    rxctrl;
    reg [2:0]       rxctrl_rxcnt;
    reg             rxctrl_rxen;
    logic           rxctrl_write;
    assign rxctrl = {13'b0, rxctrl_rxcnt, 15'b0, rxctrl_rxen};

    // ie 0x10
    logic [31:0]    ie;
    reg             ie_rxwm;
    reg             ie_txwm;
    logic           ie_write;
    assign ie = {30'b0, ip_rxwm, ip_txwm};

    // ip 0x14
    logic [31:0]    ip;
    reg             ip_rxwm;
    reg             ip_txwm;
    assign ip = {30'b0, ip_rxwm, ip_txwm};

    // div 0x18
    logic [31:0]    div;
    reg [15:0]      div_div;    // div = (fin / fbaud - 1)
    logic           div_write;
    assign div = {16'b0, div_div};

    // -- read logic -- //
    always @(posedge clk) begin
        case(avn_address)
        5'h00: avn_readdata <= txdata;
        5'h04: avn_readdata <= rxdata;
        5'h08: avn_readdata <= txctrl;
        5'h0C: avn_readdata <= rxctrl;
        5'h10: avn_readdata <= ie;
        5'h14: avn_readdata <= ip;
        5'h18: avn_readdata <= txdata;
        default: avn_readdata <= txdata;
        endcase
    end

    // -- write logic -- //

    // write enable for each register
    always @* begin
        txdata_write = 1'b0;
        txctrl_write = 1'b0;
        rxctrl_write = 1'b0;
        ie_write = 1'b0;
        div_write = 1'b0;
        /* verilator lint_off CASEINCOMPLETE */
        case(avn_address)
        /* verilator lint_on CASEINCOMPLETE */
        5'h00: txdata_write = avn_write;
        5'h08: txctrl_write = avn_write;
        5'h0C: rxctrl_write = avn_write;
        5'h10: ie_write = avn_write;
        5'h18: div_write = avn_write;
        endcase
    end

    // software: rw
    // hardware: r
    always @(posedge clk) begin
        if (txdata_write) begin
            txdata_data <= avn_writedata[7:0];
        end
        if (txctrl_write) begin
            txctrl_txcnt <= avn_writedata[18:16];
            txctrl_nstop <= avn_writedata[1];
            txctrl_txen <= avn_writedata[0];
        end
        if (rxctrl_write) begin
            rxctrl_rxcnt <= avn_writedata[18:16];
            rxctrl_rxen <= avn_writedata[0];
        end
        if (ie_write) begin
            ie_rxwm <= avn_writedata[1];
            ie_txwm <= avn_writedata[0];
        end
        if (div_write) begin
            div_div <= avn_writedata[15:0];
        end
    end

    // software: r
    // hardware: w
    always @(posedge clk) begin
        txdata_full <= txfifo_full;
        rxdata_empty <= rxfifo_empty;
        rxdata_data <= rxfifo_dout;
        ip_rxwm <= rxwm;
        ip_txwm <= txwm;
    end

    // --------------------------------------------
    //  Glue logic
    // --------------------------------------------

    assign int_txwm = ip_txwm;
    assign int_rxwm = ip_rxwm;

    assign rxdata_read = (avn_address == 5'h04) & avn_read;

    // Uart configuration
    assign cfg_div   = div_div;
    assign cfg_txen  = txctrl_txen;
    assign cfg_rxen  = rxctrl_rxen;
    assign cfg_nstop = txctrl_nstop;

    // TX fifo and Uart tx logic
    always @(posedge clk) begin
        if (rst) txdata_valid <= 1'b0;
        else txdata_valid <= txdata_write;
    end

    assign txfifo_push  = txdata_valid & ~txfifo_full;
    assign txfifo_pop   = ~txfifo_empty & tx_ready;
    assign txfifo_din   = txdata_data;
    assign tx_valid     = txfifo_pop;
    assign tx_data      = txfifo_dout;
    assign txwm         = (txfifo_entry < {1'b0, txctrl_txcnt}) & ie_txwm;

    // RX fifo and Uart rx logic
    assign rxfifo_push  = rx_valid & ~rxfifo_full;
    assign rxfifo_pop   = rxdata_read;
    assign rxfifo_din   = rx_data;
    assign rxwm         = (rxfifo_entry > {1'b0, rxctrl_rxcnt}) & ie_rxwm;

    // --------------------------------------------
    //  Module instantiation
    // --------------------------------------------

    uart_tx u_uart_tx(.*);
    uart_rx u_uart_rx(.*);

    uart_fifo #( .WIDTH (8), .DEPTH (8))
    u_tx_fifo (
        .rst    (rst),
        .clk    (clk),
        .push   (txfifo_push),
        .pop    (txfifo_pop),
        .din    (txfifo_din),
        .dout   (txfifo_dout),
        .full   (txfifo_full),
        .empty  (txfifo_empty),
        .entry  (txfifo_entry)
    );

    uart_fifo #( .WIDTH (8), .DEPTH (8))
    u_rx_fifo (
        .rst    (rst),
        .clk    (clk),
        .push   (rxfifo_push),
        .pop    (rxfifo_pop),
        .din    (rxfifo_din),
        .dout   (rxfifo_dout),
        .full   (rxfifo_full),
        .empty  (rxfifo_empty),
        .entry  (rxfifo_entry)
    );

endmodule
