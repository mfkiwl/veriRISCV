///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: lsu.v
//
// Author: Heqing Huang
// Date Created: 01/21/2022
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
    input [`CORE_MEM_RD_OP_RANGE]   mem_rd_op,
    input [`CORE_MEM_WR_OP_RANGE]   mem_wr_op,
    input [`DATA_RANGE]             lsu_addr,
    input [`DATA_RANGE]             lsu_wdata,
    output reg [`DATA_RANGE]        lsu_rdata,
    // AHBLite Interface to Instruction RAM
    output                          dbus_hwrite,
    output reg [2:0]                dbus_hsize,
    output [2:0]                    dbus_hburst,
    output [3:0]                    dbus_hport,
    output [1:0]                    dbus_htrans,
    output                          dbus_hmastlock,
    output [`INSTR_RAM_ADDR_RANGE]  dbus_haddr,
    output reg [`DATA_RANGE]        dbus_hwdata,
    input                           dbus_hready,
    input                           dbus_hresp,
    input  [`DATA_RANGE]            dbus_hrdata,
    // port to MEM stage
    output                          mem_rd

);

    reg [1:0]   last_lsu_byte_addr;
    reg [`CORE_MEM_RD_OP_RANGE]   last_mem_rd_op;
    reg         sign_bit;
    wire        sign_bit_final;
    wire        sign_ext;
    wire        mem_wr;

    assign mem_rd = (mem_rd_op != `CORE_MEM_NO_RD);
    assign mem_wr = (mem_wr_op != `CORE_MEM_NO_WR);
    assign dbus_hwrite = mem_wr;
    assign dbus_hburst = 3'b0;
    assign dbus_hport  = 4'b0001;
    assign dbus_htrans = (mem_rd | mem_wr) ? 2'b10 : 2'b00;
    assign dbus_hmastlock = 1'b0;
    assign dbus_haddr  = lsu_addr[`DATA_RAM_ADDR_RANGE];

    // FIXME
    // dbus_hready
    // dbus_hresp

    // write data generation
    // write data are provided at data phase
    always @(posedge clk) begin
        case(mem_wr_op)
            `CORE_MEM_SB: begin
                case(lsu_addr[1:0])
                    2'b00: dbus_hwdata <= {4{lsu_wdata[7:0]}};
                    2'b01: dbus_hwdata <= {4{lsu_wdata[15:8]}};
                    2'b10: dbus_hwdata <= {4{lsu_wdata[23:16]}};
                    2'b11: dbus_hwdata <= {4{lsu_wdata[31:24]}};
                endcase
            end
            `CORE_MEM_SH: begin
                case(last_lsu_byte_addr[1])
                    1'b0: dbus_hwdata <= {2{lsu_wdata[15:0]}};
                    1'b1: dbus_hwdata <= {2{lsu_wdata[31:16]}};
                endcase
            end
            default: dbus_hwdata <= lsu_wdata;
        endcase
    end

    // Read data generation
    // Read data goes to the wb stage directly without pipeline,
    // since we consider the memory with 1 read latency
    always @(posedge clk) begin
        if (mem_rd) begin
            last_lsu_byte_addr <= lsu_addr[1:0];
            last_mem_rd_op <= mem_rd_op;
        end
    end

    // LBU = 3'100, LHU = 3'b101, bit 2 is high for unsign ext
    assign sign_ext = ~last_mem_rd_op[2];
    assign sign_bit_final = sign_bit & sign_ext;

    always @(*) begin
        case(last_mem_rd_op)
            `CORE_MEM_LB, `CORE_MEM_LBU: begin
                case(last_lsu_byte_addr)
                    2'b00: lsu_rdata[7:0] = dbus_hrdata[7:0];
                    2'b01: lsu_rdata[7:0] = dbus_hrdata[15:8];
                    2'b10: lsu_rdata[7:0] = dbus_hrdata[23:16];
                    2'b11: lsu_rdata[7:0] = dbus_hrdata[31:24];
                endcase
                case(last_lsu_byte_addr)
                    2'b00: sign_bit = dbus_hrdata[7];
                    2'b01: sign_bit = dbus_hrdata[15];
                    2'b10: sign_bit = dbus_hrdata[23];
                    2'b11: sign_bit = dbus_hrdata[31];
                endcase
                lsu_rdata[31:8] = {24{sign_bit_final}};
            end
            `CORE_MEM_LH, `CORE_MEM_LHU: begin
                case(last_lsu_byte_addr[1])
                    1'b0: lsu_rdata[15:0] = dbus_hrdata[15:0];
                    1'b1: lsu_rdata[15:0] = dbus_hrdata[31:16];
                endcase
                case(last_lsu_byte_addr[1])
                    1'b0: sign_bit = dbus_hrdata[15];
                    1'b1: sign_bit = dbus_hrdata[31];
                endcase
                lsu_rdata[31:16] = {16{sign_bit_final}};
            end
            default: lsu_rdata = dbus_hrdata;
        endcase
    end

    // byte enable generation
    always @(*) begin
        case(mem_wr_op)
            `CORE_MEM_SB: dbus_hsize = 3'b000;
            `CORE_MEM_SH: dbus_hsize = 3'b001;
            `CORE_MEM_SW: dbus_hsize = 3'b010;
            default: dbus_hsize = 3'b000;
        endcase
    end

endmodule
