OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

all: $(BINDIR)init $(ETCDIR)inittab

$(BINDIR)init: init.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" init.asm $(BINDIR)init

$(ETCDIR)inittab: inittab
	mkdir -p $(ETCDIR)
	cp inittab $(ETCDIR)inittab

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
