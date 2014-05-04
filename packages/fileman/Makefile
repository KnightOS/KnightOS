OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/

all: $(BINDIR)fileman

$(BINDIR)fileman: fileman.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fileman/;$(DEPENDENCIES)" fileman.asm $(BINDIR)fileman

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
