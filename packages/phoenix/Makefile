OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=

all: $(BINDIR)phoenix

$(BINDIR)phoenix: phoenix.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/phoenix/;$(DEPENDENCIES)" phoenix.asm $(BINDIR)phoenix

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
