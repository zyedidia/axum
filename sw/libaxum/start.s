.section ".text.boot"

.globl _start
_start:
	la sp, 0x103000
	call _cstart
_halt:
	j _halt

.section .vectors, "ax"
.option norvc
	# general exception handler
	.org 0x0
	j _exception_handler_entry
	
	# timer interrupt handler
	.org 0x1c
	j _timer_irq_handler_entry

	# reset handler
	.org 0x80
	j _start
