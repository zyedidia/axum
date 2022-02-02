DEPSDIR := .deps
BUILDSTAMP := $(DEPSDIR)/rebuildstamp
DEPFILES := $(wildcard $(DEPSDIR)/*.d)
ifneq ($(DEPFILES),)
include $(DEPFILES)
endif

# when the C compiler or optimization flags change, rebuild all objects
ifneq ($(strip $(DEP_FLAGS)),$(strip $(SYNTH) $(TOP) $(MEM)))
DEP_CC := $(shell mkdir -p $(DEPSDIR); echo >$(BUILDSTAMP); echo "DEP_FLAGS:=$(SYNTH) $(TOP) $(MEM)" >$(DEPSDIR)/_flags.d)
endif

$(BUILDSTAMP):
	@mkdir -p $(@D)
	@echo >$@
