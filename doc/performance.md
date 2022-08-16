# Performance

Performance is determined by coremark testbench with 1000 iterations

## Using BRAM as main memory

| Type             | Total ticks | Total time (secs) | Iterations/Sec |
| ---------------- | ----------- | ----------------- | -------------- |
| RV32I            | 1394821     | 28                | 35             |
| RV32IM           | 556990      | 11                | 90             |
| RV32IM + ICache1 | 545027      | 11                | 90             |
| RV32IM + ICache2 | 542394      | 11                | 90             |

| Type             | Clock Speed | DE2 slacks |
| ---------------- | ----------- | ---------- |
| RV32I            | 50 Mhz      | 4.633 ns   |
| RV32IM           | 50 Mhz      | 3.663 ns   |
| RV32IM + ICache1 | 50 Mhz      | 1.810 ns   |
| RV32IM + ICache2 | 50 Mhz      | 3.243 ns   |

## Using SRAM as main memory

| Type             | Total ticks | Total time (secs) | Iterations/Sec |
| ---------------- | ----------- | ----------------- | -------------- |
| RV32IM           | 922256      | 18                | 55             |
| RV32IM + ICache1 | 707385      | 14                | 71             |
| RV32IM + ICache2 | 676891      | 13                | 76             |

| Type             | Clock Speed | DE2 slacks |
| ---------------- | ----------- | ---------- |
| RV32IM           | 50 Mhz      | 2.066 ns   |
| RV32IM + ICache1 | 50 Mhz      | 1.463 ns   |
| RV32IM + ICache2 | 50 Mhz      | 1.430 ns   |

- ICache1: Direct mapped instruction cache with 32 locations.
- ICache2: Direct mapped instruction cache with 64 locations.
