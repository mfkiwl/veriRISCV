// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Memory Stage
// ------------------------------------------------------------------------------------------------

/**

MEM stage mainly contains the load store unit (LSU)

It also contains a holding logic to hold the read data if the pipeline is stalled.

*/

`include "core.svh"

module MEM (
    input                               clk,
    input                               rst,
    input                               mem_stall,
    input                               mem_flush,

    // from EX/MEM stage pipe
    input ex2mem_pipeline_ctrl_t        ex2mem_pipeline_ctrl,
    input ex2mem_pipeline_exc_t         ex2mem_pipeline_exc,
    input ex2mem_pipeline_data_t        ex2mem_pipeline_data,

    // lsu
    output                              lsu_dbus_busy,

    // data bus
    output avalon_req_t                 dbus_avalon_req,
    input  avalon_resp_t                dbus_avalon_resp,

    // others
    output                              mem_mem_read,

    // pipeline stage
    output mem2wb_pipeline_ctrl_t       mem2wb_pipeline_ctrl,
    output mem2wb_pipeline_exc_t        mem2wb_pipeline_exc,
    output mem2wb_pipeline_data_t       mem2wb_pipeline_data,
    output [`DATA_RANGE]                mem2wb_pipeline_memory_data
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    mem2wb_pipeline_ctrl_t      mem_stage_ctrl;
    mem2wb_pipeline_exc_t       mem_stage_exc;
    mem2wb_pipeline_data_t      mem_stage_data;

    logic                       stage_run;
    logic                       stage_flush;

    reg                         use_hold_data;
    reg [`DATA_RANGE]           lsu_readdata_hold;
    logic [`DATA_RANGE]         lsu_readdata;
    logic                       lsu_readdata_valid;

    logic                       lsu_exception_load_addr_misaligned;
    logic                       lsu_exception_store_addr_misaligned;

    logic                       lsu_mem_read;
    logic                       lsu_mem_write;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign mem_stage_ctrl.valid = ex2mem_pipeline_ctrl.valid;
    assign mem_stage_ctrl.reg_write = ex2mem_pipeline_ctrl.reg_write & ~lsu_exception_load_addr_misaligned;
    assign mem_stage_ctrl.mem_read = ex2mem_pipeline_ctrl.mem_read;
    assign mem_stage_ctrl.csr_read = ex2mem_pipeline_ctrl.csr_read;
    assign mem_stage_ctrl.csr_write = ex2mem_pipeline_ctrl.csr_write;
    assign mem_stage_ctrl.mret = ex2mem_pipeline_ctrl.mret;

    assign mem_stage_exc.exception_ill_instr = ex2mem_pipeline_exc.exception_ill_instr;
    assign mem_stage_exc.exception_instr_addr_misaligned = ex2mem_pipeline_exc.exception_instr_addr_misaligned;
    assign mem_stage_exc.exception_load_addr_misaligned = lsu_exception_load_addr_misaligned;
    assign mem_stage_exc.exception_store_addr_misaligned = lsu_exception_store_addr_misaligned;

    assign mem_stage_data.pc = ex2mem_pipeline_data.pc;
    assign mem_stage_data.instruction = ex2mem_pipeline_data.instruction;
    assign mem_stage_data.reg_regid = ex2mem_pipeline_data.reg_regid;
    assign mem_stage_data.reg_writedata = ex2mem_pipeline_data.alu_out;
    assign mem_stage_data.csr_write_opcode = ex2mem_pipeline_data.csr_write_opcode;
    assign mem_stage_data.csr_writedata = ex2mem_pipeline_data.csr_writedata;
    assign mem_stage_data.csr_address = ex2mem_pipeline_data.csr_address;
    assign mem_stage_data.mem_address = ex2mem_pipeline_data.alu_out;

    // LSU data hold
    // we need to hold the lsu read data in case of the pipeline is stalled and a read is pending.
    always @(posedge clk) begin
        if (lsu_readdata_valid) lsu_readdata_hold <= lsu_readdata;
    end

    always @(posedge clk) begin
        if (rst) use_hold_data <= 1'b0;
        else if (lsu_readdata_valid && mem_stall) use_hold_data <= 1'b1;
        else if (!mem_stall) use_hold_data <= 1'b0;
    end

    assign mem2wb_pipeline_memory_data = use_hold_data ? lsu_readdata_hold : lsu_readdata;

    // lsu read/write logic

    // NOTE: A corner case: dbus is busy and we have a read/write request. At the same time,
    // interrupt/exception in WB stage need to flush memory stage.
    // However, the avalon bus protocal requires that the request must be keep unchanged till it is taken.
    // To FIX this issue, we requires that the interrupt/exception can't be taken if the Wb stage is stalled.
    assign lsu_mem_read = ex2mem_pipeline_ctrl.mem_read & ~mem_flush;
    assign lsu_mem_write = ex2mem_pipeline_ctrl.mem_write & ~mem_flush;
    assign mem_mem_read = lsu_mem_read;

    // Pipeline Stage
    assign stage_run = ~mem_stall;
    assign stage_flush = mem_flush | ~ex2mem_pipeline_ctrl.valid & stage_run;

    always @(posedge clk) begin
        if (rst) mem2wb_pipeline_ctrl <= 0;
        else if (stage_flush) mem2wb_pipeline_ctrl <= 0;
        else if (stage_run) mem2wb_pipeline_ctrl <= mem_stage_ctrl;
    end

    always @(posedge clk) begin
        if (rst) mem2wb_pipeline_exc <= 0;
        else if (mem_flush) mem2wb_pipeline_exc <= 0;
        else if (stage_run) mem2wb_pipeline_exc <= mem_stage_exc;
    end

    always @(posedge clk) begin
        if (stage_run) mem2wb_pipeline_data <= mem_stage_data;
    end

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    // lsu
    lsu u_lsu (
        .clk                        (clk),
        .rst                        (rst),
        .lsu_mem_read               (ex2mem_pipeline_ctrl.mem_read),
        .lsu_mem_write              (ex2mem_pipeline_ctrl.mem_write),
        .lsu_mem_opcode             (ex2mem_pipeline_data.mem_opcode),
        .lsu_address                (ex2mem_pipeline_data.alu_out),
        .lsu_writedata              (ex2mem_pipeline_data.mem_writedata),
        .lsu_readdata               (lsu_readdata),
        .lsu_readdata_valid         (lsu_readdata_valid),
        .lsu_dbus_busy              (lsu_dbus_busy),
        .dbus_avalon_req            (dbus_avalon_req),
        .dbus_avalon_resp           (dbus_avalon_resp),
        .lsu_exception_load_addr_misaligned   (lsu_exception_load_addr_misaligned),
        .lsu_exception_store_addr_misaligned  (lsu_exception_store_addr_misaligned)
    );

endmodule
