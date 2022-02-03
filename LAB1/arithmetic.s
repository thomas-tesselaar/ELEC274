	.text
	.global _start
	.org    0x0000

_start:                         # == INITILIAZATION ==       
#B = (J - H) * K (= 5)
	ldw r2, J(r0)
	ldw r3, H(r0)
	ldw r4, K(r0)
	sub r2, r2, r3
	mul r2, r2, r4
	stw r2, B(r0)

#W = B + 4 + A (= 11)
	ldw r3, A(r0)
	add r3, r2, r3
	addi r3, r3, 4
	stw r3, W(r0)
	
#X = A * F (= 12)
	ldw r4, A(r0)
	ldw r5, F(r0)
	mul r4, r4, r5
	stw r4, X(r0)

break

# ------------------------------------------------------------------------

        .org    0x3000
A:		.word 2
H:		.word 3
J:		.word 4
K:		.word 5
F:		.word 6

B:		.skip 4
W:		.skip 4
X:		.skip 4

        .end
