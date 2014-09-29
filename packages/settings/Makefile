OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/

all: package
	
package: $(BINDIR)settings
	kpack settings-0.1.0.pkg $(OUTDIR)

$(BINDIR)settings: settings.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/settings/;$(DEPENDENCIES)" settings.asm bin/bin/settings

clean:
	rm -rf $(OUTDIR)
	rm -rf settings-0.1.0.pkg

install: package
	kpack -e -s settings-0.1.0.pkg $(PREFIX)

.PHONY: all clean
