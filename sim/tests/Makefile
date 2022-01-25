PREFIX=riscv64-unknown-elf

RV_ROOT ?= /opt/riscv

CC=$(PREFIX)-gcc
AS=$(PREFIX)-as
LD=$(PREFIX)-ld
OBJCOPY=$(PREFIX)-objcopy
OBJDUMP=$(PREFIX)-objdump

INCLUDE=-I$(LIBAXUM_ROOT)
ARCH=rv32imac

O ?= s

CFLAGS=-O$(O) $(INCLUDE) -g -Wall -Wno-unused-function -nostdlib -nostartfiles -ffreestanding -march=$(ARCH) -mabi=ilp32 -std=gnu99 -mcmodel=medany
ASFLAGS=-march=$(ARCH) -mabi=ilp32
LDFLAGS=-T $(LIBAXUM_ROOT)/memmap.ld -L$(RV_ROOT)/$(PREFIX)/lib/$(ARCH)/ilp32 -L$(RV_ROOT)/lib/gcc/$(PREFIX)/11.1.0/$(ARCH)/ilp32 -melf32lriscv
LDLIBS=-lgcc

LIBCSRC=$(wildcard $(LIBAXUM_ROOT)/*.c) $(wildcard $(LIBAXUM_ROOT)/libc/*.c)
LIBSSRC=$(wildcard $(LIBAXUM_ROOT)/*.s)
LIBOBJ=$(LIBCSRC:.c=.o) $(LIBSSRC:.s=.o)

SRC=$(wildcard *.c)
OBJ=$(SRC:.c=.o)

all: led.hex irq.hex uart.hex

MEMDIR=$(LIBAXUM_ROOT)/../../mem

install: $(MEMDIR)/led.vmem $(MEMDIR)/irq.vmem $(MEMDIR)/uart.vmem

$(MEMDIR)/%.vmem: %.bin
	bin2hex $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -c -o $@

%.elf: %.o $(LIBOBJ)
	$(LD) $(LDFLAGS) $(LIBOBJ) $< $(LDLIBS) -o $@

%.bin: %.elf
	$(OBJCOPY) $< -O binary $@

%.hex: %.elf
	$(OBJCOPY) $< -O ihex $@

%.list: %.elf
	$(OBJDUMP) -D $< > $@

clean:
	rm -f *.o *.elf *.hex *.bin *.list

.PHONY: all install clean
