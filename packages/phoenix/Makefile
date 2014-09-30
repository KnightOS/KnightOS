OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
APPDIR:=$(OUTDIR)var/applications/

DEPENDENCIES=../corelib/;

all: package
	
package: $(BINDIR)phoenix
	kpack phoenix-0.1.0.pkg $(OUTDIR)

$(BINDIR)phoenix: *.asm *.i
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/phoenix/;$(DEPENDENCIES)" phoenix.asm $(BINDIR)phoenix
	cp phoenix.app $(APPDIR)

clean:
	rm -rf $(OUTDIR)
	rm -rf phoenix-0.1.0.pkg

install: package
	kpack -e -s phoenix-0.1.0.pkg $(PREFIX)

.PHONY: all clean
