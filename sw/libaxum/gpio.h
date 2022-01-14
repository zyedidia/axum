#pragma once

typedef enum {
    GPIO_SOFTWARE,
} gpio_iof_t;

enum {
    GPIO_0  = 0,
    GPIO_1  = 1,
    GPIO_5  = 2,
    GPIO_6  = 3,
    GPIO_9  = 4,
    GPIO_10 = 5,
    GPIO_11 = 6,
    GPIO_12 = 7,
    GPIO_13 = 8,
    GPIO_A0 = 9,
    GPIO_A1 = 10,
    GPIO_A2 = 11,
    GPIO_A3 = 12,
    GPIO_BTN = 31,
    GPIO_LED_R = 14,
    GPIO_LED_G = 15,
    GPIO_LED_B = 16,
};

void gpio_set_output(unsigned pin);
void gpio_set_input(unsigned pin);
void gpio_write(unsigned pin, unsigned val);
void gpio_set_xor(unsigned pin, unsigned val);
unsigned gpio_read(unsigned pin);
void gpio_configure(unsigned pin, gpio_iof_t mode);

