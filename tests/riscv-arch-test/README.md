# README

This folder contains the code to compile the riscv-arch-test to veriRISCV

## Generate the code

```shell
make build
```

The output (elf, objdump, verilog) will be placed at `riscv-arch-test/riscv-arch-test/work/<RUN_TARGET>/<DEVICE>`.

For example: `riscv-arch-test/riscv-arch-test/work/rv32i_m/I`

## How to Port a New Target Design

Reference: <https://github.com/riscv-non-isa/riscv-arch-test/tree/b436dd0939c968f2c3da86bb9b63bb2dfe03b134/doc#5-porting-a-new-target>

1. Create a RISCV_TARGET directory for your design

    ```shell
    cd veriRISCV/tests/riscv-arch-test
    mkdir veriRISCV
    ```

2. Now inside your TARGETDIR/RISCV_TARGET directory you will need to create the following files:

    - **model_test.h**: A header file containing the definition of the various target specific assembly macros that are required to compile and simulate the tests. The list and definition of the required target specific macros is available in the Test Format Specification
    - **link.ld**: A linker script to compile the tests for your target.

    Any other files required by the target (configuration scripts, logs, etc.) can also be placed in this directory.

3. Inside the `TARGETDIR/RISCV_TARGET` directory create a new folder named: `device`. If your device is a 32-bit target then create a directory `device/rv32i_m`. If your device is a 64-bit target then create a directory `device/rv64i_m`. If your target is configurable on the XLEN parameter then both the folders need to be created.

4. Within the `rv32i_m/rv64i_m` directories sub-folders in the name of the extensions supported by the target need to be created. For eg. A target supporting the ISA RV32IMC_Zifence will have the following directory structure:

    ```text
    rv32i_m/I
    rv32i_m/M
    rv32i_m/privilege
    rv32i_m/Zifencei
    ```

5. Each of the above extension directories will now need to include a file: `Makefile.include` which defines the following Makefile variables:

    `RUN_TARGET`:: This variable needs to include commands and steps to execute an ELF on target device. Note here that this variable should include all the necessary steps and arguments to run that specific test-suite. For example, in case of spike for the rv32i_m/C test-suite the corresponding Makefile.include has the --isa=rv32ic argument as opposed to just --isa=rv32i for the base rv32i_m/I test-suite. This variable should also include other steps to extract and sanitize the signature file as well for each test. The only argument available to this variable is the compiled elf file.

    `COMPILE_TARGET`:: This variable should include the commands and steps required to compile an assembly test for the target for each extension mentioned above. Note, currently only the GCC compiler is supported. This compiler takes march and mabi arguments from the corresponding architectural suite framework. COMPILE_TARGET will more or less be the same across test-suites. The only argument available to COMPILE_TARGET is the assembly file of one architectural test.

## Usage in my repo

In order to keep the repo clean, instead of keeping a copy of `riscv-arch-test` repo and putting my design related files in `riscv-arch-test/riscv-target`, I added `riscv-arch-test` as a git submodule and keep the design related files outside the repo.

When we want to build the design, we will need to copy or link our design folder (`veriRISCV` in my case) into `riscv-arch-test/riscv-target` and then run the corresponding make command in there. Here I have created a Makefile to do this automatically.

The output (elf, objdump, verilog) will be placed at `riscv-arch-test/riscv-arch-test/work/<RUN_TARGET>/<DEVICE>`. For example: `riscv-arch-test/riscv-arch-test/work/rv32i_m/I`
