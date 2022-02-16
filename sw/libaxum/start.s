.section ".text.boot"

.globl _start
_start:
	# load scratch space address into mscratch
	la t0, _mscratch
	csrw mscratch, t0

	la sp, 0x104000
	call _cstart
_halt:
	j _halt

_timer_irq_handler_entry:
	csrrw x31, mscratch, x31
	sw x1, 0(x31)
	sw x5, 4(x31)
	sw x6, 8(x31)
	sw x7, 12(x31)
	sw x10, 16(x31)
	sw x11, 20(x31)
	sw x12, 24(x31)
	sw x13, 28(x31)
	sw x14, 32(x31)
	sw x15, 36(x31)
	sw x16, 40(x31)
	sw x17, 44(x31)
	sw x28, 48(x31)
	sw x29, 52(x31)
	sw x30, 56(x31)

	call ctimer_irq_handler

	lw x1, 0(x31)
	lw x5, 4(x31)
	lw x6, 8(x31)
	lw x7, 12(x31)
	lw x10, 16(x31)
	lw x11, 20(x31)
	lw x12, 24(x31)
	lw x13, 28(x31)
	lw x14, 32(x31)
	lw x15, 36(x31)
	lw x16, 40(x31)
	lw x17, 44(x31)
	lw x28, 48(x31)
	lw x29, 52(x31)
	lw x30, 56(x31)
	csrrw x31, mscratch, x31
	mret


.section .vectors, "ax"
.option norvc

	# general exception handler
	.org 0x0
	j _halt
	
	# timer interrupt handler
	.org 0x1c
	j _timer_irq_handler_entry

	# reset handler
	.org 0x80
	j _start

.data
_mscratch: .space 60
