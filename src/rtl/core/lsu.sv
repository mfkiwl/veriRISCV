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

// The LSU is located at the memory stage but the logic is actually across the EX and MEM stage
// We assume that the memory has an input or output register which act as a hidden pipeline stage
// The request is sent to memory at EX stage and the data comes back at the MEM stage

`include "core.svh"

module lsu (
    input                           clk,
    input                           rst,
    // input from core logic
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
    output logic                    lsu_readdatavalid,
    // exception
    output logic                    exception_load_addr_misaligned,
    output logic                    exception_store_addr_misaligned
);

    reg [1:0]                       prev_byte_addr;
    reg [`CORE_MEM_OP_RANGE]        prev_mem_opcode;

    reg                             sign_bit;
    wire                            sign_bit_final;
    wire                            sign_ext;
    wire                            word_aligned;
    wire                            halfword_aligned;

    // ---------------------------------
    // logic
    // ---------------------------------

    assign dbus_avalon_req.write = lsu_mem_write;
    assign dbus_avalon_req.read = lsu_mem_read;
    assign dbus_avalon_req.address = lsu_address;

    // FIXME waitrequest


    // --  write data generation  -- //
    // The writedata should be aligned alrady
    assign dbus_avalon_req.writedata = lsu_writedata;

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
            `CORE_MEM_HALF: dbus_avalon_req.byte_enable = prev_byte_addr[1] ? 4'b1100 : 4'b0011;    // LH
            `CORE_MEM_WORD: dbus_avalon_req.byte_enable = 4'b1111;                                  // LW
            default: dbus_avalon_req.byte_enable = (4'b1 << prev_byte_addr);                        // LW
        endcase
    end

    // -- check address misalign -- //

    assign word_aligned = (lsu_address[1:0] == 2'b00);
    assign halfword_aligned = ~lsu_address[0];

    always @(*) begin
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_WORD: exception_store_addr_misaligned = ~word_aligned;
            `CORE_MEM_HALF: exception_store_addr_misaligned = ~halfword_aligned;
            default: exception_store_addr_misaligned = 1'b0;
        endcase
    end
    always @(*) begin
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_WORD: exception_load_addr_misaligned = ~word_aligned;
            `CORE_MEM_HALF: exception_load_addr_misaligned = ~halfword_aligned;
            default: exception_store_addr_misaligned = 1'b0;
        endcase
    end

endmodule

// backup:

    /*
    // align the data with address
    always @(posedge clk) begin
        case(lsu_mem_opcode[1:0])
            `CORE_MEM_WORD: begin   // SW
                dbus_avalon_req.writedata = lsu_writedata;
            end
            `CORE_MEM_HALF: begin   // SH
                case(prev_byte_addr[1])
                    1'b0: dbus_avalon_req.writedata <= {2{lsu_writedata[15:0]}};
                    1'b1: dbus_avalon_req.writedata <= {2{lsu_writedata[31:16]}};
                endcase
            end
            default: begin          // SB
                case(lsu_address[1:0])
                    2'b00: dbus_avalon_req.writedata <= {4{lsu_writedata[7:0]}};
                    2'b01: dbus_avalon_req.writedata <= {4{lsu_writedata[15:8]}};
                    2'b10: dbus_avalon_req.writedata <= {4{lsu_writedata[23:16]}};
                    2'b11: dbus_avalon_req.writedata <= {4{lsu_writedata[31:24]}};
                endcase
            end
        endcase
    end
    */