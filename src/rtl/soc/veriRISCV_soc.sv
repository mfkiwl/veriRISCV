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

    avalon_ram_1rw_be
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

endmodule