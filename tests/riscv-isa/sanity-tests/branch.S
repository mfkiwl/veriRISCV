ADDI x1, x0, 1		# x1 = 1
ADDI x2, x0, 1		# x2 = 1
SUB  x3, x0, x1		# x3 = -1

ADDI x4, x0, 0x0
ADDI x5, x0, 0x0
ADDI x6, x0, 0x0
ADDI x7, x0, 0x0
ADDI x8, x0, 0x0
ADDI x9, x0, 0x0
ADDI x10, x0, 0x0
ADDI x11, x0, 0x0
ADDI x12, x0, 0x0
ADDI x13, x0, 0x0
ADDI x14, x0, 0x0
ADDI x15, x0, 0x0
ADDI x16, x0, 0x0
ADDI x17, x0, 0x0
ADDI x18, x0, 0x0
ADDI x19, x0, 0x0
ADDI x20, x0, 0x0
ADDI x21, x0, 0x0

BEQ x1, x2, BEQ1
ADDI x4, x0, 0x2
ADDI x4, x0, 0x2
ADDI x4, x0, 0x2
ADDI x4, x0, 0x2
ADDI x5, x0, 0x2
BEQ1:
	ADDI x6, x0, 0x1
NOP
NOP
NOP

BNE x1, x0, BNE1
ADDI x7, x0, 0x3
ADDI x7, x0, 0x3
ADDI x7, x0, 0x3
ADDI x7, x0, 0x3
ADDI x8, x0, 0x3
BNE1:
	ADDI x9, x0, 0x1
NOP
NOP
NOP

BLT x3, x1, BLT1
ADDI x10, x0, 0x4
ADDI x10, x0, 0x4
ADDI x10, x0, 0x4
ADDI x10, x0, 0x4
ADDI x11, x0, 0x4
BLT1:
	ADDI x12, x0, 0x1
NOP
NOP
NOP

BLTU x0, x1, BLTU1
ADDI x13, x0, 0x5
ADDI x13, x0, 0x5
ADDI x13, x0, 0x5
ADDI x13, x0, 0x5
ADDI x14, x0, 0x5
BLTU1:
	ADDI x15, x0, 0x1
NOP
NOP
NOP

BGE x1, x3, BGE1
ADDI x16, x0, 0x6
ADDI x17, x0, 0x6
BGE1:
	ADDI x18, x0, 0x1
NOP
NOP
NOP

BGEU x1, x0, BGEU1
ADDI x19, x0, 0x7
ADDI x19, x0, 0x7
ADDI x19, x0, 0x7
ADDI x19, x0, 0x7
ADDI x20, x0, 0x7
BGEU1:
	ADDI x21, x0, 0x1
NOP
NOP
NOP

END:
	BEQ x0, x0, END

LOOP:
	j LOOP