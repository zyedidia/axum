CONS=boards/orangecrab.lpf

$(TOP).dfu: $(TOP).bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

$(TOP).json: $(SYNTH)
	yosys -p 'read_verilog -defer -noautowire -sv $(SYNTH); chparam -set SRAMInitFile "$(MEM)" $(TOP); chparam -set ECP5PLL 1 $(TOP); hierarchy -top $(TOP); synth_ecp5 -top $(TOP) -json $@'

$(TOP)_out.config: $(CONS) $(TOP).json
	nextpnr-ecp5 -q --lpf-allow-unconstrained --report $(REPORT) --25k --freq 48 --lpf $< --package CSFBGA285 --textcfg $@ --json $(TOP).json

$(TOP).bit: $(TOP)_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

prog: $(TOP).dfu
	sudo dfu-util -D $<
