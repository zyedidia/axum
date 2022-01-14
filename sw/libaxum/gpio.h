#pragma once

typedef enum {
    GPIO_SOFTWARE,
} gpio_iof_t;

void gpio_set_output(unsigned pin);
void gpio_set_input(unsigned pin);
void gpio_write(unsigned pin, unsigned val);
void gpio_set_xor(unsigned pin, unsigned val);
unsigned gpio_read(unsigned pin);
void gpio_configure(unsigned pin, gpio_iof_t mode);

