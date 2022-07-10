OUTPUT_ARCH( "riscv" )

ENTRY(_start)

MEMORY
{
    ram(wxa): ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    /*__stack_size = DEFINED(__stack_size) ? __stack_size : 2K; */

    .init :
    {
        . = ALIGN(4);
        _einit = .;
    } >ram

    .text :
    {
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
        _etext = .;
    } >ram

    .data :
    {
        _sdata = .;
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    } >ram

    .bss :
    {
        _sbss = .;
        *(.bss)
        *(.bss.*)
        . = ALIGN(4);
        _ebss = .;
    } >ram

}
