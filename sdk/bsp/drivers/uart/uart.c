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

#include "uart.h"
#include "platform.h"

static uart_txdata_s _txdata;
static uart_rxdata_s _rxdata;
static uart_txctrl_s _txctrl;
static uart_rxctrl_s _rxctrl;
static uart_ie_s     _ie;
static uart_ip_s     _ip;
static uart_div_s    _div;

void uart_init(uint32_t base, uart_init_cfg_s* init_cfg) {
    _txctrl.txen = init_cfg->txen;
    _txctrl.nstop = init_cfg->nstop;
    _txctrl.txcnt = init_cfg->txcnt;
    _rxctrl.rxen = init_cfg->rxen;
    _rxctrl.rxcnt = init_cfg->rxcnt;
    _ie.txwm = init_cfg->ie_txwm;
    _ie.rxwm = init_cfg->ie_rxwm;
    _div.div = init_cfg->div;

    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
    *REG32_PTR(base, UART_IE_REG)     = _ie.reg;
    *REG32_PTR(base, UART_DIV_REG)    = _div.reg;
}

int uart_open(uint32_t base) {
    _txctrl.txen = 1;
    _rxctrl.rxen = 1;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

int uart_close(uint32_t base) {
    _txctrl.txen = 0;
    _rxctrl.rxen = 0;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

void uart_write_byte_blocking(uint32_t base, const char c) {
    // wait till the txdata fifo has space
    do {
        _txdata.reg = *REG32_PTR(base, UART_TXDATA_REG);
    } while(_txdata.full);
    _txdata.data = c;
    *REG32_PTR(base, UART_TXDATA_REG) = _txdata.reg;
}

int  uart_read_byte_blocking(uint32_t base) {
    // read till the rxdata fifo is not empty
    do {
        _rxdata.reg = *REG32_PTR(base, UART_RXDATA_REG);
    } while(_rxdata.empty);
    return _rxdata.data;
}

void uart_putnc_blocking(uint32_t base, char *buf, size_t nbytes) {
    while (nbytes > 0) {
        uart_write_byte_blocking(base, *buf);
        buf++;
        nbytes--;
    }
}
