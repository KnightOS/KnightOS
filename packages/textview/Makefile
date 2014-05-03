OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

all: $(BINDIR)textview

$(BINDIR)textview: textview.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" textview.asm $(BINDIR)textview

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
