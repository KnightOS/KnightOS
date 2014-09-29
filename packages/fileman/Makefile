OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/;../configlib

all: package

package: $(BINDIR)fileman $(ETCDIR)fileman.conf
	kpack fileman-0.1.0.pkg $(OUTDIR)

$(BINDIR)fileman: fileman.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/fileman/;$(DEPENDENCIES)" fileman.asm $(BINDIR)fileman

$(ETCDIR)fileman.conf: fileman.conf
	mkdir -p $(ETCDIR)
	cp fileman.conf $(ETCDIR)fileman.conf

clean:
	rm -rf $(OUTDIR)
	rm -rf fileman-0.1.0.pkg

install: package
	kpack -e -s fileman-0.1.0.pkg $(PREFIX)

.PHONY: all clean
