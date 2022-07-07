// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/17/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Instruction Fetch stage
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module IF (
    input                   clk,
    input                   rst,
    // stage control
    input                   if_flush,
    input                   if_stall,
    // instruction bus
    output avalon_req_t     ibus_avalon_req,
    input  avalon_resp_t    ibus_avalon_resp,
    // branch control
    input                   branch_take,
    input [`PC_RANGE]       branch_pc,
    // trap control
    input                   trap_take,
    input [`PC_RANGE]       trap_pc,
    // pipelineline stage
    output if2id_pipeline_ctrl_t if2id_pipeline_ctrl,
    output if2id_pipeline_data_t if2id_pipeline_data
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------


    reg  [`DATA_RANGE]  instruction_backup;
    reg                 use_backup_instruction;
    reg                 if_stall_ff;
    logic               if_stall_risedge;
    logic [`PC_RANGE]   pc_out;

    // ---------------------------------
    // logic
    // ---------------------------------

    // we need to backup the current instruction if stall happens.

    always @(posedge clk) begin
        if (rst) if_stall_ff <= 1'b0;
        else if_stall_ff <= if_stall;
    end
    assign if_stall_risedge = if_stall & ~if_stall_ff;

    always @(posedge clk) begin
        if (if_stall_risedge) instruction_backup <= ibus_avalon_resp.readdata;
    end

    always @(posedge clk) begin
        if (rst) use_backup_instruction <= 1'b0;
        else begin
            if (if_stall) use_backup_instruction <= 1'b1;
            else use_backup_instruction <= 1'b0;
        end
    end

    assign ibus_avalon_req.write = 1'b0;
    assign ibus_avalon_req.writedata = 'b0;
    assign ibus_avalon_req.address = pc_out;
    assign ibus_avalon_req.byte_enable = 4'b1111;
    assign ibus_avalon_req.read = 1'b1; // always read

    // -- Pipeline Stage -- //
    always @(posedge clk) begin
        if (rst)            if2id_pipeline_ctrl <= 0;
        else if (if_flush)  if2id_pipeline_ctrl <= 0;
        else                if2id_pipeline_ctrl.valid <= 1'b1;
    end

    always_ff @(posedge clk) begin
        if (!if_stall) if2id_pipeline_data.pc = pc_out; // have to use blocking here to bypass verilator error checking
    end

    // the memory has 1 hidden pipelineline stage
    always @* if2id_pipeline_data.instruction = use_backup_instruction ? instruction_backup : ibus_avalon_resp.readdata;

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    pc u_pc
    (
       .clk             (clk),
       .rst             (rst),
       .stall           (if_stall),
       .branch_take     (branch_take),
       .branch_pc       (branch_pc),
       .trap_take       (trap_take),
       .trap_pc         (trap_pc),
       .pc_out          (pc_out));

endmodule
