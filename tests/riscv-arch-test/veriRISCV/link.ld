OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x0000000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x00000000);
  .text : { *(.text) }
  . = ALIGN(0x00000000);
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}