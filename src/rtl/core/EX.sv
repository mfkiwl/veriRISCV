// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Execution Stage
// ------------------------------------------------------------------------------------------------

`include "core.svh"

module EX (
    input                               clk,
    input                               rst,
    input                               ex_flush,
    input                               ex_stall,
    input                               ex_bubble,
    // from ID/EX stage pipeline
    input id2ex_pipeline_ctrl_t         id2ex_pipeline_ctrl,
    input id2ex_pipeline_exc_t          id2ex_pipeline_exc,
    input id2ex_pipeline_data_t         id2ex_pipeline_data,
    // from wb stage
    input [`DATA_RANGE]                 wb_forward_data,
    // branch control
    output [`PC_RANGE]                  branch_pc,
    output                              branch_take,
    // others
    output                              ex_mem_read,
    output                              muldiv_stall_req,
    // to EX/MEM stage pipeline
    output ex2mem_pipeline_ctrl_t       ex2mem_pipeline_ctrl,
    output ex2mem_pipeline_exc_t        ex2mem_pipeline_exc,
    output ex2mem_pipeline_data_t       ex2mem_pipeline_data
);


    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    logic [`DATA_RANGE] op1_forwarded;
    logic [`DATA_RANGE] op2_forwarded;
    logic [`DATA_RANGE] alu_op0;
    logic [`DATA_RANGE] alu_op1;

    logic               mul_req;
    logic               mul_stall;
    logic               div_req;
    logic               div_stall;

    logic [`DATA_RANGE] alu_out;
    logic [`DATA_RANGE] mul_out;
    logic [`DATA_RANGE] div_out;


    logic               stage_run;
    logic               stage_flush;

    ex2mem_pipeline_ctrl_t   ex_stage_ctrl;
    ex2mem_pipeline_exc_t    ex_stage_exc;
    ex2mem_pipeline_data_t   ex_stage_data;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    // Forwarding MUX
    assign op1_forwarded =  (id2ex_pipeline_data.op1_forward_from_mem) ? ex2mem_pipeline_data.alu_out :
                            (id2ex_pipeline_data.op1_forward_from_wb)  ? wb_forward_data :
                            id2ex_pipeline_data.rs1_readdata;

    assign op2_forwarded =  (id2ex_pipeline_data.op2_forward_from_mem) ? ex2mem_pipeline_data.alu_out :
                            (id2ex_pipeline_data.op2_forward_from_wb)  ? wb_forward_data :
                            id2ex_pipeline_data.rs2_readdata;

    // immediate select
    assign alu_op0 = id2ex_pipeline_data.alu_op1_sel_pc   ? id2ex_pipeline_data.pc :
                     id2ex_pipeline_data.alu_op1_sel_zero ? 'b0 :
                     op1_forwarded;

    assign alu_op1 = id2ex_pipeline_data.alu_op2_sel_imm  ? id2ex_pipeline_data.imm_value :
                     id2ex_pipeline_data.alu_op2_sel_4    ? 'd4 :
                     op2_forwarded;

    assign ex_mem_read = id2ex_pipeline_ctrl.mem_read & id2ex_pipeline_ctrl.reg_write;

    assign mul_req = id2ex_pipeline_ctrl.mul & ~ex_flush;
    assign div_req = id2ex_pipeline_ctrl.div & ~ex_flush;

    assign muldiv_stall_req = mul_stall | div_stall;

    // pipelien stge signal
    assign ex_stage_ctrl.valid = id2ex_pipeline_ctrl.valid;
    assign ex_stage_ctrl.csr_read  = id2ex_pipeline_ctrl.csr_read;
    assign ex_stage_ctrl.csr_write = id2ex_pipeline_ctrl.csr_write;
    assign ex_stage_ctrl.mem_read  = id2ex_pipeline_ctrl.mem_read;
    assign ex_stage_ctrl.mem_write = id2ex_pipeline_ctrl.mem_write;
    assign ex_stage_ctrl.reg_write = id2ex_pipeline_ctrl.reg_write;
    assign ex_stage_ctrl.mret = id2ex_pipeline_ctrl.mret;

    assign ex_stage_exc.exception_ill_instr = id2ex_pipeline_exc.exception_ill_instr;

    assign ex_stage_data.pc = id2ex_pipeline_data.pc;
    assign ex_stage_data.instruction = id2ex_pipeline_data.instruction;
    assign ex_stage_data.csr_write_opcode = id2ex_pipeline_data.csr_write_opcode;
    assign ex_stage_data.csr_writedata = id2ex_pipeline_data.alu_op2_sel_imm ? id2ex_pipeline_data.imm_value : op1_forwarded;
    assign ex_stage_data.csr_address = id2ex_pipeline_data.csr_address;
    assign ex_stage_data.reg_regid = id2ex_pipeline_data.reg_regid;
    assign ex_stage_data.mem_writedata = op2_forwarded;
    assign ex_stage_data.mem_opcode = id2ex_pipeline_data.mem_opcode;

    assign ex_stage_data.alu_out = id2ex_pipeline_ctrl.mul ? mul_out :
                                   id2ex_pipeline_ctrl.div ? div_out : alu_out;

    // pipeline stage
    assign stage_run = ~ex_stall;
    assign stage_flush = ex_flush | ~id2ex_pipeline_ctrl.valid & stage_run;

    always @(posedge clk) begin
        if (rst) ex2mem_pipeline_ctrl <= 0;
        else if (stage_flush || ex_bubble) ex2mem_pipeline_ctrl <= 0;
        else if (stage_run) ex2mem_pipeline_ctrl <= ex_stage_ctrl;
    end

    always @(posedge clk) begin
        if (rst) ex2mem_pipeline_exc <= 0;
        else if (ex_flush || ex_bubble) ex2mem_pipeline_exc <= 0;
        else if (stage_run) ex2mem_pipeline_exc <= ex_stage_exc;
    end

    always @(posedge clk) begin
        if (stage_run) ex2mem_pipeline_data <= ex_stage_data;
    end

    // ---------------------------------
    // Module instantiation
    // ---------------------------------

    alu u_alu (
         .alu_out       (alu_out),
         .alu_op0       (alu_op0),
         .alu_op1       (alu_op1),
         .alu_opcode    (id2ex_pipeline_data.alu_opcode));


    bu u_bu (
        .branch         (id2ex_pipeline_ctrl.branch),
        .jal            (id2ex_pipeline_ctrl.jal),
        .jalr           (id2ex_pipeline_ctrl.jalr),
        .branch_opcode  (id2ex_pipeline_data.branch_opcode),
        .branch_pc      (branch_pc),
        .branch_take    (branch_take),
        .op1            (op1_forwarded),
        .op2            (op2_forwarded),
        .imm_value      (id2ex_pipeline_data.imm_value),
        .pc             (id2ex_pipeline_data.pc),
        .exception_instr_addr_misaligned(ex_stage_exc.exception_instr_addr_misaligned));

`ifdef ISA_RV32M
    multiplier u_multiplier(
        .clk            (clk),
        .rst            (rst),
        .req            (mul_req),
        .opcode         (id2ex_pipeline_data.muldiv_opcode),
        .a              (op1_forwarded),
        .b              (op2_forwarded),
        .o              (mul_out),
        .stall          (mul_stall));

    divider u_divider(
        .clk            (clk),
        .rst            (rst),
        .req            (div_req),
        .flush          (ex_flush),
        .opcode         (id2ex_pipeline_data.muldiv_opcode),
        .a              (op1_forwarded),
        .b              (op2_forwarded),
        .o              (div_out),
        .stall          (div_stall));
`endif

endmodule
