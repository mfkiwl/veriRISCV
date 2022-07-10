// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/09/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Avalon GPIO
// ------------------------------------------------------------------------------------------------

module avalon_gpio #(
    parameter W = 32
) (
    input           clk,
    input           rst,

    inout [W-1:0]   gpio,

    input           avn_read,
    input           avn_write,
    input [6:0]     avn_address,
    input [3:0]     avn_byte_enable,    // note: not used in this design
    input [31:0]    avn_writedata,
    output reg [31:0] avn_readdata,
    output          avn_waitrequest
);

    // --------------------------------------------
    //  Register logic
    // --------------------------------------------

    // -- register definations -- //

    // value 0x0
    reg [W-1:0]     value;

    // input_en 0x4
    reg [W-1:0]     input_en;

    // output_en 0x8
    reg [W-1:0]     output_en;

    // port 0xC
    reg [W-1:0]     port;

    // -- read logic -- //
    always @(posedge clk) begin
        case(avn_address)
        7'h00: avn_readdata <= value;
        7'h04: avn_readdata <= input_en;
        7'h08: avn_readdata <= output_en;
        7'h0C: avn_readdata <= port;
        default: avn_readdata <= value;
        endcase
    end

    // -- write logic -- //
    always @(posedge clk) begin
        if (rst) begin
            value <= 0;
            input_en <= 0;
            output_en <= 0;
            port <= 0;
        end
        else begin
            value <= (gpio & input_en) | (value & ~input_en);
            if (avn_write) begin
                case(avn_address)
                7'h00: value <= avn_writedata;
                7'h04: input_en <= avn_writedata;
                7'h08: output_en <= avn_writedata;
                7'h0C: port <= avn_writedata;
                default: ;
                endcase
            end
        end
    end

    // --------------------------------------------
    //  Main logic
    // --------------------------------------------

    assign avn_waitrequest = 0;

    genvar i;
    generate
        for (i = 0; i < 31; i++)
            assign gpio[i] = output_en[i] ? port[i] : 1'bz;
    endgenerate

endmodule
