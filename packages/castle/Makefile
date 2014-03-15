OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

all: $(BINDIR)castle $(ETCDIR)castle.conf

$(BINDIR)castle: castle.asm graphics.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.asm $(BINDIR)castle

$(ETCDIR)castle.conf: castle.config.asm
	mkdir -p $(ETCDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.config.asm $(ETCDIR)castle.conf

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
