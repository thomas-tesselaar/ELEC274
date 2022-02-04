.text
.global _start
.org 0x0000
 
_start:
main:
       
    movi sp, 0x7ffC # movia sp, 0x007FFFC  
 
    movi r3, 5
		movi r9, 5
		movia r2, LIST_A
		movia r6, LIST_B
		ldw r8, BELOW_VALUES(r2)
				
GenerateListValues:
		ldw r4, 0(r2)
		call ComputeResult
		subi r3, r3, 1
		addi r2, r2, 4
		addi r6, r6, 4
		movi r0, 0
		bgt r3, r0, GenerateListValues

 CountBelowValues:
 		
		ldw r4, 0(r6)
		ldw r7, THRESHOLD(r0)
		blt r6, r7, AddCount
		subi r9, r9, 1
		addi r2, r2, 4
		bgt r6, r0, CountBelowValues
		stw r2, BELOW_VALUES(r0)

		break
 
 
# --------------------
ComputeResult:
		ldw r5, D(r0)
		muli r4, r4, 3
		sub r4, r4, r5
		stw r4, 0(r6)
		ret

# --------------------
AddCount:
		addi r8, r8, 1
		stw r8, BELOW_VALUES(r0)
		ret

# --------------------
 
        .org    0x3000
BELOW_VALUES:   .word 0
RESULT:         .word 0
LIST_A:         .word 1, 2, 3, 4, 5
LIST_B:         .skip 20
D:              .word 3
THRESHOLD:      .word 5 
	
	
	
