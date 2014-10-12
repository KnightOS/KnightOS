OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

all: init-1.0.0.pkg

init-1.0.0.pkg: $(BINDIR)init
	kpack init-1.0.0.pkg $(OUTDIR)

$(BINDIR)init: init.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/" init.asm $(BINDIR)init

clean:
	rm -rf $(OUTDIR)
	rm -rf init-*.pkg

install: init-1.0.0.pkg
	kpack -e -s init-1.0.0.pkg $(PREFIX)

.PHONY: all package clean
