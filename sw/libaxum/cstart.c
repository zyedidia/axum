#include <stdlib.h>
#include "uart.h"
#include "exception.h"

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

    exception_init();

    main();
}
