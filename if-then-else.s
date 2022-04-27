#==============
# if A <= 8 and b > 13: C = A - B
# else: C = 2 * A
#==============

.text
.global _start

.org 0x1000

_start:
	ldw r2, A(r0)
	ldw r3, B(r0)
	movi r4, 8
	movi r5, 13
	
if:
	bgt r2, r4, else
	ble r3, r5, else
then:
	sub r2, r2, r3
	br end_if
else:
	muli r2, r2, 2
end_if:
	stw r2, C(r0)
	
end:
	break
	
.org 0x2000

A: .word 2
B: .word 14
C: .skip 4
