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

module veriRISCV_soc (
    input                   clk,
    input                   rst
);

    avalon_req_t    ibus_avalon_req;
    avalon_resp_t   ibus_avalon_resp;

    avalon_req_t    dbus_avalon_req;
    avalon_resp_t   dbus_avalon_resp;

    logic           software_interrupt;
    logic           timer_interrupt;
    logic           external_interrupt;
    logic           debug_interrupt;

    // -------------------------------
    // veriRISCV Core
    // --------------------------------
    veriRISCV_core u_veriRISCV_core(
        .clk,
        .rst,
        .ibus_avalon_req,
        .ibus_avalon_resp,
        .dbus_avalon_req,
        .dbus_avalon_resp,
        .software_interrupt,
        .timer_interrupt,
        .external_interrupt,
        .debug_interrupt
    );

    // ----------------------------------------
    // main_bus_matrix
    // ----------------------------------------

    localparam MAIN_BUS_ND = 2;  // number of host
    localparam MAIN_BUS_NH = 2;  // number of device
    localparam MAIN_BUS_AW = 32;
    localparam MAIN_BUS_DW = 32;

    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    devices_address_low;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    devices_address_high;

    logic [MAIN_BUS_NH-1:0]                     hosts_avn_read;
    logic [MAIN_BUS_NH-1:0]                     hosts_avn_write;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_AW-1:0]    hosts_avn_address;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW/8-1:0]  hosts_avn_byte_enable;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW-1:0]    hosts_avn_writedata;
    logic [MAIN_BUS_NH-1:0][MAIN_BUS_DW-1:0]    hosts_avn_readdata;
    logic [MAIN_BUS_NH-1:0]                     hosts_avn_waitrequest;

    // avalon bus output
    logic [MAIN_BUS_ND-1:0]                     devices_avn_read;
    logic [MAIN_BUS_ND-1:0]                     devices_avn_write;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_AW-1:0]    devices_avn_address;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW/8-1:0]  devices_avn_byte_enable;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW-1:0]    devices_avn_writedata;
    logic [MAIN_BUS_ND-1:0][MAIN_BUS_DW-1:0]    devices_avn_readdata;
    logic [MAIN_BUS_ND-1:0]                     devices_avn_waitrequest;

    avalon_s_crossbar #(
        .NH (MAIN_BUS_NH),
        .ND (MAIN_BUS_ND),
        .DW (MAIN_BUS_DW),
        .AW (MAIN_BUS_AW))
    main_bus_crossbar (.*);

    // ----------------------------------------
    // connect host to main_bus_crossbar
    // ----------------------------------------

    // dbus - connect to port 0. Higher priority
    assign hosts_avn_read[0] = dbus_avalon_req.read;
    assign hosts_avn_write[0] = dbus_avalon_req.write;
    assign hosts_avn_address[0] = dbus_avalon_req.address;
    assign hosts_avn_byte_enable[0] = dbus_avalon_req.byte_enable;
    assign hosts_avn_writedata[0] = dbus_avalon_req.writedata;
    assign dbus_avalon_resp.readdata = hosts_avn_readdata[0];
    assign dbus_avalon_resp.waitrequest = hosts_avn_waitrequest[0];

    // ibus - connect to port 1
    assign hosts_avn_read[1] = ibus_avalon_req.read;
    assign hosts_avn_write[1] = ibus_avalon_req.write;
    assign hosts_avn_address[1] = ibus_avalon_req.address;
    assign hosts_avn_byte_enable[1] = ibus_avalon_req.byte_enable;
    assign hosts_avn_writedata[1] = ibus_avalon_req.writedata;
    assign ibus_avalon_resp.readdata = hosts_avn_readdata[1];
    assign ibus_avalon_resp.waitrequest = hosts_avn_waitrequest[1];

    // ----------------------------------------
    // connect device to main_bus_crossbar
    // ----------------------------------------

    // device 0: main memory
    assign devices_address_low[0] = `MEMORY_LOW;
    assign devices_address_high[0] = `MEMORY_HIGH;

    // use FPGA internal ram for now. will switch to sram later.
    localparam MAIN_MEMORY_AW = 20;
    avalon_ram_1rw
    #(
        .AW       (MAIN_MEMORY_AW-2),
        .DW       (32)
    )
    u_memory(
        .clk         (clk),
        .read        (devices_avn_read[0]),
        .write       (devices_avn_write[0]),
        .address     (devices_avn_address[0][MAIN_MEMORY_AW-1:2]),
        .byte_enable (devices_avn_byte_enable[0]),
        .writedata   (devices_avn_writedata[0]),
        .readdata    (devices_avn_readdata[0]),
        .waitrequest (devices_avn_waitrequest[0])
    );

    // device 1: peripheral bus matrix
    assign devices_address_low[1] = `PERIPHERAL_LOW;
    assign devices_address_high[1] = `PERIPHERAL_HIGH;

    // no peripheral bus matrix for now
    assign devices_avn_waitrequest[1] = 0;
    assign devices_avn_readdata[1] = 0;

endmodule
