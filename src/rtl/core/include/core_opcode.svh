// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/26/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Define file for veriRISCV core: opcode
// ------------------------------------------------------------------------------------------------


`ifndef _VERIRISCV_CORE_OPCODE_
`define _VERIRISCV_CORE_OPCODE_


// ALU opcode
// To simplifiy the decode logic, here we use the same encoding with the instruction func3 field
// For ADD/SUB, SRL/SRA which has the same func3 encoding, we use the forth bit to distinguesh them.
// Note that bit 5 of func7 is set for SUB and SRA so we set the forth bit of SUB/SRA to 1
`define CORE_ALU_OP_RANGE   3:0
`define CORE_ALU_ADD        4'b0000
`define CORE_ALU_SUB        4'b1000
`define CORE_ALU_SLL        4'b0001
`define CORE_ALU_SLT        4'b0010
`define CORE_ALU_SLTU       4'b0011
`define CORE_ALU_XOR        4'b0100
`define CORE_ALU_SRL        4'b0101
`define CORE_ALU_SRA        4'b1101
`define CORE_ALU_OR         4'b0110
`define CORE_ALU_AND        4'b0111

// Memory opcode
// Encoding is same in instruction func3 field
// bit 2 indicate signed/unsigned
`define CORE_MEM_OP_RANGE   2:0
`define CORE_MEM_BYTE       2'b00
`define CORE_MEM_HALF       2'b01
`define CORE_MEM_WORD       2'b10

// Branch Unit (bu) opcode
// Same as Func3 encoding
`define CORE_BRANCH_OP_RANGE    2:0

// CSR opcode
// Same as Func3 encoding
`define CORE_CSR_ADDR_RANGE     11:0
`define CORE_CSR_OP_RANGE       1:0
`define CORE_CSR_NOP            2'b00
`define CORE_CSR_RW             2'b01
`define CORE_CSR_RS             2'b10
`define CORE_CSR_RC             2'b11

// Decoder related defines

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
`define DEC_SYSTEM_31_7_FIELD 31:7

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
`define DEC_TYPE_SYSTEM     7'b1110011

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

// RV32M Standard Extension
`define DEC_RV32M_MUL       3'b000
`define DEC_RV32M_MULH      3'b001
`define DEC_RV32M_MULHSU    3'b010
`define DEC_RV32M_MULHU     3'b011
`define DEC_RV32M_DIV       3'b100
`define DEC_RV32M_DIVU      3'b101
`define DEC_RV32M_REM       3'b110
`define DEC_RV32M_REMU      3'b111

// MRET
`define DEC_SYSTEM_MRET     25'b0011000000100000000000000

`endif
