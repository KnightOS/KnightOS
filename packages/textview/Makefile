OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/
ETCDIR:=$(OUTDIR)etc/
APPDIR:=$(OUTDIR)var/applications/

DEPENDENCIES=../corelib/

all: package

package: $(BINDIR)textview $(ETCDIR)editor
	kpack textview-0.1.0.pkg $(OUTDIR)

$(BINDIR)textview: textview.asm
	mkdir -p $(BINDIR)
	mkdir -p $(APPDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/base/;$(DEPENDENCIES)" textview.asm $(BINDIR)textview
	cp textview.app $(APPDIR)

$(ETCDIR)editor:
	mkdir -p $(ETCDIR)
	echo -n "/bin/textview" > $(ETCDIR)editor

clean:
	rm -rf $(OUTDIR)
	rm -rf textview-0.1.0.pkg

install: package
	kpack -e -s textview-0.1.0.pkg $(PREFIX)

.PHONY: all clean
