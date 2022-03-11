.text
.global _start
.org 0x1000

_start:
main:	
	
	ldw r3, N(r0)
	movia r4, LIST1
	movia r5, LIST2
	movia r6, LIST3
	ldw r7, POS_COUNT(r0)
	movia r8, NEWLIST
	movi r9, 0
	
ProduceList:
	ldw r12, 0(r4)
	ldw r13, 0(r5)
	blt r12, r13, ComputeALowerThanB
	bge r12, r13, ComputeANotLowerThanB
Mid:
	bgt r8, r0, CountPosValues
Mid2:
	addi r9, r9, 1
	addi r4, r4, 4
	addi r5, r5, 4
	addi r6, r6, 4
	addi r8, r8, 4
	blt r9, r3, ProduceList
	break
	
ComputeALowerThanB:
	ldw r10, 0(r4)
	ldw r11, 0(r5)
	muli r11, r11, 5 #k is an unknown constant
	sub r10, r10, r11
	stw r10, 0(r8)
	bgt r3, r0, Mid

ComputeANotLowerThanB:
	ldw r10, 0(r5)
	ldw r11, 0(r6)
	sub r10, r10, r11
	stw r10, 0(r8)
	bgt r3, r0, Mid

CountPosValues:
	addi r7, r7, 1
	stw r7, POS_COUNT(r0)
	bgt r3, r0, Mid2

_end:
	br _end

# ------------------------------------------------------------------------

N:		.word	4  
PARAM:		.word   4 
NEWLIST:   	.skip	16
LIST1:		.word	8, -6, 4, -2
LIST2:		.word	-1, 2, -3, 4
LIST3:		.word	7, 5, 3, 1
POS_COUNT:	.skip	4


.end
