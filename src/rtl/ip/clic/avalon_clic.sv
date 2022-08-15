// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM CLIC (Core Level Interrupt Controller)
// ------------------------------------------------------------------------------------------------
//
//   ---   CLIC Register Map   ---
// Address      Width   Attr.   Name        Description Notes
// 0x00          4B      RW     msip        hart 0 MSIP Registers
// 0x10          8B      RW     mtimecmp    hart 0 Timer compare register
// 0x18          8B      RO     mtime       Timer register
//
// ------------------------------------------------------------------------------------------------

module avalon_clic (
    input               clk,
    input               rst,

    input               avn_read,
    input               avn_write,
    input [4:0]         avn_address,
    input [31:0]        avn_writedata,
    output reg [31:0]   avn_readdata,
    output              avn_waitrequest,

    output reg          timer_interrupt,
    output              software_interrupt
);

    // --------------------------------------------
    //  Register logic
    // --------------------------------------------

    // -- register definations -- //

    reg msip;               // 0x0
    reg [63:0] mtimecmp;    // 0x10
    reg [63:0] mtime;       // 0x18

    logic msip_write;
    logic mtimecmp_write_0;
    logic mtimecmp_write_1;
    logic mtime_write_0;
    logic mtime_write_1;

    // -- read logic -- //

    always @(posedge clk) begin
        /* verilator lint_off CASEINCOMPLETE */
        case(avn_address)
        /* verilator lint_on CASEINCOMPLETE */
        5'h00: avn_readdata <= {31'b0, msip};
        5'h10: avn_readdata <= mtimecmp[31:0];
        5'h14: avn_readdata <= mtimecmp[63:32];
        5'h18: avn_readdata <= mtime[31:0];
        5'h1C: avn_readdata <= mtime[63:32];
        endcase
    end

    // -- write logic -- //

    // write enable for each register
    always @* begin
        msip_write = 0;
        mtimecmp_write_0 = 0;
        mtimecmp_write_1 = 0;
        mtime_write_0 = 0;
        mtime_write_1 = 0;
        /* verilator lint_off CASEINCOMPLETE */
        case(avn_address)
        /* verilator lint_on CASEINCOMPLETE */
        5'h00: msip_write = avn_write;
        5'h10: mtimecmp_write_0 = avn_write;
        5'h14: mtimecmp_write_1 = avn_write;
        5'h18: mtime_write_0 = avn_write;
        5'h1C: mtime_write_1 = avn_write;
        endcase
    end

    always @(posedge clk) begin
        if (rst) msip <= 1'b0;
        else if (msip_write) msip <= avn_writedata[0];
    end


    always @(posedge clk) begin
        if (rst) mtimecmp <= 'b0;
        else if (mtimecmp_write_0) mtimecmp[31:0] <= avn_writedata;
        else if (mtimecmp_write_1) mtimecmp[63:32] <= avn_writedata;
    end


    always @(posedge clk) begin
        if (rst) mtime <= 'b0;
        else if (mtime_write_0) mtime[31:0] <= avn_writedata;
        else if (mtime_write_1) mtime[63:32] <= avn_writedata;
        else mtime <= mtime + 1'b1;
    end

    assign software_interrupt = msip;
    always @(posedge clk) timer_interrupt <= (mtime >= mtimecmp) & (mtimecmp != 0);

    assign avn_waitrequest = 0;

endmodule