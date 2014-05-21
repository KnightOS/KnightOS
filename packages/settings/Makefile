OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/

all: $(BINDIR)settings

$(BINDIR)settings: settings.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/settings/;$(DEPENDENCIES)" settings.asm bin/bin/settings

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
