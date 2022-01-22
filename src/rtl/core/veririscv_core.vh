///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: veririscv_core.vh
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// Define file for veririscv core architecture related configuration
//
///////////////////////////////////////////////////////////////////////////////////////////////////


`ifndef _VERIRISCV_DEFINE_
`define _VERIRISCV_DEFINE_


//////////////////////////
// General Architecture //
//////////////////////////

// Data size, RV32 - 32
`define DATA_WIDTH  32
`define DATA_RANGE  `DATA_WIDTH-1:0
`define PC_RANGE    `DATA_WIDTH-1:0

// Register Number, RV32I - 32
`define REG_NUM     32
`define RF_RANGE    $clog2(`REG_NUM)-1:0

// Instruction RAM
`define INSTR_RAM_ADDR_WIDTH 16
`define INSTR_RAM_ADDR_RANGE 15:0

// Data RAM
`define DATA_RAM_ADDR_WIDTH 16
`define DATA_RAM_ADDR_RANGE 15:0

`endif