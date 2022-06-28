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

module veriRISCV_core (
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
    avalon_req_t            ibus_avalon_req;
    avalon_resp_t           ibus_avalon_resp;
    if2id_pipeline_ctrl_t   if2id_pipeline_ctrl;
    if2id_pipeline_data_t   if2id_pipeline_data;

    // ID stage
    logic                   id_flush;
    logic                   id_stall;
    if2id_pipeline_ctrl_t   if2id_pipeline_ctrl;
    if2id_pipeline_data_t   if2id_pipeline_data;
    id2ex_pipeline_ctrl_t   id2ex_pipeline_ctrl;
    id2ex_pipeline_data_t   id2ex_pipeline_data;

    // EX stage
    logic                   ex_flush;
    logic                   ex_stall;
    id2ex_pipeline_ctrl_t   id2ex_pipeline_ctrl;
    id2ex_pipeline_data_t   id2ex_pipeline_data;
    logic                   lsu_mem_read;
    logic                   lsu_mem_write;
    logic [`CORE_MEM_OP_RANGE]  lsu_mem_opcode;
    logic [`DATA_RANGE]     lsu_address;
    logic [`DATA_RANGE]     lsu_writedata;
    ex2mem_pipeline_ctrl_t  ex2mem_pipeline_ctrl;
    ex2mem_pipeline_data_t  ex2mem_pipeline_data;

    // MEM stage
    logic                   mem_stall;
    logic                   mem_flush;
    ex2mem_pipeline_ctrl_t  ex2mem_pipeline_ctrl;
    ex2mem_pipeline_data_t  ex2mem_pipeline_data;
    mem2wb_pipeline_ctrl_t  mem2wb_pipeline_ctrl;
    mem2wb_pipeline_data_t  mem2wb_pipeline_data;

    // WB stage
    logic                   wb_reg_write;
    logic [`RF_RANGE]       wb_reg_regid;
    logic [`DATA_RANGE]     wb_reg_writedata;


    // common signals
    logic                   branch_take;
    logic [`PC_RANGE]       branch_pc;
    logic                   hdu_load_stall;



    // ---------------------------------
    // IF stage
    // ---------------------------------

    IF u_IF(
        .clk                    (clk),
        .rst                    (rst),
        .if_flush               (if_flush),
        .if_stall               (if_stall),
        .ibus_avalon_req        (ibus_avalon_req),
        .ibus_avalon_resp       (ibus_avalon_resp),
        .branch_take            (branch_take),
        .branch_pc              (branch_pc),
        .if2id_pipeline_ctrl    (if2id_pipeline_ctrl_t),
        .if2id_pipeline_data    (if2id_pipeline_data_t)
    );

    // ---------------------------------
    // ID stage
    // ---------------------------------

    ID u_ID(
        .clk                    (clk),
        .rst                    (rst),
        .id_flush               (id_flush),
        .id_stall               (id_stall),
        .if2id_pipeline_ctrl    (if2id_pipeline_ctrl),
        .if2id_pipeline_data    (if2id_pipeline_data),
        .mem_reg_regid          (ex2mem_pipeline_data.reg_regid),
        .mem_reg_write          (ex2mem_pipeline_data.reg_write),
        .wb_reg_write           (wb_reg_write),
        .wb_reg_regid           (wb_reg_regid),
        .wb_reg_writedata       (wb_reg_writedata),
        .hdu_load_stall         (hdu_load_stall),
        .id2ex_pipeline_ctrl    (id2ex_pipeline_ctrl),
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
        .id2ex_pipeline_ctrl    (id2ex_pipeline_ctrl),
        .id2ex_pipeline_data    (id2ex_pipeline_data),
        .wb_reg_writedata       (wb_reg_writedata),
        .lsu_mem_read           (lsu_mem_read),
        .lsu_mem_write          (lsu_mem_write),
        .lsu_mem_opcode         (lsu_mem_opcode),
        .lsu_address            (lsu_address),
        .lsu_writedata          (lsu_writedata),
        .branch_pc              (branch_pc),
        .branch_take            (branch_take),
        .ex2mem_pipeline_ctrl   (ex2mem_pipeline_ctrl),
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
        .ex2mem_pipeline_ctrl   (ex2mem_pipeline_ctrl),
        .ex2mem_pipeline_data   (ex2mem_pipeline_data),
        .lsu_mem_read           (lsu_mem_read),
        .lsu_mem_write          (lsu_mem_write),
        .lsu_mem_opcode         (lsu_mem_opcode),
        .lsu_address            (lsu_address),
        .lsu_writedata          (lsu_writedata),
        .avalon_req             (avalon_req),
        .avalon_resp            (avalon_resp),
        .mem2wb_pipeline_ctrl   (mem2wb_pipeline_ctrl),
        .mem2wb_pipeline_data   (mem2wb_pipeline_data)
    );


    // ---------------------------------
    // WB stage
    // ---------------------------------

    WB u_WB(
        .clk                    (clk),
        .rst                    (rst),
        .software_interrupt     (software_interrupt),
        .timer_interrupt        (timer_interrupt),
        .external_interrupt     (external_interrupt),
        .debug_interrupt        (debug_interrupt),
        .mem2wb_pipeline_ctrl   (mem2wb_pipeline_ctrt),
        .mem2wb_pipeline_data   (mem2wb_pipeline_data),
        .wb_reg_write           (wb_reg_write),
        .wb_reg_regid           (wb_reg_regid),
        .wb_reg_writedata       (wb_reg_writedata)
    );


    // ---------------------------------
    // HDU
    // ---------------------------------

    hdu u_hdu(
        .branch_take (branch_take),
        .load_stall  (load_stall),
        .if_flush    (if_flush),
        .if_stall    (if_stall),
        .id_flush    (id_flush),
        .id_stall    (id_stall),
        .ex_flush    (ex_flush),
        .ex_stall    (ex_stall),
        .mem_flush   (mem_flush),
        .mem_stall   (mem_stall)
    );


endmodule

