// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/26/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Define file for veriRISCV core: architecture
// ------------------------------------------------------------------------------------------------


`ifndef _VERIRISCV_CORE_ARCH_
`define _VERIRISCV_CORE_ARCH_


// Architecture

// Data size
`define DATA_WIDTH      32
`define DATA_RANGE      `DATA_WIDTH-1:0
`define PC_RANGE        `DATA_WIDTH-1:0

// Register Number
`define REG_NUM         32
`define RF_RANGE        $clog2(`REG_NUM)-1:0

// Instruction  RAM
`define INSTR_RAM_ADDR_WIDTH    16
`define INSTR_RAM_ADDR_RANGE    15:0

// Data RAM
`define DATA_RAM_ADDR_WIDTH     16
`define DATA_RAM_ADDR_RANGE     15:0

// Immediate number size for pipeline stage
`define CORE_IMM_RANGE          19:0

`endif
