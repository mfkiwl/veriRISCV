// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 08/06/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Divider for RISCV
// ------------------------------------------------------------------------------------------------

/**

The simpliest algorithm for divide operation for hardware is to mimic the Long division.
This divider design used the long division algorithm.

*/

`include "core.svh"

module divider (
    input                   clk,
    input                   rst,
    input                   req,
    input                   flush,
    input  [1:0]            opcode, // 2 bit is good enough
    input  [`DATA_RANGE]    a,      // rs1
    input  [`DATA_RANGE]    b,      // rs2
    output [`DATA_RANGE]    o,      // rd
    output                  stall
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    reg [1:0]                       stage_valid;
    reg                             running;
    logic                           new_req;
    logic                           done;

    reg [`DATA_RANGE]               dividend;
    reg [`DATA_RANGE]               divisor;
    reg [`DATA_RANGE]               quotient;
    reg                             is_rem; // 1 - REM/REMU, 0 - DIV/DIVU
    reg                             quotient_negate;
    reg                             remainder_negate;
    reg [$clog2(`DATA_WIDTH+1):0]   iterations;

    logic                           signed_div;
    logic                           dividend_sign_bit;
    logic                           divisor_sign_bit;
    logic [`DATA_RANGE]             dividend_unsign;
    logic [`DATA_RANGE]             divisor_unsign;
    logic                           not_divide_by_zero;

    logic [2*`DATA_WIDTH-1:0]       extended_dividend;
    logic [2*`DATA_WIDTH-1:0]       extended_divisor;
    logic [2*`DATA_WIDTH-1:0]       sub_result;
    logic                           sub_result_sign_bit;
    logic [`DATA_RANGE]             remainder;
    logic [`DATA_RANGE]             quotient_post;
    logic [`DATA_RANGE]             remainder_post;

    // ---------------------------------
    // Main logic
    // ---------------------------------

    // Process the input data and store it in the register

    assign new_req = req & ~running;

    // we use unsigned divider so for DIV/REM we need to convert NEGATIVE number to POSITIVE number
    assign dividend_sign_bit = a[`DATA_WIDTH-1];
    assign divisor_sign_bit = b[`DATA_WIDTH-1];

    assign dividend_unsign = ~a + 1'b1;
    assign divisor_unsign = ~b + 1'b1;

    assign signed_div = opcode[0] == 0; // DIV/REM => opcode[0] == 0
    assign not_divide_by_zero = b != 0;

    always @(posedge clk) begin
        if (new_req) begin
            // dividend is handled in later logic because it's need other operations
            divisor <= (signed_div && divisor_sign_bit) ? divisor_unsign : b;
            quotient_negate <= signed_div & (dividend_sign_bit ^ divisor_sign_bit) & not_divide_by_zero;
            remainder_negate <= signed_div & dividend_sign_bit;
            is_rem <= opcode[1];
        end
    end

    // Calculation process

    assign done = iterations == `DATA_WIDTH;
    // flow control
    always @(posedge clk) begin
        if (rst) running <= 1'b0;
        else if (flush) running <= 1'b0;
        else if (new_req) running <= 1'b1;
        else if (done) running <= 1'b0;
    end

    // we adjust the width of dividend and dividor to make them aligned for the subtraction.
    assign extended_dividend = {{`DATA_WIDTH{1'b0}}, dividend};
    assign extended_divisor = {1'b0, divisor, {(`DATA_WIDTH-1){1'b0}}};

    // we substract the dividend and divisor (similar to the long division)
    assign sub_result = extended_dividend - (extended_divisor >> iterations);
    assign sub_result_sign_bit = sub_result[2*`DATA_WIDTH-1];

    always @(posedge clk) begin
        if (rst) begin
            quotient <= 0;
            iterations <= 0;
        end
        else if (flush || new_req) begin
            quotient <= 0;
            iterations <= 0;
        end
        else if (running) begin
            // left shift by 1 position to push the previous bit to the left (This is mimic we move right in long division)
            quotient[`DATA_WIDTH-1:1] <= quotient[`DATA_WIDTH-2:0];
            // if subracting yield a positive number, then this position is a one othervise it is zero (similar to long division)
            quotient[0] <= (sub_result_sign_bit == 0) ? 1'b1 : 1'b0;
            iterations <= iterations + 1'b1;
        end
    end

    // handle dividen seperately
    always @(posedge clk) begin
        if (new_req) dividend <= (signed_div && dividend_sign_bit) ? dividend_unsign : a;
        // if subracting yield a positive number, then we update the dividend with the remaining data
        else dividend <= (sub_result_sign_bit == 0) ? sub_result[`DATA_RANGE] : dividend;
    end

    assign remainder = dividend;

    // Post process the result

    // adjust the sign of the result
    assign quotient_post = quotient_negate ? (~quotient + 1'b1) : quotient;
    assign remainder_post = remainder_negate ? (~remainder + 1'b1) : remainder;

    // assign the correct value to output
    assign o = is_rem ? remainder_post : quotient_post;

    assign stall = new_req | (running & ~done);

endmodule