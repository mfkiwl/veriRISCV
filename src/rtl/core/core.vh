///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: core.vh
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// Define file for core related parameter
//
///////////////////////////////////////////////////////////////////////////////////////////////////


`ifndef _CORE_VH_
`define _CORE_VH_

// ALU opcode
// To simplifiy the decode logic, here we use the same encoding with the instruction func3 field
// For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the forth bit to distinguesh them.
// Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to 1
`define CORE_ALU_OP_RANGE  3:0
`define CORE_ALU_ADD       4'b0000
`define CORE_ALU_SUB       4'b1000
`define CORE_ALU_SLL       4'b0001
`define CORE_ALU_SLT       4'b0010
`define CORE_ALU_SLTU      4'b0011
`define CORE_ALU_XOR       4'b0100
`define CORE_ALU_SRL       4'b0101
`define CORE_ALU_SRA       4'b1101
`define CORE_ALU_OR        4'b0110
`define CORE_ALU_AND       4'b0111

// Immediate number size for pipeline stage
`define IMM_RANGE          19:0

// Memory opcode
// Encoding is same in instruction
`define CORE_MEM_RD_OP_RANGE 2:0
`define CORE_MEM_LB         3'b000
`define CORE_MEM_LH         3'b001
`define CORE_MEM_LW         3'b010
`define CORE_MEM_LBU        3'b100
`define CORE_MEM_LHU        3'b101
`define CORE_MEM_NO_RD      3'b111
`define CORE_MEM_WR_OP_RANGE 1:0
`define CORE_MEM_SB         2'b00
`define CORE_MEM_SH         2'b01
`define CORE_MEM_SW         2'b10
`define CORE_MEM_NO_WR      2'b11

// Branch Unit (bu) opcode
// Same as Func3 encoding
`define CORE_BRANCH_OP_RANGE    2:0

// CSR opcode
// Same as Func3 encoding
`define CORE_CSR_ADDR_RANGE 11:0
`define CORE_CSR_OP_RANGE   1:0
`define CORE_CSR_NOP        2'b00
`define CORE_CSR_RW         2'b01
`define CORE_CSR_RS         2'b10
`define CORE_CSR_RC         2'b11

`endif