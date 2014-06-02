OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/

all: $(BINDIR)fileman $(ETCDIR)fileman.conf

$(BINDIR)fileman: fileman.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fileman/;$(DEPENDENCIES)" fileman.asm $(BINDIR)fileman

$(ETCDIR)fileman.conf: fileman.conf
	mkdir -p $(ETCDIR)
	cp fileman.conf $(ETCDIR)fileman.conf

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
