/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/08/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * avalon uart driver
 * ---------------------------------------------------------------
 */

#include "avalon_uart.h"

#define AVALON_UART_REG2POINTER(base, reg)   ((uint32_t *) (base + reg))

static avalon_uart_txdata_s _txdata;
static avalon_uart_rxdata_s _rxdata;
static avalon_uart_txctrl_s _txctrl;
static avalon_uart_rxctrl_s _rxctrl;
static avalon_uart_ie_s     _ie;
static avalon_uart_ip_s     _ip;
static avalon_uart_div_s    _div;

void avalon_uart_init(uint32_t base, avalon_uart_init_s* init_cfg) {
    _txctrl.txen = init_cfg->txen;
    _txctrl.nstop = init_cfg->nstop;
    _txctrl.txcnt = init_cfg->txcnt;
    _rxctrl.rxen = init_cfg->rxen;
    _rxctrl.rxcnt = init_cfg->rxcnt;
    _ie.txwm = init_cfg->ie_txwm;
    _ie.rxwm = init_cfg->ie_rxwm;
    _div.div = init_cfg->div;

    *AVALON_UART_REG2POINTER(base, AVALON_UART_TXCTRL_REG) = _txctrl.reg;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_RXCTRL_REG) = _rxctrl.reg;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_IE_REG)     = _ie.reg;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_DIV_REG)    = _div.reg;
}

int avalon_uart_open(uint32_t base) {
    _txctrl.txen = 1;
    _rxctrl.rxen = 1;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_TXCTRL_REG) = _txctrl.reg;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_RXCTRL_REG) = _rxctrl.reg;
}

int avalon_uart_close(uint32_t base) {
    _txctrl.txen = 0;
    _rxctrl.rxen = 0;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_TXCTRL_REG) = _txctrl.reg;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_RXCTRL_REG) = _rxctrl.reg;
}

void avalon_uart_write_byte_blocking(uint32_t base, const char c) {
    // wait till the txdata fifo has space
    do {
        _txdata.reg = *AVALON_UART_REG2POINTER(base, AVALON_UART_TXDATA_REG);
    } while(_txdata.full);
    _txdata.data = c;
    *AVALON_UART_REG2POINTER(base, AVALON_UART_TXDATA_REG) = _txdata.reg;
}

int  avalon_uart_read_byte_blocking(uint32_t base) {
    // read till the rxdata fifo is not empty
    do {
        _rxdata.reg = *AVALON_UART_REG2POINTER(base, AVALON_UART_RXDATA_REG);
    } while(_rxdata.empty);
    return _rxdata.data;
}

void avalon_uart_putnc_blocking(uint32_t base, char *buf, size_t nbytes) {
    while (nbytes > 0) {
        avalon_uart_write_byte_blocking(base, *buf);
        buf++;
        nbytes--;
    }
}
