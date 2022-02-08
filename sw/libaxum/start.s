# mmio timer base address
.equ timer_base, 0x30000
# mmio timer register offsets
.equ mtime, 0
.equ mtimecmp, 8

.equ trap_sp, 0x104000

.section ".text.boot"

.globl _start
_start:
	# timer interrupt every 65536 cycles
	# at 32MHz this is every 2ms
	la t0, timer_base
	li t1, 0xffff
	sw t1, mtimecmp(t0) # load 0xffff into mtimecmp
	sw x0, mtime(t0) # clear mtime

	# enable interrupts
	li t0, (1 << 7) | (1 << 11)
	csrw mie, t0
	csrwi mstatus, (1 << 3)

	li t0, 0
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
