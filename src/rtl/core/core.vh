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
`define CORE_MEM_OP_RANGE 2:0
// One hot encoding for byte, half, and sign
// which is the same as func3 field
// Bit 0: 1- half word access
// Bit 1: 1- word access
// Bit 2: 1 - signed. 0 - unsigned
`define CORE_MEM_HALF   2'b01
`define CORE_MEM_WORD   2'b10

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