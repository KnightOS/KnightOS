OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/

all: package

package: $(BINDIR)kpm-gui $(LIBDIR)kpm
	kpack kpm-0.1.0.pkg $(OUTDIR)

$(LIBDIR)kpm: $(INCDIR)kpm.inc kpm.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" kpm.asm $(LIBDIR)kpm

$(BINDIR)kpm-gui: $(INCDIR)kpm.inc main.asm kpm-gui/*.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" main.asm $(BINDIR)kpm-gui

$(INCDIR)kpm.inc:
	mkdir -p $(INCDIR)
	cp kpm.inc $(INCDIR)

clean:
	rm -rf $(OUTDIR)
	rm -rf kpm-0.1.0.pkg

install: package
	kpack -e -s kpm-0.1.0.pkg $(PREFIX)

.PHONY: all package clean
