.section ".text.boot"

.globl _start
_start:
	la sp, 0x104000
	call _cstart
_halt:
	j _halt

.section .vectors, "ax"
.option norvc

	# general exception handler
	.org 0x0
	j _halt
	
	# reset handler
	.org 0x80
	j _start
