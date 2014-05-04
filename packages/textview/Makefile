OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/

all: $(BINDIR)textview $(ETCDIR)editor

$(BINDIR)textview: textview.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/;$(DEPENDENCIES)" textview.asm $(BINDIR)textview

$(ETCDIR)editor:
	mkdir -p $(ETCDIR)
	echo -n "/etc/textview" > $(ETCDIR)editor

clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
