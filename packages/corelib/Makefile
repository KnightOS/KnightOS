OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: $(LIBDIR)core $(INCDIR)corelib.inc

$(LIBDIR)core: corelib.asm characters.asm errors.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/corelib/" corelib.asm $(LIBDIR)core

$(INCDIR)corelib.inc:
	mkdir -p $(INCDIR)
	cp corelib.inc $(INCDIR)corelib.inc

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
