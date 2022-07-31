// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 01/21/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Load Store Unit
// ------------------------------------------------------------------------------------------------

`include "core.svh"

// FIXME:
// If memory stage is stalled. We need to have a way to keep the read data otherwise the read data will be lost

module lsu (
    input                           clk,
    input                           rst,
    // input from core logic in EX stage
    input                           lsu_mem_read,
    input                           lsu_mem_write,
    input [`CORE_MEM_OP_RANGE]      lsu_mem_opcode,
    input [`DATA_RANGE]             lsu_address,
    input [`DATA_RANGE]             lsu_writedata,
    // data bus
    output avalon_req_t             dbus_avalon_req,
    input  avalon_resp_t            dbus_avalon_resp,
    // port to MEM stage
    output logic [`DATA_RANGE]      lsu_readdata,
    output reg                      lsu_readdata_valid,
    output logic                    lsu_dbus_busy,
    // exception
    output logic                    lsu_exception_load_addr_misaligned,
    output logic                    lsu_exception_store_addr_misaligned
);

    reg [1:0]                       prev_byte_addr;
    reg [`CORE_MEM_OP_RANGE]        prev_mem_opcode;
    reg                             wait_memory;

    logic                           sign_bit;
    logic                           sign_bit_final;
    logic                           sign_ext;
    logic                           word_aligned;
    logic                           halfword_aligned;

    logic                           addr_misaligned;


    // ---------------------------------
    // logic
    // ---------------------------------
    assign lsu_dbus_busy = (dbus_avalon_req.read | dbus_avalon_req.write) & dbus_avalon_resp.waitrequest;

    assign dbus_avalon_req.write = lsu_mem_write & ~addr_misaligned;
    assign dbus_avalon_req.read = lsu_mem_read & ~addr_misaligned;
    assign dbus_avalon_req.address = {lsu_address[`DATA_WIDTH-1:2], 2'b00}; // make it aligned to word boundary

    // read latency is 1 so the data will be ready one cycle after the read is taken
    always @(posedge clk) begin
        if (rst) lsu_readdata_valid <= 1'b0;
        else lsu_readdata_valid <= dbus_avalon_req.read & ~dbus_avalon_resp.waitrequest;
    end

    // --  write data generation  -- //
    always @* begin
        dbus_avalon_req.writedata = lsu_writedata;
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_WORD: dbus_avalon_req.writedata = lsu_writedata;
            `CORE_MEM_HALF: dbus_avalon_req.writedata = {2{lsu_writedata[15:0]}};
            default:        dbus_avalon_req.writedata = {4{lsu_writedata[7:0]}};

        endcase
    end

    // --  Read data generation  -- //

    // store the byte address and the memory opcode
    always @(posedge clk) begin
        if (lsu_mem_read) begin
            prev_byte_addr <= lsu_address[1:0];
            prev_mem_opcode <= lsu_mem_opcode;
        end
    end

    // 000  LB *
    // 001  LH *
    // 010  LW *
    // 100  LBU
    // 101  LHU
    // opcode[2] is zero for signed extension
    assign sign_ext = ~prev_mem_opcode[2];
    assign sign_bit_final = sign_bit & sign_ext;

    // we assume that the memory does not align the read data with the address.
    // so we need to re-align the data with address here.
    always @(*) begin
        sign_bit = 0;
        case(prev_mem_opcode[1:0])
            `CORE_MEM_WORD: begin // LW
                lsu_readdata = dbus_avalon_resp.readdata;
            end
            `CORE_MEM_HALF: begin   // LH/LHU
                case(prev_byte_addr[1])
                    1'b0: lsu_readdata[15:0] = dbus_avalon_resp.readdata[15:0];
                    1'b1: lsu_readdata[15:0] = dbus_avalon_resp.readdata[31:16];
                endcase
                case(prev_byte_addr[1])
                    1'b0: sign_bit = dbus_avalon_resp.readdata[15];
                    1'b1: sign_bit = dbus_avalon_resp.readdata[31];
                endcase
                lsu_readdata[31:16] = {16{sign_bit_final}};
            end
            default: begin  // LB/LBU
                case(prev_byte_addr)
                    2'b00: lsu_readdata[7:0] = dbus_avalon_resp.readdata[7:0];
                    2'b01: lsu_readdata[7:0] = dbus_avalon_resp.readdata[15:8];
                    2'b10: lsu_readdata[7:0] = dbus_avalon_resp.readdata[23:16];
                    2'b11: lsu_readdata[7:0] = dbus_avalon_resp.readdata[31:24];
                endcase
                case(prev_byte_addr)
                    2'b00: sign_bit = dbus_avalon_resp.readdata[7];
                    2'b01: sign_bit = dbus_avalon_resp.readdata[15];
                    2'b10: sign_bit = dbus_avalon_resp.readdata[23];
                    2'b11: sign_bit = dbus_avalon_resp.readdata[31];
                endcase
                lsu_readdata[31:8] = {24{sign_bit_final}};
            end
        endcase
    end

    // -- byte enable generation -- //
    always @(*) begin
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_HALF: dbus_avalon_req.byte_enable = lsu_address[1] ? 4'b1100 : 4'b0011;   // LH
            `CORE_MEM_WORD: dbus_avalon_req.byte_enable = 4'b1111;                              // LW
            default: dbus_avalon_req.byte_enable = (4'b1 << lsu_address[1:0]);                  // LW
        endcase
    end

    // -- check address misalign -- //

    assign word_aligned = (lsu_address[1:0] == 2'b00);
    assign halfword_aligned = ~lsu_address[0];

    always @(*) begin
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_WORD: addr_misaligned = ~word_aligned;
            `CORE_MEM_HALF: addr_misaligned = ~halfword_aligned;
            default: addr_misaligned = 1'b0;
        endcase
    end

    assign lsu_exception_load_addr_misaligned = addr_misaligned & lsu_mem_read;
    assign lsu_exception_store_addr_misaligned = addr_misaligned & lsu_mem_write;

endmodule
