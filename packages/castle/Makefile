OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/

all: package

package: $(BINDIR)castle $(ETCDIR)castle.conf $(ETCDIR)launcher
	kpack castle-0.1.0.pkg $(OUTDIR)

$(BINDIR)castle: castle.asm graphics.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/;$(DEPENDENCIES)" castle.asm $(BINDIR)castle

$(ETCDIR)castle.conf: castle.config.asm
	mkdir -p $(ETCDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/castle/" castle.config.asm $(ETCDIR)castle.conf

$(ETCDIR)launcher:
	mkdir -p $(ETCDIR)
	echo -n "/bin/castle" > $(ETCDIR)launcher

clean:
	rm -rf $(OUTDIR)
	rm -rf castle-0.1.0.pkg

install: package
	kpack -e castle-0.1.0.pkg $(PREFIX)

.PHONY: all clean
