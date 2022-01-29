///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: decoder.vh
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// Define file for decoder.
// - Instruction set related macro to decode the instruction
//
///////////////////////////////////////////////////////////////////////////////////////////////////


`ifndef _DECODER_VH_
`define _DECODER_VH_

// Instruction Field
`define DEC_OPCODE_FIELD    6:0
`define DEC_RD_FIELD        11:7
`define DEC_FUNC3_FIELD     14:12
`define DEC_RS1_FIELD       19:15
`define DEC_RS2_FIELD       24:20
`define DEC_FUNC7_FIELD     31:25
`define DEC_CSR_ADDR_FIELD  31:20

// Instruction Field Range
`define DEC_OPCODE_RANGE    6:0
`define DEC_RD_RANGE        4:0
`define DEC_FUNC3_RANGE     2:0
`define DEC_RS1_RANGE       4:0
`define DEC_RS2_RANGE       4:0
`define DEC_FUNC7_RANGE     6:0
`define DEC_CSR_ADDR_FIELD  31:20


// Instruction Type
`define DEC_TYPE_LOGIC      7'b0110011
`define DEC_TYPE_ILOGIC     7'b0010011
`define DEC_TYPE_STORE      7'b0100011
`define DEC_TYPE_LOAD       7'b0000011
`define DEC_TYPE_BRAHCN     7'b1100011
`define DEC_TYPE_JALR       7'b1100111
`define DEC_TYPE_JAL        7'b1101111
`define DEC_TYPE_AUIPC      7'b0010111
`define DEC_TYPE_LUI        7'b0110111
`define DEC_TYPE_CSR        7'b1110011

// Logic Instruction Func3
`define DEC_LOGIC_ADD       3'b000
`define DEC_LOGIC_SUB       3'b000
`define DEC_LOGIC_SLL       3'b001
`define DEC_LOGIC_SLT       3'b010
`define DEC_LOGIC_SLTU      3'b011
`define DEC_LOGIC_XOR       3'b100
`define DEC_LOGIC_SRL       3'b101
`define DEC_LOGIC_SRA       3'b101
`define DEC_LOGIC_OR        3'b110
`define DEC_LOGIC_AND       3'b111

// Branch Instruction Func3
`define DEC_BRANCH_BEQ      3'b000
`define DEC_BRANCH_BNE      3'b001
`define DEC_BRANCH_BLT      3'b100
`define DEC_BRANCH_BGE      3'b101
`define DEC_BRANCH_BLTU     3'b110
`define DEC_BRANCH_BGEU     3'b111

`endif