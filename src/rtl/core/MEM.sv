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


`include "core.svh"

module MEM (
    input                               clk,
    input                               rst,
    input                               mem_stall,
    input                               mem_flush,

    // from EX/MEM stage pipe
    input ex2mem_pipeline_ctrl_t        ex2mem_pipeline_ctrl,
    input ex2mem_pipeline_data_t        ex2mem_pipeline_data,

    // input from EX stage for lsu (without pipeline)
    input                               lsu_mem_read,
    input                               lsu_mem_write,
    input [`CORE_MEM_OP_RANGE]          lsu_mem_opcode,
    input [`DATA_RANGE]                 lsu_address,
    input [`DATA_RANGE]                 lsu_writedata,

    // data bus
    output avalon_req_t                 dbus_avalon_req,
    input  avalon_resp_t                dbus_avalon_resp,

    // pipeline stage
    output mem2wb_pipeline_ctrl_t       mem2wb_pipeline_ctrl,
    output mem2wb_pipeline_data_t       mem2wb_pipeline_data
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    mem2wb_pipeline_ctrl_t      mem_stage_ctrl;
    mem2wb_pipeline_data_t      mem_stage_data;

    logic                       lsu_readdatavalid;
    logic [`DATA_RANGE]         lsu_readdata;

    logic                       stage_run;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    assign mem_stage_data.reg_writedata = lsu_readdatavalid ? lsu_readdata : ex2mem_pipeline_data.alu_out;

    // Pipeline Stage
    assign stage_run = ~mem_stall;

    always @(posedge clk) begin
        if (rst) begin
            mem2wb_pipeline_ctrl <= 0;
        end
        else if (!ex2mem_pipeline_ctrl.valid || mem_flush) begin
            mem2wb_pipeline_ctrl <= 0;
        end
        else if (stage_run) begin
            mem2wb_pipeline_ctrl <= mem_stage_ctrl;
        end
    end

    always @(posedge clk) begin
        if (stage_run) mem2wb_pipeline_data <= mem_stage_data;
    end


    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    lsu u_lsu (
        .clk                        (clk),
        .rst                        (rst),

        .lsu_mem_read               (lsu_mem_read),
        .lsu_mem_write              (lsu_mem_write),
        .lsu_mem_opcode             (lsu_mem_opcode),
        .lsu_address                (lsu_address),
        .lsu_writedata              (lsu_writedata),
        // data bus
        .dbus_avalon_req            (dbus_avalon_req),
        .dbus_avalon_resp           (dbus_avalon_resp),
        .lsu_readdata               (lsu_readdata),
        .lsu_readdatavalid          (lsu_readdatavalid),
        .exception_load_addr_misaligned   (mem_stage_ctrl.exception_load_addr_misaligned),
        .exception_store_addr_misaligned  (mem_stage_ctrl.exception_store_addr_misaligned)
    );

endmodule
