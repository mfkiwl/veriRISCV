OUTPUT_ARCH( "riscv" )

ENTRY(_start)

MEMORY
{
    ram(wxa): ORIGIN = 0x00000000, LENGTH = 32K
}

SECTIONS
{
    __stack_size = DEFINED(__stack_size) ? __stack_size : 2K;

    .init :
    {
        KEEP (*(SORT_NONE(.init)));
    } >ram

    .text :
    {
        *(.text)
        *(.text.*)
        . = ALIGN(4);
        PROVIDE( _etext = .);
    } >ram

    .preinit_array :
    {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } >ram AT>ram

    .init_array :
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
        KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
        PROVIDE_HIDDEN (__init_array_end = .);
    } >ram AT>ram

    .dtors :
    {
        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
    } >ram AT>ram

    .data :
    {
        PROVIDE(_sdata = .);
        *(.rdata)
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(8);
        *(.srodata.cst16)
        *(.srodata.cst8)
        *(.srodata.cst4)
        *(.srodata.cst2)
        *(.srodata .srodata.*)
        PROVIDE(_edata = .);
    } >ram AT>ram

    .bss  :
    {
        PROVIDE(_sbss = .);
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
        PROVIDE(_ebss = .);
    } >ram AT>ram

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
