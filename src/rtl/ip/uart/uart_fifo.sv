/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/07/2022
 * ---------------------------------------------------------------
 * Uart FIFO
 * ---------------------------------------------------------------
 * Read latency is 0
 * ---------------------------------------------------------------
 */


module uart_fifo #(
    parameter WIDTH = 32,           // Data width
    parameter DEPTH = 4,            // FIFO depth
    parameter AWIDTH = $clog2(DEPTH)
) (
    input                       rst,
    input                       clk,
    input                       push,
    input                       pop,
    input [WIDTH-1:0]           din,
    output logic [WIDTH-1:0]    dout,
    output                      full,
    output                      empty,
    output [AWIDTH:0]           entry
);



    reg [WIDTH-1:0]     mem[2**AWIDTH-1:0];     // Only this style works in vivado.
    reg [AWIDTH:0]      rdptr;
    reg [AWIDTH:0]      wtptr;

    logic               ren;
    logic               wen;
    logic [AWIDTH:0]    wrptr_minus_rdptr;

    // --------------------------------
    // FIFO control logic
    // --------------------------------
    always @(posedge clk) begin
        if (rst) begin
            rdptr <= 'b0;
            wtptr <= 'b0;
        end
        else begin
            if (ren) begin
                rdptr <= rdptr + 1'b1;
            end
            if (wen) begin
                wtptr <= wtptr + 1'b1;
            end
        end
    end

    assign wen = ~full & push;
    assign ren = ~empty & pop;

    assign wrptr_minus_rdptr = wtptr - rdptr;
    assign full  = wrptr_minus_rdptr == DEPTH;
    assign empty = wrptr_minus_rdptr == 0;
    assign entry = wrptr_minus_rdptr;

    // --------------------------------
    // RAM control logic
    // --------------------------------
    always @(posedge clk) begin
        if (wen)
        begin
            mem[wtptr[AWIDTH-1:0]] <= din;
        end
    end

    always @* begin
        dout = mem[rdptr[AWIDTH-1:0]];
    end

endmodule