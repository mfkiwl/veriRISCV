/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 04/19/2022
 * ---------------------------------------------------------------
 * General SRAM controller with avalon inteface
 *
 * Note: The address of avalon MM interface is "WORD" address instead of "BYTE" address
 * ---------------------------------------------------------------
 */

module avalon_sram_controller #(
    parameter AVN_AW = 18,    // Input bus address
    parameter AVN_DW = 16,     // Input bus data width
    parameter SRAM_AW = 18,
    parameter SRAM_DW = 16
) (
    input                       clk,
    input                       rst,
    // Avalon interface bus
    input                       avn_read,
    input                       avn_write,
    input  [AVN_AW-1:0]         avn_address,    // NOTE: the address is the word address instead of byte address
    input  [AVN_DW-1:0]         avn_writedata,
    input  [AVN_DW/8-1:0]       avn_byteenable,
    output [AVN_DW-1:0]         avn_readdata,
    output reg                  avn_waitrequest,
    // sram interface
    output reg                  sram_ce_n,
    output reg                  sram_oe_n,
    output reg                  sram_we_n,
    output reg [SRAM_DW/8-1:0]  sram_be_n,
    output reg [SRAM_AW-1:0]    sram_addr,
    inout  [SRAM_DW-1:0]        sram_dq
);

generate

// Same data width between avalon bus and sram
if (AVN_DW == SRAM_DW) begin: x1

    // --------------------------------------------
    //  Signal Declaration
    // --------------------------------------------

    logic [AVN_DW-1:0]    sram_dq_write;
    logic                 sram_dq_en;

    reg                   avn_read_s0;
    reg                   avn_write_s0;
    reg  [AVN_AW-1:0]     avn_address_s0;
    reg  [AVN_DW-1:0]     avn_writedata_s0;
    reg  [AVN_DW/8-1:0]   avn_byteenable_s0;

    // --------------------------------------------
    //  main logic
    // --------------------------------------------

    assign sram_dq = sram_dq_en ? sram_dq_write : 'z;

    // register the user bus
    always @(posedge clk) begin
        if (rst) begin
            avn_read_s0 <= 0;
            avn_write_s0 <= 0;
        end
        else begin
            avn_read_s0 <= avn_read;
            avn_write_s0 <= avn_write;
        end
    end

    always @(posedge clk) begin
        avn_address_s0 <= avn_address;
        avn_writedata_s0 <= avn_writedata;
        avn_byteenable_s0 <= avn_byteenable;
    end

    // drive the sram interface
    assign sram_addr = avn_address_s0;
    assign sram_ce_n = ~(avn_read_s0 | avn_write_s0);
    assign sram_oe_n = ~avn_read_s0;
    assign sram_we_n = ~avn_write_s0;
    assign sram_be_n = ~avn_byteenable_s0;
    assign sram_dq_write = avn_writedata_s0;
    assign sram_dq_en = avn_write_s0;

    // read data to user bus
    assign avn_readdata = sram_dq;
    assign avn_waitrequest = 1'b0;
end

// avalon data width = 2 x sram data width
if (AVN_DW == SRAM_DW * 2) begin: x2

    // --------------------------------------------
    //  Signal Declaration
    // --------------------------------------------

    reg [SRAM_DW-1:0]       sram_dq_write;
    reg                     sram_dq_en;

    reg  [SRAM_DW-1:0]      writedata_2nd;
    reg  [SRAM_DW/8-1:0]    byteenable_2nd;
    reg  [SRAM_DW-1:0]      readdata_1st;

    enum reg [1:0] {IDLE, ACCESS1, ACCESS2} state;
    logic                   take_new_request;
    logic                   new_request;

    // --------------------------------------------
    //  main logic
    // --------------------------------------------

    assign take_new_request = (state == IDLE) | (state == ACCESS2);
    assign new_request = avn_read | avn_write;

    always @(posedge clk) begin
        if (rst) state <= IDLE;
        else begin
            case(state)
                IDLE: if (new_request)      state <= ACCESS1;
                ACCESS1:                    state <= ACCESS2;
                ACCESS2: if (new_request)   state <= ACCESS1;
                         else               state <= IDLE;
                default:                    state <= IDLE;
            endcase
        end
    end

    // register the user bus
    always @(posedge clk) begin
        if (rst) begin
            sram_ce_n <= 1'b1;
            sram_oe_n <= 1'b1;
            sram_we_n <= 1'b1;
            sram_dq_en <= 1'b0;
        end
        else if (take_new_request) begin
            sram_ce_n <= ~(avn_read | avn_write);
            sram_oe_n <= avn_write;
            sram_we_n <= ~avn_write;
            sram_dq_en <= avn_write;
        end
    end

    always @(posedge clk) begin
        if (take_new_request) begin
            sram_addr <= {avn_address[SRAM_AW-2:0], 1'b0}; // adjust the word address to half word address
                                                           // word size is defined as AVN_DW (may not be 32 bits)
            sram_dq_write <= avn_writedata[SRAM_DW-1:0];
            sram_be_n <= ~avn_byteenable[SRAM_DW/8-1:0];
            writedata_2nd <= avn_writedata[AVN_DW-1:SRAM_DW];
            byteenable_2nd <= avn_byteenable[AVN_DW/8-1:SRAM_DW/8];
        end
        else if (state == ACCESS1) begin
            sram_addr <= sram_addr + 1'b1;
            sram_dq_write <= writedata_2nd;
            sram_be_n <= ~byteenable_2nd;
        end
    end

    assign sram_dq = sram_dq_en ? sram_dq_write : 'z;

    always @(posedge clk) if (state == ACCESS1) readdata_1st <= sram_dq;
    assign avn_readdata = {sram_dq, readdata_1st};
    assign avn_waitrequest = take_new_request;
end

endgenerate

endmodule
