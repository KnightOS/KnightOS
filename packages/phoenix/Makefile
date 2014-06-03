OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/;

all: $(BINDIR)phoenix

$(BINDIR)phoenix: *.asm *.i
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/phoenix/;$(DEPENDENCIES)" phoenix.asm $(BINDIR)phoenix

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
