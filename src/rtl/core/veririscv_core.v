///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: veririscv_core
//
// Author: Heqing Huang
// Date Created: 01/18/2022
//
// ================== Description ==================
//
// veririscv core top level
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "veririscv_core.vh"
`include "core.vh"

module veririscv_core (
    input   clk,
    input   rst,
    `ifdef COCOTB_SIM
    input   rstn,
    `endif
    // AHBLite Interface to Instruction RAM
    output                          ibus_hwrite,
    output [2:0]                    ibus_hsize,
    output [2:0]                    ibus_hburst,
    output [3:0]                    ibus_hport,
    output [1:0]                    ibus_htrans,
    output                          ibus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  ibus_haddr,
    output [`DATA_RANGE]            ibus_hwdata,
    input                           ibus_hready,
    input                           ibus_hresp,
    input  [`DATA_RANGE]            ibus_hrdata,
    // AHBLite Interface to memory/data bus
    output                          dbus_hwrite,
    output [2:0]                    dbus_hsize,
    output [2:0]                    dbus_hburst,
    output [3:0]                    dbus_hport,
    output [1:0]                    dbus_htrans,
    output                          dbus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  dbus_haddr,
    output [`DATA_RANGE]            dbus_hwdata,
    input                           dbus_hready,
    input                           dbus_hresp,
    input  [`DATA_RANGE]            dbus_hrdata,
    // Interrupt
    input                           software_interrupt,
    input                           timer_interrupt,
    input                           external_interrupt,
    input                           debug_interrupt
);

    /////////////////////////////////
    // Signal Declaration
    /////////////////////////////////

    /*AUTOREG*/

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [`DATA_RANGE]  ex2mem_alu_out;         // From EX of EX.v
    wire [`CORE_CSR_ADDR_RANGE] ex2mem_csr_addr;// From EX of EX.v
    wire                ex2mem_csr_rd;          // From EX of EX.v
    wire [`DATA_RANGE]  ex2mem_csr_wdata;       // From EX of EX.v
    wire [`CORE_CSR_OP_RANGE] ex2mem_csr_wr_op; // From EX of EX.v
    wire                ex2mem_exc_ill_instr;   // From EX of EX.v
    wire                ex2mem_exc_instr_addr_misaligned;// From EX of EX.v
    wire [`DATA_RANGE]  ex2mem_instruction;     // From EX of EX.v
    wire                ex2mem_mret;            // From EX of EX.v
    wire [`PC_RANGE]    ex2mem_pc;              // From EX of EX.v
    wire [`RF_RANGE]    ex2mem_reg_waddr;       // From EX of EX.v
    wire                ex2mem_reg_wen;         // From EX of EX.v
    wire [`CORE_ALU_OP_RANGE] id2ex_alu_op;     // From ID of ID.v
    wire                id2ex_br_instr;         // From ID of ID.v
    wire [`CORE_BRANCH_OP_RANGE] id2ex_branch_op;// From ID of ID.v
    wire [`CORE_CSR_ADDR_RANGE] id2ex_csr_addr; // From ID of ID.v
    wire                id2ex_csr_rd;           // From ID of ID.v
    wire [`CORE_CSR_OP_RANGE] id2ex_csr_wr_op;  // From ID of ID.v
    wire                id2ex_exc_ill_instr;    // From ID of ID.v
    wire [`DATA_RANGE]  id2ex_imm_value;        // From ID of ID.v
    wire [`DATA_RANGE]  id2ex_instruction;      // From ID of ID.v
    wire                id2ex_jal_instr;        // From ID of ID.v
    wire                id2ex_jalr_instr;       // From ID of ID.v
    wire [`CORE_MEM_OP_RANGE] id2ex_mem_op;     // From ID of ID.v
    wire                id2ex_mem_rd;           // From ID of ID.v
    wire                id2ex_mem_wr;           // From ID of ID.v
    wire                id2ex_mret;             // From ID of ID.v
    wire [`DATA_RANGE]  id2ex_op1_data;         // From ID of ID.v
    wire                id2ex_op1_forward_from_mem;// From ID of ID.v
    wire                id2ex_op1_forward_from_wb;// From ID of ID.v
    wire                id2ex_op1_sel_pc;       // From ID of ID.v
    wire                id2ex_op1_sel_zero;     // From ID of ID.v
    wire [`DATA_RANGE]  id2ex_op2_data;         // From ID of ID.v
    wire                id2ex_op2_forward_from_mem;// From ID of ID.v
    wire                id2ex_op2_forward_from_wb;// From ID of ID.v
    wire                id2ex_op2_sel_4;        // From ID of ID.v
    wire [`PC_RANGE]    id2ex_pc;               // From ID of ID.v
    wire [`RF_RANGE]    id2ex_reg_waddr;        // From ID of ID.v
    wire                id2ex_reg_wen;          // From ID of ID.v
    wire                id2ex_sel_imm;          // From ID of ID.v
    wire                id_flush;               // From hdu of hdu.v
    wire [`DATA_RANGE]  if2id_instruction;      // From IF of IF.v
    wire [`PC_RANGE]    if2id_pc;               // From IF of IF.v
    wire                if2id_stall;            // From hdu of hdu.v
    wire                if2id_valid;            // From IF of IF.v
    wire                if_flush;               // From hdu of hdu.v
    wire                load_dependence;        // From ID of ID.v
    wire [`DATA_RANGE]  lsu_addr;               // From EX of EX.v
    wire [`CORE_MEM_OP_RANGE] lsu_mem_op;       // From EX of EX.v
    wire                lsu_mem_rd;             // From EX of EX.v
    wire                lsu_mem_wr;             // From EX of EX.v
    wire [`DATA_RANGE]  lsu_wdata;              // From EX of EX.v
    wire [`CORE_CSR_ADDR_RANGE] mem2wb_csr_addr;// From MEM of MEM.v
    wire                mem2wb_csr_rd;          // From MEM of MEM.v
    wire [`DATA_RANGE]  mem2wb_csr_wdata;       // From MEM of MEM.v
    wire [`CORE_CSR_OP_RANGE] mem2wb_csr_wr_op; // From MEM of MEM.v
    wire                mem2wb_exc_ill_instr;   // From MEM of MEM.v
    wire                mem2wb_exc_instr_addr_misaligned;// From MEM of MEM.v
    wire                mem2wb_exc_load_addr_misaligned;// From MEM of MEM.v
    wire                mem2wb_exc_store_addr_misaligned;// From MEM of MEM.v
    wire [`DATA_RANGE]  mem2wb_instruction;     // From MEM of MEM.v
    wire [`DATA_RANGE]  mem2wb_lsu_addr;        // From MEM of MEM.v
    wire                mem2wb_mret;            // From MEM of MEM.v
    wire [`PC_RANGE]    mem2wb_pc;              // From MEM of MEM.v
    wire [`RF_RANGE]    mem2wb_reg_waddr;       // From MEM of MEM.v
    wire [`DATA_RANGE]  mem2wb_reg_wdata;       // From MEM of MEM.v
    wire                mem2wb_reg_wen;         // From MEM of MEM.v
    wire                take_branch;            // From EX of EX.v
    wire [`PC_RANGE]    target_pc;              // From EX of EX.v
    wire [`RF_RANGE]    wb_reg_waddr;           // From WB of WB.v
    wire [`DATA_RANGE]  wb_reg_wdata;           // From WB of WB.v
    wire                wb_reg_wen;             // From WB of WB.v
    // End of automatics


    /////////////////////////////////

    /////////////////////////////////
    // IF stage
    /////////////////////////////////
    IF
    IF (/*AUTOINST*/
        // Outputs
        .ibus_hwrite                    (ibus_hwrite),
        .ibus_hsize                     (ibus_hsize[2:0]),
        .ibus_hburst                    (ibus_hburst[2:0]),
        .ibus_hport                     (ibus_hport[3:0]),
        .ibus_htrans                    (ibus_htrans[1:0]),
        .ibus_hmastlock                 (ibus_hmastlock),
        .ibus_haddr                     (ibus_haddr[`INSTR_RAM_ADDR_RANGE]),
        .ibus_hwdata                    (ibus_hwdata[`DATA_RANGE]),
        .if2id_valid                    (if2id_valid),
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .if_flush                       (if_flush),
        .if2id_stall                    (if2id_stall),
        .ibus_hready                    (ibus_hready),
        .ibus_hresp                     (ibus_hresp),
        .ibus_hrdata                    (ibus_hrdata[`DATA_RANGE]),
        .take_branch                    (take_branch),
        .target_pc                      (target_pc[`PC_RANGE]));

    /////////////////////////////////
    // ID stage
    /////////////////////////////////

    /* ID AUTO_TEMPLATE (
        .reg_\(.*\)     (wb_reg_\1),
        .lsu_mem_rd     (mem_rd),
        ); */
    ID
    ID (/*AUTOINST*/
        // Outputs
        .load_dependence                (load_dependence),
        .id2ex_pc                       (id2ex_pc[`PC_RANGE]),
        .id2ex_instruction              (id2ex_instruction[`DATA_RANGE]),
        .id2ex_br_instr                 (id2ex_br_instr),
        .id2ex_jal_instr                (id2ex_jal_instr),
        .id2ex_jalr_instr               (id2ex_jalr_instr),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_op1_sel_pc               (id2ex_op1_sel_pc),
        .id2ex_op1_sel_zero             (id2ex_op1_sel_zero),
        .id2ex_op2_sel_4                (id2ex_op2_sel_4),
        .id2ex_op1_forward_from_mem     (id2ex_op1_forward_from_mem),
        .id2ex_op1_forward_from_wb      (id2ex_op1_forward_from_wb),
        .id2ex_op2_forward_from_mem     (id2ex_op2_forward_from_mem),
        .id2ex_op2_forward_from_wb      (id2ex_op2_forward_from_wb),
        .id2ex_csr_rd                   (id2ex_csr_rd),
        .id2ex_csr_wr_op                (id2ex_csr_wr_op[`CORE_CSR_OP_RANGE]),
        .id2ex_csr_addr                 (id2ex_csr_addr[`CORE_CSR_ADDR_RANGE]),
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_op1_data                 (id2ex_op1_data[`DATA_RANGE]),
        .id2ex_op2_data                 (id2ex_op2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`DATA_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_mem_rd                   (id2ex_mem_rd),
        .id2ex_mem_wr                   (id2ex_mem_wr),
        .id2ex_mem_op                   (id2ex_mem_op[`CORE_MEM_OP_RANGE]),
        .id2ex_branch_op                (id2ex_branch_op[`CORE_BRANCH_OP_RANGE]),
        .id2ex_mret                     (id2ex_mret),
        .id2ex_exc_ill_instr            (id2ex_exc_ill_instr),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .id_flush                       (id_flush),
        .if2id_valid                    (if2id_valid),
        .if2id_pc                       (if2id_pc[`PC_RANGE]),
        .if2id_instruction              (if2id_instruction[`DATA_RANGE]),
        .lsu_mem_rd                     (mem_rd),                // Templated
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .wb_reg_wen                     (wb_reg_wen),
        .wb_reg_waddr                   (wb_reg_waddr[`RF_RANGE]),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]));

    /////////////////////////////////
    // EX stage
    /////////////////////////////////

    /* EX AUTO_TEMPLATE (
        ); */
    EX
    EX (/*AUTOINST*/
        // Outputs
        .lsu_mem_rd                     (lsu_mem_rd),
        .lsu_mem_wr                     (lsu_mem_wr),
        .lsu_mem_op                     (lsu_mem_op[`CORE_MEM_OP_RANGE]),
        .lsu_addr                       (lsu_addr[`DATA_RANGE]),
        .lsu_wdata                      (lsu_wdata[`DATA_RANGE]),
        .target_pc                      (target_pc[`PC_RANGE]),
        .take_branch                    (take_branch),
        .ex2mem_pc                      (ex2mem_pc[`PC_RANGE]),
        .ex2mem_instruction             (ex2mem_instruction[`DATA_RANGE]),
        .ex2mem_csr_rd                  (ex2mem_csr_rd),
        .ex2mem_csr_wr_op               (ex2mem_csr_wr_op[`CORE_CSR_OP_RANGE]),
        .ex2mem_csr_wdata               (ex2mem_csr_wdata[`DATA_RANGE]),
        .ex2mem_csr_addr                (ex2mem_csr_addr[`CORE_CSR_ADDR_RANGE]),
        .ex2mem_reg_wen                 (ex2mem_reg_wen),
        .ex2mem_reg_waddr               (ex2mem_reg_waddr[`RF_RANGE]),
        .ex2mem_alu_out                 (ex2mem_alu_out[`DATA_RANGE]),
        .ex2mem_mret                    (ex2mem_mret),
        .ex2mem_exc_ill_instr           (ex2mem_exc_ill_instr),
        .ex2mem_exc_instr_addr_misaligned(ex2mem_exc_instr_addr_misaligned),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .id2ex_pc                       (id2ex_pc[`PC_RANGE]),
        .id2ex_instruction              (id2ex_instruction[`DATA_RANGE]),
        .id2ex_reg_wen                  (id2ex_reg_wen),
        .id2ex_reg_waddr                (id2ex_reg_waddr[`RF_RANGE]),
        .id2ex_op1_data                 (id2ex_op1_data[`DATA_RANGE]),
        .id2ex_op2_data                 (id2ex_op2_data[`DATA_RANGE]),
        .id2ex_imm_value                (id2ex_imm_value[`DATA_RANGE]),
        .id2ex_alu_op                   (id2ex_alu_op[`CORE_ALU_OP_RANGE]),
        .id2ex_mem_rd                   (id2ex_mem_rd),
        .id2ex_mem_wr                   (id2ex_mem_wr),
        .id2ex_mem_op                   (id2ex_mem_op[`CORE_MEM_OP_RANGE]),
        .id2ex_branch_op                (id2ex_branch_op[`CORE_BRANCH_OP_RANGE]),
        .id2ex_br_instr                 (id2ex_br_instr),
        .id2ex_jal_instr                (id2ex_jal_instr),
        .id2ex_jalr_instr               (id2ex_jalr_instr),
        .id2ex_sel_imm                  (id2ex_sel_imm),
        .id2ex_op1_sel_pc               (id2ex_op1_sel_pc),
        .id2ex_op1_sel_zero             (id2ex_op1_sel_zero),
        .id2ex_op2_sel_4                (id2ex_op2_sel_4),
        .id2ex_op1_forward_from_mem     (id2ex_op1_forward_from_mem),
        .id2ex_op1_forward_from_wb      (id2ex_op1_forward_from_wb),
        .id2ex_op2_forward_from_mem     (id2ex_op2_forward_from_mem),
        .id2ex_op2_forward_from_wb      (id2ex_op2_forward_from_wb),
        .id2ex_csr_rd                   (id2ex_csr_rd),
        .id2ex_csr_wr_op                (id2ex_csr_wr_op[`CORE_CSR_OP_RANGE]),
        .id2ex_csr_addr                 (id2ex_csr_addr[`CORE_CSR_ADDR_RANGE]),
        .id2ex_mret                     (id2ex_mret),
        .id2ex_exc_ill_instr            (id2ex_exc_ill_instr),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]));

    /////////////////////////////////
    // MEM stage
    /////////////////////////////////

    MEM
    MEM (/*AUTOINST*/
         // Outputs
         .dbus_hwrite                   (dbus_hwrite),
         .dbus_hsize                    (dbus_hsize[2:0]),
         .dbus_hburst                   (dbus_hburst[2:0]),
         .dbus_hport                    (dbus_hport[3:0]),
         .dbus_htrans                   (dbus_htrans[1:0]),
         .dbus_hmastlock                (dbus_hmastlock),
         .dbus_haddr                    (dbus_haddr[`INSTR_RAM_ADDR_RANGE]),
         .dbus_hwdata                   (dbus_hwdata[`DATA_RANGE]),
         .mem2wb_pc                     (mem2wb_pc[`PC_RANGE]),
         .mem2wb_instruction            (mem2wb_instruction[`DATA_RANGE]),
         .mem2wb_reg_wen                (mem2wb_reg_wen),
         .mem2wb_reg_waddr              (mem2wb_reg_waddr[`RF_RANGE]),
         .mem2wb_reg_wdata              (mem2wb_reg_wdata[`DATA_RANGE]),
         .mem2wb_csr_rd                 (mem2wb_csr_rd),
         .mem2wb_csr_wr_op              (mem2wb_csr_wr_op[`CORE_CSR_OP_RANGE]),
         .mem2wb_csr_wdata              (mem2wb_csr_wdata[`DATA_RANGE]),
         .mem2wb_csr_addr               (mem2wb_csr_addr[`CORE_CSR_ADDR_RANGE]),
         .mem2wb_lsu_addr               (mem2wb_lsu_addr[`DATA_RANGE]),
         .mem2wb_mret                   (mem2wb_mret),
         .mem2wb_exc_ill_instr          (mem2wb_exc_ill_instr),
         .mem2wb_exc_instr_addr_misaligned(mem2wb_exc_instr_addr_misaligned),
         .mem2wb_exc_load_addr_misaligned(mem2wb_exc_load_addr_misaligned),
         .mem2wb_exc_store_addr_misaligned(mem2wb_exc_store_addr_misaligned),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .ex2mem_pc                     (ex2mem_pc[`PC_RANGE]),
         .ex2mem_instruction            (ex2mem_instruction[`DATA_RANGE]),
         .ex2mem_reg_wen                (ex2mem_reg_wen),
         .ex2mem_reg_waddr              (ex2mem_reg_waddr[`RF_RANGE]),
         .ex2mem_alu_out                (ex2mem_alu_out[`DATA_RANGE]),
         .ex2mem_csr_rd                 (ex2mem_csr_rd),
         .ex2mem_csr_wr_op              (ex2mem_csr_wr_op[`CORE_CSR_OP_RANGE]),
         .ex2mem_csr_wdata              (ex2mem_csr_wdata[`DATA_RANGE]),
         .ex2mem_csr_addr               (ex2mem_csr_addr[`CORE_CSR_ADDR_RANGE]),
         .ex2mem_mret                   (ex2mem_mret),
         .ex2mem_exc_ill_instr          (ex2mem_exc_ill_instr),
         .ex2mem_exc_instr_addr_misaligned(ex2mem_exc_instr_addr_misaligned),
         .lsu_mem_rd                    (lsu_mem_rd),
         .lsu_mem_wr                    (lsu_mem_wr),
         .lsu_mem_op                    (lsu_mem_op[`CORE_MEM_OP_RANGE]),
         .lsu_addr                      (lsu_addr[`DATA_RANGE]),
         .lsu_wdata                     (lsu_wdata[`DATA_RANGE]),
         .dbus_hready                   (dbus_hready),
         .dbus_hresp                    (dbus_hresp),
         .dbus_hrdata                   (dbus_hrdata[`DATA_RANGE]));

    /////////////////////////////////
    // WB stage
    /////////////////////////////////

    WB
    WB (/*AUTOINST*/
        // Outputs
        .wb_reg_wen                     (wb_reg_wen),
        .wb_reg_waddr                   (wb_reg_waddr[`RF_RANGE]),
        .wb_reg_wdata                   (wb_reg_wdata[`DATA_RANGE]),
        // Inputs
        .clk                            (clk),
        .rst                            (rst),
        .software_interrupt             (software_interrupt),
        .timer_interrupt                (timer_interrupt),
        .external_interrupt             (external_interrupt),
        .debug_interrupt                (debug_interrupt),
        .mem2wb_pc                      (mem2wb_pc[`PC_RANGE]),
        .mem2wb_instruction             (mem2wb_instruction[`DATA_RANGE]),
        .mem2wb_mret                    (mem2wb_mret),
        .mem2wb_reg_wen                 (mem2wb_reg_wen),
        .mem2wb_reg_waddr               (mem2wb_reg_waddr[`RF_RANGE]),
        .mem2wb_reg_wdata               (mem2wb_reg_wdata[`DATA_RANGE]),
        .mem2wb_csr_rd                  (mem2wb_csr_rd),
        .mem2wb_csr_wr_op               (mem2wb_csr_wr_op[`CORE_CSR_OP_RANGE]),
        .mem2wb_csr_wdata               (mem2wb_csr_wdata[`DATA_RANGE]),
        .mem2wb_csr_addr                (mem2wb_csr_addr[`CORE_CSR_ADDR_RANGE]),
        .mem2wb_lsu_addr                (mem2wb_lsu_addr[`DATA_RANGE]),
        .mem2wb_exc_ill_instr           (mem2wb_exc_ill_instr),
        .mem2wb_exc_instr_addr_misaligned(mem2wb_exc_instr_addr_misaligned),
        .mem2wb_exc_load_addr_misaligned(mem2wb_exc_load_addr_misaligned),
        .mem2wb_exc_store_addr_misaligned(mem2wb_exc_store_addr_misaligned));


    /////////////////////////////////
    // LSU
    /////////////////////////////////

    hdu
    hdu (/*AUTOINST*/
         // Outputs
         .if_flush                      (if_flush),
         .id_flush                      (id_flush),
         .if2id_stall                   (if2id_stall),
         // Inputs
         .take_branch                   (take_branch),
         .load_dependence               (load_dependence),
         .id2ex_csr_rd                  (id2ex_csr_rd),
         .ex2mem_csr_rd                 (ex2mem_csr_rd),
         .mem2wb_csr_rd                 (mem2wb_csr_rd));

    /////////////////////////////////
    // Simulation Related
    /////////////////////////////////

    `ifdef COCOTB_SIM_DUMP
        initial begin
            $dumpfile ("veririscv_core.vcd");
            $dumpvars (0, veririscv_core);
            #1;
        end
    `endif

endmodule

