.equ timer_base, 0x30000

.section ".text.boot"

.globl _start
_start:
	# load scratch space address into mscratch
	la t0, _mscratch
	csrw mscratch, t0

	# timer interrupt every 65536 cycles
	# at 32MHz this is every 2ms
	la t0, timer_base
	li t1, 0xffff
	sw t1, 8(t0)

	# enable interrupts
	li t0, (1 << 7) | (1 << 11)
	csrw mie, t0
	csrwi mstatus, (1 << 3)

	li t0, 0
	la sp, 0x104000
	call _cstart
_halt:
	j _halt

_timer_intr_handler:
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

	la t0, timer_base
	sw x0, 0(t0) # clear mtime
	lw x1, 8(t0)
	sw x1, 8(t0) # rewrite mtimecmp to clear irq

	la t0, _timer_irq_handler
	lw t1, 0(t0)
	jalr ra, t1

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
	j _timer_intr_handler

	# reset handler
	.org 0x80
	j _start

.data
_mscratch: .space 60
