OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

all: package

package: $(BINDIR)init $(ETCDIR)inittab 
	kpack init-0.1.0.pkg $(OUTDIR)

$(BINDIR)init: init.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" init.asm $(BINDIR)init

$(ETCDIR)inittab: inittab
	mkdir -p $(ETCDIR)
	cp inittab $(ETCDIR)inittab

clean:
	rm -rf $(OUTDIR)
	rm -rf init-0.1.0.pkg

install: package
	kpack -e -s init-0.1.0.pkg $(PREFIX)

.PHONY: all package clean
