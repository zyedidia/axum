.section ".text.boot"

.org 0x80
.globl _start
_start:
	la sp, 0x102080
	call _cstart
halt:
	j halt

