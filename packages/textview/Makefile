OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/

DEPENDENCIES=../corelib/

all: package

package: $(BINDIR)textview $(ETCDIR)editor
	kpack textview-0.1.0.pkg $(OUTDIR)

$(BINDIR)textview: textview.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/;$(DEPENDENCIES)" textview.asm $(BINDIR)textview

$(ETCDIR)editor:
	mkdir -p $(ETCDIR)
	echo -n "/bin/textview" > $(ETCDIR)editor

clean:
	rm -rf $(OUTDIR)
	rm -rf textview-0.1.0.pkg

install: package
	kpack -e textview-0.1.0.pkg $(PREFIX)

.PHONY: all clean
