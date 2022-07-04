

// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 02/03/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Register module for mcsr.
// ------------------------------------------------------------------------------------------------

module mcsr
(
    input               clk,
    input               rst,
    input               csr_read,
    input               csr_write,
    input [11:0]        csr_address,
    input [31:0]        csr_writedata,
    output reg [31:0]   csr_readdata,

    // Hardware value input port
    input [1:0]         i_mstatus_mpp,
    input               i_mstatus_mpp_wen,
    input               i_mstatus_mpie,
    input               i_mstatus_mpie_wen,
    input               i_mstatus_mie,
    input               i_mstatus_mie_wen,
    input               i_misa_mxl_wen,
    input               i_misa_extensions_wen,
    input               i_mtvec_base_wen,
    input               i_mtvec_mode_wen,
    input               i_mscratch_value_wen,
    input [31:0]        i_mepc_value,
    input               i_mepc_value_wen,
    input               i_mcause_interrupt,
    input               i_mcause_interrupt_wen,
    input [30:0]        i_mcause_exception_code,
    input               i_mcause_exception_code_wen,
    input [31:0]        i_mtval_value,
    input               i_mtval_value_wen,
    input               i_mvendorid_value_wen,
    input               i_marchid_value_wen,
    input               i_mimpid_value_wen,
    input               i_mhartid_value_wen,

    // Hardware value output port
    output              o_mstatus_mpie,
    output              o_mstatus_mie,
    output [29:0]       o_mtvec_base,
    output [1:0]        o_mtvec_mode,
    output [31:0]       o_mscratch_value,
    output [31:0]       o_mepc_value
);

    logic [31:0]    mstatus;
    logic [1:0]     mstatus_mpp;    // we only supprot M mode
    reg             mstatus_mpie;
    reg             mstatus_mie;

    logic [31:0]    misa;
    logic [1:0]     misa_mxl;
    logic [25:0]    misa_extensions;

    logic [31:0]    mtvec;
    reg [29:0]      mtvec_base;
    reg [1:0]       mtvec_mode;

    logic [31:0]    mscratch;
    reg [31:0]      mscratch_value;

    logic [31:0]    mepc;
    reg [31:0]      mepc_value;

    logic [31:0]    mcause;
    reg             mcause_interrupt;
    reg [30:0]      mcause_exception_code;

    logic [31:0]    mtval;
    reg [31:0]      mtval_value;

    logic [31:0]    mvendorid;
    logic [31:0]    mvendorid_value;

    logic [31:0]    marchid;
    logic [31:0]    marchid_value;

    logic [31:0]    mimpid;
    logic [31:0]    mimpid_value;

    logic [31:0]    mhartid;
    logic [31:0]    mhartid_value;


    // -- Assign register with its field -- //

    assign mstatus = {19'h0, mstatus_mpp, 3'h0, mstatus_mpie, 3'h0, mstatus_mie, 3'h0};
    assign misa = {misa_mxl, 4'h0, misa_extensions};
    assign mtvec = {mtvec_base, mtvec_mode};
    assign mscratch = {mscratch_value};
    assign mepc = {mepc_value};
    assign mcause = {mcause_interrupt, mcause_exception_code};
    assign mtval = {mtval_value};
    assign mvendorid = {mvendorid_value};
    assign marchid = {marchid_value};
    assign mimpid = {mimpid_value};
    assign mhartid = {mhartid_value};

    // -- Assign constant field with its value -- //

    assign mstatus_mpp = 2'b11;

    assign misa_mxl = 2'h1;
    assign misa_extensions = 26'h100;

    assign mvendorid_value = 32'h0;

    assign marchid_value = 32'h0;

    assign mimpid_value = 32'h0;

    assign mhartid_value = 32'h0;


    // -- Assign output with its field -- //

    assign o_mstatus_mpie = mstatus_mpie;
    assign o_mstatus_mie = mstatus_mie;
    assign o_mtvec_base = mtvec_base;
    assign o_mtvec_mode = mtvec_mode;
    assign o_mscratch_value = mscratch_value;
    assign o_mepc_value = mepc_value;

    // -- Read Logic -- //
    always @(*) begin
        case(csr_address)
            12'h300: csr_readdata = mstatus;
            12'h301: csr_readdata = misa;
            12'h305: csr_readdata = mtvec;
            12'h340: csr_readdata = mscratch;
            12'h341: csr_readdata = mepc;
            12'h342: csr_readdata = mcause;
            12'h343: csr_readdata = mtval;
            12'hf11: csr_readdata = mvendorid;
            12'hf12: csr_readdata = marchid;
            12'hf13: csr_readdata = mimpid;
            12'hf14: csr_readdata = mhartid;
            default: csr_readdata = 0;
        endcase
    end

    // -- Write Logic -- //
    always @(posedge clk) begin
        if (rst) begin
            mstatus_mpie <= 1'h0;
            mstatus_mie <= 1'h1;        // set to 1 ?
            mtvec_base <= 30'h0;
            mtvec_mode <= 2'h0;
            mscratch_value <= 32'h0;
            mepc_value <= 32'h0;
            mcause_interrupt <= 1'h0;
            mcause_exception_code <= 31'h0;
            mtval_value <= 32'h0;
        end
        else begin
            if (i_mstatus_mpie_wen) mstatus_mpie <= i_mstatus_mpie;
            if (i_mstatus_mie_wen) mstatus_mie <= i_mstatus_mie;
            if (i_mepc_value_wen) mepc_value <= i_mepc_value;
            if (i_mcause_interrupt_wen) mcause_interrupt <= i_mcause_interrupt;
            if (i_mcause_exception_code_wen) mcause_exception_code <= i_mcause_exception_code;
            if (i_mtval_value_wen) mtval_value <= i_mtval_value;

            if (csr_write) begin
                case(csr_address)
                    12'h300: begin
                        mstatus_mpie <= csr_writedata[7:7];
                        mstatus_mie <= csr_writedata[3:3];
                    end
                    12'h305: begin
                        mtvec_base <= csr_writedata[31:2];
                        mtvec_mode <= csr_writedata[1:0];
                    end
                    12'h340: begin
                        mscratch_value <= csr_writedata[31:0];
                    end
                    12'h341: begin
                        mepc_value <= csr_writedata[31:0];
                    end
                    12'h342: begin
                        mcause_interrupt <= csr_writedata[31:31];
                        mcause_exception_code <= csr_writedata[30:0];
                    end
                    12'h343: begin
                        mtval_value <= csr_writedata[31:0];
                    end
                    default: begin end
                endcase
            end
        end
    end

endmodule
