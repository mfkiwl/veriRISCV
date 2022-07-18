OUTPUT_ARCH( "riscv" )

ENTRY(_start)

MEMORY
{
    ram(wxa): ORIGIN = 0x00000000, LENGTH = 16K
}

SECTIONS
{
    __stack_size = DEFINED(__stack_size) ? __stack_size : 2K;

    .init :
    {
        . = ALIGN(4);
        _einit = .;
    } >ram

    .text :
    {
        _stext = .;
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
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800);
        /**(.sdata .sdata.*)*/
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

    . = ALIGN(8);
    PROVIDE( _end = . );
    PROVIDE( end = . );

  .stack ORIGIN(ram) + LENGTH(ram) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    . = __stack_size;
    PROVIDE( _sp = . );
  } >ram AT>ram

}
