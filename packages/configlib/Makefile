OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: $(LIBDIR)config $(INCDIR)config.inc

$(LIBDIR)config: config.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/config/" config.asm $(LIBDIR)config

$(INCDIR)config.inc:
	mkdir -p $(INCDIR)
	cp config.inc $(INCDIR)config.inc

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
