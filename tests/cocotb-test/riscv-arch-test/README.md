# README

This directory contains cocotb functions to run **riscv-arch-test** and check the results

## Prerequisites

The riscv-tests needs to be compiled to generate the content for instruction memory and data memory.

Go to `veriRISCV/tests/riscv-isa/riscv-arch-test` to figure out how to compile and generate the memory contents. Check the README.md file there.

## Usage

- `TestsUtils.py`: This file provide the generic test function used in cocotb.
- `GenTests.py`: This file generate another python script `Tests.py` which contains the test function for each instruction.
- `Tests.py`: This file contains all the test function to be used in cocotb.

1. Generate `Tests.py` with instruction you want to test.

    ```shell
    python GenTests.py
    ```

2. Run `make` command to run the test in cocotb

    ```shell
    make
    ```
