---
geometry: "left=3cm,right=3cm,top=2cm,bottom=2cm"
---

# General design

Three new CSRs:

* MRF (machine register file): holds the address of the current register file.
  The first write to MRF causes it to fill the register file from the given
  address (the register file contents before the first write are not saved
  anywhere).

* MTRF (machine trap register file): holds the value that MRF will be assigned
  when a trap occurs.

* MPRF (machine previous register file): holds the value that MRF will be
  assigned when an `mret` occurs. Also holds the previous MRF during a trap.

The hardware automatically performs the following:

* When a trap occurs:

```
MPRF <- MRF
MRF  <- MTRF
```

* When `mret` is executed:

```
MRF <- MPRF
```

# Examples

The following examples show pseudocode for how this trap handling system may be
used by software.

## Initialization:

```
regs_t trap_regs; // allocated statically

trap_init() {
    trap_regs.sp = trap_sp;
    write_csr(MTRF, &trap_regs);
    write_csr(MRF, &init_thread.regs);
    init_thread.main();
}
```

## Basic trap handler

```
trap_entry() {
    handle_trap();

    if (do_ctx_switch) {
        write_csr(MPRF, &new_thread.regs);
        write_csr(MEPC, new_thread.pc);
    }

    mret;
}
```

## Nested traps

Example pseudocode for trap handler with support for one level of nesting:

```
regs_t nested_trap_regs; // allocated statically

trap_init() {
    nested_trap_regs.sp = nested_trap_sp;
    ...
}

trap_entry() {
    uintptr_t stored_mepc = read_csr(MEPC);
    uintptr_t stored_mprf = read_csr(MPRF);
    uintptr_t stored_mtrf = read_csr(MTRF);
    write_csr(MTRF, &nested_trap_regs);

    handle_trap();

    if (do_ctx_switch) {
        write_csr(MPRF, &new_thread.regs);
        write_csr(MEPC, new_thread.pc);
    } else {
        write_csr(MPRF, stored_mprf);
        write_csr(MEPC, stored_mepc);
    }

    write_csr(MTRF, stored_mtrf);

    mret;
}
```

Note: It is almost possible to allow unlimited nesting by allocating new
register file contexts on the stack rather than statically:

```
regs_t nested_trap_regs; // allocated on the stack
write_csr(MTRF, &nested_trap_regs);
```

but there is a problem because `nested_trap_regs` must be given a valid stack
pointer, and with unlimited nesting this can't be a pre-determined constant.
Need to think more about this (idea: some way to indicate that the stack
pointer shouldn't be replaced?).

# Possible hardware optimizations

## Number of register files

* 1 register file: spill and fill every time MRF is written.
* 4 register files, with dedicated register files for user, interrupt, syscall,
  and fault contexts (may require some tweaks to the current architecture of
  MRF/MTRF/MPRF).
* k register files, with a caching policy.

## Lazy register file access

* Fully lazy: each individual register is spilled/filled only when it is
  accessed for the first time.
    * Requires tracking information on every register.
* Partially lazy: registers are spilled/filled in groups lazily. The first
  time any register in a group is accessed, all registers in the group are
  spilled/filled.
    * One possible group split: caller-saved (group 1) and callee-saved (group 2).

## Memory system optimizations

These optimizations to the memory system would enable faster register file
switching.

* Wider data lines: more registers can be saved and loaded at once. For
  example, with a 992-bit data line, the entire register file can be stored in
  one memory operation (31 registers because the zero register doesn't count).
* More memory ports: if the additional ports are of the same type (read/write)
  then this is equivalent to wider data lines. If they are of different types,
  there may be opportunity for pipelining spills and fills together (depending
  on how many cycles a spill/fill takes).
