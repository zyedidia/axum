#include <stdlib.h>
#include "Vaxum_top.h"
#include "Vaxum_top___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

void reset(Vaxum_top* dut) {
    dut->rst_n = 0;
    dut->clk = 1;
    dut->eval();
    dut->clk = 0;
    dut->eval();
    dut->clk = 1;
    dut->eval();
    dut->clk = 0;
    dut->eval();
    dut->rst_n = 1;
}

int main(int argc, char **argv) {
    Verilated::traceEverOn(true);

    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

    // Create an instance of our module under test
    Vaxum_top* dut = new Vaxum_top;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("trace.vcd");

    reset(dut);

    // Tick the clock until we are done
    for (int i = 0; i < 100000; i++) {
        dut->clk = 0;
        dut->eval();
        tfp->dump(i*2);

        dut->clk = 1;
        dut->eval();
        tfp->dump(i*2+1);
        tfp->flush();
    }

    tfp->close();
    return 0;
}
