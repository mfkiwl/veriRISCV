// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 06/28/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon MM ram 1rw
// ------------------------------------------------------------------------------------------------

module avalon_ram_1rw #(
    parameter AW = 10,
    parameter DW = 32
) (
    input               clk,
    input               read,
    input               write,
    input [AW-1:0]      address,        // this is the word size
    input [DW/8-1:0]    byte_enable,
    input [DW-1:0]      writedata,
    output reg [DW-1:0] readdata,
    output              waitrequest
);


    reg [DW-1:0] ram[0:(1<<AW)-1];

    always @(posedge clk) begin
        if (write) ram[address] <= writedata;
        if (read) readdata <= ram[address];
    end

endmodule
