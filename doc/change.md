# Change Log

## 08/04/2022 - Release: veriRISCV_1.0

### Performance

- commit: 911e2ca95faab2331b69d6e100e6221de6555721
- clock speed: 25 Mhz
  - DE2 slack: 12.140 ns
- coremark:
  - Total ticks      : 1377065
  - Total time (secs): 56
  - Iterations/Sec   : 17
  - Iterations       : 1000

## 08/04/2022 - Improved clock speed and updated read hazard handling

### Changes

Updated the hazard handling for memory read dependence and CSR

- We do not forward csr read data to EX stage. Additional stall cycle is added.
- We do not forward the memory read data to EX stage. Additional stall cycle is added.
- Now load dependence will take 2 clock cycles to resolves.

### Performance

- clock speed: 50 Mhz
  - DE2 slack: 4.633 ns
- coremark:
  - Total ticks      : 1395287
  - Total time (secs): 28
  - Iterations/Sec   : 35
  - Iterations       : 1000

Compared to previous one, total ticks increased by (1395287 - 1377065) / 1377065 = 1.3% due to the additional stall cycle for load dependence.

Assume that we have x such instructions has load dependence. And in general each instructions take 1 cycles to complete.
