// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM PLIC (Platform Level Interrupt Controller)
// ------------------------------------------------------------------------------------------------
//
// Currently PLIC support 32 different interrupt
// All the interrupts are treated equally.
//
//   ---   PLIC Register Map   ---
// Address      Width   Attr.   Name            Description Notes
//  0x0         32      RW      mint_enable     machine level interrupt enable
//  0x4         32      RO      mint            machine level interrupt register
// ------------------------------------------------------------------------------------------------

module avalon_plic (
    input               clk,
    input               rst,

    input               avn_read,
    input               avn_write,
    input [3:0]         avn_address,
    input [31:0]        avn_writedata,
    output reg [31:0]   avn_readdata,
    output              avn_waitrequest,

    input [31:0]        plic_interrupt_in,
    output reg          external_interrupt
);

    // --------------------------------------------
    //  Register logic
    // --------------------------------------------

    // -- register definations -- //

    reg [31:0] mint_enable;     // 0x0
    reg [31:0] mint;            // 0x4

    logic mint_enable_write;

    // -- read logic -- //

    always @(posedge clk) begin
        /* verilator lint_off CASEINCOMPLETE */
        case(avn_address)
        /* verilator lint_on CASEINCOMPLETE */
        4'h0: avn_readdata <= mint_enable;
        4'h4: avn_readdata <= mint;
        endcase
    end

    // -- write logic -- //

    // write enable for each register
    always @* begin
        mint_enable_write = 0;
        /* verilator lint_off CASEINCOMPLETE */
        case(avn_address)
        /* verilator lint_on CASEINCOMPLETE */
        4'h0: mint_enable_write = avn_write;
        endcase
    end

    always @(posedge clk) begin
        if (rst) mint_enable <= 0;
        else if (mint_enable_write) mint_enable <= avn_writedata;
    end

    // --------------------------------------------
    //  Main logic
    // --------------------------------------------

    logic [31:0] interrupt_masked;

    assign interrupt_masked = plic_interrupt_in & mint_enable;

    always @(posedge clk) mint <= interrupt_masked;

    always @(posedge clk) external_interrupt <= |interrupt_masked;

    assign avn_waitrequest = 0;


endmodule