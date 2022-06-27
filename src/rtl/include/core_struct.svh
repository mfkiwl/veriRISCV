// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/26/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Define file for veriRISCV core: struct
// ------------------------------------------------------------------------------------------------


`ifndef _VERIRISCV_CORE_STRUCT_
`define _VERIRISCV_CORE_STRUCT_

`include "core_arch.svh"

// Avalon bus define

`define BYTE_WIDTH          (`DATA_WIDTH / 8)
`define BYTE_RANGE          `BYTE_WIDTH-1:0

typedef struct packed {
    logic                   read;
    logic                   write;
    logic [`DATA_RANGE]     address;    // used 32 bit address here for simplcity
    logic [`BYTE_RANGE]     byte_enable;
    logic [`DATA_RANGE]     writedata;
} avalon_req_t;

typedef struct packed {
    logic [`DATA_RANGE]     readdata;
    logic                   waitrequest;
} avalon_resp_t;

// IF to ID stage pipeline

typedef struct packed {
    logic               valid;
    logic [`PC_RANGE]   pc;
    logic [`DATA_RANGE] instruction;
} if2id_pipe_t;

`endif
