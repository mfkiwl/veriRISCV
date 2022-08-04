// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/10/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// cpu init code - config and setup peripherals
// ------------------------------------------------------------------------------------------------

#include <stdint.h>

#include "platform.h"

extern void trap_entry();

void _init() {

    // write the trap handler register
    write_csr(mtvec, (uint32_t) &trap_entry);

    // enable global interrupt (mstatus)
    write_csr(mstatus, 0x8);

    // enable interrupt (mie)
    write_csr(mie, 0x888);

    // Initialize uart

    uart_init_cfg_s uart_init_cfg;
    uart_init_cfg.txen  = 1;
    uart_init_cfg.nstop = 0;
    uart_init_cfg.txcnt = 7;
    uart_init_cfg.rxen  = 1;
    uart_init_cfg.rxcnt = 0;
    uart_init_cfg.div = UART_CAL_DIV(CLK_FREQ_MHZ, 115200);

    #ifdef UART_FAST_DRIVER
    uart_init_cfg.ie_txwm = 1;
    uart_init_cfg.ie_rxwm = 0;
    uart_init_cfg.tx_irq = UART_TX_IRQ;
    uart_init_cfg.rx_irq = UART_RX_IRQ;
    #else
    uart_init_cfg.ie_txwm = 0;
    uart_init_cfg.ie_rxwm = 0;
    #endif

    uart_init(UART0_BASE, &uart_init_cfg);

}
