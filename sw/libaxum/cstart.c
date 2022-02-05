#include <stdlib.h>
#include "rf.h"
#include "uart.h"

extern int main();

extern int __bss_start__, __bss_end__;

void _cstart() {
    int* bss = &__bss_start__;
    int* bss_end = &__bss_end__;

    while (bss < bss_end) {
        *bss++ = 0;
    }

    uart_set_baud(115200);
    init_printf(NULL, uart_putc);

    uint32_t trap_sp = 0x104000;
    rf_ctx(RF_CTX_EXC)->x1 = trap_sp;
    rf_ctx(RF_CTX_IRQ)->x1 = trap_sp;
    rf_ctx(RF_CTX_ECALL)->x1 = trap_sp;

    main();
}
