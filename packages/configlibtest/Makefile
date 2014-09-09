OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../configlib/

all: $(BINDIR)cfgtest $(ETCDIR)cfgtest.conf

$(BINDIR)cfgtest: main.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/cfgtest/;$(DEPENDENCIES)" main.asm bin/bin/cfgtest

$(ETCDIR)cfgtest.conf: cfgtest.conf
	mkdir -p $(ETCDIR)
	cp cfgtest.conf $(ETCDIR)cfgtest.conf

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
