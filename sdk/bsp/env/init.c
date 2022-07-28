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

#include "platform.h"

void _init() {

    // init the uart with default configuration
    // TBD

    // write the trap handler register
    // TBD

    // enable global interrupt (mstatus)
    //_write_csr(mstatus, 0x8);
    // enable interrupt (mie)
    //_write_csr(mie, 0x888);

    // -- Initialize uart -- //
    avalon_uart_init_s uart_init;
    uart_init.txen  = 1;
    uart_init.nstop = 0;
    uart_init.txcnt = 0;
    uart_init.rxen  = 0;
    uart_init.rxcnt = 0;
    uart_init.ie_txwm = 0;
    uart_init.ie_rxwm = 0;
    uart_init.div = AVALON_UART_CAL_DIV(CLK_FREQ_MHZ, 115200);

    avalon_uart_init(UART0_BASE, &uart_init);


}