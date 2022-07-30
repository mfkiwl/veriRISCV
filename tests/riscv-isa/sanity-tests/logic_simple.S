# This test covers all the Logic Instruction and Immediate instruction
# Func7 - 'b0110011, 'b0100011

ADDI x1, x0, 0xFF
ORI  x2, x0, 0xF0
XORI x3, x0, 0x0F
ADDI x4, x0, 0x1

NOP
NOP
NOP
NOP

SUB  x5, x0, x4
ADD  x6, x2, x3
SUB  x7, x1, x2
SLL	 x8, x1, x4
SLT  x9, x5, x0
SLTU x10, x5, x0
XOR	 x11, x2, x3
SRL  x12, x5, x4
SRA  x13, x5, x4
OR   x14, x2, x3
AND  x15, x1, x2

SLTI  x16, x5, 0x0
SLTIU x17, x5, 0x0
ANDI  x18, x1, 0x0F
SLLI  x19, x1, 0x4
SRLI  x20, x5, 0x1
SRAI  x21, x5, 0x1

LOOP:
	j LOOP