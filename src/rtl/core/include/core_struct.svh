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
`include "core_opcode.svh"

// ---------------------------------
// Avalon bus define
// ---------------------------------

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


// ---------------------------------
// Pipeline Stages
// ---------------------------------

// IF/ID
typedef struct packed {
    logic [`PC_RANGE]               pc;
    logic [`DATA_RANGE]             instruction;
} if2id_pipeline_data_t;

typedef struct packed {
    logic                           valid;
} if2id_pipeline_ctrl_t;

// ID/EX
typedef struct packed {
    logic                          valid;
    // branch
    logic                          branch;
    logic                          jal;
    logic                          jalr;
    // csr
    logic                          csr_read;
    logic                          csr_write;
    // register
    logic                          reg_write;
    // memory
    logic                          mem_read;
    logic                          mem_write;
    // other instruction
    logic                          mret;
} id2ex_pipeline_ctrl_t;

typedef struct packed {
    logic                          exception_ill_instr;
} id2ex_pipeline_exc_t;

typedef struct packed {
    // general info
    logic [`PC_RANGE]              pc;
    logic [`DATA_RANGE]            instruction;
    // branch
    logic [`CORE_BRANCH_OP_RANGE]  branch_opcode;
    // alu
    logic                          alu_op1_sel_pc;
    logic                          alu_op1_sel_zero;
    logic                          alu_op2_sel_4;
    logic                          alu_op2_sel_imm;
    logic [`CORE_ALU_OP_RANGE]     alu_opcode;
    logic [`DATA_RANGE]            imm_value;
    // forwarding logic
    logic                          op1_forward_from_mem;
    logic                          op1_forward_from_wb;
    logic                          op2_forward_from_mem;
    logic                          op2_forward_from_wb;
    // csr
    logic [`CORE_CSR_OP_RANGE]     csr_write_opcode;
    logic [`CORE_CSR_ADDR_RANGE]   csr_address;
    // register
    logic [`RF_RANGE]              reg_regid;
    logic [`DATA_RANGE]            rs1_readdata;
    logic [`DATA_RANGE]            rs2_readdata;
    // memory
    logic [`CORE_MEM_OP_RANGE]     mem_opcode;
} id2ex_pipeline_data_t;

// EX/MEM
typedef struct packed {
    logic                          valid;
    // csr
    logic                          csr_read;
    logic                          csr_write;
    // memory
    logic                          mem_read;
    // register file
    logic                          reg_write;
    // other
    logic                          mret;
} ex2mem_pipeline_ctrl_t;

typedef struct packed {
    logic                          exception_ill_instr;
    logic                          exception_instr_addr_misaligned;
    logic                          exception_load_addr_misaligned;
    logic                          exception_store_addr_misaligned;
} ex2mem_pipeline_exc_t;

typedef struct packed {
    logic [`PC_RANGE]              pc;
    logic [`DATA_RANGE]            instruction;
    // csr
    logic [`CORE_CSR_OP_RANGE]     csr_write_opcode;
    logic [`DATA_RANGE]            csr_writedata;
    logic [`CORE_CSR_ADDR_RANGE]   csr_address;
    // register file
    logic [`RF_RANGE]              reg_regid;
    // other
    logic [`DATA_RANGE]            alu_out;
    logic [`DATA_RANGE]            lsu_address;
} ex2mem_pipeline_data_t;

// MEM/WB
typedef struct packed {
    logic                          valid;
    // register file
    logic                          reg_write;
    // csr
    logic                          csr_read;
    logic                          csr_write;
    // other
    logic                          mret;
} mem2wb_pipeline_ctrl_t;

typedef struct packed {
    logic                          exception_ill_instr;
    logic                          exception_instr_addr_misaligned;
    logic                          exception_load_addr_misaligned;
    logic                          exception_store_addr_misaligned;
} mem2wb_pipeline_exc_t;


typedef struct packed {
    logic [`PC_RANGE]              pc;
    logic [`DATA_RANGE]            instruction;
    // register file
    logic [`RF_RANGE]              reg_regid;
    logic [`DATA_RANGE]            reg_writedata;
    // csr
    logic [`CORE_CSR_OP_RANGE]     csr_write_opcode;
    logic [`DATA_RANGE]            csr_writedata;
    logic [`CORE_CSR_ADDR_RANGE]   csr_address;
    // other
    logic [`DATA_RANGE]            lsu_address;
} mem2wb_pipeline_data_t;

`endif
