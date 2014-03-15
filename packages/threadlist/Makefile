OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

all: $(BINDIR)threadlist

$(BINDIR)threadlist: threadlist.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/threadlist/" threadlist.asm $(BINDIR)threadlist

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
