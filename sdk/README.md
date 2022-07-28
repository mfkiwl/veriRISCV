# SDK

This folder contains a simple, light-weight software development kit (SDK) for running C program in veriRISCV SoC.

## Requirements

- **GNU MCU Eclipse RISC-V Embedded GCC** is used to compile the C code into RISC-V ISA using newlib as the C standard library.
- **Python3** is used to run the script to download program to the FPGA board

## Directory

Here is the directory structure for the veriRISCV SDK

```console
├── bsp
│   ├── drivers
│   ├── env
│   └── tools
├── makefile
├── README.md
└── software
```

- **bsp**

  This directory contains the board support package

  - **drivers** driver code for various peripherals
  - **env** various system and environment code including linker scripts, boot code and start up code, newlib functions, etc.
  - **tools** some useful programs

- **software**

  This directory contains various software programs

  - **blink** Blink the FPGA LED
  - **hello_riscv** Print the "hello world" message using printf
  - **fibonacci** Calculate some fibonacci numbers and print the result in the screen
  - **coremark** coremark tests


## How to use

A makefile based flow is provided to compile and run program in target FPGA board.

```shell
$ make help

 veriRISCV Processor Software Development Kit

 software [PROGRAM=blink BOARD=de2]:
    Build a software program to load with the debugger.

 uart_upload [PROGRAM=blink BOARD=de2]:
    Launch UartDownload script to flash your program to the on-board Memory/Flash.

 dasm [PROGRAM=de2]:
     Generates the dissassembly output of 'objdump -D' to stdout.
```

Some pre-defined make target can help speed up the process. For example:

```shell
# compile and de-assemble blink program with de2 board setup
$ make blink

# upload the blink program to FPGA with de2 board
$ make upload_blink
```

## Acknowledgements

The SDK is designed based on the [SI-RISCV/hbird-e-sdk](https://github.com/SI-RISCV/hbird-e-sdk)

The directory structure, boot and start up code, linker scripts, and the makefile flows are designed based on the hbird-e-sdk with some modifications to suit the veriRISCV design.
