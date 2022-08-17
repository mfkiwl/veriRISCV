# Cache Performance

## Baseline - with/without RV32M

|  Type  | Total ticks | Total time (secs) | Iterations/Sec |
| :----: | :---------: | :---------------: | :------------: |
| RV32I  |   1394821   |        28         |       35       |
| RV32IM |   556990    |        11         |       90       |

## I-Cache Performance (RV32IM)

- Performance is determined by running coremark testbench with 1000 iterations
- Cache line size is 4 bytes
- Using SRAM as main memory
- 1 ways is direct mapped cache, >=2 ways is set associative cache

| Cache Size (Bytes) | Ways  | Total ticks | Total time (secs) | Iterations/Sec |
| :----------------: | :---: | :---------: | :---------------: | :------------: |
|      No cache      |   x   |   922256    |        18         |       55       |
|        128         |   1   |   707385    |        14         |       71       |
|        128         |   2   |   713258    |        14         |       71       |
|        128         |   4   |   711927    |        14         |       71       |
|        256         |   1   |   676891    |        13         |       76       |
|        256         |   2   |   674032    |        13         |       76       |
|        256         |   4   |   672277    |        13         |       76       |
|        512         |   1   |   648829    |        13         |       76       |
|        512         |   2   |   631773    |        12         |       83       |
|        512*        |   4   |   626184    |        12         |       83       |

\* This one has an issue, the message did not complete
