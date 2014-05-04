OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/

all: $(BINDIR)castle $(ETCDIR)castle.conf $(ETCDIR)launcher

$(BINDIR)castle: castle.asm graphics.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/;$(DEPENDENCIES)" castle.asm $(BINDIR)castle

$(ETCDIR)castle.conf: castle.config.asm
	mkdir -p $(ETCDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.config.asm $(ETCDIR)castle.conf

$(ETCDIR)launcher:
	mkdir -p $(ETCDIR)
	echo -n "/bin/castle" > $(ETCDIR)launcher

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
