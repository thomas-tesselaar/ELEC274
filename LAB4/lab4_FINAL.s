    .equ		JTAG_UART_BASE,		0x10001000
    .equ		DATA_OFFSET,		0
    .equ		STATUS_OFFSET,		4
    .equ		WSPACE_MASK,		0xFFFF
    
    .text
    .global _start
    .org 0x0000

_start:
    movia   sp, 0x007FFFFC      # initialize stack pointer

    movia	r2, LAB_TITLE
	call	PrintString
	
	movia	r2, LAB_NAMES
	call	PrintString
	
	ldw 	r3, N(r0)	#SWAP these three inputs to the right order
	movia	r4, list1	#START with r2 instead of r3
	movia	r5, list2
	call	LeftShiftListItems

_end:
    break
    br _end
	
# ------------------------------------------------------------

LeftShiftListItems:
	subi 	sp, sp, 36
	stw		ra, 32(sp)
	stw		r2, 28(sp)
	stw		r3, 24(sp) #n value
	stw		r4, 20(sp) #list1
	stw		r5, 16(sp) #list2
	stw		r6, 12(sp) #list1 elm
	stw		r7, 8(sp) #list2 elm
	stw		r8, 4(sp) #count
	stw		r9, 0(sp)
	
	movi	r8, 0

LSLI_LOOP:
	ldw		r6, 0(r4)	#ptr1[i]
	ldw		r7, 0(r5)	#ptr2[i]
	
	mov		r2, r6
	Call	PrintHexWord
	
	movia	r9, LAB_COMMA
	ldb		r2, 0(r9)
	Call	PrintChar
	
	mov		r2, r7
	Call	PrintHexWord
	
	sll		r6,	r6,	r7
	stw		r6, 0(r4)
	
	movia	r2, LAB_ARROW
	Call	PrintString
	
	mov		r2, r6
	Call	PrintHexWord
	
	movia	r9, LAB_NL
	ldb		r2, 0(r9)
	Call	PrintChar
	
LSLI_IF:
	bge		r6, r0, LSLI_ELSE
	addi	r8, r8, 1

LSLI_ELSE:
	addi	r4, r4, 4
	addi	r5, r5, 4
	subi	r3, r3, 1
	bgt		r3, r0, LSLI_LOOP
	
	mov		r2, r8
	Call	PrintHexWord
	
	movia	r2, LAB_NEG
	Call	PrintString
	
	ldw		ra, 32(sp)
	ldw		r2, 28(sp)
	ldw		r3, 24(sp)
	ldw		r4, 20(sp)
	ldw		r5, 16(sp)
	ldw		r6,	12(sp)
	ldw		r7,	8(sp)
	ldw		r8, 4(sp)
	ldw		r9, 0(sp)
	addi	sp, sp, 36
	
	ret


# ------------------------------------------------------------

PrintString:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    mov     r4, r2                      # move string pointer to r4

ps_loop:
    ldb		r2, 0(r4)                   # read byte into r2 from the pointer r4
    beq     r2, r0, ps_end_loop         # if ch is 0, loop past end
    call    PrintChar                   # otherwise, call printChar subroutine with r2 as input
    addi    r4, r4, 1                   # increment string pointer (1 byte at a time!)
    beq     r0, r0, ps_loop             # unconditional loop (while loop)

ps_end_loop:
    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret

# ------------------------------------------------------------

PrintHexWord:
    subi    sp, sp, 20          # subtract from stack pointer
    stw     ra, 16(sp)          # store return address for nested functions
    stw     r2, 12(sp)          # used to send value to PrintHexByte
    stw     r3, 8(sp)           # loop counter
    stw     r4, 4(sp)           # shift amount multi
    stw     r5, 0(sp)           # temporarily hold input value

    movi    r3, 4               # set loop amount (4 bytes per word, so 4 loops)
    movi    r4, 32              # hold amount to shift right
    mov     r5, r2              # move input value to r5

