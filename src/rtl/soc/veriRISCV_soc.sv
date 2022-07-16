// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// A simple SoC for the cpu design
// ------------------------------------------------------------------------------------------------

`include "core.svh"
`include "veriRISCV_soc.svh"

module veriRISCV_soc #(
`ifdef SRAM
    parameter SRAM_AW = 18,
    parameter SRAM_DW = 16,
`endif
    parameter GPIO_WIDTH = 32,
    parameter UART_BAUD_RATE = 115200,
    parameter CLK_FREQ_MHZ = 50
) (
    input                   clk,
    input                   rst,

    inout [GPIO_WIDTH-1:0]  gpio0,
    inout [GPIO_WIDTH-1:0]  gpio1,

`ifdef SRAM
    output                  sram_ce_n,
    output                  sram_oe_n,
    output                  sram_we_n,
    output [SRAM_DW/8-1:0]  sram_be_n,
    output [SRAM_AW-1:0]    sram_addr,
    inout  [SRAM_DW-1:0]    sram_dq,
`endif

    input                   uart_debug_en,
    output                  uart_txd,
    input                   uart_rxd
);

    avalon_req_t    ibus_avalon_req;
    avalon_resp_t   ibus_avalon_resp;

    avalon_req_t    dbus_avalon_req;
    avalon_resp_t   dbus_avalon_resp;

    logic           software_interrupt;
    logic           timer_interrupt;
    logic           external_interrupt;
    logic           debug_interrupt;

    // debug bus
    logic           debug_avn_read;
    logic           debug_avn_write;
    logic [31:0]    debug_avn_address;
    logic [3:0]     debug_avn_byte_enable;
    logic [31:0]    debug_avn_writedata;
    logic [31:0]    debug_avn_readdata;
    logic           debug_avn_waitrequest;

    // instruction bus
    logic           ibus_avn_read;
    logic           ibus_avn_write;
    logic [31:0]    ibus_avn_address;
    logic [3:0]     ibus_avn_byte_enable;
    logic [31:0]    ibus_avn_writedata;
    logic [31:0]    ibus_avn_readdata;
    logic           ibus_avn_waitrequest;

    // data bus
    logic           dbus_avn_read;
    logic           dbus_avn_write;
    logic [31:0]    dbus_avn_address;
    logic [3:0]     dbus_avn_byte_enable;
    logic [31:0]    dbus_avn_writedata;
    logic [31:0]    dbus_avn_readdata;
    logic           dbus_avn_waitrequest;

    // main memory (sram) port
    logic           ram_avn_read;
    logic           ram_avn_write;
    logic [31:0]    ram_avn_address;
    logic [3:0]     ram_avn_byte_enable;
    logic [31:0]    ram_avn_writedata;
    logic [31:0]    ram_avn_readdata;
    logic           ram_avn_waitrequest;

    // AON domain
    logic           aon_avn_read;
    logic           aon_avn_write;
    logic [31:0]    aon_avn_address;
    logic [3:0]     aon_avn_byte_enable;
    logic [31:0]    aon_avn_writedata;
    logic [31:0]    aon_avn_readdata;
    logic           aon_avn_waitrequest;

    // GPIO0
    logic           gpio0_avn_read;
    logic           gpio0_avn_write;
    logic [31:0]    gpio0_avn_address;
    logic [3:0]     gpio0_avn_byte_enable;
    logic [31:0]    gpio0_avn_writedata;
    logic [31:0]    gpio0_avn_readdata;
    logic           gpio0_avn_waitrequest;

    // GPIO1
    logic           gpio1_avn_read;
    logic           gpio1_avn_write;
    logic [31:0]    gpio1_avn_address;
    logic [3:0]     gpio1_avn_byte_enable;
    logic [31:0]    gpio1_avn_writedata;
    logic [31:0]    gpio1_avn_readdata;
    logic           gpio1_avn_waitrequest;

    // UART
    logic           uart0_avn_read;
    logic           uart0_avn_write;
    logic [31:0]    uart0_avn_address;
    logic [3:0]     uart0_avn_byte_enable;
    logic [31:0]    uart0_avn_writedata;
    logic [31:0]    uart0_avn_readdata;
    logic           uart0_avn_waitrequest;

    logic           sys_rst; // sys reset

    // when uart_debug_en is set, reset rest of the system
    assign sys_rst = rst | uart_debug_en;

    // -------------------------------
    // veriRISCV Core
    // --------------------------------
    veriRISCV_core u_veriRISCV_core(
        .clk,
        .rst    (sys_rst),
        .ibus_avalon_req,
        .ibus_avalon_resp,
        .dbus_avalon_req,
        .dbus_avalon_resp,
        .software_interrupt,
        .timer_interrupt,
        .external_interrupt,
        .debug_interrupt
    );

    assign software_interrupt = 0;
    assign timer_interrupt = 0;
    assign external_interrupt = 0;
    assign debug_interrupt = 0;

    // instruction bus
    assign ibus_avn_read = ibus_avalon_req.read;
    assign ibus_avn_write = ibus_avalon_req.write;
    assign ibus_avn_address = ibus_avalon_req.address;
    assign ibus_avn_byte_enable = ibus_avalon_req.byte_enable;
    assign ibus_avn_writedata = ibus_avalon_req.writedata;
    assign ibus_avalon_resp.readdata = ibus_avn_readdata;
    assign ibus_avalon_resp.waitrequest = ibus_avn_waitrequest;

    // data bus
    assign dbus_avn_read = dbus_avalon_req.read;
    assign dbus_avn_write = dbus_avalon_req.write;
    assign dbus_avn_address = dbus_avalon_req.address;
    assign dbus_avn_byte_enable = dbus_avalon_req.byte_enable;
    assign dbus_avn_writedata = dbus_avalon_req.writedata;
    assign dbus_avalon_resp.readdata = dbus_avn_readdata;
    assign dbus_avalon_resp.waitrequest = dbus_avn_waitrequest;

    // ----------------------------------------
    //  avalon bus
    // ----------------------------------------

    veriRISCV_avalon_bus u_veriRISCV_avalon_bus (.*);

    // ----------------------------------------
    //  SoC Component
    // ----------------------------------------

    // Main memory

