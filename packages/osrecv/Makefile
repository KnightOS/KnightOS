OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

all: $(BINDIR)osrecv

$(BINDIR)osrecv: osrecv.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/osrecv/" osrecv.asm $(BINDIR)osrecv

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
