.section ".text.boot"

.globl _start
_start:
	la t0, _user_regs
	csrw 0x345, t0
	la sp, 0x103000
	call _cstart
_halt:
	j _halt

_exception_entry:
	addi sp, sp, -4
	sw s0, 0(sp)
	la s0, exc_regs
	csrw 0x345, s0
	call exception_entry
	la s0, _user_regs
	csrw 0x345, s0
	lw s0, 0(sp)
	addi sp, sp, 4
	mret

_timer_irq_entry:
	addi sp, sp, -4
	sw s0, 0(sp)
	la s0, exc_regs
	csrw 0x345, s0
	call timer_irq_entry
	la s0, _user_regs
	csrw 0x345, s0
	lw s0, 0(sp)
	addi sp, sp, 4
	mret

.section .vectors, "ax"
.option norvc
	# general exception handler
	.org 0x0
	j _exception_entry
	
	# timer interrupt handler
	.org 0x1c
	j _timer_irq_entry

	# reset handler
	.org 0x80
	j _start

.data
_user_regs: .space 128