`ifdef SRAM
    avalon_sram_controller #(
        .AVN_AW     (SRAM_AW),
        .AVN_DW     (32),
        .SRAM_AW    (SRAM_AW),
        .SRAM_DW    (SRAM_DW)
    )
    u_avalon_sram_controller (
        .clk                (clk),
        .avn_read           (ram_avn_read),
        .avn_write          (ram_avn_write),
        .avn_address        (ram_avn_address[SRAM_AW+2-1:2]), // sram take word address instead of byte address
        .avn_byteenable     (ram_avn_byte_enable),
        .avn_writedata      (ram_avn_writedata),
        .avn_readdata       (ram_avn_readdata),
        .avn_waitrequest    (ram_avn_waitrequest),
        .* // sram port
    );
`else
    localparam MM_AW = `MAIN_MEMORY_AW;
    avalon_ram_1rw
    #(
        .AW       (MM_AW-2),
        .DW       (32)
    )
    u_memory(
        .clk         (clk),
        .read        (ram_avn_read),
        .write       (ram_avn_write),
        .address     (ram_avn_address[MM_AW-1:2]),  // bram take word address instead of byte address
        .byte_enable (ram_avn_byte_enable),
        .writedata   (ram_avn_writedata),
        .readdata    (ram_avn_readdata),
        .waitrequest (ram_avn_waitrequest)
    );
`endif

    // uart debug host
    localparam UART_DIV = CLK_FREQ_MHZ * 1000000 / UART_BAUD_RATE;

    avalon_uart_host
    u_uart_debug (
        .clk                (clk),
        .rst                (rst),
        .avn_read           (debug_avn_read),
        .avn_write          (debug_avn_write),
        .avn_address        (debug_avn_address),
        .avn_writedata      (debug_avn_writedata),
        .avn_byte_enable    (debug_avn_byte_enable),
        .avn_readdata       (debug_avn_readdata),
        .avn_waitrequest    (debug_avn_waitrequest),
        .cfg_div            (UART_DIV[15:0]),
        .cfg_rxen           (uart_debug_en),
        .uart_rxd           (uart_rxd)
    );

    // AON domain
    assign aon_avn_readdata = 0;
    assign aon_avn_waitrequest = 0;

    // UART0
    avalon_uart
    uart_0 (
        .clk                (clk),
        .rst                (sys_rst),
        .avn_read           (uart0_avn_read),
        .avn_write          (uart0_avn_write),
        .avn_address        (uart0_avn_address[4:0]),
        .avn_writedata      (uart0_avn_writedata),
        .avn_readdata       (uart0_avn_readdata),
        .avn_waitrequest    (uart0_avn_waitrequest),
        .int_txwm           (),
        .int_rxwm           (),
        .uart_txd           (uart_txd),
        .uart_rxd           (uart_rxd)
    );

    // GPIO0
    avalon_gpio #(.W(GPIO_WIDTH))
    gpio_0 (
        .clk            (clk),
        .rst            (sys_rst),
        .gpio           (gpio0),
        .avn_read       (gpio0_avn_read),
        .avn_write      (gpio0_avn_write),
        .avn_address    (gpio0_avn_address[6:0]),
        .avn_byte_enable(gpio0_avn_byte_enable),
        .avn_writedata  (gpio0_avn_writedata),
        .avn_readdata   (gpio0_avn_readdata),
        .avn_waitrequest(gpio0_avn_waitrequest)
    );

    // GPIO1
    avalon_gpio #(.W(GPIO_WIDTH))
    gpio_1 (
        .clk            (clk),
        .rst            (sys_rst),
        .gpio           (gpio1),
        .avn_read       (gpio1_avn_read),
        .avn_write      (gpio1_avn_write),
        .avn_address    (gpio1_avn_address[6:0]),
        .avn_byte_enable(gpio1_avn_byte_enable),
        .avn_writedata  (gpio1_avn_writedata),
        .avn_readdata   (gpio1_avn_readdata),
        .avn_waitrequest(gpio1_avn_waitrequest)
    );

endmodule
