// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/09/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon Bus for the SoC design
// ------------------------------------------------------------------------------------------------

`include "core.svh"
`include "veriRISCV_soc.svh"
`include "veriRISCV_soc_utils.svh"

module veriRISCV_avalon_bus (
    input           clk,
    input           rst,

    // debug bus
    input           debug_avn_read,
    input           debug_avn_write,
    input [31:0]    debug_avn_address,
    input [3:0]     debug_avn_byte_enable,
    input [31:0]    debug_avn_writedata,
    output [31:0]   debug_avn_readdata,
    output          debug_avn_waitrequest,

    // instruction bus
    input           ibus_avn_read,
    input           ibus_avn_write,
    input [31:0]    ibus_avn_address,
    input [3:0]     ibus_avn_byte_enable,
    input [31:0]    ibus_avn_writedata,
    output [31:0]   ibus_avn_readdata,
    output          ibus_avn_waitrequest,

    // data bus
    input           dbus_avn_read,
    input           dbus_avn_write,
    input [31:0]    dbus_avn_address,
    input [3:0]     dbus_avn_byte_enable,
    input [31:0]    dbus_avn_writedata,
    output [31:0]   dbus_avn_readdata,
    output          dbus_avn_waitrequest,

    // main memory (sram) port
    output          ram_avn_read,
    output          ram_avn_write,
    output [31:0]   ram_avn_address,
    output [3:0]    ram_avn_byte_enable,
    output [31:0]   ram_avn_writedata,
    input [31:0]    ram_avn_readdata,
    input           ram_avn_waitrequest,

    // AON domain
    output          aon_avn_read,
    output          aon_avn_write,
    output [31:0]   aon_avn_address,
    output [3:0]    aon_avn_byte_enable,
    output [31:0]   aon_avn_writedata,
    input [31:0]    aon_avn_readdata,
    input           aon_avn_waitrequest,

    // GPIO0
    output          gpio0_avn_read,
    output          gpio0_avn_write,
    output [31:0]   gpio0_avn_address,
    output [3:0]    gpio0_avn_byte_enable,
    output [31:0]   gpio0_avn_writedata,
    input [31:0]    gpio0_avn_readdata,
    input           gpio0_avn_waitrequest,

    // GPIO1
    output          gpio1_avn_read,
    output          gpio1_avn_write,
    output [31:0]   gpio1_avn_address,
    output [3:0]    gpio1_avn_byte_enable,
    output [31:0]   gpio1_avn_writedata,
    input [31:0]    gpio1_avn_readdata,
    input           gpio1_avn_waitrequest,

    // UART
    output          uart0_avn_read,
    output          uart0_avn_write,
    output [31:0]   uart0_avn_address,
    output [3:0]    uart0_avn_byte_enable,
    output [31:0]   uart0_avn_writedata,
    input [31:0]    uart0_avn_readdata,
    input           uart0_avn_waitrequest
);

    // ----------------------------------------
    // Main bus crossbar
    // ----------------------------------------

    localparam MAIN_BUS_NH = 3;  // number of host
    localparam MAIN_BUS_ND = 2;  // number of device
    localparam MAIN_BUS_AW = 32;
    localparam MAIN_BUS_DW = 32;

    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    main_devices_address_low;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    main_devices_address_high;

    logic [MAIN_BUS_NH-1:0]                     main_hosts_avn_read;
    logic [MAIN_BUS_NH-1:0]                     main_hosts_avn_write;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_AW-1:0]    main_hosts_avn_address;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW/8-1:0]  main_hosts_avn_byte_enable;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW-1:0]    main_hosts_avn_writedata;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW-1:0]    main_hosts_avn_readdata;
    logic [MAIN_BUS_NH-1:0]                     main_hosts_avn_waitrequest;

    logic [MAIN_BUS_ND-1:0]                     main_devices_avn_read;
    logic [MAIN_BUS_ND-1:0]                     main_devices_avn_write;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    main_devices_avn_address;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW/8-1:0]  main_devices_avn_byte_enable;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW-1:0]    main_devices_avn_writedata;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW-1:0]    main_devices_avn_readdata;
    logic [MAIN_BUS_ND-1:0]                     main_devices_avn_waitrequest;

    avalon_s_crossbar #(
        .NH (MAIN_BUS_NH),
        .ND (MAIN_BUS_ND),
        .DW (MAIN_BUS_DW),
        .AW (MAIN_BUS_AW))
    main_bus_crossbar (
        .clk                        (clk),
        .rst                        (rst),
        .devices_address_low        (main_devices_address_low),
        .devices_address_high       (main_devices_address_high),
        .hosts_avn_read             (main_hosts_avn_read),
        .hosts_avn_write            (main_hosts_avn_write),
        .hosts_avn_address          (main_hosts_avn_address),
        .hosts_avn_byte_enable      (main_hosts_avn_byte_enable),
        .hosts_avn_writedata        (main_hosts_avn_writedata),
        .hosts_avn_readdata         (main_hosts_avn_readdata),
        .hosts_avn_waitrequest      (main_hosts_avn_waitrequest),
        .devices_avn_read           (main_devices_avn_read),
        .devices_avn_write          (main_devices_avn_write),
        .devices_avn_address        (main_devices_avn_address),
        .devices_avn_byte_enable    (main_devices_avn_byte_enable),
        .devices_avn_writedata      (main_devices_avn_writedata),
        .devices_avn_readdata       (main_devices_avn_readdata),
        .devices_avn_waitrequest    (main_devices_avn_waitrequest)
    );

    // ----------------------------------------
    // peripheral bus decoder
    // ----------------------------------------

    localparam PERI_BUS_ND = 4;  // number of device
    localparam PERI_BUS_AW = 32;
    localparam PERI_BUS_DW = 32;

    logic [PERI_BUS_ND-1:0][PERI_BUS_AW-1:0]    peri_devices_address_low;
    logic [PERI_BUS_ND-1:0][PERI_BUS_AW-1:0]    peri_devices_address_high;

    logic                                       peri_host_avn_read;
    logic                                       peri_host_avn_write;
    logic [PERI_BUS_AW-1:0]                     peri_host_avn_address;
    logic [PERI_BUS_DW/8-1:0]                   peri_host_avn_byte_enable;
    logic [PERI_BUS_DW-1:0]                     peri_host_avn_writedata;
    logic [PERI_BUS_DW-1:0]                     peri_host_avn_readdata;
    logic                                       peri_host_avn_waitrequest;

    logic [PERI_BUS_ND-1:0]                     peri_devices_avn_read;
    logic [PERI_BUS_ND-1:0]                     peri_devices_avn_write;
    logic [PERI_BUS_ND-1:0][PERI_BUS_AW-1:0]    peri_devices_avn_address;
    logic [PERI_BUS_ND-1:0][PERI_BUS_DW/8-1:0]  peri_devices_avn_byte_enable;
    logic [PERI_BUS_ND-1:0][PERI_BUS_DW-1:0]    peri_devices_avn_writedata;
    logic [PERI_BUS_ND-1:0][PERI_BUS_DW-1:0]    peri_devices_avn_readdata;
    logic [PERI_BUS_ND-1:0]                     peri_devices_avn_waitrequest;

    avalon_s_decoder #(
        .ND (PERI_BUS_ND),
        .DW (PERI_BUS_DW),
        .AW (PERI_BUS_AW))
    peri_bus_decoder (
        .clk                        (clk),
        .rst                        (rst),
        .devices_address_low        (peri_devices_address_low),
        .devices_address_high       (peri_devices_address_high),
        .host_avn_read              (peri_host_avn_read),
        .host_avn_write             (peri_host_avn_write),
        .host_avn_address           (peri_host_avn_address),
        .host_avn_byte_enable       (peri_host_avn_byte_enable),
        .host_avn_writedata         (peri_host_avn_writedata),
        .host_avn_readdata          (peri_host_avn_readdata),
        .host_avn_waitrequest       (peri_host_avn_waitrequest),
        .devices_avn_read           (peri_devices_avn_read),
        .devices_avn_write          (peri_devices_avn_write),
        .devices_avn_address        (peri_devices_avn_address),
        .devices_avn_byte_enable    (peri_devices_avn_byte_enable),
        .devices_avn_writedata      (peri_devices_avn_writedata),
        .devices_avn_readdata       (peri_devices_avn_readdata),
        .devices_avn_waitrequest    (peri_devices_avn_waitrequest)
    );


    // ----------------------------------------
    // connect host to main_bus_crossbar
    // ----------------------------------------

    // debug - connect to port 0
    `CONNECT_AVALON_S_HOSTS(main, debug, 0)

    // dbus - connect to port 1
    `CONNECT_AVALON_S_HOSTS(main, dbus, 1)

    // ibus - connect to port 2
    `CONNECT_AVALON_S_HOSTS(main, ibus, 2)

    // ----------------------------------------
    // connect device to main bus crossbar
    // ----------------------------------------

    // device 0: main memory
    assign main_devices_address_low[0]  = `MEMORY_LOW;
    assign main_devices_address_high[0] = `MEMORY_HIGH;

    `CONNECT_AVALON_S_DEVICE(main, ram, 0)

    // device 1: peripheral bus decoder
    assign main_devices_address_low[1]  = `PERIPHERAL_LOW;
    assign main_devices_address_high[1] = `PERIPHERAL_HIGH;

    `CONNECT_AVALON_S_DEVICE(main, peri_host, 1)

    // ----------------------------------------
    // connect device to peripheral bus decoder
    // ----------------------------------------

    // device 0: AON
    assign peri_devices_address_low[0]  = `AON_LOW;
    assign peri_devices_address_high[0] = `AON_HIGH;

    `CONNECT_AVALON_S_DEVICE(peri, aon, 0)

    // device 1: GPIO0
    assign peri_devices_address_low[1]  = `GPIO0_LOW;
    assign peri_devices_address_high[1] = `GPIO0_HIGH;

    `CONNECT_AVALON_S_DEVICE(peri, gpio0, 1)

    // device 2: GPIO1
    assign peri_devices_address_low[2]  = `GPIO1_LOW;
    assign peri_devices_address_high[2] = `GPIO1_HIGH;

    `CONNECT_AVALON_S_DEVICE(peri, gpio1, 2)

    // device 3: UART0
    assign peri_devices_address_low[3]  = `UART0_LOW;
    assign peri_devices_address_high[3] = `UART0_HIGH;

    `CONNECT_AVALON_S_DEVICE(peri, uart0, 3)

endmodule
