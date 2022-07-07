// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/06/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// SoC Define
// ------------------------------------------------------------------------------------------------

`ifndef _VERIRISCV_SOC_
`define _VERIRISCV_SOC_

// Memory Map

// 0x0000_0000 - 0x7FFF_FFFF: instruction ram and data ram
// 0x8000_0000 - 0x8000_0FFF: Always-On (AON) domain
// 0x8000_1000 - 0x8000_1FFF: GPIO0
// 0x8000_2000 - 0x8000_2FFF: GPIO1
// 0x8000_3000 - 0x8000_3FFF: UART0

`define MEMORY_LOW      32'h0000_0000
`define MEMORY_HIGH     32'h7FFF_FFFF

`define PERIPHERAL_LOW  32'h8000_0000
`define PERIPHERAL_HIGH 32'hFFFF_FFFF

`endif
