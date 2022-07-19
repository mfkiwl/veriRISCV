// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM ram 1rw with 2 clock cycle to access the data.
// This ram is designed to match the avalon bus timing for using the external SRAM.
// ------------------------------------------------------------------------------------------------

module avalon_ram_1rw_2c #(
    parameter AW = 18,    // Input bus address
    parameter DW = 32     // Input bus data width
) (
    input               clk,
    input               rst,
    // Avalon interface bus
    input               read,
    input               write,
    input  [AW-1:0]     address,    // NOTE: the address is the word address instead of byte address
    input  [DW-1:0]     writedata,
    input  [DW/8-1:0]   byte_enable,
    output reg [DW-1:0] readdata,
    output reg          waitrequest
);

    // --------------------------------------------
    //  Signal Declaration
    // --------------------------------------------

    localparam DEPTH = 2 ** AW;
    localparam BYTE_WIDTH = 8;
    localparam NUM_BYTES = DW / BYTE_WIDTH;

    enum reg [1:0] {IDLE, ACCESS1, ACCESS2} state;

    logic           take_new_request;
    logic           new_request;
    reg [DW-1:0]    readdata_s0;

    // --------------------------------------------
    //  main logic
    // --------------------------------------------

    assign take_new_request = (state == IDLE) | (state == ACCESS2);
    assign new_request = read | write;

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

    assign waitrequest = take_new_request;

    always @(posedge clk) readdata <= readdata_s0;

`ifdef COCOTB_SIM

    reg [DW-1:0] ram[DEPTH-1:0];

    always @(posedge clk) begin
        if(write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(byte_enable[i]) ram[address][i*BYTE_WIDTH +: BYTE_WIDTH] <= writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        readdata_s0 <= ram[address];
    end

`else

    reg [NUM_BYTES-1:0][BYTE_WIDTH-1:0] ram[DEPTH-1:0];

    always @(posedge clk) begin
        if(write) begin
            if(byte_enable[0]) ram[address][0] <= writedata[7:0];
            if(byte_enable[1]) ram[address][1] <= writedata[15:8];
            if(byte_enable[2]) ram[address][2] <= writedata[23:16];
            if(byte_enable[3]) ram[address][3] <= writedata[31:24];
        end
        readdata_s0 <= ram[address];
    end

`endif

endmodule
