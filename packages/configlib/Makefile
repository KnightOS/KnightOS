OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: package

package: $(LIBDIR)config $(INCDIR)config.inc
	kpack configlib-0.1.0.pkg $(OUTDIR)

$(LIBDIR)config: config.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/config/" config.asm $(LIBDIR)config

$(INCDIR)config.inc:
	mkdir -p $(INCDIR)
	cp config.inc $(INCDIR)config.inc

clean:
	rm -rf $(OUTDIR)
	rm -rf configlib-0.1.0.pkg

install: package
	kpack -e -s configlib-0.1.0.pkg $(PREFIX)

.PHONY: all clean
