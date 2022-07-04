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

module veriRISCV_soc #(
    parameter IAW = 20, // Instruction RAM Address width
    parameter DAW = 20  // Data RAM Address width
)(
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

`ifdef SAPERATE_RAM

    avalon_ram_1rw
    #(
        .AW       (IAW-2),
        .DW       (32)
    )
    u_instruction_ram(
        .clk         (clk),
        .read        (ibus_avalon_req.read),
        .write       (ibus_avalon_req.write),
        .address     (ibus_avalon_req.address[IAW-1:2]),    // word size
        .byte_enable (ibus_avalon_req.byte_enable),
        .writedata   (ibus_avalon_req.writedata),
        .readdata    (ibus_avalon_resp.readdata),
        .waitrequest (ibus_avalon_resp.waitrequest)
    );

    avalon_ram_1rw
    #(
        .AW       (DAW-2),
        .DW       (32)
    )
    u_data_ram(
        .clk         (clk),
        .read        (dbus_avalon_req.read),
        .write       (dbus_avalon_req.write),
        .address     (dbus_avalon_req.address[DAW-1:2]),    // word size
        .byte_enable (dbus_avalon_req.byte_enable),
        .writedata   (dbus_avalon_req.writedata),
        .readdata    (dbus_avalon_resp.readdata),
        .waitrequest (dbus_avalon_resp.waitrequest)
    );

`else

    localparam AW = IAW > DAW ? IAW : DAW;

    avalon_ram_2rw
    #(
        .AW       (AW-2),
        .DW       (32)
    )
    u_memory(
        .clk            (clk),
        .p1_read        (ibus_avalon_req.read),
        .p1_write       (ibus_avalon_req.write),
        .p1_address     (ibus_avalon_req.address[IAW-1:2]),    // word size
        .p1_byte_enable (ibus_avalon_req.byte_enable),
        .p1_writedata   (ibus_avalon_req.writedata),
        .p1_readdata    (ibus_avalon_resp.readdata),
        .p1_waitrequest (ibus_avalon_resp.waitrequest),
        .p2_read        (dbus_avalon_req.read),
        .p2_write       (dbus_avalon_req.write),
        .p2_address     (dbus_avalon_req.address[DAW-1:2]),    // word size
        .p2_byte_enable (dbus_avalon_req.byte_enable),
        .p2_writedata   (dbus_avalon_req.writedata),
        .p2_readdata    (dbus_avalon_resp.readdata),
        .p2_waitrequest (dbus_avalon_resp.waitrequest)
    );

`endif

endmodule