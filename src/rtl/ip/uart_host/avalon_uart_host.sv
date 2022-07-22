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


module avalon_uart_host #(
    parameter WRITE_START_KEY   = 64'h5050505011111111,
    parameter READ_START_KEY    = 64'h5050505022222222,
    parameter END_KEY           = 64'h50505050EEEEEEEE
) (
    input               clk,
    input               rst,

    output              avn_read,
    output              avn_write,
    output [31:0]       avn_address,
    output [31:0]       avn_writedata,
    output [3:0]        avn_byte_enable,
    input  [31:0]       avn_readdata,
    input               avn_waitrequest,

    input [15:0]        uart_div,
    input               uart_debug_en,
    input               uart_rxd,
    output              uart_txd,
    output reg          uart_host_writing,
    output reg          uart_host_reading
);

    // --------------------------------------------
    //  Sginal Declaration
    // --------------------------------------------

    localparam WIDTH = 64;

    logic               cfg_nstop;
    logic [15:0]        cfg_div;
    logic               cfg_rxen;
    logic               cfg_txen;

    logic               tx_valid;
    logic [7:0]         tx_data;
    logic               tx_ready;

    logic               rx_valid;
    logic [7:0]         rx_data;

    reg                 cmd_fifo_push;
    logic               cmd_fifo_pop;
    logic               cmd_fifo_full;
    logic               cmd_fifo_empty;
    logic [WIDTH:0]     cmd_fifo_din;
    logic [WIDTH:0]     cmd_fifo_dout;

    logic               read_fifo_push;
    logic               read_fifo_pop;
    logic               read_fifo_full;
    logic               read_fifo_empty;
    logic [31:0]        read_fifo_din;
    logic [31:0]        read_fifo_dout;

    reg [WIDTH-1:0]     cmd;
    reg [3:0]           data_count;
    reg                 cmd_cmpl;
    reg                 cmd_type;

    logic               write_start_cmd;
    logic               read_start_cmd;
    logic               end_cmd;
    logic               avn_cmd_type;
    logic               data_count_fire;

    reg                 read_data_valid;

    typedef enum logic [2:0] {IDLE, START, DATA0, DATA1, DATA2, DATA3} send_state_t;
    send_state_t        send_state, send_state_next;
    reg [31:0]          read_data;

    // --------------------------------------------
    //  Main logic
    // --------------------------------------------

    //-- uart config --//
    assign cfg_nstop = 0;
    assign cfg_txen = uart_debug_en;
    assign cfg_rxen = uart_debug_en;
    assign cfg_div = uart_div;

    // -- receive command from uart rx and send it to command fifo --//
    assign data_count_fire = data_count == 7;
    assign write_start_cmd = (cmd == WRITE_START_KEY);
    assign read_start_cmd = (cmd == READ_START_KEY);
    assign end_cmd = (cmd == END_KEY);

    always @(posedge clk) begin
        if (rst) data_count <= 0;
        else begin
            if (rx_valid) begin
                if (data_count_fire) data_count <= 0;
                else data_count <= data_count + 1'b1;
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

    always @(posedge clk) begin
        if (cmd_cmpl && write_start_cmd) cmd_type <= 1'b0;
        else if (cmd_cmpl && read_start_cmd) cmd_type <= 1'b1;
    end

    always @(posedge clk) begin
        if (rst) uart_host_writing <= 1'b0;
        else begin
            if (cmd_cmpl && write_start_cmd) uart_host_writing <= 1'b1;
            else if (cmd_cmpl && end_cmd) uart_host_writing <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) uart_host_reading <= 1'b0;
        else begin
            if (cmd_cmpl && read_start_cmd) uart_host_reading <= 1'b1;
            else if (cmd_cmpl && end_cmd) uart_host_reading <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) cmd_fifo_push <= 1'b0;
        else cmd_fifo_push <= cmd_cmpl & ~cmd_fifo_full & ~end_cmd & (uart_host_writing | uart_host_reading);
    end

    assign cmd_fifo_din = {cmd_type, cmd};

    //-- Get the command from command fifo and send it to the avalon bus --//
    assign cmd_fifo_pop = (avn_write | avn_read) & ~avn_waitrequest;
    assign avn_cmd_type = cmd_fifo_dout[64];
    assign avn_write = ~cmd_fifo_empty & ~avn_cmd_type;
    assign avn_read = ~cmd_fifo_empty & avn_cmd_type;
    assign avn_address = cmd_fifo_dout[31:0];
    assign avn_writedata = cmd_fifo_dout[63:32];
    assign avn_byte_enable = 4'b1111;

    //-- receive data from avalon bus and send it to the read fifo --//
    always @(posedge clk) begin
        if (rst) read_data_valid <= 0;
        else read_data_valid <= avn_read & ~avn_waitrequest; // read latency is 1
    end

    assign read_fifo_push = read_data_valid;    // ideally the FIFO should not be full when we push
    assign read_fifo_din = avn_readdata;

    //-- read the data from read FIFO and send it through uart tx --//

    //     typedef enum logic [2:0] {IDLE, START, DATA0, DATA1, DATA2, DATA3} send_state_t;
    always @(posedge clk) begin
        if (rst) send_state <= IDLE;
        else send_state <= send_state_next;
    end

    always @(posedge clk) begin
        if (read_fifo_pop) read_data <= read_fifo_dout;
    end

    always @* begin
        tx_valid = 0;
        tx_data = read_data[7:0];
        read_fifo_pop = 0;
        send_state_next = send_state;
        case(send_state)
            IDLE: begin
                if (tx_ready && !read_fifo_empty) begin
                    send_state_next = START;
                    read_fifo_pop = 1'b1;
                end
            end
            START: begin
                send_state_next = DATA0;
                tx_data = read_data[7:0];
                tx_valid = 1'b1;
            end
            DATA0: begin
                if (tx_ready) begin
                    send_state_next = DATA1;
                    tx_data = read_data[15:8];
                    tx_valid = 1'b1;
                end
            end
            DATA1: begin
                if (tx_ready) begin
                    send_state_next = DATA2;
                    tx_data = read_data[23:16];
                    tx_valid = 1'b1;
                end
            end
            DATA2: begin
                if (tx_ready) begin
                    send_state_next = DATA3;
                    tx_data = read_data[31:24];
                    tx_valid = 1'b1;
                end
            end
            DATA3: begin
                if (tx_ready) begin
                    send_state_next = IDLE;
                end
            end
            default: begin end
        endcase
    end

    // --------------------------------------------
    //  Module instantiation
    // --------------------------------------------

    uart_rx u_uart_rx(.*);
    uart_tx u_uart_tx(.*);

    uart_fifo #( .WIDTH (65), .DEPTH (2))
    u_cmd_fifo (
        .rst    (rst),
        .clk    (clk),
        .push   (cmd_fifo_push),
        .pop    (cmd_fifo_pop),
        .din    (cmd_fifo_din),
        .dout   (cmd_fifo_dout),
        .full   (cmd_fifo_full),
        .empty  (cmd_fifo_empty),
        .entry  ()
    );

    uart_fifo #( .WIDTH (32), .DEPTH (2))
    u_read_fifo (
        .rst    (rst),
        .clk    (clk),
        .push   (read_fifo_push),
        .pop    (read_fifo_pop),
        .din    (read_fifo_din),
        .dout   (read_fifo_dout),
        .full   (read_fifo_full),
        .empty  (read_fifo_empty),
        .entry  ()
    );

endmodule
