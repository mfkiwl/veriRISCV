// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/19/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// veriRISCV cpu core top level
// ------------------------------------------------------------------------------------------------


`include "core.svh"

module veriRISCV_core #(
`ifdef USE_ICACHE
    parameter ICACHE_LINE_SIZE = 4,  // cache line size in bytes, support 4 byte only for now
    parameter ICACHE_DEPTH = 32,     // depth of the cache set. Must be power of 2
    parameter ICACHE_WAYS = 2,       // cache ways. 1 => direct mapped. >=2 set associative
`endif
    parameter IFQ_DEPTH = 16,   // instruction fetch queue depth. Set to 16 so it is mapped to FPGA BRAM
    parameter IFQ_AFULL_TH = 1  // instruction fetch queue almost full threshold
)(
    input                   clk,
    input                   rst,
    // instruction bus
    output avalon_req_t     ibus_avalon_req,
    input  avalon_resp_t    ibus_avalon_resp,
    // data bus
    output avalon_req_t     dbus_avalon_req,
    input  avalon_resp_t    dbus_avalon_resp,
    // Interrupt
    input                   software_interrupt,
    input                   timer_interrupt,
    input                   external_interrupt,
    input                   debug_interrupt
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    // IF stage
    logic                   if_flush;
    logic                   if_stall;
    if2id_pipeline_ctrl_t   if2id_pipeline_ctrl;
    if2id_pipeline_data_t   if2id_pipeline_data;

    // ID stage
    logic                   id_flush;
    logic                   id_stall;
    logic                   id_bubble;
    id2ex_pipeline_ctrl_t   id2ex_pipeline_ctrl;
    id2ex_pipeline_exc_t    id2ex_pipeline_exc;
    id2ex_pipeline_data_t   id2ex_pipeline_data;

    // EX stage
    logic                   ex_flush;
    logic                   ex_stall;
    logic                   ex_bubble;
    logic                   ex_mem_read;
    ex2mem_pipeline_ctrl_t  ex2mem_pipeline_ctrl;
    ex2mem_pipeline_exc_t   ex2mem_pipeline_exc;
    ex2mem_pipeline_data_t  ex2mem_pipeline_data;

    // MEM stage
    logic                   mem_stall;
    logic                   mem_flush;
    logic                   mem_mem_read;
    mem2wb_pipeline_ctrl_t  mem2wb_pipeline_ctrl;
    mem2wb_pipeline_exc_t   mem2wb_pipeline_exc;
    mem2wb_pipeline_data_t  mem2wb_pipeline_data;
    logic [`DATA_RANGE]     mem2wb_pipeline_memory_data;

    // WB stage
    logic                   wb_stall;
    logic                   wb_reg_write;
    logic [`RF_RANGE]       wb_reg_regid;
    logic [`DATA_RANGE]     wb_reg_writedata;
    logic [`DATA_RANGE]     wb_forward_data;


    // common signals
    logic                   branch_take;
    logic [`PC_RANGE]       branch_pc;

    logic                   trap_take;
    logic [`PC_RANGE]       trap_pc;
    logic                   ifu_ibus_busy;
    logic                   lsu_dbus_busy;
    logic                   hdu_load_stall_req;
    logic                   muldiv_stall_req;

`ifdef USE_ICACHE
    avalon_req_t            icache_avn_req;
    avalon_resp_t           icache_avn_resp;
`endif

    // ---------------------------------
    // IF stage
    // ---------------------------------

    IF #(
        .IFQ_DEPTH      (IFQ_DEPTH),
        .IFQ_AFULL_TH   (IFQ_AFULL_TH))
    u_IF(
        .clk                    (clk),
        .rst                    (rst),
        .if_flush               (if_flush),
        .if_stall               (if_stall),
    `ifdef USE_ICACHE
        .ibus_avalon_req        (icache_avn_req),
        .ibus_avalon_resp       (icache_avn_resp),
    `else
        .ibus_avalon_req        (ibus_avalon_req),
        .ibus_avalon_resp       (ibus_avalon_resp),
    `endif
        .branch_take            (branch_take),
        .branch_pc              (branch_pc),
        .trap_take              (trap_take),
        .trap_pc                (trap_pc),
        .if2id_pipeline_ctrl    (if2id_pipeline_ctrl),
        .if2id_pipeline_data    (if2id_pipeline_data)
    );

    // ---------------------------------
    // ID stage
    // ---------------------------------

    ID u_ID(
        .clk                    (clk),
        .rst                    (rst),
        .id_flush               (id_flush),
        .id_stall               (id_stall),
        .id_bubble              (id_bubble),
        .if2id_pipeline_ctrl    (if2id_pipeline_ctrl),
        .if2id_pipeline_data    (if2id_pipeline_data),
        .mem_reg_regid          (ex2mem_pipeline_data.reg_regid),
        .mem_reg_write          (ex2mem_pipeline_ctrl.reg_write),
        .wb_reg_write           (wb_reg_write),
        .wb_reg_regid           (wb_reg_regid),
        .wb_reg_writedata       (wb_reg_writedata),
        .ex_mem_read            (ex_mem_read),
        .mem_mem_read           (mem_mem_read),
        .hdu_load_stall_req         (hdu_load_stall_req),
        .id2ex_pipeline_ctrl    (id2ex_pipeline_ctrl),
        .id2ex_pipeline_exc     (id2ex_pipeline_exc),
        .id2ex_pipeline_data    (id2ex_pipeline_data)
    );

    // ---------------------------------
    // EX stage
    // ---------------------------------

    EX u_EX(
        .clk                    (clk),
        .rst                    (rst),
        .ex_flush               (ex_flush),
        .ex_stall               (ex_stall),
        .ex_bubble              (ex_bubble),
        .id2ex_pipeline_ctrl    (id2ex_pipeline_ctrl),
        .id2ex_pipeline_exc     (id2ex_pipeline_exc),
        .id2ex_pipeline_data    (id2ex_pipeline_data),
        .wb_forward_data        (wb_forward_data),
        .branch_pc              (branch_pc),
        .branch_take            (branch_take),
        .ex_mem_read            (ex_mem_read),
        .muldiv_stall_req       (muldiv_stall_req),
        .ex2mem_pipeline_ctrl   (ex2mem_pipeline_ctrl),
        .ex2mem_pipeline_exc    (ex2mem_pipeline_exc),
        .ex2mem_pipeline_data   (ex2mem_pipeline_data)
    );

    // ---------------------------------
    // MEM stage
    // ---------------------------------

    MEM u_MEM(
        .clk                    (clk),
        .rst                    (rst),
        .mem_stall              (mem_stall),
        .mem_flush              (mem_flush),
        .dbus_avalon_req        (dbus_avalon_req),
        .dbus_avalon_resp       (dbus_avalon_resp),
        .mem_mem_read           (mem_mem_read),
        .lsu_dbus_busy          (lsu_dbus_busy),
        .ex2mem_pipeline_ctrl   (ex2mem_pipeline_ctrl),
        .ex2mem_pipeline_exc    (ex2mem_pipeline_exc),
        .ex2mem_pipeline_data   (ex2mem_pipeline_data),
        .mem2wb_pipeline_ctrl   (mem2wb_pipeline_ctrl),
        .mem2wb_pipeline_exc    (mem2wb_pipeline_exc),
        .mem2wb_pipeline_data   (mem2wb_pipeline_data),
        .mem2wb_pipeline_memory_data   (mem2wb_pipeline_memory_data)
    );


    // ---------------------------------
    // WB stage
    // ---------------------------------

    // NOTE: In general we can consider using ex2mem_pipeline_ctrl.valid as mem_valid
    // One concern is that what if mem stage get flushed then ex2mem_pipeline_ctrl.valid is not good enough.
    // This is OK for now becasue mem stage only get flushed by a taken trap.

    WB u_WB(
        .clk                    (clk),
        .rst                    (rst),
        .wb_stall               (wb_stall),
        .software_interrupt     (software_interrupt),
        .timer_interrupt        (timer_interrupt),
        .external_interrupt     (external_interrupt),
        .debug_interrupt        (debug_interrupt),
        .mem2wb_pipeline_ctrl   (mem2wb_pipeline_ctrl),
        .mem2wb_pipeline_exc    (mem2wb_pipeline_exc),
        .mem2wb_pipeline_data   (mem2wb_pipeline_data),
        .mem2wb_pipeline_memory_data   (mem2wb_pipeline_memory_data),
        .mem_valid              (ex2mem_pipeline_ctrl.valid),
        .mem_instruction_pc     (ex2mem_pipeline_data.pc),
        .wb_reg_write           (wb_reg_write),
        .wb_reg_regid           (wb_reg_regid),
        .wb_reg_writedata       (wb_reg_writedata),
        .wb_forward_data        (wb_forward_data),
        .trap_take              (trap_take),
        .trap_pc                (trap_pc)
    );


    // ---------------------------------
    // HDU
    // ---------------------------------

    hdu u_hdu(
        .branch_take        (branch_take),
        .trap_take          (trap_take),
        .lsu_dbus_busy      (lsu_dbus_busy),
        .load_stall_req     (hdu_load_stall_req),
        .muldiv_stall_req   (muldiv_stall_req),
        .ex_csr_read        (id2ex_pipeline_ctrl.csr_read),
        .mem_csr_read       (ex2mem_pipeline_ctrl.csr_read),
        .if_flush           (if_flush),
        .if_stall           (if_stall),
        .id_flush           (id_flush),
        .id_stall           (id_stall),
        .id_bubble          (id_bubble),
        .ex_flush           (ex_flush),
        .ex_stall           (ex_stall),
        .ex_bubble          (ex_bubble),
        .mem_flush          (mem_flush),
        .mem_stall          (mem_stall),
        .wb_stall           (wb_stall)
    );

    // ---------------------------------
    // I-CACHE
    // ---------------------------------

`ifdef USE_ICACHE
    cache #(
        .CACHE_LINE_SIZE    (ICACHE_LINE_SIZE),
        .CACHE_SET_DEPTH    (ICACHE_DEPTH),
        .CACHE_WAYS         (ICACHE_WAYS))
    u_instruction_cache (
        .clk                (clk),
        .rst                (rst),
        .core_avn_req       (icache_avn_req),
        .core_avn_resp      (icache_avn_resp),
        .mem_avn_req        (ibus_avalon_req),
        .mem_avn_resp       (ibus_avalon_resp)
    );
`endif

endmodule
