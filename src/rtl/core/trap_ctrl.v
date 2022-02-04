///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
//
// ~~~ veriRISCV ~~~
//
// Module Name: trap_ctrl
//
// Author: Heqing Huang
// Date Created: 01/29/2022
//
// ================== Description ==================
//
// Trap control module
//
// Only support machine mode for now
//
///////////////////////////////////////////////////////////////////////////////////////////////////

`include "core.vh"
`include "veririscv_core.vh"

module trap_ctrl (
    input                   clk,
    input                   rst,
    // input information
    input [`PC_RANGE]       pc,
    input [`DATA_RANGE]     fault_address,
    input [`DATA_RANGE]     fault_instruction,
    // Interrupt
    input                   software_interrupt,
    input                   timer_interrupt,
    input                   external_interrupt,
    input                   debug_interrupt,
    // Exception
    input                   exc_instr_addr_misaligned,
    input                   exc_ill_instr,
    input                   exc_load_addr_misaligned,
    input                   exc_store_addr_misaligned,
    // take_trap return
    input                   mret,
    // input from mcsr module
    input [`DATA_WIDTH-3:0] i_mtvec_base,
    input [1:0]             i_mtvec_mode,
    input                   i_mstatus_mie,
    input                   i_mstatus_mpie,
    input [`PC_RANGE]       i_mepc_value,
    // output to mcsr module
    output [30:0]           o_mcause_exception_code,
    output                  o_mcause_interrupt,
    output [`DATA_RANGE]    o_mepc_value,
    output [`DATA_RANGE]    o_mtval_value,
    output                  o_mstatus_mie,
    output                  o_mstatus_mpie,
    output [1:0]            o_mstatus_mpp,
    // output control
    output                  take_trap,
    output [`PC_RANGE]      target_pc
);

    wire [`PC_RANGE]        vectored_pc;
    wire                    use_vectored_pc;

    wire                    is_exception;
    wire                    is_interrupt;
    wire                    exception_enter;
    wire                    interrupt_enter;
    wire                    trap_return;
    wire                    trap_enter;

    reg [`DATA_WIDTH-2:0]   exception_code;
    reg [`DATA_WIDTH-2:0]   interrupt_code;
    wire [3:0]              oh_exception_sel;
    wire [2:0]              oh_interrupt_sel;
    wire [`DATA_WIDTH-2:0]  mcause_exception_code;

    wire    mtval_addr_misalign;


    ////////////////////////////////////////
    // Check interruption
    ////////////////////////////////////////

    assign is_exception = exc_instr_addr_misaligned | exc_ill_instr | exc_load_addr_misaligned | exc_store_addr_misaligned;
    assign is_interrupt = software_interrupt | timer_interrupt | external_interrupt | debug_interrupt;
    assign exception_enter = i_mstatus_mie & is_exception;
    assign interrupt_enter = i_mstatus_mie & is_interrupt;
    assign trap_enter = exception_enter | interrupt_enter;
    assign trap_return = mret;
    assign take_trap = trap_enter | trap_return;

    ////////////////////////////////////////
    // PC address generation
    ////////////////////////////////////////

    // When MODE=Direct, all traps into machine mode cause the pc to be set to the address in the BASE field.
    // When MODE=Vectored, all synchronous exceptions into machine mode cause the pc to be set to the address
    // in the BASE field, whereas interrupts cause the pc to be set to the address in the BASE field plus
    // four times the interrupt cause number.

    assign vectored_pc = {2'b0, i_mtvec_base} + {interrupt_code[`DATA_WIDTH-4:0], 3'b0};
    assign use_vectored_pc = (i_mtvec_mode == 2'b01) & is_interrupt;
    assign target_pc = trap_return ? i_mepc_value :
                       use_vectored_pc ? vectored_pc : {2'b0, i_mtvec_base};

    ////////////////////////////////////////
    // exception code generation
    ////////////////////////////////////////
    assign oh_exception_sel = {exc_store_addr_misaligned,exc_load_addr_misaligned,exc_ill_instr,exc_instr_addr_misaligned};
    always @(*) begin
        case(oh_exception_sel)
            4'b0001: exception_code = 'd0;  // Instruction address misaligned
            4'b0010: exception_code = 'd1;  // Instruction access fault
            4'b0100: exception_code = 'd4;  // Load address misaligned
            4'b1000: exception_code = 'd6;  // Store/AMO address misaligned
            default: exception_code = 0;
        endcase
    end

    assign oh_interrupt_sel = {external_interrupt,timer_interrupt,software_interrupt};
    always @(*) begin
        case(oh_interrupt_sel)
            3'b001: interrupt_code = 'd3;       // machine software_interrupt
            3'b010: interrupt_code = 'd7;       // machine timer_interrupt
            3'b100: interrupt_code = 'd11;      // machine external_interrupt
            default: interrupt_code = 0;
        endcase
    end

    assign mcause_exception_code = is_interrupt ? interrupt_code : exception_code;

    // update mcause register
    assign o_mcause_exception_code = mcause_exception_code;
    assign o_mcause_interrupt = is_interrupt;

    ////////////////////////////////////////
    // update csr register
    ////////////////////////////////////////

    // update mepc register
    // When a take_trap is taken into M-mode, mepc is written with the virtual address of the instruction
    // that was interrupted or that encountered the exception.
    assign o_mepc_value = pc;

    // update mtval register
    // we only have fault address and fault instruction right now
    assign mtval_addr_misalign = exc_instr_addr_misaligned | exc_load_addr_misaligned | exc_store_addr_misaligned;
    assign o_mtval_value = mtval_addr_misalign ? fault_address : fault_instruction;

    // update mie
    assign o_mstatus_mie = trap_enter ? 1'b0 : i_mstatus_mpie;

    // update mpie
    assign o_mstatus_mpie = trap_enter ? i_mstatus_mie : 1'b1;

    // update mpp
    assign o_mstatus_mpp = 2'b11; // only support machine mode

endmodule