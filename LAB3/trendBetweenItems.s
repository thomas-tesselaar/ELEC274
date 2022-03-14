	.equ		JTAG_UART_BASE,		0x10001000
	.equ		DATA_OFFSET,		0
	.equ		STATUS_OFFSET,		4
	.equ		WSPACE_MASK,		0xFFFF

	.text
	.global _start
	.org    0x0000

_start:
	movia	sp, 0x007FFFFC
	movia	r2, NAMES
	call	PrintString
	ldw 	r3, N(r0)
	movia	r7, LIST
	call	TrendBetweenItems

_end:
	break
	br _end

# ------------------------------------------------------------

TrendBetweenItems:
	subi	sp, sp, 32
	stw		ra, 28(sp)
	stw		r2, 24(sp)
	stw		r3, 20(sp) #n value
	stw		r4, 16(sp) #list elm
	stw		r5, 12(sp) #diff
	stw		r6, 8(sp) #last item
	stw		r7, 4(sp)
	stw		r8, 0(sp) #char
	
	movia	r2, TREND_INTRO
	call 	PrintString
	
	movi	r6, 0
	
tbi_loop:
	ldw		r4, 0(r7)
	movia	r2, TREND_DOTS
	call	PrintString
	sub		r5, r4, r6
	
	bgt 	r0, r5, tbi_if
	bgt 	r5, r0, tbi_elseif

tbi_else:
	movia	r8, TREND_ELSE
	ldb		r2, 0(r8)
	call	PrintChar
	br		tbi_endif
	
tbi_if:
	movia	r8,	TREND_IF
	ldb		r2, 0(r8)
	call	PrintChar
	br		tbi_endif

tbi_elseif:
	movia	r8, TREND_ELSEIF
	ldb		r2, 0(r8)
	call	PrintChar

tbi_endif:
	addi	r7, r7, 4
	subi	r3, r3, 1
	mov		r6, r4
	bgt		r3, r0, tbi_loop
	
	movia	r8, TREND_NEWLINE
	ldb		r2, 0(r8)
	call	PrintChar
	
	ldw		ra, 28(sp)
	ldw		r2, 24(sp)
	ldw		r3, 20(sp)
	ldw		r4, 16(sp)
	ldw		r5, 12(sp)
	ldw		r6,	8(sp)
	ldw		r7,	4(sp)
	ldw		r8, 0(sp)
	addi	sp, sp, 32
	
	ret

# ------------------------------------------------------------

PrintString:
	subi	sp, sp, 12                  # save reg values for use
	stw 	ra, 8(sp)
	stw 	r3, 4(sp)
	stw 	r4, 0(sp)

	mov 	r4, r2                      # move string pointer to r4

ps_loop:
	ldb		r2, 0(r4)                   # read byte into r2 from the pointer r4
	beq 	r2, r0, ps_end_loop         # if ch is 0, loop past end
	call	PrintChar                   # otherwise, call printChar subroutine with r2 as input
	addi	r4, r4, 1                   # increment string pointer (1 byte at a time!)
	beq 	r0, r0, ps_loop             # unconditional loop (while loop)

ps_end_loop:
	ldw 	ra, 8(sp)                   # restore reg values
	ldw 	r3, 4(sp)
	ldw 	r4, 0(sp)
	addi	sp, sp, 12

	ret

# ------------------------------------------------------------

PrintChar:
	subi	sp, sp, 12                   # save reg values for use
	stw 	ra, 8(sp)
	stw 	r3, 4(sp)
	stw 	r4, 0(sp)

	movia	r3, JTAG_UART_BASE          # move pointer to the JTAG UART location in memory using movia (large address)

# start polling loop
pc_loop:
	ldwio	r4, STATUS_OFFSET(r3)       # load word from control reg of JTAG UART (+4 from base addr)
	andhi	r4, r4, WSPACE_MASK         # and top 16 bits of the control reg w/ FFFF 
	beq 	r4, r0, pc_loop             # if top 16 bits is 0, no space for char to be read, repeat polling loop
    
	stwio	r2, DATA_OFFSET(r3)         # store the character in the "data" area of the JTAG UART to be read (+0 from base addr)

	ldw 	ra, 8(sp)                   # restore reg values
	ldw 	r3, 4(sp)                   
	ldw 	r4, 0(sp)
	addi	sp, sp, 12

	ret
    
# ------------------------------------------------------------

                .org     0x1000
N:              .word    6
LIST            .word    -1, 8, 3, 3, 5, 7
NAMES:          .ascii   "L3 for Name, Name "   
                .asciz   "Name\n"     # add zero byte to end of string in memory
TREND_INTRO:    .ascii   "trend between "
                .asciz   "items:"
TREND_DOTS:     .asciz   "..."
TREND_IF:       .asciz   "\\"
TREND_ELSEIF:   .asciz   "/"
TREND_ELSE:     .asciz   "-"
TREND_NEWLINE:  .asciz   "\n"
   				.end
