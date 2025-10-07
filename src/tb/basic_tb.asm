
main:    
    lw s0, MMIO_BASE
    
    sw zero, 0(s0)
    addi s1, zero, 100
    addi s2, zero, 22
    add s3, s1, s2	# value 0x7A
    sw s3, 0(s0)	# store 0x7A in MMIO register
    
    addi s2, zero, 100
    beq s1, s2, BEQ_TAKEN
    sw s1, 0(s0)
	jal zero, NEXT

BEQ_TAKEN:
	lui s1, 0x18888
	sw s1, 0(s0)

NEXT:
	lui s2, 0x19999
	srai s3, s2, 10
	sw s3, 0(s0)
	
	lw s4, LOOP_ITER
	ori s5, zero, 0x88

LOOP:
	addi s4, s4, -1
	sw s5, 0(s0)
	addi s5, s5, 0x11
	bne s4, zero, LOOP
	jal FUNCTION
	lw s4, 0(s0)
	and s4, s4, s5
	sw s4, 0(s0)

halt:	
    j halt

FUNCTION:
	ori t0, zero 0x123
	sw t0, 0(s0)
	ret

# ------- <code memory (Instruction Memory ROM) ends>	

#------- <Data Memory begins>		
.data

DMEM:

MMIO_BASE: .word 0x00007f00
LOOP_ITER: .word 3

#------- <Data Memory ends>	
