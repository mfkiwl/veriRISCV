// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/29/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Instruction fetch unit
// ------------------------------------------------------------------------------------------------

/**

The Instruction fetch unit contrains an instruction fetch queue (IFQ) and a program counter (pc)

The instruction fetch queue is a simply a FIFO.
- When the FIFO has space, we fetch the next instruction pointed by PC
  from instruction bus and then push the instruction and its PC into the FIFO.
- When the FIFO is not empty and IF stage is not stalled, we read the next instruction from the FIFO.
- If we have a taken branch or a trap, HDU will issue if_flush to IF stage, then the FIFO content will be flushed
  by resetting its read and write pointer.

*/

`include "core.svh"

module ifu #(
    parameter IFQ_DEPTH = 4,    // instruction fetch queue depth
    parameter IFQ_AFULL_TH = 1  // instruction fetch queue almost full threshold
)(
    input                       clk,
    input                       rst,
    // ifu control
    input                       ifu_flush,
    input                       ifu_stall,
    // pc transfer
    input                       branch_take,
    input  [`PC_RANGE]          branch_pc,
    input                       trap_take,
    input [`PC_RANGE]           trap_pc,
    // output instruction and pc
    output logic [`DATA_RANGE]  instruction,
    output logic [`DATA_RANGE]  instruction_pc,
    output logic                instruction_valid,
    // instruction bus
    output avalon_req_t         ibus_avalon_req,
    input  avalon_resp_t        ibus_avalon_resp
);

    // ---------------------------------
    // Signal Declaration
    // ---------------------------------

    // instruction fetch queue
    localparam IFQ_AWIDTH = $clog2(IFQ_DEPTH);
    localparam IFQ_WIDTH  = `DATA_WIDTH * 2;

    reg [IFQ_WIDTH-1:0]     ifq_mem[IFQ_DEPTH-1:0];
    reg [IFQ_WIDTH-1:0]     ifq_mem_dout;
    reg [IFQ_AWIDTH:0]      ifq_rdptr;
    reg [IFQ_AWIDTH:0]      ifq_wtptr;
    reg                     ifq_wen;

    logic [IFQ_WIDTH-1:0]   ifq_mem_din;
    logic                   ifq_ren;
    logic                   ifq_afull;
    logic                   ifq_empty;
    logic [IFQ_AWIDTH:0]    ifq_wrptr_minus_rdptr;

    // PC
    reg [`PC_RANGE]         pc;
    reg [`PC_RANGE]         pending_pc;
    reg                     pending_pc_valid;

    // FLUSH
    reg                     flush_pending_read;

    // other signals
    reg [`DATA_RANGE]       current_pc;
    logic                   ibus_read_fire;

    // ---------------------------------
    // main logic
    // ---------------------------------

    // IBUS logic

    assign ibus_avalon_req.write       = 1'b0;          // never write to instruction ram
    assign ibus_avalon_req.writedata   = 'b0;
    assign ibus_avalon_req.address     = pc;            // instruction ram address is PC
    assign ibus_avalon_req.byte_enable = 4'b1111;

    // when instruction queue is not afull, read the instruction memory
    assign ibus_avalon_req.read        = ~rst & ~ifq_afull;

    // PC logic

    // Corner Case: For a taken branch or a trap, we should not take the new pc when the ibus is busy
    // because we need to keep the address stable after we initiate the bus request for avalon bus.
    // To deal with this corner case, we introduced a pending pc here.
    // The target pc will be stored in pending pc buffer if we can't take the pc right now.
    // The pending pc will be loaded into pc when the current bus request completes

    always @(posedge clk) begin
        if (rst) pending_pc_valid <= 1'b0;
        if ((trap_take || branch_take) && ibus_avalon_resp.waitrequest) pending_pc_valid <= 1'b1;
        else if (pending_pc_valid && !ibus_avalon_resp.waitrequest) pending_pc_valid <= 1'b0;
    end

    always @(posedge clk) begin
        if (trap_take && ibus_avalon_resp.waitrequest) pending_pc <= trap_pc;
        else if (branch_take && ibus_avalon_resp.waitrequest) pending_pc <= branch_pc;
    end

    always @(posedge clk) begin
        if (rst) pc <= 0;
        else begin
            // we only update PC when the bus is not busy
            if (!ibus_avalon_resp.waitrequest) begin
                if (trap_take) pc <= trap_pc;
                else if (branch_take) pc <= branch_pc;
                else if (pending_pc_valid) pc <= pending_pc;
                else if (ibus_avalon_req.read) pc <= pc + 4;
            end
        end
    end

    // IFQ logic

    // IFQ stores the instruction and its corresponding pc. IFQ is just a FIFO.

    assign ifq_wrptr_minus_rdptr = ifq_wtptr - ifq_rdptr;
    assign ifq_empty = ifq_wrptr_minus_rdptr == 0;
    assign ifq_ren = ~ifq_empty & ~ifu_stall;

    // We use afull (almost full) instead of full because when we initiate a read to instruction bus, the read data
    // come back after few cycles (>=1), so we need to give buffers in the FIFO to take the read data.
    assign ifq_afull  = ifq_wrptr_minus_rdptr >= IFQ_DEPTH - IFQ_AFULL_TH;

    always @(posedge clk) begin
        if (rst) ifq_wen <= 0;
        else ifq_wen <= ibus_read_fire & ~flush_pending_read & ~ifu_flush;
    end

    always @(posedge clk) begin
        if (rst) begin
            ifq_rdptr <= 'b0;
            ifq_wtptr <= 'b0;
        end
        else begin
            if (ifu_flush) begin
                ifq_rdptr <= 'b0;
                ifq_wtptr <= 'b0;
            end
            else begin
                if (ifq_ren) ifq_rdptr <= ifq_rdptr + 1'b1;
                if (ifq_wen) ifq_wtptr <= ifq_wtptr + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (ifq_wen) ifq_mem[ifq_wtptr[IFQ_AWIDTH-1:0]] <= ifq_mem_din;
    end

    always @(posedge clk) begin
        if (ifq_ren) ifq_mem_dout <= ifq_mem[ifq_rdptr[IFQ_AWIDTH-1:0]];
    end

    // we need to store the pc into a register to match the latency of the read data. (instruction)
    always @(posedge clk) current_pc <= pc;
    assign ifq_mem_din = {ibus_avalon_resp.readdata, current_pc};

    // Flush logic

    // If we are flusing the IF stage then we flush the IFQ.
    // If we have a instruction bus read request with waitrequest asserted at this time, flush will not flush the
    // read request because avalon bus need the request to be stable when waitrequest is asserted.
    // So we need to prevent the current read result being pushed into the IFQ.
    // This is achieved by adding a flush_pending_read signal.
    // If flush_pending_read is set then ifq_wen will not be set.
    always @(posedge clk) begin
        if (rst) flush_pending_read <= 1'b0;
        else if (ifu_flush && ibus_avalon_resp.waitrequest) flush_pending_read <= 1'b1;
        else if (ibus_read_fire) flush_pending_read <= 1'b0;
    end

    // Output Instructions from IFU

    assign {instruction, instruction_pc} = ifq_mem_dout;

    always @(posedge clk) begin
        if (rst) instruction_valid <= 1'b0;
        else begin
            instruction_valid <= 1'b0;      // default is not valid
            if (ifu_flush) instruction_valid <= 1'b0;   // flush make the valid 0
            else if (ifq_ren) instruction_valid <= 1'b1;    // if we read from IFQ then it's valid
            else if (ifu_stall) instruction_valid <= instruction_valid;
        end
    end

    // Other logic

    assign ibus_read_fire = ibus_avalon_req.read & ~ibus_avalon_resp.waitrequest;

    // ---------------------------------
    // Simulation only
    // ---------------------------------

    `ifdef COCOTB_SIM
    `ifdef COCOTB_LOG_INSTUCTION

        integer f1, f2;
        logic [31:0] previous_pc = 1;

        initial begin
            f1 = $fopen("instructions.log","w");
            f2 = $fopen("instructions_time.log","w");
        end

        always @(posedge clk) begin
            if (instruction_valid && instruction_pc != previous_pc) begin
                $fwrite(f1, "%10x | %10x\n", instruction_pc, instruction);
                $fwrite(f2, "%10x | %10x | %t\n", instruction_pc, instruction, $time);
                previous_pc = instruction_pc;
            end
        end

    `endif
    `endif

endmodule
