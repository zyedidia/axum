CONS=boards/icesugar.pcf

$(TOP).bin: $(TOP).asc
	icepack $< $@

$(TOP).json: $(SYNTH)
	yosys -p 'read_verilog -defer -noautowire -sv $(SYNTH); chparam -set SRAMInitFile "$(MEM)" $(TOP); hierarchy -top $(TOP); synth_ice40 -top $(TOP) -json $@'

$(TOP).asc: $(CONS) $(TOP).json
	nextpnr-ice40 --pcf-allow-unconstrained -q --report $(REPORT) --up5k --pcf $< --package sg48 --asc $@ --json $(TOP).json

prog: $(TOP).bin
	sudo iceprog $<
