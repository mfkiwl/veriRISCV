///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: lsu.v
//
// Author: Heqing Huang
// Date Created: 01/17/2022
//
// ================== Description ==================
//
// lsu (load/store unit)
//
// Assume that the memory registers the input request so the pipeline stage is embedded at the memory
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "decoder.vh"
`include "veririscv_core.vh"

module lsu (
    input                           clk,
    // input from core logic
    input [`CORE_MEM_RD_OP_RENGE]   mem_rd_op,
    input [`CORE_MEM_WR_OP_RENGE]   mem_wr_op,
    input [`DATA_RANGE]             lsu_addr,
    input [`DATA_RANGE]             lsu_wdata,
    output reg [`DATA_RANGE]        lsu_rdata,
    // ports to memory/data bus
    output reg [`DATA_RAM_ADDR_RANGE]   mem_addr,
    output reg [`DATA_RANGE]            mem_wdata,
    output reg [3:0]                    mem_byte_en,
    output                              mem_wr,
    output                              mem_rd,
    input  [`DATA_RANGE]                mem_rdata,
    input                               mem_vld
);

    reg [1:0]   last_lsu_byte_addr;
    reg         sign_bit;
    wire        sign_bit_final;
    wire        sign_ext;

    assign mem_rd = (mem_rd_op != `CORE_MEM_NO_RD);
    assign mem_wr = (mem_wr_op != `CORE_MEM_NO_WR);
    assign mem_addr = lsu_addr[`DATA_RAM_ADDR_RANGE];

    // write data generation
    always @(*) begin
        case(mem_wr_op)
            `CORE_MEM_SB: begin
                case(lsu_addr[1:0])
                    2'b00: mem_wdata = {4{lsu_wdata[7:0]}};
                    2'b01: mem_wdata = {4{lsu_wdata[15:8]}};
                    2'b10: mem_wdata = {4{lsu_wdata[23:16]}};
                    2'b11: mem_wdata = {4{lsu_wdata[31:24]}};
                endcase
            end
            `CORE_MEM_SH: begin
                case(last_lsu_byte_addr[1])
                    1'b0: mem_wdata = {2{lsu_wdata[15:0]}};
                    1'b1: mem_wdata = {2{lsu_wdata[31:16]}};
                endcase
            end
            default: mem_wdata = lsu_wdata;
        endcase
    end

    // Read data generation
    // Read data goes to the wb stage directly without pipeline,
    // since we consider the memory with 1 read latency
    always @(posedge clk) begin
        if (mem_rd) last_lsu_byte_addr <= lsu_addr[1:0];
    end

    // LBU = 3'100, LHU = 3'b101, bit 2 is high for unsign ext
    assign sign_ext = ~mem_rd_op[2];
    assign sign_bit_final = sign_bit & sign_ext;

    always @(*) begin
        case(mem_rd_op)
            `CORE_MEM_LB, `CORE_MEM_LBU: begin
                case(last_lsu_byte_addr)
                    2'b00: lsu_rdata[7:0] = mem_rdata[7:0];
                    2'b01: lsu_rdata[7:0] = mem_rdata[15:8];
                    2'b10: lsu_rdata[7:0] = mem_rdata[23:16];
                    2'b11: lsu_rdata[7:0] = mem_rdata[31:24];
                endcase
                case(last_lsu_byte_addr)
                    2'b00: sign_bit = mem_rdata[7];
                    2'b01: sign_bit = mem_rdata[15];
                    2'b10: sign_bit = mem_rdata[23];
                    2'b11: sign_bit = mem_rdata[31];
                endcase
                lsu_rdata[31:8] = {24{sign_bit_final}};
            end
            `CORE_MEM_LH, `CORE_MEM_LHU: begin
                case(last_lsu_byte_addr[1])
                    1'b0: lsu_rdata[15:0] = mem_rdata[15:0];
                    1'b1: lsu_rdata[15:0] = mem_rdata[31:16];
                endcase
                case(last_lsu_byte_addr[1])
                    1'b0: sign_bit = mem_rdata[15];
                    1'b1: sign_bit = mem_rdata[31];
                endcase
                lsu_rdata[31:16] = {16{sign_bit_final}};
            end
            default: lsu_rdata = mem_rdata;
        endcase
    end

    // byte enable generation
    always @(*) begin
        case(mem_wr_op)
            `CORE_MEM_SB: begin
                case(lsu_addr[1:0])
                    2'b00: mem_byte_en = 4'b0001;
                    2'b01: mem_byte_en = 4'b0010;
                    2'b10: mem_byte_en = 4'b0100;
                    2'b11: mem_byte_en = 4'b1000;
                endcase
            end
            `CORE_MEM_SH: begin
                mem_byte_en = {lsu_addr[1], lsu_addr[1], ~lsu_addr[1], ~lsu_addr[1]};
            end
            `CORE_MEM_SW: mem_byte_en = 4'b1111;
            default: mem_byte_en = 4'b0000;
        endcase
    end

endmodule
