OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/

all: $(LIBDIR)core

$(LIBDIR)core: corelib.asm characters.asm errors.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/corelib/" corelib.asm $(LIBDIR)core

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
