OUTDIR:=bin/
BINDIR:=$(OUTDIR)bin/

DEPENDENCIES=../corelib/

all: package

package: $(BINDIR)threadlist
	kpack threadlist-0.1.0.pkg $(OUTDIR)

$(BINDIR)threadlist: threadlist.asm
	mkdir -p $(BINDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/threadlist/;$(DEPENDENCIES)" threadlist.asm $(BINDIR)threadlist

clean:
	rm -rf $(OUTDIR)
	rm -rf threadlist-0.1.0.pkg

install:
	kpack -e -s threadlist-0.1.0.pkg $(PREFIX)

.PHONY: all clean
