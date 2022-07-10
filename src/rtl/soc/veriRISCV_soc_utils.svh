// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/09/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// SoC Utility macros
// ------------------------------------------------------------------------------------------------

`ifndef _VERIRISCV_SOC_UTILS_
`define _VERIRISCV_SOC_UTILS_


// connect a bus to a host port in avalon bus crossbar
`define CONNECT_AVALON_S_HOSTS(PORT, BUS, IDX) \
    assign ``PORT``_hosts_avn_read[IDX]         = ``BUS``_avn_read; \
    assign ``PORT``_hosts_avn_write[IDX]        = ``BUS``_avn_write; \
    assign ``PORT``_hosts_avn_address[IDX]      = ``BUS``_avn_address; \
    assign ``PORT``_hosts_avn_byte_enable[IDX]  = ``BUS``_avn_byte_enable; \
    assign ``PORT``_hosts_avn_writedata[IDX]    = ``BUS``_avn_writedata; \
    assign ``BUS``_avn_readdata                 = ``PORT``_hosts_avn_readdata[IDX]; \
    assign ``BUS``_avn_waitrequest              = ``PORT``_hosts_avn_waitrequest[IDX];

// connect a bus to a device port in avalon bus crossbar/decoder
`define CONNECT_AVALON_S_DEVICE(PORT, BUS, IDX) \
    assign ``BUS``_avn_read                         = ``PORT``_devices_avn_read[IDX]; \
    assign ``BUS``_avn_write                        = ``PORT``_devices_avn_write[IDX]; \
    assign ``BUS``_avn_address                      = ``PORT``_devices_avn_address[IDX]; \
    assign ``BUS``_avn_byte_enable                  = ``PORT``_devices_avn_byte_enable[IDX]; \
    assign ``BUS``_avn_writedata                    = ``PORT``_devices_avn_writedata[IDX]; \
    assign ``PORT``_devices_avn_readdata[IDX]       = ``BUS``_avn_readdata; \
    assign ``PORT``_devices_avn_waitrequest[IDX]    = ``BUS``_avn_waitrequest;

`endif
