# README

This directory contains cocotb functions to run **riscv-tests** and check the results

## Prerequisites

The riscv-tests needs to be compiled to generate the content for instruction memory and data memory.

Go to `veriRISCV/tests/riscv-tests` to figure out how to compile and generate the memory contents. Check the README.md file there.

## Usage

- `RVTestsUtils.py`: This file provide the generic test function used in cocotb.
- `GenTests.py`: This file generate another python script `RVTests.py` which contains the test function for each instruction.
- `RVTests.py`: This file contains all the test function to be used in cocotb.

1. Generate `RVTests.py` with instruction you want to test.

    ```shell
    python GenTests.py
    ```

2. Run `make` command to run the test in cocotb

    ```shell
    make
    ```
