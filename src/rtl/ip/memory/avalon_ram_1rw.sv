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
    parameter DW = 32   // only support DW = 32 for now
) (
    input               clk,
    input               read,           // not used
    input               write,
    input [AW-1:0]      address,        // this is the word size
    input [DW/8-1:0]    byte_enable,
    input [DW-1:0]      writedata,
    output [DW-1:0]     readdata,
    output              waitrequest
);

    localparam RAM_DEPTH = 2 ** AW;
    localparam BYTE_WIDTH = 8;
    localparam NUM_BYTES = DW / BYTE_WIDTH;

    assign waitrequest = 1'b0;

`ifdef COCOTB_SIM

    reg [DW-1:0] ram[RAM_DEPTH-1:0];
    reg [DW-1:0] data;

    always @(posedge clk) begin
        if(write) begin
            for (int i = 0; i < NUM_BYTES; i = i + 1) begin
                if(byte_enable[i]) ram[address][i*BYTE_WIDTH +: BYTE_WIDTH] <= writedata[i*BYTE_WIDTH +: BYTE_WIDTH];
            end
        end
        data <= ram[address];
    end

    assign readdata = data;

`elsif VIVADO

    // use seperate ram for each byte

    reg [BYTE_WIDTH-1:0] ram0[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram1[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram2[RAM_DEPTH-1:0];
    reg [BYTE_WIDTH-1:0] ram3[RAM_DEPTH-1:0];

    reg [BYTE_WIDTH-1:0] data0;
    reg [BYTE_WIDTH-1:0] data1;
    reg [BYTE_WIDTH-1:0] data2;
    reg [BYTE_WIDTH-1:0] data3;

    always @(posedge clk) begin
        if(write) begin
            if(byte_enable[0]) ram0[address] <= writedata[7:0];
            if(byte_enable[1]) ram1[address] <= writedata[15:8];
            if(byte_enable[2]) ram2[address] <= writedata[23:16];
            if(byte_enable[3]) ram3[address] <= writedata[31:24];
        end
        data0 <= ram0[address];
        data1 <= ram1[address];
        data2 <= ram2[address];
        data3 <= ram3[address];
    end

    assign readdata = {data3,data2,data1,data0};

`else

    reg [NUM_BYTES-1:0][BYTE_WIDTH-1:0] ram[RAM_DEPTH-1:0];
    reg [DW-1:0] data;

    always @(posedge clk) begin
        if(write) begin
            if(byte_enable[0]) ram[address][0] <= writedata[7:0];
            if(byte_enable[1]) ram[address][1] <= writedata[15:8];
            if(byte_enable[2]) ram[address][2] <= writedata[23:16];
            if(byte_enable[3]) ram[address][3] <= writedata[31:24];
        end
        data <= ram[address];
    end

    assign readdata = data;

`endif

endmodule

/*

    This template does not work because the memory is too big

    // Taken from vivado templates
    localpra INIT_FILE = "";

    reg [(NUM_BYTES*BYTE_WIDTH)-1:0] ram [RAM_DEPTH-1:0];
    reg [(NUM_BYTES*BYTE_WIDTH)-1:0] data = {(NUM_BYTES*BYTE_WIDTH){1'b0}};

    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") begin: use_init_file
        initial
            $readmemh(INIT_FILE, ram, 0, RAM_DEPTH-1);
        end else begin: init_bram_to_zero
        integer ram_index;
        initial
            for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            ram[ram_index] = {(NUM_BYTES*BYTE_WIDTH){1'b0}};
        end
    endgenerate

    generate
    genvar i;
        for (i = 0; i < NUM_BYTES; i = i+1) begin: byte_write
        always @(posedge clk)
            if (write)
            if (byte_enable[i]) begin
                ram[address][(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH] <= writedata[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH];
                data[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH] <= writedata[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH];
            end else
                data[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH] <= ram[address][(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH];
        end
    endgenerate

    assign readdata = data;

*/