phwa_loop:   
    subi    r4, r4, 8           # decrement amount to shift left by each time by 16 bits (1 byte)
    srl     r2, r5, r4          # shift value left by shift amount
    andi    r2, r2, 0xFF        # and only 8 bits (0xFF) held in r2 to be printed using printhexbyte
    call    PrintHexByte        # print the byte being held in r2 (ie. printing XX, in order of XX000000, 00XX0000, 0000XX00, 000000XX)
    subi    r3, r3, 1           # decrement loop counter
    bgt     r3, r0, phwa_loop   # loop if needed

    ldw     ra, 16(sp)          # store return address for nested functions
    ldw     r2, 12(sp)          
    ldw     r3, 8(sp)           
    ldw     r4, 4(sp)           
    ldw     r5, 0(sp)            
    addi    sp, sp, 20          # add to stack pointer

    ret

# ------------------------------------------------------------

PrintHexByte:
    subi    sp, sp, 12      # save reg values for use
    stw     ra, 8(sp)
    stw     r2, 4(sp)       # restore original value of r2
    stw     r3, 0(sp)       # hold original input value n

    mov     r3, r2
    srli    r2, r2, 4       # shift n right 4 to get top 4 bytes
    call    PrintHexDigit   # print top 4 bytes
    andi    r2, r3, 0xF     # get bottom 4 bytes
    call    PrintHexDigit   # print bottom 4 bytes
    
    ldw     ra, 8(sp)       # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)
    addi    sp, sp, 12
    
    ret

# ------------------------------------------------------------

PrintHexDigit:
    subi    sp, sp, 12          # save reg values for use
    stw     ra, 8(sp)                   
    stw     r2, 4(sp)                   
    stw     r3, 0(sp)           # hold constant for comparison

phd_if:
    movi    r3, 10
    bge     r2, r3, phd_else    
phd_then:
    addi    r2, r2, '0'         # store appropriate ASCII representation for PrintChar (<10)
    br      phd_end_if
phd_else:
    subi    r2, r2, 10
    addi    r2, r2, 'A'         # store appropriate ASCII representation for PrintChar (>10)
phd_end_if:
    call    PrintChar           # argument ready in r2
    
    ldw     ra, 8(sp)           # restore reg values
    ldw     r2, 4(sp)
    ldw     r3, 0(sp)           # hold constant for comparison
    addi    sp, sp, 12
    ret

# ------------------------------------------------------------

PrintChar:
    subi    sp, sp, 12                  # save reg values for use
    stw     ra, 8(sp)
    stw     r3, 4(sp)
    stw     r4, 0(sp)

    movia   r3, JTAG_UART_BASE          # move pointer to the JTAG UART location in memory using movia (large address)

# start polling loop
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)       # load word from control reg of JTAG UART (+4 from base addr)
    andhi   r4, r4, WSPACE_MASK         # and top 16 bits of the control reg w/ FFFF 
    beq     r4, r0, pc_loop             # if top 16 bits is 0, no space for char to be read, repeat polling loop
    
    stwio   r2, DATA_OFFSET(r3)         # store the character in the "data" area of the JTAG UART to be read (+0 from base addr)

    ldw     ra, 8(sp)                   # restore reg values
    ldw     r3, 4(sp)                   
    ldw     r4, 0(sp)
    addi    sp, sp, 12

    ret
    
# ------------------------------------------------------------

    .org 0x1000
N:			.word	4
list1:		.word	0x332211, 0x665544, 0xFFEEDD, 0xCCBBAA
list2:		.word	4, 8, 12, 16
LAB_TITLE: 	.asciz	"ELEC 274 Lab 4\n"
LAB_NAMES:	.asciz	"Kevin, Thomas, Liyi\n"
LAB_COMMA:	.asciz	","
LAB_ARROW:	.asciz	" --> "
LAB_NL:		.asciz	"\n"
LAB_NEG:	.asciz	" items now negative\n"
    .end