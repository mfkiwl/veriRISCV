REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

CPU_CORE_PATH 	= $(REPO_ROOT)/src/rtl/core
IP_PATH 		= $(REPO_ROOT)/src/rtl/ip
AVN_BUS_PATH 	= $(IP_PATH)/bus/avalon_standard
GPIO_PATH 		= $(IP_PATH)/gpio
SRAM_PATH 		= $(IP_PATH)/sram_controller
UART_PATH 		= $(IP_PATH)/uart
UART_HOST_PATH 	= $(IP_PATH)/uart_host

include $(CPU_CORE_PATH)/veriRISCV_core.mk

# bus
VERILOG_SOURCES += $(AVN_BUS_PATH)/bus_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_decoder.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_crossbar.sv

# SRAM CONTROLLER
VERILOG_SOURCES += $(SRAM_PATH)/avalon_sram_controller.sv

# GPIO
VERILOG_SOURCES += $(GPIO_PATH)/avalon_gpio.sv

# UART
VERILOG_SOURCES += $(UART_PATH)/uart_fifo.sv
VERILOG_SOURCES += $(UART_PATH)/uart_baud.sv
VERILOG_SOURCES += $(UART_PATH)/uart_rx.sv
VERILOG_SOURCES += $(UART_PATH)/uart_tx.sv
VERILOG_SOURCES += $(UART_PATH)/uart_core.sv
VERILOG_SOURCES += $(UART_PATH)/avalon_uart.sv

# UART HOST
VERILOG_SOURCES += $(UART_HOST_PATH)/avalon_uart_host.sv

# MEMORY
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_1rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_1rw_2c.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_2rw.sv

# SOC
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_avalon_bus.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_soc.sv
