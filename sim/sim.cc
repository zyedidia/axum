#include <iostream>
#include <fstream>

#include <backends/cxxrtl/cxxrtl_vcd.h>

#include "soc_top.cxx"

void reset(cxxrtl_design::p_soc__top& soc) {
    soc.p_rst__n.set<bool>(false);
    soc.p_clk.set<bool>(true);
    soc.step();
    soc.p_clk.set<bool>(false);
    soc.step();
    soc.p_rst__n.set<bool>(true);
}

void dump_regs(cxxrtl_design::p_soc__top& soc) {
    // for (int i = 0; i < 32; i++) {
    //     printf("x%d: %d\n", i, soc.memory_p_cpu__unit_2e_decode__unit_2e_reg__file__unit_2e_regs[i].get<unsigned>());
    // }
}

void dump_mem(cxxrtl_design::p_soc__top& soc, unsigned max_addr) {
    // for (int i = 0; i < max_addr; i += 4) {
    //     printf("[0x%x]: %d\n", i, soc.memory_p_ram__unit_2e_mem[i/4].get<unsigned>());
    // }
}

int main() {
    cxxrtl_design::p_soc__top soc;

    cxxrtl::debug_items all_debug_items;
    soc.debug_info(all_debug_items);

    cxxrtl::vcd_writer vcd;
    vcd.timescale(10, "ns");

    vcd.add(all_debug_items);

    std::ofstream waveform("waveform.vcd");

    reset(soc);

    const int ncycle = 1000;
    for (int i = 0; i < ncycle; i++) {
        soc.p_clk.set<bool>(false);
        soc.step();
        vcd.sample(i*2);

        waveform << vcd.buffer;
        vcd.buffer.clear();

        soc.p_clk.set<bool>(true);
        soc.step();
        vcd.sample(i*2+1);

        waveform << vcd.buffer;
        vcd.buffer.clear();
    }

    printf("Simulated %d clock cycles\n", ncycle);

    // printf("Dumping registers:\n");
    // dump_regs(soc);
    // const int max_addr = 101;
    // printf("Dumping memory up to address 0x%x:\n", max_addr-1);
    // dump_mem(soc, max_addr);
}

