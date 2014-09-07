OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/

all: $(BINDIR)ktunnel

$(BINDIR)ktunnel: ktunnel.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/ktunnel/;$(DEPENDENCIES)" ktunnel.asm bin/bin/ktunnel

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
