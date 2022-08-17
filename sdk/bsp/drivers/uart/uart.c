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
#include "interrupt.h"

// -------------------------------------
// Static variables
// -------------------------------------

static uart_txctrl_s _txctrl;
static uart_rxctrl_s _rxctrl;
static uint8_t       _tx_irq;
static uint8_t       _rx_irq;

#ifdef UART_FAST_DRIVER

static uint32_t _uart_base;
static uint8_t  _tx_buffer[UART_BUFFER_SIZE];

// NOTE: These variables needs to be volatile because some of them are changed in ISR
// without volatile modifier, -O2 optimization will not work
static volatile uint16_t _tx_buffer_start = 0;
static volatile uint16_t _tx_buffer_end = 0;
static volatile uint8_t  _tx_buffer_start_wrap = 0;
static volatile uint8_t  _tx_buffer_end_wrap = 0;

static void _uart_txwm_isr(void* isr_context);

#endif



// -------------------------------------
// Uart init
// -------------------------------------

/**
 * @brief Initialize the uart peripheral
 *
 * @param base
 * @param init_cfg
 */
void uart_init(uint32_t base, uart_init_cfg_s* init_cfg) {

    uart_div_s _div;
    uart_ie_s  _ie;

    _txctrl.txen  = init_cfg->txen;
    _txctrl.nstop = init_cfg->nstop;
    _txctrl.txcnt = init_cfg->txcnt;
    _rxctrl.rxen  = init_cfg->rxen;
    _rxctrl.rxcnt = init_cfg->rxcnt;
    _ie.txwm = init_cfg->ie_txwm;
    _ie.rxwm = init_cfg->ie_rxwm;
    _div.div = init_cfg->div;


    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
    *REG32_PTR(base, UART_IE_REG)     = _ie.reg;
    *REG32_PTR(base, UART_DIV_REG)    = _div.reg;

    // if we use interrupt, register the isr
    #ifdef UART_FAST_DRIVER
    _tx_irq = init_cfg->tx_irq;
    _rx_irq = init_cfg->rx_irq;
    // we need to use a static/global variable here. If we use &base as isr_context,
    // the base variable will be discarded after the function returns and isr will
    // get a garbage value as base
    _uart_base = base;
    external_isr_register(_tx_irq, &_uart_txwm_isr, &_uart_base);
    #endif
}

/**
 * @brief Open the uart peripheral
 *
 * @param base
 * @return int
 */
int uart_open(uint32_t base) {
    _txctrl.txen = 1;
    _rxctrl.rxen = 1;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

/**
 * @brief Close the uart peripheral
 *
 * @param base
 * @return int
 */
int uart_close(uint32_t base) {
    _txctrl.txen = 0;
    _rxctrl.rxen = 0;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

// -------------------------------------
// Uart write
// -------------------------------------


// -- FAST DRIVER --//
#ifdef UART_FAST_DRIVER

/**
 * @brief Check if the write buffer is full or not
 *
 * @return uint8_t
 */
static uint8_t _tx_buffer_full() {
    uint8_t equal, wrapped;
    equal = _tx_buffer_end == _tx_buffer_start;
    wrapped = _tx_buffer_start_wrap != _tx_buffer_end_wrap;
    return equal && wrapped;
}

/**
 * @brief Check if the write buffer is empty or not
 *
 * @return uint8_t
 */
static uint8_t _tx_buffer_empty() {
    uint8_t equal, wrapped;
    equal = _tx_buffer_end == _tx_buffer_start;
    wrapped = _tx_buffer_start_wrap != _tx_buffer_end_wrap;
    return equal && !wrapped;
}

/**
 * @brief Interrupt service routine to handle uart tx watermark interrupt
 *
 * @param isr_context
 */
static void _uart_txwm_isr(void* isr_context) {

    uart_txdata_s _txdata;
    uint32_t* base = (uint32_t*) isr_context;

    // if we have more data to be sent:
    while (!_tx_buffer_empty()) {

        // check if TX FIFO is full, if yes, then we should wait for the next interrupt
        _txdata.reg = *REG32_PTR(*base, UART_TXDATA_REG);
        if (_txdata.full) return;

        // write the data into TX FIFO
        _txdata.data = _tx_buffer[_tx_buffer_start++];
        UART_TXDATA_WRITE(*base, _txdata.reg);

        // update the write pointer
        if (_tx_buffer_start == UART_BUFFER_SIZE) {
            _tx_buffer_start = 0;
            _tx_buffer_start_wrap = ~_tx_buffer_start_wrap;
        }

    }

    // disable the interrupt since we don't have any more data to be sent
    external_isr_disable(_tx_irq);
}

/**
 * @brief Write N character through uart
 *
 * @param base
 * @param buf
 * @param nbytes
 */
int uart_write(uint32_t base, char *buf, size_t nbytes) {

    volatile uint8_t full;
    int count = nbytes;
    uart_txdata_s _txdata;

        while (count > 0) {
            full = _tx_buffer_full();
            // block wait if necessary
            if (full) {
                external_isr_enable(_tx_irq);
                // wait till buffer have space
                while(full) full = _tx_buffer_full();
            }

            // push the data into the buffer
            _tx_buffer[_tx_buffer_end++] = *buf;

            // update write pointer
            if (_tx_buffer_end == UART_BUFFER_SIZE) {
                _tx_buffer_end = 0;
                _tx_buffer_end_wrap = ~_tx_buffer_end_wrap;
            }

            buf++;
            count--;
        }

        // enable interrupt to drain out the buffer
        external_isr_enable(_tx_irq);

        // return number of bytes being sent
        return (nbytes - count);
}

#else

int uart_write(uint32_t base, char *buf, size_t nbytes) {

    uart_txdata_s _txdata;
    int count = nbytes;

    while (count > 0) {
        // wait till the txdata fifo has space
        do {
            _txdata.reg = *REG32_PTR(base, UART_TXDATA_REG);
        } while(_txdata.full);
        // write the data to FIFO
        _txdata.data = *buf;
        UART_TXDATA_WRITE(base, _txdata.reg);

        buf++;
        count--;
    }
    return (nbytes - count);
}


#endif


// -------------------------------------
// Uart read
// -------------------------------------

uint8_t uart_getc(uint32_t base) {
    uart_rxdata_s _rxdata;
    // read till the rxdata fifo is not empty
    do {
        _rxdata.reg = *REG32_PTR(base, UART_RXDATA_REG);
    } while(_rxdata.empty);
    return _rxdata.data;
}
